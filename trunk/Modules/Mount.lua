--[[--------------------------------------------------------------------
	Hydra
	Multibox leveling helper.
	Copyright (c) 2010-2012 Phanx <addons@phanx.net>. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info17572-Hydra.html
	http://www.curse.com/addons/wow/hydra
------------------------------------------------------------------------
	Hydra Mount
	* Mounts other characters in the party when you mount
----------------------------------------------------------------------]]

local _, core = ...

local L = core.L

local SOLO, PARTY, TRUSTED, LEADER = 0, 1, 2, 3
local playerName = UnitName("player")

local responding

local module = core:RegisterModule("Mount", CreateFrame("Frame"))
module:SetScript("OnEvent", function(f, e, ...) return f[e] and f[e](f, ...) end)

module.defaults = { enable = true }

------------------------------------------------------------------------

function module:CheckState()
	if core.state > SOLO and self.db.enable then
		self:Debug("Enable module: Mount")
		self:RegisterEvent("CHAT_MSG_ADDON")
		self:RegisterEvent("UNIT_SPELLCAST_SENT")
		if not IsAddonMessagePrefixRegistered("HydraMount") then
			RegisterAddonMessagePrefix("HydraMount")
		end
	else
		self:Debug("Disable module: Mount")
		self:UnregisterAllEvents()
	end
end

------------------------------------------------------------------------

function module:CHAT_MSG_ADDON(prefix, message, channel, sender)
	if prefix ~= "HydraMount" or sender == playerName or (channel ~= "PARTY" and channel ~= "RAID") or not core:IsTrusted(sender) then return end
	self:Debug("CHAT_MSG_ADDON", prefix, message, channel, sender)

	if message == "ERROR" then
		self:Print(L["ERROR: %s is missing that mount!"], sender)
		return
	end

	local remoteID, remoteName = strmatch(message, "^(%d+) (.+)$")
	if not remoteID or not remoteName then return end

	remoteID = tonumber(remoteID)
	self:Debug(sender, "mounted on", remoteID, remoteName)

	if IsMounted() then return self:Debug("Already mounted.") end
	if not UnitIsVisible(sender) then return self:Debug("Not mounting because", sender, "is out of range.") end

	responding = true

	-- 1. look for same mount
	for i = 1, GetNumCompanions("MOUNT") do
		local _, name, id = GetCompanionInfo("MOUNT", i)
		if id == remoteID then
			self:Debug("Found same mount", name)
			CallCompanion("MOUNT", i)
			responding = nil
			return
		end
	end

	-- 2. look for equivalent mount
	local ground, air, water = self.mountData:GetMountInfo(remoteID)
	local list = self.mountList[water and "water" or air and "air" or "ground"]
	for i = 1, GetNumCompanions("MOUNT") do
		local _, name, id = GetCompanionInfo("MOUNT", i)
		self:Debug("Checking mount", name)
		if list[id] then
			self:Debug("Found equivalent mount", name)
			CallCompanion("MOUNT", i)
			responding = nil
			return
		end
	end

	SendAddonMessage("HydraMount", "ERROR", "RAID")
	responding = nil
end

------------------------------------------------------------------------

function module:UNIT_SPELLCAST_SENT(unit, spell)
	if responding or unit ~= "player" or core.state == SOLO or UnitAffectingCombat("player") then return end
	for i = 1, GetNumCompanions("MOUNT") do
		local _, name, id = GetCompanionInfo("MOUNT", i)
		if name == spell or GetSpellInfo(id) == spell then -- stupid paladin mount summon spell doesn't match companion name
			self:Debug("Summoning mount", name, id)
			SendAddonMessage("HydraMount", id .. " " .. name, "RAID")
		end
	end
end

hooksecurefunc("CallCompanion", function(type, i)
	if responding or core.state == SOLO then return end
	if type == "MOUNT" then
		local _, name, id = GetCompanionInfo(type, i)
		module:Debug("CallCompanion", type, i, name, id)
		SendAddonMessage("HydraMount", id .. " " .. name, "RAID")
	end
end)

------------------------------------------------------------------------

module.mountData = LibStub("LibMounts-1.0")
module.mountList = LibStub("LibMounts-1.0_Data")

------------------------------------------------------------------------

function module:SetupOptions(panel)
	local title, notes = LibStub("PhanxConfig-Header").CreateHeader(panel, panel.name, L["Summons your mount when another party member mounts."])

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
	help:SetText(L.HELP_MOUNT)

	panel.refresh = function()
		enable:SetChecked(self.db.enable)
	end
end