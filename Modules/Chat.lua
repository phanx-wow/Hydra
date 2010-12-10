--[[--------------------------------------------------------------------
	Hydra
	Multibox leveling helper.
	by Phanx < addons@phanx.net >
	Copyright © 2010 Phanx. Some rights reserved. See LICENSE.txt for details.
	http://www.wowinterface.com/downloads/info17572-Hydra.html
	http://wow.curseforge.com/projects/hydra/
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
if not core then core = _G.Hydra end

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
		if self.db.mode == "appfocus" then self:Show() end
		self:RegisterEvent("CHAT_MSG_ADDON")
		self:RegisterEvent("CHAT_MSG_PARTY")
		self:RegisterEvent("CHAT_MSG_PARTY_LEADER")
		self:RegisterEvent("CHAT_MSG_SYSTEM")
		self:RegisterEvent("CHAT_MSG_WHISPER")
		self:RegisterEvent("CHAT_MSG_BN_WHISPER")
	end
end

------------------------------------------------------------------------

local playerToken = "@" .. playerName

function module:CHAT_MSG_PARTY(message, sender)
	if sender == playerName then return end
	if message:match("^!") then return end -- command or error response

	self:Debug("CHAT_MSG_PARTY", sender, message)

	if message:match("^>> .-: .+$") then
		if not message:match("POSSIBLE SPAM") then
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
			SendChatMessage("!ERROR: Party timeout reached.", "PARTY")
		else
			-- forwarding response to whisper sender
			SendChatMessage(message, "WHISPER", nil, partyForwardFrom)
			partyForwardTime = GetTime()
		end
	elseif partyForwardFrom then
		-- we forwarded something earlier
		local text = message:match(playerToken .. " (.+)$")
		if text then
			-- someone responding to our last forward
			self:Debug("Detected response to old forward.")
			SendChatMessage(text, "WHISPER", nil, partyForwardFrom)
		end
	end
end

module.CHAT_MSG_PARTY_LEADER = module.CHAT_MSG_PARTY

------------------------------------------------------------------------

function module:CHAT_MSG_BN_WHISPER(message, sender)
	self:Debug("CHAT_MSG_WHISPER", sender, message)

	SendAddonMessage("HydraChat", format("BN %s %s", sender, message))
end

------------------------------------------------------------------------

local ignorewords = {
	"account",
	"battle",
	"bonus",
	"buy",
	"blizz",
	"cheap",
	"complain",
	"contest",
	"coupon",
	"customer",
	"dear",
	"deliver",
	"detect",
	"discount",
	"extra",
	"free",
	"gift",
	"gold",
	"illegal",
	"interest",
	"login",
	"lowest",
	"lucky",
	"order",
	"powerle?ve?l",
	"price",
	"promoti[on][gn]",
	"reduced",
	"safe",
	"secure",
	"server",
	"service",
	"scan",
	"stock",
	"suspecte?d?",
	"suspend",
	"validat[ei]",
	"verif[iy]",
	"violat[ei]",
	"visit",
	"welcome",
	"www",
	"%d+%.?%d*eur",
	"%d+%.?%d*dollars",
	"[\226\130\172$\194\163]%d+",
	(UnitName("player")), -- spammers seem to think addressing you by your character's name adds a personal touch...
}

function module:CHAT_MSG_WHISPER(message, sender, _, _, _, flag, _, _, _, _, _, _, guid)
	self:Debug("CHAT_MSG_WHISPER", guid, flag, sender, message)

	if UnitInParty(sender) then
		self:Debug("UnitInParty")

		-- a party member whispered me "@Someone Hello!"
		local target, text = message:match("^@(.-) (.+)$")

		if target and text then
			-- sender wants us to whisper target with text
			whisperForwardTo, whisperForwardTime = target, GetTime()
			SendChatMessage(text, "WHISPER", nil, target)

		elseif whisperForwardTo then
			-- we've forwarded to whisper recently
			if GetTime() - whisperForwardTime > self.db.timeout then
				-- it's been a while since our last forward to whisper
				whisperForwardTo = nil
				SendChatMessage("!ERROR: Whisper timeout reached.", "WHISPER", nil, sender)
			else
				-- whisper last forward target
				whisperForwardTime = GetTime()
				SendChatMessage(message, "WHISPER", nil, whisperForwardTo)
			end
		end
	else
		local spamwords = 0
		local searchstring = message:lower():gsub("%W", "")
		for _, word in ipairs(ignorewords) do
			if searchstring:find(word) then
				spamwords = spamwords + 1
			end
		end
		if spamwords > 3 then
			message = "POSSIBLE SPAM"
		end

		local active = self.db.mode == "appfocus" and GetTime() - frametime < 0.25 or IsPartyLeader()
		self:Debug(active and "Active" or "Not active")
		if not active then -- someone outside the party whispered me
			if message ~= "POSSIBLE SPAM" then
				hasActiveConversation, partyForwardFrom, partyForwardTime = true, sender, GetTime()
			end
			if flag == "GM" then
				SendAddonMessage("HydraChat", format("GM |cff00ccff%s|r %s", sender, message), "PARTY")
				SendChatMessage(format(">> GM %s: %s", sender, message), "PARTY")
			else
				local color = class and (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[(guid and guid ~= "" and select(2, GetPlayerInfoByGUID(arg12))) or "UNKNOWN"]
				SendAddonMessage("HydraChat", format("W %s %s", (color and format("\124cff%02x%02x%02x%s\124r", color.r * 255, color.g * 255, color.b * 255, sender) or sender), message), "PARTY")
				SendChatMessage(format(">> %s: %s", sender, message), "PARTY")
			end
		end
	end
end

------------------------------------------------------------------------

function module:CHAT_MSG_SYSTEM(message)
	if message == ERR_FRIEND_NOT_FOUND then
		-- the whisper couldn't be forwarded
	end
end

------------------------------------------------------------------------

function module:CHAT_MSG_ADDON(prefix, message, channel, sender)
	if prefix ~= "HydraChat" or channel ~= "PARTY" or sender == playerName or not core:IsTrusted(sender) then return end

	local ftype, fsender, fmessage = message:trim():match("^(%S+) (%S+) (.+)$")
	self:Debug("HydraChat", sender, ftype, fsender, fmessage)

	if type == "GM" then
		self:Debug(sender, "received a whisper from GM", fsender)
		self:Alert("|TInterface\\ChatFrame\\UI-ChatIcon-Blizz.blp:0:2:0:-3|t " .. sender .. " has received a whisper from a GM!", true)
		self:Print("|TInterface\\ChatFrame\\UI-ChatIcon-Blizz.blp:0:2:0:-3|t", sender, "has received a whisper from a GM!")
	elseif type == "BN" then
		self:Print(sender, "received a Battle.net whisper from", fsender)
	elseif type == "W" then
		self:Debug(sender, "received a whisper from", fsender)
	end
end

------------------------------------------------------------------------