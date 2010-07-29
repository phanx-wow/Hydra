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

module.debug = true

------------------------------------------------------------------------

function module:CheckState()
	self:Debug("Enable module: Party")

	self:RegisterEvent("CHAT_MSG_ADDON")
	self:RegisterEvent("PARTY_INVITE_REQUEST")
end

------------------------------------------------------------------------

function module:CHAT_MSG_ADDON(prefix, message, channel, sender)
	if channel == "WHISPER" and prefix == "HydraInvite" then
		if not core:IsTrusted(sender) then
			return SendChatMessage("I cannot invite you because you are not on my trusted list.", "WHISPER", nil, sender)
		end
		if GetNumPartyMembers() > 0 and not IsPartyLeader() then
			return SendChatMessage("I cannot invite you because I am not the module leader.", "WHISPER", nil, sender)
		end
		if message ~= "NOPROMOTE" then
			remote = sender
			self:RegisterEvent("PARTY_LEADER_CHANGED")
		end
		InviteUnit(sender)
	elseif prefix == "HydraPromote" then
		if not core:IsTrusted(sender) then
			return SendChatMessage("I cannot promote you because you are not on my trusted list.", "WHISPER", nil, sender)
		end
		if GetNumPartyMembers() > 0 and not IsPartyLeader() then
			return SendChatMessage("I cannot promote you because I am not the module leader.", "WHISPER", nil, sender)
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

SlashCmdList.INVITEME = function(noPromote)
	if GetNumPartyMembers() > 0 or GetNumRaidMembers() > 0 then return end
	local name, realm = UnitName("target")
	if realm and realm ~= "" and realm ~= realmName then return end
	if UnitCanCooperate("player", "target") then
		noPromote = noPromote and noPromote:trim():len() > 0
		SendAddonMessage("HydraInvite", noPromote and "NOPROMOTE" and "ME", "WHISPER", name)
	end
end

------------------------------------------------------------------------

SLASH_PROMOTEME1 = "/pme"
SLASH_PROMOTEME2 = "/promoteme"

SlashCmdList.PROMOTEME = function()
	if GetNumPartyMembers() == 0 or GetNumRaidMembers() > 0 then return end
	local name, realm = UnitName("target")
	if realm and realm ~= "" and realm ~= realmName then return end
	if UnitCanCooperate("player", "target") then
		SendAddonMessage("HydraPromote", "ME", "WHISPER", name)
	end
end

------------------------------------------------------------------------