--[[--------------------------------------------------------------------
	Hydra
	Multibox leveling helper.
	Copyright (c) 2010-2014 Phanx <addons@phanx.net>. All rights reserved.
	http://www.wowinterface.com/downloads/info17572-Hydra.html
	http://www.curse.com/addons/wow/hydra
	https://github.com/Phanx/Hydra
------------------------------------------------------------------------
	Hydra Follow
	* Alerts when someone who is following you falls off
	* /followme or /fme commands all party members to follow you
	* /corpse r[elease] causes all dead party members to release their spirit
	* /corpse a[ccept] causes all ghost party members to accept their corpse
----------------------------------------------------------------------]]

local _, Hydra = ...
local L = Hydra.L
local SOLO, PARTY, TRUSTED, LEADER = Hydra.STATE_SOLO, Hydra.STATE_PARTY, Hydra.STATE_TRUSTED, Hydra.STATE_LEADER
local PLAYER_FULLNAME = Hydra.PLAYER_FULLNAME

local Follow = Hydra:NewModule("Follow")
Follow.defaults = {
	enable = true,
	refollowAfterCombat = false,
	verbose = true,
}

local followers, following, lastFollowing = {}

local ACTION_FOLLOW, MESSAGE_START, MESSAGE_STOP = "FOLLOW", "START", "STOP"
local ACTION_ACCEPT, ACTION_RELEASE, MESSAGE_CANTRES, MESSAGE_WAIT, MESSAGE_SOULSTONE, MESSAGE_REINCARNATE, MESSAGE_SELFRES = "ACCEPT", "RELEASE", "NORES", "WAIT", "SS", "REINC", "SELFRES"

------------------------------------------------------------------------

function Follow:ShouldEnable()
	return Hydra.state > SOLO
end

function Follow:OnEnable()
	self:RegisterEvent("AUTOFOLLOW_BEGIN")
	self:RegisterEvent("AUTOFOLLOW_END")
	if self.db.refollowAfterCombat then
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
	end
end

function Follow:OnDisable()
	followers, following = wipe(followers), nil
end

------------------------------------------------------------------------

function Follow:OnAddonMessage(message, channel, sender)
	self:Debug("AddonMessage", channel, sender, message)

	local message, detail = strsplit(" ", message, 2)

	if message == ACTION_START then
		if target == PLAYER_FULLNAME then -- sender is following me
			if self.db.verbose then
				self:Print(L.FollowingYouStart, sender)
			end
			followers[sender] = GetTime()
			if lastFollowing == sender then
				-- Avoid recursion!
				self:Debug("Last follower now following. Avoid recursion!")
				lastFollowing = nil
			end
		else
			-- sender is following someone else
		end

	elseif message == MESSAGE_STOP then
		if followers[sender] then -- sender stopped following me
			if GetTime() - followers[sender] > 2 then
				if self.db.verbose then
					self:Print(L.FollowingYouStop, sender)
				end
				local target = Ambiguate(sender, "none")
				if not CheckInteractDistance(target, 2) and not UnitOnTaxi("player") then
					self:Alert(format(L.FollowingYouStop, sender))
				end
			end
			followers[sender] = nil
		end

	elseif message == ACTION_FOLLOW then
		if Hydra:IsTrusted(sender) and self.db.enable then -- sender wants me to follow them
			local target = Ambiguate(sender, "none")
			if CheckInteractDistance(target, 4) then
				self:Debug(sender, "has sent a follow request.")
				FollowUnit(target)
			else
				if self.db.verbose then
					self:Print(L.FollowTooFar, sender)
				end
			end
		end

	elseif message == ACTION_RELEASE then
		if UnitIsDead("player") and not UnitIsGhost("player") then
			local ss = HasSoulstone()
			if not ss then
				RepopMe()
			elseif ss == L.UseSoulstone then
				self:SendAddonMessage(MESSAGE_SOULSTONE)
			elseif ss == L.Reincarnate then
				self:SendAddonMessage(MESSAGE_REINCARNATE)
			else -- probably "Twisting Nether"
				self:SendAddonMessage(MESSAGE_SELFRES)
			end
		end

	elseif message == ACTION_ACCEPT then
		if UnitIsGhost("player") then
			RetrieveCorpse()
		elseif HasSoulstone() then
			UseSoulstone()
		end
		if CannotBeResurrected() then
			self:SendAddonMessage(MESSAGE_CANTRES)
		else
			local delay = GetCorpseRecorveryDelay()
			if delay and delay > 0 then
				self:SendAddonMessage(MESSAGE_WAIT .. " " .. delay)
			end
		end

	elseif message == MESSAGE_CANTRES then
		self:Print(L.CantRes, sender)

	elseif action == MESSAGE_WAIT then
		self:Print(L.CantResDelay, sender, detail)

	elseif message == MESSAGE_SOULSTONE then
		self:Print(L.CanUseSoulstone, sender)

	elseif message == MESSAGE_REINCARNATE then
		self:Print(L.CanReincarnate, sender)

	elseif message == MESSAGE_SELFRES then
		self:Print(L.CanSelfRes, sender)
	end
end

function Follow:AUTOFOLLOW_BEGIN(name)
	name = Hydra:ValidateName(UnitName(name)) -- arg doesn't include a realm name
	self:Debug("Now following", name)
	self:SendAddonMessage(MESSAGE_START .. " " .. name)
	following = name
	lastFollowing = name
end

function Follow:AUTOFOLLOW_END()
	if not following then return end -- we don't know who we were following!
	self:Debug("No longer following", following)
	self:SendAddonMessage(MESSAGE_STOP)
	following = nil
end

function Follow:PLAYER_REGEN_ENABLED()
	if not lastFollowing then
		self:Debug("No target to re-follow")
		return
	end

	local target = Ambiguate(lastFollowing, "none")
	if CheckInteractDistance(target, 4) then
		self:Debug("Refollowing", lastFollowing)
		FollowUnit(target)
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
SLASH_HYDRA_FOLLOWME3 = L.SlashFollowMe

function SlashCmdList.HYDRA_FOLLOWME(command)
	if not Follow.enabled then return end
	command = command and strlower(strtrim(command)) or ""

	if strlen(command) > 0 then
		local sent = 0
		for name in gmatch(command, "%S+") do
			local name, displayName = Hydra:IsTrusted(name)
			if name then
				local target = name and Ambiguate(name, "none")
				if UnitInParty(target) or UnitInRaid(target) then
					Follow:Debug("Sending follow command to:", name)
					Follow:SendAddonMessage(ACTION_FOLLOW, name)
					sent = sent + 1
				end
			end
		end
		if sent > 0 then
			return
		end
	end

	local name, displayName = Hydra:IsTrusted(UnitName("target"))
	if name and Follow.db.targetedFollowMe and not UnitIsUnit("target", "player") and ( UnitInParty("target") or UnitInRaid("target") ) then
		Follow:Debug("Sending follow command to target:", name)
		Follow:SendAddonMessage(ACTION_FOLLOW, name)
	else
		Follow:Debug("Sending follow command to party")
		Follow:SendAddonMessage(ACTION_FOLLOW)
	end
end

------------------------------------------------------------------------

SLASH_HYDRA_CORPSE1 = "/corpse"
SLASH_HYDRA_CORPSE2 = L.SlashCorpse

function SlashCmdList.HYDRA_CORPSE(command)
	if not Follow.enabled then return end
	command = command and strlower(strtrim(command)) or ""

	if strmatch(command, L.CmdAccept) or strmatch(command, "^re?l?e?a?s?e?") then
		Follow:SendAddonMessage(ACTION_RELEASE)
	elseif strmatch(command, L.CmdRelease) or strmatch(command, "^ac?c?e?p?t?") then
		Follow:SendAddonMessage(ACTION_ACCEPT)
	end
end

------------------------------------------------------------------------

BINDING_NAME_HYDRA_FOLLOW_TARGET = L.FollowTarget
BINDING_NAME_HYDRA_FOLLOW_ME = L.FollowMe
BINDING_NAME_HYDRA_RELEASE_CORPSE = L.ReleaseCorpse
BINDING_NAME_HYDRA_ACCEPT_CORPSE = L.AcceptCorpse

------------------------------------------------------------------------

Follow.displayName = L.Follow
function Follow:SetupOptions(panel)
	local title, notes = panel:CreateHeader(L.Follow, L.Follow_Info)

	local enable = panel:CreateCheckbox(L.Enable, L.Enable_Info)
	enable:SetPoint("TOPLEFT", notes, "BOTTOMLEFT", 0, -12)
	function enable:OnValueChanged(value)
		Follow.db.enable = value
		Follow:Refresh()
	end

	local refollow = panel:CreateCheckbox(L.RefollowAfterCombat, L.RefollowAfterCombat_Info)
	refollow:SetPoint("TOPLEFT", enable, "BOTTOMLEFT", 0, -8)
	function refollow:OnValueChanged(value)
		Follow.db.refollowAfterCombat = value
		if value and Follow.db.enable then
			Follow:RegisterEvent("PLAYER_REGEN_ENABLED")
		else
			Follow:UnregisterEvent("PLAYER_REGEN_ENABLED")
		end
	end

	local verbose = panel:CreateCheckbox(L.Verbose, L.Verbose_Info)
	verbose:SetPoint("TOPLEFT", refollow, "BOTTOMLEFT", 0, -8)
	function verbose:OnValueChanged(value)
		Follow.db.verbose = value
	end

	local targeted = panel:CreateCheckbox(L.TargetedFollowMe, L.TargetedFollowMe_Info)
	targeted:SetPoint("TOPLEFT", verbose, "BOTTOMLEFT", 0, -8)
	function targeted:OnValueChanged(value)
		Follow.db.targetedFollowMe = value
	end

	local follow = panel:CreateKeyBinding(L.FollowTarget, L.FollowTarget_Info, "HYDRA_FOLLOW_TARGET")
	follow:SetPoint("TOPLEFT", notes, "BOTTOM", -8, -8)
	follow:SetPoint("TOPRIGHT", notes, "BOTTOMRIGHT", 0, -8)

	local followme = panel:CreateKeyBinding(L.FollowMe, L.FollowMe_Info, "HYDRA_FOLLOW_ME")
	followme:SetPoint("TOPLEFT", follow, "BOTTOMLEFT", 0, -8)
	followme:SetPoint("TOPRIGHT", follow, "BOTTOMRIGHT", 0, -8)

	local release = panel:CreateKeyBinding(L.ReleaseCorpse, L.ReleaseCorpse_Info, "HYDRA_RELEASE_CORPSE")
	release:SetPoint("TOPLEFT", followme, "BOTTOMLEFT", 0, -8)
	release:SetPoint("TOPRIGHT", followme, "BOTTOMRIGHT", 0, -8)

	local acceptres = panel:CreateKeyBinding(L.AcceptCorpse, L.AcceptCorpse_Info, "HYDRA_ACCEPT_CORPSE")
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
		enable:SetChecked(Follow.db.enable)
		refollow:SetChecked(Follow.db.refollowAfterCombat)
		verbose:SetChecked(Follow.db.verbose)
		targeted:SetChecked(Follow.db.targetedFollowMe)
		follow:RefreshValue()
		followme:RefreshValue()
		release:RefreshValue()
		acceptres:RefreshValue()
	end
end