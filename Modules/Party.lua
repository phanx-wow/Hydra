--[[--------------------------------------------------------------------
	Hydra
	Multibox leveling helper.
	by Phanx < addons@phanx.net >
	Copyright © 2010 Phanx. Some rights reserved. See LICENSE.txt for details.
	http://www.wowinterface.com/downloads/info17572-Hydra.html
	http://wow.curseforge.com/projects/hydra/
------------------------------------------------------------------------
	Hydra Party
	* Type "/inviteme" to command your target to invite you to a module
	  and promote you to module leader. Supplying any parameter with this
	  command will stop the target from promoting you after inviting.
	* Type "/promoteme" to command your target to promote you to module
	  leader.
----------------------------------------------------------------------]]

local _, core = ...
if not core then core = _G.Hydra end

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
	if sender == playerName then return end

	if prefix == "HydraInvite" and channel == "WHISPER" then
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
	target = string.trim(target or ""):lower()

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
	end

	if not core:IsTrusted(target) then return end

	module:Debug("INVITEME", target, nopromote)

	SendAddonMessage("HydraInvite", nopromote and "NOPROMOTE" or "ME", "WHISPER", target)
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