--[[--------------------------------------------------------------------
	HYDRA CHAT
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

local TIMEOUT = 300

HYDRA_CHAT_MODE = "leader" -- appfocus | leader

------------------------------------------------------------------------

local _, core = ...
local SOLO, PARTY, TRUSTED, LEADER = 0, 1, 2, 3
local realmName, playerName = GetRealmName(), UnitName("player")

local partyForwardTime, partyForwardFrom, hasActiveConversation = 0
local whisperForwardTime, whisperForwardTo = 0
local frametime, hasfocus = 0

local module = core:RegisterModule("Chat", CreateFrame("Frame"))
module:SetScript("OnEvent", function(f, e, ...) return f[e] and f[e](f, ...) end)
module:SetScript("OnUpdate", function() frametime = GetTime() end)
module:Hide()

module.debug = true

------------------------------------------------------------------------

function module:CheckState()
	if core.state < TRUSTED then
		self:Debug("Disable module: Chat")
		self:UnregisterAllEvents()
		self:Hide()
	else
		self:Debug("Enable module: Chat")
		if HYDRA_CHAT_MODE == "appfocus" then self:Show() end
		self:RegisterEvent("CHAT_MSG_ADDON")
		self:RegisterEvent("CHAT_MSG_PARTY")
		self:RegisterEvent("CHAT_MSG_PARTY_LEADER")
		self:RegisterEvent("CHAT_MSG_SYSTEM")
		self:RegisterEvent("CHAT_MSG_WHISPER")
	end
end

------------------------------------------------------------------------

function module:CHAT_MSG_PARTY(message, sender)
	if sender == playerName then return end
	self:Debug("Received party message from", sender, ": ", message)

	local target, text = message:match("^([^!]%S+) >> (.*)$")
	if target and text then
		-- someone else forwarded a whisper, our conversation is no longer the active one
		self:Debug("Someone else forwarded a whisper.")
		hasActiveConversation = nil

	elseif hasActiveConversation and not message:match("^[!@]") then
		-- someone responding to our last forwarded whisper
		self:Debug("hasActiveConversation")
		if GetTime() - partyForwardTime > TIMEOUT then
			-- it's been a while
			hasActiveConversation = nil
			SendChatMessage("!ERROR: Party timeout reached.", "PARTY")
		else
			-- forwarding response to whisper sender
			SendChatMessage(message, "WHISPER", nil, partyForwardFrom)
			partyForwardTime = GetTime()
		end

	elseif partyForwardFrom then
		self:Debug("partyForwardFrom")
		local text = message:match("^%s*@" .. playerName .. " (.+)$")
		if text then
			-- someone responding to a previous forward
			self:Debug("Detected response to old forward.")
			SendChatMessage(message:gsub("@" .. playerName, ""), "WHISPER", nil, partyForwardFrom)
		end
	end
end

module.CHAT_MSG_PARTY_LEADER = module.CHAT_MSG_PARTY

------------------------------------------------------------------------

function module:CHAT_MSG_WHISPER(message, sender, _, _, _, flag)
	self:Debug("CHAT_MSG_WHISPER", sender, ">", message, flag)

	if UnitInParty(sender) then
		self:Debug("Party member", sender, "whispered me:", message)

		-- a party member whispered me "@Someone Hello!"
		local target, text = message:match("@(%S+) (.+)")

		if target and text then -- whisper "Someone" with "Hello!"
			whisperForwardTo, whisperForwardTime = target, GetTime()
			SendChatMessage(text, "WHISPER", nil, target)

		elseif whisperForwardTo then
			if GetTime() - whisperForwardTime > TIMEOUT then -- it's been a while since our last forward to whisper
				whisperForwardTo = nil
				SendChatMessage("!ERROR: Whisper timeout reached.", "WHISPER", nil, sender)

			else -- whisper last forward target
				whisperForwardTime = GetTime()
				SendChatMessage(message, "WHISPER", nil, whisperForwardTo)
			end
		end
	else
		local active
		if HYDRA_CHAT_MODE == "appfocus" then
			self:Debug("Checking for application focus")
			local elapsed = GetTime() - frametime
			if hasfocus and elapsed > 0.5 then -- a frame hasn't been drawn in the last half second, this client is not active
				self:Debug("Client lost focus")
				hasfocus = nil
			elseif elapsed < 0.5 and not hasfocus then -- client gained focus
				self:Debug("Client gained focus")
				hasfocus = true
				active = true
			end
		elseif IsPartyLeader() then
			self:Debug("IsPartyLeader")
			active = true
		end
		self:Debug(active and "Active" or "Not active")
		if not active then -- someone outside the party whispered me
			hasActiveConversation, partyForwardFrom, partyForwardTime = true, sender, GetTime()
			if flag == "GM" then
				SendChatMessage("GM " .. sender .. " >> " .. message, "PARTY")
				SendAddonMessage("HydraChat", "GM " .. sender .. " " .. message, "PARTY")
			else
				SendChatMessage(sender .. " >> " .. message, "PARTY")
				SendAddonMessage("HydraChat", "W " .. sender .. " " .. message, "PARTY")
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
	elseif type == "W" then
		self:Debug(sender, "received a whisper from", fsender)
	end
end

------------------------------------------------------------------------