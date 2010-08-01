--[[--------------------------------------------------------------------
	HYDRA PARTY
	* Type "/inviteme" to command your target to invite you to a module
	  and promote you to module leader. Supplying any parameter with this
	  command will stop the target from promoting you after inviting.
	* Type "/promoteme" to command your target to promote you to module
	  leader.
----------------------------------------------------------------------]]

local _, core = ...
local SOLO, PARTY, TRUSTED, LEADER = 0, 1, 2, 3
local realmName, playerName = GetRealmName(), UnitName("player")

local remote

local module = core:RegisterModule("Party", CreateFrame("Frame"))
module:SetScript("OnEvent", function(f, e, ...) return f[e] and f[e](f, ...) end)

module.defaults = { enable = true }

------------------------------------------------------------------------

function module:CheckState()
	if self.db.enable then
		self:Debug("Enable module: Party")
		self:RegisterEvent("CHAT_MSG_ADDON")
		self:RegisterEvent("PARTY_INVITE_REQUEST")
	else
		self:Debug("Disable module: Party")
		self:UnregisterAllEvents()
	end
end

------------------------------------------------------------------------

function module:CHAT_MSG_ADDON(prefix, message, channel, sender)
	if channel == "WHISPER" and prefix == "HydraInvite" then
		if not core:IsTrusted(sender) then
			return SendChatMessage("I cannot invite you, because you are not on my trusted list.", "WHISPER", nil, sender)
		end
		if GetNumPartyMembers() > 0 and not IsPartyLeader() then
			return SendChatMessage("I cannot invite you, because I am not the module leader.", "WHISPER", nil, sender)
		end
		if message ~= "NOPROMOTE" then
			remote = sender
			self:RegisterEvent("PARTY_LEADER_CHANGED")
		end
		InviteUnit(sender)

	elseif prefix == "HydraPromote" then
		if not core:IsTrusted(sender) then
			return SendChatMessage("I cannot promote you, because you are not on my trusted list.", "WHISPER", nil, sender)
		end
		if GetNumPartyMembers() > 0 and not IsPartyLeader() then
			return SendChatMessage("I cannot promote you, because I am not the party leader.", "WHISPER", nil, sender)
		end
		if GetNumPartyMembers() == 0 then
			-- we're not in a party, invite instead
			return self:CHAT_MSG_ADDON("HydraInvite", "ME", "WHISPER", sender)
		end
		PromoteToLeader(sender)
	end
end

function module:PARTY_LEADER_CHANGED()
	if GetNumPartyMembers() > 0 and IsPartyLeader() then
		self:UnregisterEvent("PARTY_LEADER_CHANGED")
		PromoteToLeader(remote)
		remote = nil
	end
end

------------------------------------------------------------------------

function module:PARTY_INVITE_REQUEST(sender)
	if core:IsTrusted(sender) then
		-- AcceptGroup()
		local dialog = StaticPopup_Visible("PARTY_INVITE")
		if dialog then
			_G[dialog .. "Button1"]:Click()
		end
	end
end

------------------------------------------------------------------------

SLASH_INVITEME1 = "/ime"
SLASH_INVITEME2 = "/inviteme"

SlashCmdList.INVITEME = function(target)
	if GetNumPartyMembers() > 0 or GetNumRaidMembers() > 0 then return end
	input = string.trim(input or "")

	local nopromote

	if target:match("nopromote") then
		nopromote = true
		target = target:replace("nopromote", ""):trim()
	end

	if target == "" then
		local name, realm = UnitName("target")
		if realm and realm ~= "" and realm ~= realmName then return end
		if not UnitCanCooperate("player", "target") then return end
		target = name
	else
		target = target:gsub("%a", string.upper, 1)
	end

	if not core:IsTrusted(target) then return end

	module:Debug("INVITEME", target, nopromote)

	SendAddonMessage("HydraInvite", nopromote and "NOPROMOTE" or "ME", "WHISPER", name)
end

------------------------------------------------------------------------

SLASH_PROMOTEME1 = "/pme"
SLASH_PROMOTEME2 = "/promoteme"

SlashCmdList.PROMOTEME = function()
	if GetNumPartyMembers() == 0 or GetNumRaidMembers() > 0 then return end

	module:Debug("PROMOTEME")

	SendAddonMessage("HydraPromote", "ME", "PARTY")
end

------------------------------------------------------------------------