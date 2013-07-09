--[[--------------------------------------------------------------------
	Hydra
	Multibox leveling helper.
	Copyright (c) 2010-2013 Phanx <addons@phanx.net>. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info17572-Hydra.html
	http://www.curse.com/addons/wow/hydra
------------------------------------------------------------------------
	Hydra Group
	* Type "/inviteme" to command your target to invite you to a module
	  and promote you to module leader. Supplying any parameter with this
	  command will stop the target from promoting you after inviting.
	* Type "/promoteme" to command your target to promote you to module
	  leader.
----------------------------------------------------------------------]]

local _, core = ...

local L = core.L

local SOLO, PARTY, TRUSTED, LEADER = 0, 1, 2, 3
local realmName, playerName = GetRealmName(), UnitName("player")

local remote

local module = core:RegisterModule("Group", CreateFrame("Frame"))
module:SetScript("OnEvent", function(f, e, ...) return f[e] and f[e](f, ...) end)

module.defaults = { enable = true }

------------------------------------------------------------------------

function module:CheckState()
	if self.db.enable then
		self:Debug("Enable module: Group")
		self:RegisterEvent("PARTY_INVITE_REQUEST")
	else
		self:Debug("Disable module: Group")
		self:UnregisterAllEvents()
	end
end

------------------------------------------------------------------------

function module:ReceiveAddonMessage(message, channel, sender)
	self:Debug("ReceiveAddonMessage", message, channel, sender)

	if message:match("INVITE") and channel == "WHISPER" then
		if not core:IsTrusted(sender) then
			return self:SendChatMessage(L.CantInviteNotTrusted, sender)
		end

		if GetNumGroupMembers() > 0 and not UnitIsGroupLeader("player") then
			return self:SendChatMessage(L.CantInviteNotLeader, sender)
		end

		if message:match("PROMOTE") then
			remote = sender
			self:RegisterEvent("PARTY_LEADER_CHANGED")
		end
		InviteUnit(sender)

	elseif message:match("PROMOTE") then
		if not core:IsTrusted(sender) then
			return -- self:SendChatMessage(L.CantPromoteNotTrusted, sender)
		end

		if GetNumGroupMembers() > 0 then
			if UnitIsGroupLeader("player") then
				return PromoteToLeader(sender)
			else
				return -- self:SendChatMessage(L.CantPromoteNotLeader, sender)
			end
		else
			-- we're not in a group, invite instead
			return self:CHAT_MSG_ADDON("HydraGroup", "INVITE", "WHISPER", sender)
		end
	end
end

function module:PARTY_LEADER_CHANGED()
	if GetNumGroupMembers() > 0 and UnitIsGroupLeader("player") then
		self:UnregisterEvent("PARTY_LEADER_CHANGED")
		PromoteToLeader(remote)
		remote = nil
	end
end

------------------------------------------------------------------------

do
	local function checkInvite(which, sender)
		if core:IsTrusted(sender) then
			module:Debug("Sender", sender, "is trusted.")
			local dialog = StaticPopup_Visible(which)
			if dialog then
				module:Debug("Dialog found:", dialog)
				StaticPopup_OnClick(_G[dialog], 1)
			else
				module:Debug("Dialog not found.")
			end
		end
	end

	hooksecurefunc("StaticPopup_Show", function(which, sender)
		if which == "PARTY_INVITE" or which == "PARTY_INVITE_XREALM" then
			module:Debug("StaticPopup_Show", which, sender)
			checkInvite(which, sender)
		end
	end)

	function module:PARTY_INVITE_REQUEST(sender, roleTankAvailable, roleHealerAvailable, roleDamagerAvailable, isCrossRealm)
		if role1 or role2 or role3 then
			-- LFG thingy
			return
		end
		self:Debug("PARTY_INVITE_REQUEST", sender)
		checkInvite(isCrossRealm and "PARTY_INVITE_XREALM" or "PARTY_INVITE", sender)
	end
end

------------------------------------------------------------------------

SLASH_HYDRA_INVITEME1 = "/inviteme"
SLASH_HYDRA_INVITEME2 = "/ime"

if L.SlashInviteMe ~= SLASH_HYDRA_INVITEME1 and L.SlashInviteMe ~= SLASH_HYDRA_INVITEME2 then
	SLASH_HYDRA_INVITEME3 = L.SlashInviteMe
end

SlashCmdList.HYDRA_INVITEME = function(name)
	if GetNumGroupMembers() > 0 then return end

	name = name and strtrim(name) or ""

	local nopromote
	name, nopromote = gsub(name, L.CmdNoPromote)
	name, nopromote = gsub(name, "[Nn][Oo][Pp][Rr][Oo][Mm][Oo][Tt][Ee]")
	nopromote = nopromote and nopromote > 0

	if strlen(name) == 0 and UnitCanCooperate("player", "target") then
		name = core:ValidateName(UnitName("target"))
	end

	if core:IsTrusted(name) then
		module:Debug("INVITEME", trusted, nopromote)
		module:SendAddonMessage(nopromote and "INVITE" or "INVITEANDPROMOTE", "WHISPER", trusted)
	end
end

------------------------------------------------------------------------

SLASH_HYDRA_PROMOTEME1 = "/promoteme"
SLASH_HYDRA_PROMOTEME2 = "/pme"

if L.SlashPromoteMe ~= SLASH_HYDRA_PROMOTEME1 and L.SlashPromoteMe ~= SLASH_HYDRA_PROMOTEME2 then
	SLASH_HYDRA_PROMOTEME3 = L.SlashPromoteMe
end

SlashCmdList.HYDRA_PROMOTEME = function()
	if GetNumGroupMembers() == 0 then return end

	module:Debug("PROMOTEME")
	module:SendAddonMessage("PROMOTE")
end

------------------------------------------------------------------------

module.displayName = L.Group
function module:SetupOptions(panel)
	local title, notes = LibStub("PhanxConfig-Header").CreateHeader(panel, L.Group, L.Group_Info)

	local enable = LibStub("PhanxConfig-Checkbox").CreateCheckbox(panel, L.Enable, L.Enable_Info)
	enable:SetPoint("TOPLEFT", notes, "BOTTOMLEFT", 0, -12)
	enable.OnClick = function(_, checked)
		self.db.enable = checked
		self:CheckState()
	end

	local help = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	help:SetPoint("BOTTOMLEFT", 16, 16)
	help:SetPoint("BOTTOMRIGHT", -16, 16)
	help:SetHeight(112)
	help:SetJustifyH("LEFT")
	help:SetJustifyV("BOTTOM")
	help:SetText(L.GroupHelpText)

	panel.refresh = function()
		enable:SetChecked(self.db.enable)
	end
end