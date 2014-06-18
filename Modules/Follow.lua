--[[--------------------------------------------------------------------
	Hydra
	Multibox leveling helper.
	Copyright (c) 2010-2014 Phanx <addons@phanx.net>. All rights reserved.
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
local SOLO, PARTY, TRUSTED, LEADER = core.STATE_SOLO, core.STATE_PARTY, core.STATE_TRUSTED, core.STATE_LEADER
local PLAYER_FULLNAME = core.PLAYER_FULLNAME

local module = core:NewModule("Follow")
module.defaults = {
	enable = true,
	refollowAfterCombat = false,
	verbose = true,
}

local followers, following, lastFollowing = {}

local ACTION_FOLLOW, MESSAGE_START, MESSAGE_STOP = "FOLLOW", "START", "STOP"
local ACTION_ACCEPT, ACTION_RELEASE, MESSAGE_CANTRES, MESSAGE_WAIT, MESSAGE_SOULSTONE, MESSAGE_REINCARNATE, MESSAGE_SELFRES = "ACCEPT", "RELEASE", "NORES", "WAIT", "SS", "REINC", "SELFRES"

------------------------------------------------------------------------

function module:ShouldEnable()
	return core.state > SOLO
end

function module:OnEnable()
	self:RegisterEvent("AUTOFOLLOW_BEGIN")
	self:RegisterEvent("AUTOFOLLOW_END")
	if self.db.refollowAfterCombat then
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
	end
end

function module:OnDisable()
	followers, following = wipe(followers), nil
end

------------------------------------------------------------------------

function module:OnAddonMessage(message, channel, sender)
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
		if core:IsTrusted(sender) and self.db.enable then -- sender wants me to follow them
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

function module:AUTOFOLLOW_BEGIN(name)
	name = core:ValidateName(UnitName(name)) -- arg doesn't include a realm name
	self:Debug("Now following", name)
	self:SendAddonMessage(MESSAGE_START .. " " .. name)
	following = name
	lastFollowing = name
end

function module:AUTOFOLLOW_END()
	if not following then return end -- we don't know who we were following!
	self:Debug("No longer following", following)
	self:SendAddonMessage(MESSAGE_STOP)
	following = nil
end

function module:PLAYER_REGEN_ENABLED()
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
	if not module.enabled then return end
	command = command and strlower(strtrim(command)) or ""

	if strlen(command) > 0 then
		local sent = 0
		for name in gmatch(command, "%S+") do
			local name, displayName = core:IsTrusted(name)
			if name and ( UnitInParty(displayName) or UnitInRaid(displayName) ) then
				module:Debug("Sending follow command to:", name)
				module:SendAddonMessage(ACTION_FOLLOW, name)
				sent = sent + 1
			end
		end
		if sent > 0 then
			return
		end
	end

	local name, displayName = core:IsTrusted(UnitName("target"))
	if name and module.db.targetedFollowMe and not UnitIsUnit("target", "player") and ( UnitInParty("target") or UnitInRaid("target") ) then
		module:Debug("Sending follow command to target:", name)
		module:SendAddonMessage(ACTION_FOLLOW, name)
	else
		module:Debug("Sending follow command to party")
		module:SendAddonMessage(ACTION_FOLLOW)
	end
end

------------------------------------------------------------------------

SLASH_HYDRA_CORPSE1 = "/corpse"
SLASH_HYDRA_CORPSE2 = L.SlashCorpse

function SlashCmdList.HYDRA_CORPSE(command)
	if not module.enabled then return end
	command = command and strlower(strtrim(command)) or ""

	if strmatch(command, L.CmdAccept) or strmatch(command, "^re?l?e?a?s?e?") then
		module:SendAddonMessage(ACTION_RELEASE)
	elseif strmatch(command, L.CmdRelease) or strmatch(command, "^ac?c?e?p?t?") then
		module:SendAddonMessage(ACTION_ACCEPT)
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
	local title, notes = panel:CreateHeader(L.Follow, L.Follow_Info)

	local enable = panel:CreateCheckbox(L.Enable, L.Enable_Info)
	enable:SetPoint("TOPLEFT", notes, "BOTTOMLEFT", 0, -12)
	function enable.Callback(this, value)
		self.db.enable = value
		self:Refresh()
	end

	local refollow = panel:CreateCheckbox(L.RefollowAfterCombat, L.RefollowAfterCombat_Info)
	refollow:SetPoint("TOPLEFT", enable, "BOTTOMLEFT", 0, -8)
	function refollow.Callback(this, value)
		self.db.refollowAfterCombat = value
		if value and self.db.enable then
			self:RegisterEvent("PLAYER_REGEN_ENABLED")
		else
			self:UnregisterEvent("PLAYER_REGEN_ENABLED")
		end
	end

	local verbose = panel:CreateCheckbox(L.Verbose, L.Verbose_Info)
	verbose:SetPoint("TOPLEFT", refollow, "BOTTOMLEFT", 0, -8)
	function verbose.Callback(this, value)
		self.db.verbose = value
	end

	local targeted = panel:CreateCheckbox(L.TargetedFollowMe, L.TargetedFollowMe_Info)
	targeted:SetPoint("TOPLEFT", verbose, "BOTTOMLEFT", 0, -8)
	function targeted.Callback(this, value)
		self.db.targetedFollowMe = value
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