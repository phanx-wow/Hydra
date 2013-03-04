--[[--------------------------------------------------------------------
	Hydra
	Multibox leveling helper.
	Copyright (c) 2010-2012 Phanx <addons@phanx.net>. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info17572-Hydra.html
	http://www.curse.com/addons/wow/hydra
------------------------------------------------------------------------
	Hydra Follow
	* Alerts when someone who is following you falls off
	* /followme or /fme commands all party members to follow you
	* /corpse r[elease] causes all dead party members to release their spirit
	* /corpse a[ccept] causes all ghost party members to accept their corpse
----------------------------------------------------------------------]]

local _, core = ...

local L = core.L

local SOLO, PARTY, TRUSTED, LEADER = 0, 1, 2, 3
local playerName = UnitName("player")

local followers, following = { }

local module = core:RegisterModule("Follow", CreateFrame("Frame"))
module:SetScript("OnEvent", function(f, e, ...) return f[e] and f[e](f, ...) end)

module.defaults = { enable = true, verbose = true }

if GetLocale():match("^en") then
	L["release"] = "re?l?e?a?s?e?"
	L["accept"] = "ac?c?e?p?t?"
end

------------------------------------------------------------------------

function module:CheckState()
	if core.status == SOLO then
		self:Debug("Disable module: Follow")
		self:UnregisterAllEvents()
		followers, following = wipe(followers), nil
	else
		self:Debug("Enable module: Follow")
		self:RegisterEvent("AUTOFOLLOW_BEGIN")
		self:RegisterEvent("AUTOFOLLOW_END")
		self:RegisterEvent("CHAT_MSG_ADDON")
		if not IsAddonMessagePrefixRegistered("HydraCorpse") then
			RegisterAddonMessagePrefix("HydraCorpse")
		end
		if not IsAddonMessagePrefixRegistered("HydraFollow") then
			RegisterAddonMessagePrefix("HydraFollow")
		end
	end
end

------------------------------------------------------------------------

function module:CHAT_MSG_ADDON(prefix, message, channel, sender)
	if sender == playerName then return end

	if prefix == "HydraFollow" then
		if message == playerName then -- sender is following me
			if self.db.verbose then
				self:Print(L["%s is now following you."], sender)
			end
			followers[sender] = GetTime()

		elseif message == "END" and followers[sender] then -- sender stopped following me
			if GetTime() - followers[sender] > 2 then
				if self.db.verbose then
					self:Print(L["%s is no longer following you."], sender)
				end
				if not CheckInteractDistance(sender, 2) and not UnitOnTaxi("player") then
					self:Alert(format(L["%s is no longer following you!"], sender))
				end
			end
			followers[sender] = nil

		elseif message == "ME" and core:IsTrusted(sender) and self.db.enable then -- sender wants me to follow them
			if CheckInteractDistance(sender, 4) then
				self:Debug(sender, "has sent a follow request.")
				FollowUnit(sender)
			else
				if self.db.verbose then
					self:Print(L["%s is too far away to follow!"], sender)
				end
			end
		end

	elseif prefix == "HydraCorpse" then
		if message == "release" and UnitIsDead("player") and not UnitIsGhost("player") and core:IsTrusted(sender) then
			local ss = HasSoulstone()
			if ss then
				if ss == L["Use Soulstone"] then
					self:SendChatMessage(L["I have a soulstone."]) -- #TODO: use comms
				elseif ss == L["Reincarnate"] then
					self:SendChatMessage(L["I can reincarnate."]) -- #TODO: use comms
				else -- probably "Twisting Nether"
					self:SendChatMessage(L["I can resurrect myself."]) -- #TODO: use comms
				end
			else
				RepopMe()
			end

		elseif message == "accept" and core:IsTrusted(sender) then
			if UnitIsGhost("player") then
				RetrieveCorpse()
			elseif HasSoulstone() then
				UseSoulstone()
			end
			if CannotBeResurrected() then
				self:SendChatMessage(L["I cannot resurrect!"]) -- #TODO: use comms
			end
		end
	end
end

function module:AUTOFOLLOW_BEGIN(name)
	self:Debug("Now following", name)
	self:SendAddonMessage("HydraFollow", name, "WHISPER", name)
	following = name
end

function module:AUTOFOLLOW_END()
	if not following then return end -- we don't know who we were following!
	self:Debug("No longer following", following)
	self:SendAddonMessage("HydraFollow", "END", "WHISPER", following)
	following = nil
end

------------------------------------------------------------------------

SLASH_HYDRA_FOLLOWME1 = "/fme"
SLASH_HYDRA_FOLLOWME2 = "/followme"
do
	local slash = rawget(L, "SLASH_HYDRA_FOLLOWME3")
	if slash and slash ~= SLASH_HYDRA_FOLLOWME1 and slash ~= SLASH_HYDRA_FOLLOWME2 then
		SLASH_FOLLOWME3 = slash
	end
end

function SlashCmdList.HYDRA_FOLLOWME(names)
	if core.state == SOLO then return end
	local target = UnitName("target")
	if names and strlen(names) > 0 then
		local sent = 0
		for name in gmatch(names, "%S+") do
			name = gsub(strlower(name), "%a", strupper, 1)
			if core:IsTrusted(name) and (UnitInParty(name) or UnitInRaid(name)) then
				module:Debug("Sending follow command to:", name)
				module:SendAddonMessage("HydraFollow", "ME", "WHISPER", name)
				sent = sent + 1
			end
		end
		if sent > 0 then
			return
		end
	end
	if target and module.db.targetedFollowMe and core:IsTrusted(target) and (UnitInParty(name) or UnitInRaid(name)) then
		module:Debug("Sending follow command to target:", target)
		module:SendAddonMessage("HydraFollow", "ME", "WHISPER", target)
	else
		module:Debug("Sending follow command to party")
		module:SendAddonMessage("HydraFollow", "ME")
	end
end

------------------------------------------------------------------------

SLASH_HYDRA_CORPSE1 = "/corpse"
do
	local slash = rawget(L, "SLASH_HYDRA_CORPSE2")
	if slash and slash ~= SLASH_HYDRA_CORPSE1 then
		SLASH_HYDRA_CORPSE2 = slash
	end
end

function SlashCmdList.HYDRA_CORPSE(command)
	if core.state == SOLO then return end
	command = command and strlower(strtrim(command)) or ""
	if strmatch(command, L["release"]) or strmatch(command, "^r") then
		module:SendAddonMessage("HydraCorpse", "release")
	elseif strmatch(command, L["accept"]) or strmatch(command, "^a") then
		module:SendAddonMessage("HydraCorpse", "accept")
	end
end

------------------------------------------------------------------------

BINDING_NAME_HYDRA_FOLLOW_TARGET = rawget(L, "BINDING_NAME_HYDRA_FOLLOW_TARGET") or "Follow target"
BINDING_NAME_HYDRA_FOLLOW_ME = rawget(L, "BINDING_NAME_HYDRA_FOLLOW_ME") or "Request follow"
BINDING_NAME_HYDRA_RELEASE_CORPSE = rawget(L, "BINDING_NAME_HYDRA_RELEASE_CORPSE") or "Release spirit"
BINDING_NAME_HYDRA_ACCEPT_CORPSE = rawget(L, "BINDING_NAME_HYDRA_ACCEPT_CORPSE") or "Resurrect"

------------------------------------------------------------------------

function module:SetupOptions(panel)
	local title, notes = LibStub("PhanxConfig-Header").CreateHeader(panel, panel.name, L["Responds to follow requests from trusted party members."])

	local CreateCheckbox = LibStub("PhanxConfig-Checkbox").CreateCheckbox
	local CreateKeyBinding = LibStub("PhanxConfig-KeyBinding").CreateKeyBinding

	local enable = CreateCheckbox(panel, L["Enable"],
		L["Enable this module."])
	enable:SetPoint("TOPLEFT", notes, "BOTTOMLEFT", 0, -12)
	enable.OnClick = function(_, checked)
		self.db.enable = checked
	end

	local verbose = CreateCheckbox(panel, L["Verbose mode"],
		L["Enable notification messages from this module."])
	verbose:SetPoint("TOPLEFT", enable, "BOTTOMLEFT", 0, -8)
	verbose.OnClick = function(_, checked)
		self.db.verbose = checked
	end

	local targeted = CreateCheckbox(panel, L["Targeted /followme"],
		L["Send the /followme only to your current target while targeting a trusted party member."])
	targeted:SetPoint("TOPLEFT", verbose, "BOTTOMLEFT", 0, -8)
	targeted.OnClick = function(_, checked)
		self.db.targetedFollowMe = checked
	end

	local follow = CreateKeyBinding(panel, BINDING_NAME_HYDRA_FOLLOW_TARGET,
		L["Set a key binding to follow your current target."],
		"HYDRA_FOLLOW_TARGET")
	follow:SetPoint("TOPLEFT", notes, "BOTTOM", -8, -8)
	follow:SetPoint("TOPRIGHT", notes, "BOTTOMRIGHT", 0, -8)

	local followme = CreateKeyBinding(panel, BINDING_NAME_HYDRA_FOLLOW_ME,
		L["Set a key binding to direct all characters in your party to follow you."],
		"HYDRA_FOLLOW_ME")
	followme:SetPoint("TOPLEFT", follow, "BOTTOMLEFT", 0, -8)
	followme:SetPoint("TOPRIGHT", follow, "BOTTOMRIGHT", 0, -8)

	local release = CreateKeyBinding(panel, BINDING_NAME_HYDRA_RELEASE_CORPSE,
		L["Set a key binding to direct all dead characters in your party to release their spirit."],
		"HYDRA_RELEASE_CORPSE")
	release:SetPoint("TOPLEFT", followme, "BOTTOMLEFT", 0, -8)
	release:SetPoint("TOPRIGHT", followme, "BOTTOMRIGHT", 0, -8)

	local acceptres = CreateKeyBinding(panel, BINDING_NAME_HYDRA_ACCEPT_CORPSE,
		L["Set a key binding to direct all ghost characters in your party to accept resurrection to their corpse."],
		"HYDRA_ACCEPT_CORPSE")
	acceptres:SetPoint("TOPLEFT", release, "BOTTOMLEFT", 0, -8)
	acceptres:SetPoint("TOPRIGHT", release, "BOTTOMRIGHT", 0, -8)

	local help = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	help:SetPoint("BOTTOMLEFT", 16, 16)
	help:SetPoint("BOTTOMRIGHT", -16, 16)
	help:SetHeight(112)
	help:SetJustifyH("LEFT")
	help:SetJustifyV("BOTTOM")
	help:SetText(L.HELP_FOLLOW)

	panel.refresh = function()
		enable:SetChecked(self.db.enable)
		verbose:SetChecked(self.db.verbose)
		targeted:SetChecked(self.db.targetedFollowMe)
		follow:RefreshValue()
		followme:RefreshValue()
		release:RefreshValue()
		acceptres:RefreshValue()
	end
end