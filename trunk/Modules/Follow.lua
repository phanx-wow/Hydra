--[[--------------------------------------------------------------------
	Hydra
	Multibox leveling helper.
	Copyright (c) 2010-2013 Phanx <addons@phanx.net>. All rights reserved.
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

local followers, following, lastFollowing = { }

local module = core:RegisterModule("Follow", CreateFrame("Frame"))
module:SetScript("OnEvent", function(f, e, ...) return f[e] and f[e](f, ...) end)

module.defaults = { enable = true, refollowAfterCombat = false, verbose = true }

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
		if self.db.refollowAfterCombat then
			self:RegisterEvent("PLAYER_REGEN_ENABLED")
		end
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
				self:Print(L.FollowingYouStart, sender)
			end
			followers[sender] = GetTime()
			if lastFollowing == sender then
				-- Avoid recursion!
				self:Debug("Last follower now following. Avoid recursion!")
				lastFollowing = nil
			end

		elseif message == "END" and followers[sender] then -- sender stopped following me
			if GetTime() - followers[sender] > 2 then
				if self.db.verbose then
					self:Print(L.FollowingYouStop, sender)
				end
				if not CheckInteractDistance(sender, 2) and not UnitOnTaxi("player") then
					self:Alert(format(L.FollowingYouStop, sender))
				end
			end
			followers[sender] = nil

		elseif message == "ME" and core:IsTrusted(sender) and self.db.enable then -- sender wants me to follow them
			if CheckInteractDistance(sender, 4) then
				self:Debug(sender, "has sent a follow request.")
				FollowUnit(sender)
			else
				if self.db.verbose then
					self:Print(L.FollowTooFar, sender)
				end
			end
		end

	elseif prefix == "HydraCorpse" and core:IsTrusted(sender) then
		if message == "RELEASE" and UnitIsDead("player") and not UnitIsGhost("player") then
			local ss = HasSoulstone()
			if ss then
				if ss == L.UseSoulstone then
					self:SendAddonMessage("HydraFollow", "SS")
				elseif ss == L.Reincarnate then
					self:SendAddonMessage("HydraFollow", "REINC")
				else -- probably "Twisting Nether"
					self:SendAddonMessage("HydraFollow", "SELFRES")
				end
			else
				RepopMe()
			end

		elseif message == "ACCEPT" then
			if UnitIsGhost("player") then
				RetrieveCorpse()
			elseif HasSoulstone() then
				UseSoulstone()
			end
			if CannotBeResurrected() then
				self:SendAddonMessage("HydraFollow", "NORES")
			else
				local delay = GetCorpseRecorveryDelay()
				if delay and delay > 0 then
					self:SendAddonMessage("HydraFollow", "WAIT " .. delay)
				end
			end

		elseif strmatch(message, "^WAIT ") then
			local delay = strmatch(message, "%d+")
			self:Print(L.CantResDelay, sender, delay)

		elseif message == "NORES" then
			self:Print(L.CantRes, sender)

		elseif message == "SS" then
			self:Print(L.CanUseSoulstone, sender)

		elseif message == "REINC" then
			self:Print(L.CanReincarnate, sender)

		elseif message == "SELFRES" then
			self:Print(L.CanSelfRes, sender)
		end
	end
end

function module:AUTOFOLLOW_BEGIN(name)
	self:Debug("Now following", name)
	self:SendAddonMessage("HydraFollow", name, name)
	following = name
	lastFollowing = name
end

function module:AUTOFOLLOW_END()
	if not following then return end -- we don't know who we were following!
	self:Debug("No longer following", following)
	self:SendAddonMessage("HydraFollow", "END", following)
	following = nil
end

function module:PLAYER_REGEN_ENABLED()
	if not lastFollowing then
		self:Debug("No target to re-follow")
		return
	end

	if CheckInteractDistance(lastFollowing, 4) then
		self:Debug("Refollowing", lastFollowing)
		FollowUnit(lastFollowing)
	else
		if self.db.verbose then
			self:Print(L.ReFollowTooFar, lastFollowing)
			lastFollowing = nil
		end
	end
end

------------------------------------------------------------------------

SLASH_HYDRA_FOLLOWME1 = "/followme"
SLASH_HYDRA_FOLLOWME2 = "/fme"

if L.SlashFollowMe ~= SLASH_HYDRA_FOLLOWME1 and L.SlashFollowMe ~= SLASH_HYDRA_FOLLOWME2 then
	SLASH_FOLLOWME3 = L.SlashFollowMe
end

function SlashCmdList.HYDRA_FOLLOWME(names)
	if core.state == SOLO then return end

	if names and strlen(names) > 0 then
		local sent = 0
		for name in gmatch(names, "%S+") do
			local trusted = core:IsTrusted(name)
			if trusted and (UnitInParty(trusted) or UnitInRaid(trusted)) then
				module:Debug("Sending follow command to:", trusted)
				module:SendAddonMessage("HydraFollow", "ME", trusted)
				sent = sent + 1
			end
		end
		if sent > 0 then
			return
		end
	end

	local target, targetRealm = UnitName("target")
	local trusted = target and core:IsTrusted(target, targetRealm)
	if target and module.db.targetedFollowMe and trusted and (UnitInParty(trusted) or UnitInRaid(trusted)) then
		module:Debug("Sending follow command to target:", trusted)
		module:SendAddonMessage("HydraFollow", "ME", trusted)
	else
		module:Debug("Sending follow command to party")
		module:SendAddonMessage("HydraFollow", "ME")
	end
end

------------------------------------------------------------------------

SLASH_HYDRA_CORPSE1 = "/corpse"

if L.SlashCorpse ~= SLASH_HYDRA_CORPSE1 then
	SLASH_HYDRA_CORPSE2 = L.SlashCorpse
end

function SlashCmdList.HYDRA_CORPSE(command)
	if core.state == SOLO then return end
	command = command and strlower(strtrim(command)) or ""
	if strmatch(command, L.CmdAccept) or strmatch(command, "^re?l?e?a?s?e?") then
		module:SendAddonMessage("HydraCorpse", "RELEASE")
	elseif strmatch(command, L.CmdRelease) or strmatch(command, "^ac?c?e?p?t?") then
		module:SendAddonMessage("HydraCorpse", "ACCEPT")
	end
end

------------------------------------------------------------------------

BINDING_NAME_HYDRA_FOLLOW_TARGET = L.FollowTarget
BINDING_NAME_HYDRA_FOLLOW_ME = L.FollowMe
BINDING_NAME_HYDRA_RELEASE_CORPSE = L.ReleaseCorpse
BINDING_NAME_HYDRA_ACCEPT_CORPSE = L.AcceptCorpse

------------------------------------------------------------------------

module.displayName = L.Follow
function module:SetupOptions(panel)
	local title, notes = LibStub("PhanxConfig-Header").CreateHeader(panel, L.Follow, L.Follow_Info)

	local CreateCheckbox = LibStub("PhanxConfig-Checkbox").CreateCheckbox
	local CreateKeyBinding = LibStub("PhanxConfig-KeyBinding").CreateKeyBinding

	local enable = CreateCheckbox(panel, L.Enable, L.Enable_Info)
	enable:SetPoint("TOPLEFT", notes, "BOTTOMLEFT", 0, -12)
	enable.OnClick = function(_, checked)
		self.db.enable = checked
	end

	local refollow = CreateCheckbox(panel, L.RefollowAfterCombat, L.RefollowAfterCombat_Info)
	refollow:SetPoint("TOPLEFT", enable, "BOTTOMLEFT", 0, -8)
	refollow.OnClick = function(_, checked)
		self.db.refollowAfterCombat = checked
		self:CheckState()
	end

	local verbose = CreateCheckbox(panel, L.Verbose, L.Verbose_Info)
	verbose:SetPoint("TOPLEFT", refollow, "BOTTOMLEFT", 0, -8)
	verbose.OnClick = function(_, checked)
		self.db.verbose = checked
	end

	local targeted = CreateCheckbox(panel, L.TargetedFollowMe, L.TargetedFollowMe_Info)
	targeted:SetPoint("TOPLEFT", verbose, "BOTTOMLEFT", 0, -8)
	targeted.OnClick = function(_, checked)
		self.db.targetedFollowMe = checked
	end

	local follow = CreateKeyBinding(panel, L.FollowTarget, L.FollowTarget_Info, "HYDRA_FOLLOW_TARGET")
	follow:SetPoint("TOPLEFT", notes, "BOTTOM", -8, -8)
	follow:SetPoint("TOPRIGHT", notes, "BOTTOMRIGHT", 0, -8)

	local followme = CreateKeyBinding(panel, L.FollowMe, L.FollowMe_Info, "HYDRA_FOLLOW_ME")
	followme:SetPoint("TOPLEFT", follow, "BOTTOMLEFT", 0, -8)
	followme:SetPoint("TOPRIGHT", follow, "BOTTOMRIGHT", 0, -8)

	local release = CreateKeyBinding(panel, L.ReleaseCorpse, L.ReleaseCorpse_Info, "HYDRA_RELEASE_CORPSE")
	release:SetPoint("TOPLEFT", followme, "BOTTOMLEFT", 0, -8)
	release:SetPoint("TOPRIGHT", followme, "BOTTOMRIGHT", 0, -8)

	local acceptres = CreateKeyBinding(panel, L.AcceptCorpse, L.AcceptCorpse_Info, "HYDRA_ACCEPT_CORPSE")
	acceptres:SetPoint("TOPLEFT", release, "BOTTOMLEFT", 0, -8)
	acceptres:SetPoint("TOPRIGHT", release, "BOTTOMRIGHT", 0, -8)

	local help = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	help:SetPoint("BOTTOMLEFT", 16, 16)
	help:SetPoint("BOTTOMRIGHT", -16, 16)
	help:SetHeight(112)
	help:SetJustifyH("LEFT")
	help:SetJustifyV("BOTTOM")
	help:SetText(L.FollowHelpText)

	panel.refresh = function()
		enable:SetChecked(self.db.enable)
		refollow:SetChecked(self.db.refollowAfterCombat)
		verbose:SetChecked(self.db.verbose)
		targeted:SetChecked(self.db.targetedFollowMe)
		follow:RefreshValue()
		followme:RefreshValue()
		release:RefreshValue()
		acceptres:RefreshValue()
	end
end