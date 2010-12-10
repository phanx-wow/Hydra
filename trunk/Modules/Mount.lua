--[[--------------------------------------------------------------------
	Hydra
	Multibox leveling helper.
	by Phanx < addons@phanx.net >
	http://www.wowinterface.com/downloads/info17572-Hydra.html
	http://wow.curseforge.com/projects/hydra/

	Copyright © 2010 Phanx
	I, the copyright holder of this work, hereby release it into the public
	domain. This applies worldwide. In case this is not legally possible:
	I grant anyone the right to use this work for any purpose, without any
	conditions, unless such conditions are required by law.
------------------------------------------------------------------------
	Hydra Mount
	* Mounts other characters in the party when you mount
----------------------------------------------------------------------]]

local _, core = ...
if not core then core = _G.Hydra end

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
	else
		self:Debug("Disable module: Mount")
		self:UnregisterAllEvents()
	end
end

------------------------------------------------------------------------

function module:CHAT_MSG_ADDON(prefix, message, channel, sender)
	if prefix ~= "HydraMount" or channel ~= "PARTY" or sender == playerName or not core:IsTrusted(sender) then return end
	self:Debug("CHAT_MSG_ADDON", prefix, message, channel, sender)

	if message == "ERROR" then
		print("ERROR:", sender, "is missing that mount!")
		return
	end

	local remoteID, remoteName = message:match("^(%d+) (.+)$")
	if not remoteID or not remoteName then return end
	remoteID = tonumber(remoteID)
	self:Debug(sender, "mounted on", remoteName, remoteID, self.mounts[remoteID])

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

	SendAddonMessage("HydraMount", "ERROR", "PARTY")
	responding = nil
end

------------------------------------------------------------------------

function module:UNIT_SPELLCAST_SENT(unit, spell)
	if responding or unit ~= "player" or core.state == SOLO or UnitAffectingCombat("player") then return end
	for i = 1, GetNumCompanions("MOUNT") do
		local _, name, id = GetCompanionInfo("MOUNT", i)
		if name == spell or (GetSpellInfo(id)) == spell then -- stupid paladin mount summon spell doesn't match companion name
			self:Debug("Summoning mount", name, id)
			SendAddonMessage("HydraMount", id .. " " .. name, "PARTY")
		end
	end
end

hooksecurefunc("CallCompanion", function(type, i)
	if responding or core.state == SOLO then return end
	if type == "MOUNT" then
		local _, name, id = GetCompanionInfo(type, i)
		module:Debug("CallCompanion", type, i, name, id)
		SendAddonMessage("HydraMount", id .. " " .. name, "PARTY")
	end
end)

------------------------------------------------------------------------

module.mountData = LibStub("LibMounts-1.0")
module.mountList = LibStub("LibMounts-1.0_Data")