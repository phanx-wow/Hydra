--[[--------------------------------------------------------------------
	Hydra
	Multibox leveling helper.
	Copyright (c) 2010-2013 Phanx <addons@phanx.net>. All rights reserved.
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

local SOLO, GROUP, TRUSTED, LEADER = 0, 1, 2, 3
local realmName, playerName = GetRealmName(), UnitName("player")

local groupForwardTime, groupForwardFrom, hasActiveConversation = 0
local whisperForwardTime, whisperForwardTo, whisperForwardMessage = 0
local frameTime, hasFocus = 0

local module = core:RegisterModule("Chat", CreateFrame("Frame"))
module:SetScript("OnEvent", function(f, e, ...) return f[e] and f[e](f, ...) end)
module:SetScript("OnUpdate", function() frameTime = GetTime() end)
module:Hide()

module.defaults = {
	enable = true,
	mode = "LEADER", -- APPFOCUS | LEADER
	timeout = 300,
}

------------------------------------------------------------------------

function module:CheckState()
	return self.db.enable and core.state >= TRUSTED
end

function module:Enable()
	-- #TEMP: fix old lowercase entry
	self.db.mode = strupper(self.db.mode)

	self:RegisterEvent("CHAT_MSG_GROUP")
	self:RegisterEvent("CHAT_MSG_GROUP_LEADER")
	self:RegisterEvent("CHAT_MSG_RAID")
	self:RegisterEvent("CHAT_MSG_RAID_LEADER")
	self:RegisterEvent("CHAT_MSG_SYSTEM")
	self:RegisterEvent("CHAT_MSG_WHISPER")
	self:RegisterEvent("CHAT_MSG_BN_WHISPER")

	self:SetShown(self.db.mode == "APPFOCUS")
end

function module:Disable()
	self:UnregisterAllEvents()
	self:Hide()
end

------------------------------------------------------------------------

local playerToken = "@" .. playerName

function module:CHAT_MSG_GROUP(message, sender)
	if sender == playerName or strmatch(message, "^!") then return end -- command or error response

	self:Debug("CHAT_MSG_GROUP", sender, message)

	if strmatch(message, "^>> .-: .+$") then
		if not strmatch(message, "POSSIBLE SPAM") then
			-- someone else forwarded a whisper, our conversation is no longer the active one
			self:Debug("Someone else forwarded a whisper.")
			hasActiveConversation = nil
		end

	elseif hasActiveConversation and not message:match("^@") then
		-- someone responding to our last forwarded whisper
		self:Debug("hasActiveConversation")
		if GetTime() - groupForwardTime > self.db.timeout then
			-- it's been a while
			hasActiveConversation = nil
			self:SendChatMessage("!ERROR: " .. L.GroupTimeoutError)
		else
			-- forwarding response to whisper sender
			self:SendChatMessage(message, groupForwardFrom)
			groupForwardTime = GetTime()
		end

	elseif groupForwardFrom then
		-- we forwarded something earlier
		local text = strmatch(message, playerToken .. " (.+)$")
		if text then
			-- someone responding to our last forward
			self:Debug("Detected response to old forward.")
			self:SendChatMessage(text, groupForwardFrom)
		end
	end
end

module.CHAT_MSG_GROUP_LEADER = module.CHAT_MSG_GROUP
module.CHAT_MSG_RAID = module.CHAT_MSG_GROUP
module.CHAT_MSG_RAID_LEADER = module.CHAT_MSG_GROUP

------------------------------------------------------------------------

local ignorewords = {
	"account",
	"battle", "bonus", "buy", "blizz",
	"cheap", "complain", "contest", "coupon", "customer",
	"dear", "deliver", "detect", "discount",
	"extra",
	"fast track", "free",
	"gift", "gold",
	"honorablemention",
	"illegal", "in",
	"lowest", "lucky",
	"mrpopularity",
	"order",
	"powerle?ve?l", "price", "promoti[on][gn]",
	"recruiting", "reduced",
	"safe", "secure", "server", "service", "scan", "stock", "suspecte?d?", "suspend",
	"validat[ei]", "verif[iy]", "violat[ei]", "visit",
	"welcome", "www",
	"%d+%.?%d*eur", "%d+%.?%d*dollars",
	"[\226\130\172$\194\163]%d+",
	(UnitName("player")), -- spammers seem to think addressing you by your character's name adds a personal touch...
}

local lastForwardedTo, lastForwardedMessage

function module:CHAT_MSG_WHISPER(message, sender, _, _, _, flag, _, _, _, _, _, guid)
	self:Debug("CHAT_MSG_WHISPER", flag, sender, message)

	if UnitInRaid(sender) or UnitInParty(sender) then
		self:Debug("Sender in group.")

		-- a group member whispered me "@Someone Hello!"
		local target, text = strmatch(message, "^@(.-) (.+)$")

		if target and text then
			-- sender wants us to whisper target with text
			self:Debug("Forwarding message to", target, ":", text)
			whisperForwardTo, whisperForwardTime = target, GetTime()
			self:SendChatMessage(text, target)

		elseif whisperForwardTo then
			-- we've forwarded to whisper recently
			self:Debug("Previously forwarded a whisper...")
			if GetTime() - whisperForwardTime > self.db.timeout then
				-- it's been a while since our last forward to whisper
				self:Debug("...but the timeout has been reached.")
				whisperForwardTo = nil
				self:SendChatMessage("!ERROR: " .. L.WhisperTimeoutError, sender)

			elseif message ~= whisperForwardMessage then
				-- whisper last forward target
				self:Debug("...forwarding this whisper to the same target.")
				whisperForwardTime = GetTime()
				self:SendChatMessage(message, whisperForwardTo)

			else
				-- message was echoed, avoid a loop
				self:Debug("Loop averted!")
			end
		end
	else
		local active
		if self.db.mode == "APPFOCUS" then
			active = GetTime() - frameTime < 0.1
		else
			active = UnitIsGroupLeader("player")
		end
		self:Debug("active", active)
		if not active then -- someone outside the group whispered me
			if flag == "GM" then
				self:SendAddonMessage(format("GM |cff00ccff%s|r %s", sender, message))
				self:SendChatMessage(format(">> GM %s: %s", sender, message))

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
					hasActiveConversation, groupForwardFrom, groupForwardTime = true, sender, GetTime()
				end

				local color
				if guid and guid ~= "" then
					local _, class = GetPlayerInfoByGUID(guid)
					if class then
						color = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[class]
					end
				end
				self:SendAddonMessage(format("W %s %s", (color and format("\124cff%02x%02x%02x%s\124r", color.r * 255, color.g * 255, color.b * 255, sender) or sender), message))
				self:SendChatMessage(format(">> %s: %s", sender, message))
			end
		end
	end
end

------------------------------------------------------------------------

function module:CHAT_MSG_BN_WHISPER(message, sender, _, _, _, _, _, _, _, _, _, _, pID)
	self:Debug("CHAT_MSG_BN_WHISPER", sender, pID, message)
	local _, _, battleTag = BNGetFriendInfoByID(pID)
	self:SendAddonMessage(strjoin("§", "BW", battleTag, message))
end

function module:CHAT_MSG_BN_CONVERSATION(message, sender, _, channel, _, _, _, channelNumber, _, _, _, _, pID)
	self:Debug("CHAT_MSG_BN_CONVERSATION", sender, message)
	self:SendAddonMessage(strjoin("§", "BC", battleTag, message, channel, channelNumber))
end

------------------------------------------------------------------------

function module:CHAT_MSG_SYSTEM(message)
	if message == ERR_FRIEND_NOT_FOUND then
		-- the whisper couldn't be forwarded
	end
end

------------------------------------------------------------------------

function module:ReceiveAddonMessage(message, channel, sender)
	if not core:IsTrusted(sender) or not UnitInParty(sender) or not UnitInRaid(sender) then return end

	local fwdEvent, fwdSender, fwdMessage = strmatch(message, "^([^%s§]+)[%§]([^%s§]+)[%§]?(.*)$")
	self:Debug("HydraChat", sender, fwdEvent, fwdSender, fwdMessage)

	if fwdEvent == "GM" then
		local message = "\124TInterface\\ChatFrame\\UI-ChatIcon-Blizz.blp:0:2:0:-3\124t" .. format(L.WhisperFromGM, sender)
		self:Debug(message)
		self:Alert(message, true)
		self:Print(message)

	elseif fwdEvent == "W" then
		self:Debug(L.WhisperFrom, sender, fwdSender)

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
				self:Print(L.WhisperFromBnet, sender, fwdSender, fwdMessage)
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
				self:Print(L.WhisperFromConvo, sender, fwdSender, fwdMessage)
			end
		end
	end
end

------------------------------------------------------------------------

module.displayName = L.Chat
function module:SetupOptions(panel)
	local title, notes = LibStub("PhanxConfig-Header").CreateHeader(panel, L.Chat, L.Chat_Info)

	local enable = LibStub("PhanxConfig-Checkbox").CreateCheckbox(panel, L.Enable, L.Enable_info)
	enable:SetPoint("TOPLEFT", notes, "BOTTOMLEFT", 0, -12)
	enable.OnClick = function(_, checked)
		self.db.enable = checked
		self:Refresh()
	end

	local modes = {
		APPFOCUS = L.ApplicationFocus,
		LEADER = L.GroupLeader,
	}

	local mode = LibStub("PhanxConfig-Dropdown").CreateDropdown(panel, L.DetectionMethod, L.DetectionMethod_Info)
	mode:SetPoint("TOPLEFT", enable, "BOTTOMLEFT", 0, -16)
	mode:SetPoint("TOPRIGHT", notes, "BOTTOM", -8, -12 - enable:GetHeight() - 16)
	do
		local info = {
			checked = function(this)
				return self.db.mode == this.value
			end,
			func = function(this)
				self.db.mode = this.value
				self:Refresh()
			end,
		}
		UIDropDownMenu_Initialize(mode.dropdown, function()
			info.text = L.AppFocus
			info.value = "APPFOCUS"
			UIDropDownMenu_AddButton(info)

			info.text = L.GroupLeader
			info.value = "LEADER"
			UIDropDownMenu_AddButton(info)
		end)
	end

	local timeout = LibStub("PhanxConfig-Slider").CreateSlider(panel, L.Timeout, L.GroupTimeout_Info, 30, 600, 30)
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
	help:SetText(L.ChatHelpText)

	panel.refresh = function()
		enable:SetChecked(self.db.enable)
		mode:SetValue(modes[ self.db.mode ])
		timeout:SetValue(self.db.timeout)
	end
end