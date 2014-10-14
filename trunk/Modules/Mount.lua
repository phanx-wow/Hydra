--[[--------------------------------------------------------------------
	Hydra
	Multibox leveling helper.
	Copyright (c) 2010-2014 Phanx. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info17572-Hydra.html
	http://www.curse.com/addons/wow/hydra
------------------------------------------------------------------------
	Hydra Mount
	* Mount and dismount together.
----------------------------------------------------------------------]]

local _, core = ...
local L = core.L
local SOLO, PARTY, TRUSTED, LEADER = core.STATE_SOLO, core.STATE_PARTY, core.STATE_TRUSTED, core.STATE_LEADER
SOLO = -1 -- #DEBUG
local module = core:NewModule("Mount")
module.defaults = {
	mount = true,
	dismount = true,
}

local ACTION_DISMOUNT, ACTION_MOUNT = "DISMOUNT", "MOUNT"
local MESSAGE_ERROR = "ERROR"

local isCasting, isMounted, responding

------------------------------------------------------------------------

function module:ShouldEnable()
	return core.state > SOLO and (self.db.mount or self.db.dismount)
end

function module:OnEnable()
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	if not UnitAffectingCombat("player") then
		self:PLAYER_REGEN_ENABLED()
	end

	if IsMounted() then
		for i = 1, C_MountJournal.GetNumMounts() do
			local _, id, _, active = C_MountJournal.GetMountInfo(i)
			if active then
				local name = GetSpellInfo(id)
				self:Debug("Already mounted:", name)
				isMounted = name
				self:RegisterUnitEvent("UNIT_AURA", "player")
				break
			end
		end
	end
end

------------------------------------------------------------------------

local mountTypeString = {
	-- http://www.wowinterface.com/forums/showthread.php?p=294988#post294988
	[230] = "GROUND",
	[231] = "TURTLE",
	[232] = "VASHJIR",
	[241] = "AQ40",
	[242] = "GHOST",
	[247] = "AIR",
	[248] = "AIR",
	[254] = "VASHJIR",
	[269] = "WATER_WALKING",
}

function module:OnAddonMessage(message, channel, sender)
	local target = Ambiguate(sender, "none")
	if not core:IsTrusted(sender) or not (UnitInParty(target) or UnitInRaid(target)) then return end
	self:Debug("OnAddonMessage", message, channel, sender)

	local action, remoteID, remoteName = strsplit(" ", message, 3)

	if action == MESSAGE_ERROR then
		self:Print("ERROR: " .. L.MountMissing, sender)
		return
	elseif action == ACTION_DISMOUNT then
		self:Debug(sender, "dismounted")
		if self.db.dismount then
			responding = true
			Dismount()
			responding = nil
		end
		return
	end

	if action ~= ACTION_MOUNT or not remoteID or not remoteName or not self.db.mount then return end

	remoteID = tonumber(remoteID)
	self:Debug(sender, "mounted on", remoteID, remoteName)

	if IsMounted() then return self:Debug("Already mounted.") end
	if not UnitIsVisible(target) then return self:Debug("Not mounting because", sender, "is out of range.") end

	responding = true

	-- 1. Look for same mount
	if not self.db.mountRandom then
		for i = 1, C_MountJournal.GetNumMounts() do
			local name, id = C_MountJournal.GetMountInfo(i)
			if id == remoteID then
				self:Debug("Found same mount", name)
				C_MountJournal.Summon(i)
				responding = nil
				return
			end
		end
	end

	-- 2. Look for equivalent mount
	local mountType, equivalent
	local numMounts = C_MountJournal.GetNumMounts()
	for i = 1, numMounts do
		local _, id = C_MountJournal.GetMountInfo(i)
		if id == remoteID then
			local _, _, _, _, mountTypeID = C_MountJournal.GetMountInfoExtra(i)
			mountType = mountTypeString[mountTypeID]
			break
		end
	end
	if not mountType then
		return self:Debug("Mount type not recognized")
	end
	for i = 1, numMounts do
		local _, id, _, _, usable = C_MountJournal.GetMountInfo(i)
		if usable then
			local _, _, _, _, mountTypeID = C_MountJournal.GetMountInfoExtra(i)
			if mountTypeString[mountTypeID] == mountType then
				if not equivalent then
					equivalent = i
					if not self.db.mountRandom then
						break
					end
				elseif type(equivalent) == "table" then
					tinsert(equivalent, i)
				else
					equivalent = { equivalent, i }
				end
			end
		end
	end
	local i = type(equivalent) == "table" and equivalent[random(#equivalent)] or equivalent
	if i then
		local name = C_MountJournal.GetMountInfo(i)
		self:Debug("Found equivalent mount", name)
		C_MountJournal.Summon(i)
		responding = nil
		return
	end

	-- 3. Admit defeat
	self:SendAddonMessage(MESSAGE_ERROR)
	responding = nil
end

------------------------------------------------------------------------

function module:PLAYER_REGEN_DISABLED()
	self:RegisterUnitEvent("UNIT_SPELLCAST_START", "player")
end

function module:PLAYER_REGEN_ENABLED()
	self:UnregisterEvent("UNIT_SPELLCAST_START")
end

function module:UNIT_SPELLCAST_START(unit, spellName, _, castID, spellID)
	self:Debug("UNIT_SPELLCAST_START", spellName)
	for i = 1, C_MountJournal.GetNumMounts() do
		local name, id = C_MountJournal.GetMountInfo(i)
		if id == spellID then
			if not responding then
				self:Debug("Summoning mount", name, id)
				self:SendAddonMessage(ACTION_MOUNT .. " " .. id .. " " .. name)
				isCasting = spellName
			end
			self:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
			self:RegisterUnitEvent("UNIT_SPELLCAST_STOP", "player")
		end
	end
end

function module:UNIT_SPELLCAST_SUCCEEDED(unit, spellName, _, castID, spellID)
	self:Debug("UNIT_SPELLCAST_SUCCEEDED", spellName)
	if spellName == isCasting then
		isMounted = spellName
		self:RegisterUnitEvent("UNIT_AURA", "player")
	end
end

function module:UNIT_SPELLCAST_STOP(unit, spellName, _, castID, spellID)
	self:Debug("UNIT_SPELLCAST_STOP", spellName)
	self:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	self:UnregisterEvent("UNIT_SPELLCAST_STOP")
end

function module:UNIT_AURA(unit)
	if not UnitBuff(unit, isMounted) then
		if not responding then
			self:Debug("Dismounted")
			self:SendAddonMessage(ACTION_DISMOUNT)
		end
		self:UnregisterEvent("UNIT_AURA")
		isMounted = nil
	end
end

------------------------------------------------------------------------

module.displayName = L.Mount
function module:SetupOptions(panel)
	local title, notes = panel:CreateHeader(L.Mount, L.Mount_Info)

	local mount = panel:CreateCheckbox(L.MountTogether, L.MountTogether_Info)
	mount:SetPoint("TOPLEFT", notes, "BOTTOMLEFT", 0, -12)
	function mount.Callback(this, value)
		self.db.mount = value
		self:IsEnabled()
	end

	local mountRandom = panel:CreateCheckbox(L.MountRandom, L.MountRandom)
	mountRandom:SetPoint("TOPLEFT", mount, "BOTTOMLEFT", 0, -8)
	function mountRandom.Callback(this, value)
		self.db.mountRandom = value
		self:IsEnabled()
	end

	local dismount = panel:CreateCheckbox(L.Dismount, L.Dismount_Info)
	dismount:SetPoint("TOPLEFT", mountRandom, "BOTTOMLEFT", 0, -8)
	function dismount.Callback(this, value)
		self.db.dismount = value
		self:IsEnabled()
	end

	local help = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	help:SetPoint("BOTTOMLEFT", 16, 16)
	help:SetPoint("BOTTOMRIGHT", -16, 16)
	help:SetHeight(112)
	help:SetJustifyH("LEFT")
	help:SetJustifyV("BOTTOM")
	help:SetText(L.MountHelpText)

	panel.refresh = function()
		mount:SetChecked(self.db.mount)
		mountRandom:SetChecked(self.db.mountRandom)
		dismount:SetChecked(self.db.dismount)
	end
end

------------------------------------------------------------------------
--[[ NOT CURRENTLY USED

local mountPassengers = {
	[61467]  = 2, -- Grand Black War Mammoth (horde)
	[61465]  = 2, -- Grand Black War Mammoth (alliance)
	[122708] = 2, -- Grand Expedition Yak
	[61469]  = 2, -- Grand Ice Mammoth (horde)
	[61470]  = 2, -- Grand Ice Mammoth (alliance)
	[55531]  = 1, -- Mechano-hog
	[60424]  = 1, -- Mekgineer's Chopper
	[121820] = 1, -- Obsidian Nightwing
	[93326]  = 1, -- Sandstone Drake
	[61447]  = 2, -- Traveler's Tundra Mammoth (horde)
	[61425]  = 2, -- Traveler's Tundra Mammoth (alliance)
	[75973]  = 1, -- X-53 Touring Rocket
}

function module:GetMountPassengers(id)
	return self.mountSpecial.passengers[id]
end
]]