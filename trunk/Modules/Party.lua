--[[--------------------------------------------------------------------
	Hydra
	Multibox leveling helper.
	Copyright (c) 2010-2012 Phanx <addons@phanx.net>. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info17572-Hydra.html
	http://www.curse.com/addons/wow/hydra
------------------------------------------------------------------------
	Hydra Party
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

local module = core:RegisterModule("Party", CreateFrame("Frame"))
module:SetScript("OnEvent", function(f, e, ...) return f[e] and f[e](f, ...) end)

module.defaults = { enable = true }

------------------------------------------------------------------------

function module:CheckState()
	if self.db.enable then
		self:Debug("Enable module: Party")
		self:RegisterEvent("CHAT_MSG_ADDON")
		self:RegisterEvent("PARTY_INVITE_REQUEST")
		if not IsAddonMessagePrefixRegistered( "HydraParty" ) then
			RegisterAddonMessagePrefix( "HydraParty" )
		end
	else
		self:Debug("Disable module: Party")
		self:UnregisterAllEvents()
	end
end

------------------------------------------------------------------------

function module:CHAT_MSG_ADDON( prefix, message, channel, sender )
	if prefix ~= "HydraParty" or sender == playerName then return end

	if message:match( "INVITE" ) and channel == "WHISPER" then
		if not core:IsTrusted( sender ) then
			return SendChatMessage( L["I cannot invite you, because you are not on my trusted list."], "WHISPER", nil, sender )
		end
		if GetNumPartyMembers() > 0 and not IsPartyLeader() then
			return SendChatMessage( L["I cannot invite you, because I am not the module leader."], "WHISPER", nil, sender )
		end
		if message:match( "PROMOTE" ) then
			remote = sender
			self:RegisterEvent( "PARTY_LEADER_CHANGED" )
		end
		InviteUnit(sender)

	elseif message:match( "PROMOTE" ) then
		if not core:IsTrusted(sender) then
			return SendChatMessage( L["I cannot promote you, because you are not on my trusted list."], "WHISPER", nil, sender )
		end
		if GetNumPartyMembers() > 0 and not IsPartyLeader() then
			return SendChatMessage( L["I cannot promote you, because I am not the party leader."], "WHISPER", nil, sender )
		end
		if GetNumPartyMembers() == 0 then
			-- we're not in a party, invite instead
			return self:CHAT_MSG_ADDON( "HydraParty", "INVITE", "WHISPER", sender )
		end
		PromoteToLeader( sender )
	end
end

function module:PARTY_LEADER_CHANGED()
	if GetNumPartyMembers() > 0 and IsPartyLeader() then
		self:UnregisterEvent( "PARTY_LEADER_CHANGED" )
		PromoteToLeader( remote )
		remote = nil
	end
end

------------------------------------------------------------------------

do
	local function checkPartyInvite(sender)
		if core:IsTrusted(sender) then
			module:Debug("Sender", sender, "is trusted.")
			local dialog = StaticPopup_Visible("PARTY_INVITE")
			if dialog then
				module:Debug("Dialog found:", dialog)
				StaticPopup_OnClick(_G[dialog], 1)
			else
				module:Debug("Dialog not found.")
			end
		end
	end

	hooksecurefunc("StaticPopup_Show", function(which, sender)
		if which == "PARTY_INVITE" then
			module:Debug("StaticPopup_Show", which, sender)
			checkPartyInvite(sender)
		end
	end)

	function module:PARTY_INVITE_REQUEST(sender)
		self:Debug("PARTY_INVITE_REQUEST", sender)
		checkPartyInvite(sender)
	end
end

------------------------------------------------------------------------

SLASH_HYDRA_INVITEME1 = "/ime"
SLASH_HYDRA_INVITEME2 = "/inviteme"
do
	local slash = rawget( core.L, "SLASH_HYDRA_INVITEME3" )
	if slash and slash ~= SLASH_HYDRA_INVITEME1 and slash ~= SLASH_HYDRA_INVITEME2 then
		SLASH_HYDRA_INVITEME3 = slash
	end
end

SlashCmdList.HYDRA_INVITEME = function(target)
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

	SendAddonMessage("HydraParty", nopromote and "INVITE" or "INVITEANDPROMOTE", "WHISPER", target)
end

------------------------------------------------------------------------

SLASH_HYDRA_PROMOTEME1 = "/pme"
SLASH_HYDRA_PROMOTEME2 = "/promoteme"
do
	local slash = rawget( core.L, "SLASH_HYDRA_PROMOTEME3" )
	if slash and slash ~= SLASH_HYDRA_PROMOTEME1 and slash ~= SLASH_HYDRA_PROMOTEME2 then
		SLASH_HYDRA_PROMOTEME3 = slash
	end
end

SlashCmdList.HYDRA_PROMOTEME = function()
	if GetNumPartyMembers() == 0 or GetNumRaidMembers() > 0 then return end

	module:Debug("PROMOTEME")

	SendAddonMessage("HydraParty", "PROMOTE", "PARTY")
end

------------------------------------------------------------------------

function module:SetupOptions(panel)
	local title, notes = LibStub("PhanxConfig-Header").CreateHeader(panel, panel.name, L["Responds to invite and promote requests from trusted players."])

	local enable = LibStub("PhanxConfig-Checkbox").CreateCheckbox(panel, L["Enable"])
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
	help:SetText(L.HELP_PARTY)

	panel.refresh = function()
		enable:SetChecked(self.db.enable)
	end
end