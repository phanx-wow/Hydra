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
local PLAYER = core.PLAYER_NAME
local SOLO, PARTY, TRUSTED, LEADER = core.STATE_SOLO, core.STATE_PARTY, core.STATE_TRUSTED, core.STATE_LEADER

local followers, following, lastFollowing = {}

local module = core:NewModule("Follow")
module.defaults = {
	enable = true,
	refollowAfterCombat = false,
	verbose = true,
}

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

function module:ReceiveAddonMessage(message, channel, sender)
	if strmatch(message, "^START ") then
		local target = strsub(message, 6)
		if target == PLAYER then -- sender is following me
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

	elseif message == "END" then
		if followers[sender] then -- sender stopped following me
			if GetTime() - followers[sender] > 2 then
				if self.db.verbose then
					self:Print(L.FollowingYouStop, sender)
				end
				if not CheckInteractDistance(sender, 2) and not UnitOnTaxi("player") then
					self:Alert(format(L.FollowingYouStop, sender))
				end
			end
			followers[sender] = nil
		end

	elseif message == "FOLLOW" then
		if core:IsTrusted(sender) and self.db.enable then -- sender wants me to follow them
			if CheckInteractDistance(sender, 4) then
				self:Debug(sender, "has sent a follow request.")
				FollowUnit(sender)
			else
				if self.db.verbose then
					self:Print(L.FollowTooFar, sender)
				end
			end
		end

	elseif message == "RELEASE" then
		if UnitIsDead("player") and not UnitIsGhost("player") then
			local ss = HasSoulstone()
			if not ss then
				RepopMe()
			elseif ss == L.UseSoulstone then
				self:SendAddonMessage("SS")
			elseif ss == L.Reincarnate then
				self:SendAddonMessage("REINC")
			else -- probably "Twisting Nether"
				self:SendAddonMessage("SELFRES")
			end
		end

	elseif message == "ACCEPT" then
		if UnitIsGhost("player") then
			RetrieveCorpse()
		elseif HasSoulstone() then
			UseSoulstone()
		end
		if CannotBeResurrected() then
			self:SendAddonMessage("NORES")
		else
			local delay = GetCorpseRecorveryDelay()
			if delay and delay > 0 then
				self:SendAddonMessage("WAIT " .. delay)
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

function module:AUTOFOLLOW_BEGIN(name)
	name = core:ValidateName(UnitName(name)) -- arg doesn't include a realm name
	self:Debug("Now following", name)
	self:SendAddonMessage("BEGIN", name)
	following = name
	lastFollowing = name
end

function module:AUTOFOLLOW_END()
	if not following then return end -- we don't know who we were following!
	self:Debug("No longer following", following)
	self:SendAddonMessage("END", following)
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
SLASH_HYDRA_FOLLOWME3 = L.SlashFollowMe

function SlashCmdList.HYDRA_FOLLOWME(command)
	if not module.enabled then return end
	command = command and strlower(strtrim(command)) or ""

	if strlen(command) > 0 then
		local sent = 0
		for name in gmatch(command, "%S+") do
			local trusted = core:IsTrusted(name)
			if trusted and ( UnitInParty(trusted) or UnitInRaid(trusted) ) then
				module:Debug("Sending follow command to:", trusted)
				module:SendAddonMessage("FOLLOW", trusted)
				sent = sent + 1
			end
		end
		if sent > 0 then
			return
		end
	end

	local trusted = core:IsTrusted(UnitName("target"))
	if trusted and module.db.targetedFollowMe and not UnitIsUnit(trusted, "player") and ( UnitInParty(trusted) or UnitInRaid(trusted) ) then
		module:Debug("Sending follow command to target:", trusted)
		module:SendAddonMessage("FOLLOW", trusted)
	else
		module:Debug("Sending follow command to party")
		module:SendAddonMessage("FOLLOW")
	end
end

------------------------------------------------------------------------

SLASH_HYDRA_CORPSE1 = "/corpse"
SLASH_HYDRA_CORPSE2 = L.SlashCorpse

function SlashCmdList.HYDRA_CORPSE(command)
	if not module.enabled then return end
	command = command and strlower(strtrim(command)) or ""

	if strmatch(command, L.CmdAccept) or strmatch(command, "^re?l?e?a?s?e?") then
		module:SendAddonMessage("RELEASE")
	elseif strmatch(command, L.CmdRelease) or strmatch(command, "^ac?c?e?p?t?") then
		module:SendAddonMessage("ACCEPT")
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
	local title, notes = LibStub("PhanxConfig-Header"):New(panel, L.Follow, L.Follow_Info)

	local CreateCheckbox = LibStub("PhanxConfig-Checkbox").CreateCheckbox
	local CreateKeyBinding = LibStub("PhanxConfig-KeyBinding").CreateKeyBinding

	local enable = CreateCheckbox(panel, L.Enable, L.Enable_Info)
	enable:SetPoint("TOPLEFT", notes, "BOTTOMLEFT", 0, -12)
	enable.OnValueChanged = function(this, value)
		self.db.enable = value
		self:Refresh()
	end

	local refollow = CreateCheckbox(panel, L.RefollowAfterCombat, L.RefollowAfterCombat_Info)
	refollow:SetPoint("TOPLEFT", enable, "BOTTOMLEFT", 0, -8)
	refollow.OnValueChanged = function(this, value)
		self.db.refollowAfterCombat = value
		if value and self.db.enable then
			self:RegisterEvent("PLAYER_REGEN_ENABLED")
		else
			self:UnregisterEvent("PLAYER_REGEN_ENABLED")
		end
	end

	local verbose = CreateCheckbox(panel, L.Verbose, L.Verbose_Info)
	verbose:SetPoint("TOPLEFT", refollow, "BOTTOMLEFT", 0, -8)
	verbose.OnValueChanged = function(this, value)
		self.db.verbose = value
	end

	local targeted = CreateCheckbox(panel, L.TargetedFollowMe, L.TargetedFollowMe_Info)
	targeted:SetPoint("TOPLEFT", verbose, "BOTTOMLEFT", 0, -8)
	targeted.OnValueChanged = function(this, value)
		self.db.targetedFollowMe = value
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