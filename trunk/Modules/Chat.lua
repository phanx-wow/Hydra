--[[--------------------------------------------------------------------
	Hydra
	Multibox leveling helper.
	Copyright (c) 2010-2012 Phanx <addons@phanx.net>. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info17572-Hydra.html
	http://www.curse.com/addons/wow/hydra
------------------------------------------------------------------------
	Hydra Chat
	* Forwards whispers to characters without app focus to party chat
	* Relays responses to forwarded whispers in party chat back to the
	  original sender as a whisper from the forwarding character
	* Respond to a whisper forwarded by a character other than the last
	  forwarder by typing "@name message" in party chat, where "name" is
	  the character that forwarded the whipser
	* Respond to a whisper forwarded by a character that has since
	  forwarded another whisper, or send an arbitrary whipser from a
	  character, by whispering the character with "@name message", where
	  "name" is the target of the message
----------------------------------------------------------------------]]

local _, core = ...

local L = core.L

local SOLO, PARTY, TRUSTED, LEADER = 0, 1, 2, 3
local realmName, playerName = GetRealmName(), UnitName("player")

local partyForwardTime, partyForwardFrom, hasActiveConversation = 0
local whisperForwardTime, whisperForwardTo = 0
local frametime, hasfocus = 0

local module = core:RegisterModule("Chat", CreateFrame("Frame"))
module:SetScript("OnEvent", function(f, e, ...) return f[e] and f[e](f, ...) end)
module:SetScript("OnUpdate", function() frametime = GetTime() end)
module:Hide()

module.defaults = {
	enable = true,
	mode = "leader", -- appfocus | leader
	timeout = 300,
}

------------------------------------------------------------------------

function module:CheckState()
	if core.state < TRUSTED or not self.db.enable then
		self:Debug("Disable module: Chat")
		self:UnregisterAllEvents()
		self:Hide()

	else
		self:Debug("Enable module: Chat")
		if self.db.mode == "appfocus" then
			self:Show()
		end

		self:RegisterEvent("CHAT_MSG_ADDON")
		self:RegisterEvent("CHAT_MSG_PARTY")
		self:RegisterEvent("CHAT_MSG_PARTY_LEADER")
		self:RegisterEvent("CHAT_MSG_RAID")
		self:RegisterEvent("CHAT_MSG_RAID_LEADER")
		self:RegisterEvent("CHAT_MSG_SYSTEM")
		self:RegisterEvent("CHAT_MSG_WHISPER")
		self:RegisterEvent("CHAT_MSG_BN_WHISPER")

		if not IsAddonMessagePrefixRegistered("HydraChat") then
			RegisterAddonMessagePrefix("HydraChat")
		end
	end
end

------------------------------------------------------------------------

local playerToken = "@" .. playerName

function module:CHAT_MSG_PARTY(message, sender)
	if sender == playerName or strmatch(message, "^!") then return end -- command or error response

	self:Debug("CHAT_MSG_PARTY", sender, message)

	if strmatch(message, "^>> .-: .+$") then
		if not strmatch(message, "POSSIBLE SPAM") then
			-- someone else forwarded a whisper, our conversation is no longer the active one
			self:Debug("Someone else forwarded a whisper.")
			hasActiveConversation = nil
		end

	elseif hasActiveConversation and not message:match("^@") then
		-- someone responding to our last forwarded whisper
		self:Debug("hasActiveConversation")
		if GetTime() - partyForwardTime > self.db.timeout then
			-- it's been a while
			hasActiveConversation = nil
			self:SendChatMessage(L["!ERROR: Party forwarding timeout reached."], "RAID")
		else
			-- forwarding response to whisper sender
			self:SendChatMessage(message, "WHISPER", nil, partyForwardFrom)
			partyForwardTime = GetTime()
		end

	elseif partyForwardFrom then
		-- we forwarded something earlier
		local text = strmatch(message, playerToken .. " (.+)$")
		if text then
			-- someone responding to our last forward
			self:Debug("Detected response to old forward.")
			self:SendChatMessage(text, "WHISPER", nil, partyForwardFrom)
		end
	end
end

module.CHAT_MSG_PARTY_LEADER = module.CHAT_MSG_PARTY
module.CHAT_MSG_RAID = module.CHAT_MSG_PARTY
module.CHAT_MSG_RAID_LEADER = module.CHAT_MSG_PARTY

------------------------------------------------------------------------

local ignorewords = {
	"account",
	"battle", "bonus", "buy", "blizz",
	"cheap", "complain", "contest", "coupon", "customer",
	"dear", "deliver", "detect", "discount",
	"extra",
	"free",
	"gift", "gold",
	"illegal", "in",
	"lowest", "lucky",
	"order",
	"powerle?ve?l", "price", "promoti[on][gn]",
	"reduced",
	"safe", "secure", "server", "service", "scan", "stock", "suspecte?d?", "suspend",
	"validat[ei]", "verif[iy]", "violat[ei]", "visit",
	"welcome", "www",
	"%d+%.?%d*eur", "%d+%.?%d*dollars",
	"[\226\130\172$\194\163]%d+",
	(UnitName("player")), -- spammers seem to think addressing you by your character's name adds a personal touch...
}

function module:CHAT_MSG_WHISPER(message, sender, _, _, _, flag, _, _, _, _, _, guid)
	self:Debug("CHAT_MSG_WHISPER", guid, flag, sender, message)

	if UnitInRaid(sender) or UnitInParty(sender) then
		self:Debug("unit in party/raid")

		-- a party member whispered me "@Someone Hello!"
		local target, text = strmatch(message, "^@(.-) (.+)$")

		if target and text then
			-- sender wants us to whisper target with text
			whisperForwardTo, whisperForwardTime = target, GetTime()
			self:SendChatMessage(text, "WHISPER", nil, target)

		elseif whisperForwardTo then
			-- we've forwarded to whisper recently
			if GetTime() - whisperForwardTime > self.db.timeout then
				-- it's been a while since our last forward to whisper
				whisperForwardTo = nil
				self:SendChatMessage(L["!ERROR: Whisper timeout reached."], "WHISPER", nil, sender)

			else
				-- whisper last forward target
				whisperForwardTime = GetTime()
				self:SendChatMessage(message, "WHISPER", nil, whisperForwardTo)
			end
		end
	else
		local isLeader
		if IsPartyLeader then
			isLeader = IsPartyLeader()
		else
			isLeader = UnitIsGroupLeader("player")
		end
		local active = self.db.mode == "appfocus" and GetTime() - frametime < 0.25 or isLeader
		self:Debug(active and "Active" or "Not active")
		if not active then -- someone outside the party whispered me
			if flag == "GM" then
				self:SendAddonMessage("HydraChat", format("GM |cff00ccff%s|r %s", sender, message), "RAID")
				self:SendChatMessage(format(">> GM %s: %s", sender, message), "RAID")

			else
				local spamwords = 0
				local searchstring = gsub(strlower(message), "%W", "")
				for _, word in ipairs(ignorewords) do
					if strfind(searchstring, word) then
						spamwords = spamwords + 1
					end
				end
				if spamwords > 3 then
					message = "POSSIBLE SPAM"
					hasActiveConversation, partyForwardFrom, partyForwardTime = true, sender, GetTime()
				end

				local color
				if guid and guid ~= "" then
					local _, class = GetPlayerInfoByGUID(guid)
					if class then
						color = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[class]
					end
				end
				self:SendAddonMessage("HydraChat", format("W %s %s", (color and format("\124cff%02x%02x%02x%s\124r", color.r * 255, color.g * 255, color.b * 255, sender) or sender), message), "RAID")
				self:SendChatMessage(format(">> %s: %s", sender, message), "RAID")
			end
		end
	end
end

------------------------------------------------------------------------

function module:CHAT_MSG_BN_WHISPER(message, sender, _, _, _, _, _, _, _, _, _, _, pID)
	self:Debug("CHAT_MSG_BN_WHISPER", sender, pID, message)
	local _, _, battleTag = BNGetFriendInfoByID(pID)
	self:SendAddonMessage("HydraChat", strjoin("§", "BW", battleTag, message))
end

function module:CHAT_MSG_BN_CONVERSATION(message, sender, _, channel, _, _, _, channelNumber, _, _, _, _, pID)
	self:Debug("CHAT_MSG_BN_CONVERSATION", sender, message)
	self:SendAddonMessage("HydraChat", strjoin("§", "BC", battleTag, message, channel, channelNumber))
end

------------------------------------------------------------------------

function module:CHAT_MSG_SYSTEM(message)
	if message == ERR_FRIEND_NOT_FOUND then
		-- the whisper couldn't be forwarded
	end
end

------------------------------------------------------------------------

function module:CHAT_MSG_ADDON(prefix, message, channel, sender)
	if prefix ~= "HydraChat" or (channel ~= "PARTY" and channel ~= "RAID") or sender == playerName or not core:IsTrusted(sender) then return end

	local fwdEvent, fwdSender, fwdMessage = strmatch(message, "^([^%s§]+)[%§]([^%s§]+)[%§]?(.*)$")
	self:Debug("HydraChat", sender, fwdEvent, fwdSender, fwdMessage)

	if fwdEvent == "GM" then
		local message = format(L["\124TInterface\\ChatFrame\\UI-ChatIcon-Blizz.blp:0:2:0:-3\124t %s has received a whisper from a GM!"], sender)
		self:Debug(message)
		self:Alert(message, true)
		self:Print(message)

	elseif fwdEvent == "W" then
		self:Debug(L["%1$s received a whisper from %2$s."], sender, fwdSender)

	elseif fwdEvent == "BW" then
		local found
		for i = 1, BNGetNumFriends() do
			local id, name, tag, useTag, _, _, _, _, _, _, _, _, _, useName = BNGetFriendInfo(i)
			if tag == fwdSender then
				found = true
				for i = 1, 10 do
					local frame = _G["ChatFrame"..i]
					if frame and frame.tab:IsShown() then
						ChatFrame_MessageEventHandler(frame, "CHAT_MSG_BN_WHISPER", fwdMessage, useName and name or tag, "", "", "", "", 0, 0, "", 0, 0, "", id)
					end
				end
			end
			if not found then
				self:Print(L["%1$s received a Battle.net whisper from %2$s:\n%3$s"], sender, fwdSender, fwdMessage)
			end
		end

	elseif fwdEvent == "BC" then
		local fwdChannelNumber, fwdChannel, fwdMessage = strsplit("§", fwdMessage)
		local found
		for i = 1, BNGetNumFriends() do
			local id, name, tag, useTag, _, _, _, _, _, _, _, _, _, useName = BNGetFriendInfo(i)
			if tag == fwdSender then
				found = true
				for i = 1, 10 do
					local frame = _G["ChatFrame"..i]
					if frame and frame.tab:IsShown() then
						ChatFrame_MessageEventHandler(frame, "CHAT_MSG_BN_CONVERSATION", fwdMessage, useName and name or tag, "", fwdChannel or "", "", "", 0, tostring(fwdChannelNumber) or 0, "", 0, 0, "", id)
					end
				end
			end
			if not found then
				self:Print(L["%1$s received a Battle.net message from %2$s in %3$s:\n%4$s"], sender, fwdSender, fwdChannel, fwdMessage)
			end
		end
	end
end

------------------------------------------------------------------------

function module:SetupOptions(panel)
	local title, notes = LibStub("PhanxConfig-Header").CreateHeader(panel, panel.name,
		L["Forwards whispers sent to inactive characters to party chat, and forwards replies to the original sender."])

	local enable = LibStub("PhanxConfig-Checkbox").CreateCheckbox(panel, L["Enable"])
	enable:SetPoint("TOPLEFT", notes, "BOTTOMLEFT", 0, -12)
	enable.OnClick = function(_, checked)
		self.db.enable = checked
		self:CheckState()
	end

	local modes = {
		appfocus = L["Application Focus"],
		leader = L["Party Leader"],
	}

	local mode = LibStub("PhanxConfig-Dropdown").CreateDropdown(panel, L["Detection method"], nil,
		L["Select the method to use for detecting the primary character."] .. "\n\n" .. L["If you are multiboxing on multiple physical machines, or are running multiple copies of WoW in windowed mode, the \"Application Focus\" mode will probably not work for you, and you should make sure that your primary character is the party leader."])
	mode:SetPoint("TOPLEFT", enable, "BOTTOMLEFT", 0, -16)
	mode:SetPoint("TOPRIGHT", notes, "BOTTOM", -8, -12 - enable:GetHeight() - 16)
	do
		local info = { }
		local IsChecked = function(this)
			return self.db.mode == this.value
		end
		local OnClick = function(this)
			self.db.mode = this.value
			self:CheckState()
		end
		UIDropDownMenu_Initialize(mode.dropdown, function()
			info.text = L["Application Focus"]
			info.value = "appfocus"
			info.checked = IsChecked
			info.func = OnClick
			UIDropDownMenu_AddButton(info)

			info.text = L["Party Leader"]
			info.value = "leader"
			info.checked = IsChecked
			info.func = OnClick
			UIDropDownMenu_AddButton(info)
		end)
	end

	local timeout = LibStub("PhanxConfig-Slider").CreateSlider(panel, L["Timeout"], 30, 600, 30, nil,
		L["If this many seconds have elapsed since the last forwarded message, don't forward messages typed in party chat to the last whisperer unless the target is explicitly specified."])
	timeout:SetPoint("TOPLEFT", mode, "BOTTOMLEFT", 0, -16)
	timeout:SetPoint("TOPRIGHT", mode, "BOTTOMRIGHT", 0, -16)
	timeout.OnValueChanged = function(_, value)
		value = floor((value + 1) / 30) * 30
		self.db.timeout = value
		return value
	end

	local help = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	help:SetPoint("BOTTOMLEFT", 16, 16)
	help:SetPoint("BOTTOMRIGHT", -16, 16)
	help:SetHeight(112)
	help:SetJustifyH("LEFT")
	help:SetJustifyV("BOTTOM")
	help:SetText(L.HELP_CHAT)

	panel.refresh = function()
		enable:SetChecked(self.db.enable)
		mode:SetValue(modes[ self.db.mode ])
		timeout:SetValue(self.db.timeout)
	end
end