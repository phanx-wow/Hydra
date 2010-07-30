--[[--------------------------------------------------------------------
	HYDRA MOUNT
	* Mounts other characters in the party when you mount
----------------------------------------------------------------------]]

local _, core = ...
local SOLO, PARTY, TRUSTED, LEADER = 0, 1, 2, 3
local playerName = UnitName("player")

local responding

local module = core:RegisterModule("Mount", CreateFrame("Frame"))
module:SetScript("OnEvent", function(f, e, ...) return f[e] and f[e](f, ...) end)

module.defaults = { enable = true }

------------------------------------------------------------------------

function module:CheckState()
	if core.state == SOLO or not self.db.enable then
		self:Debug("Disable module: Mount")
		self:UnregisterAllEvents()
	else
		self:Debug("Enable module: Mount")
		self:RegisterEvent("CHAT_MSG_ADDON")
		self:RegisterEvent("UNIT_SPELLCAST_SENT")
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

	if IsMounted() then return self:Debug("Already mounted.") end
	if not UnitIsVisible(sender) then return self:Debug("Not mounting because", sender, "is out of range.") end

	responding = true

	self:Debug(sender, "mounted on", message)
	for i = 1, GetNumCompanions("MOUNT") do
		local _, name = GetCompanionInfo("MOUNT", i)
		if name == message then
			CallCompanion("MOUNT", i)
			responding = nil
		end
	end

	if responding then
		SendAddonMessage("HydraMount", "ERROR", "PARTY")
		responding = nil
	end
end

------------------------------------------------------------------------

function module:UNIT_SPELLCAST_SENT(unit, spell, rank, id)
	if responding or unit ~= "player" or core.state == SOLO or UnitAffectingCombat("player") then return end
	for i = 1, GetNumCompanions("MOUNT") do
		local _, name = GetCompanionInfo("MOUNT", i)
		if name == spell then
			self:Debug("Summoning mount:", name)
			SendAddonMessage("HydraMount", name, "PARTY")
		end
	end
end

hooksecurefunc("CallCompanion", function(type, i)
	if responding or core.state == SOLO then return end
	if type == "MOUNT" then
		local _, name = GetCompanionInfo(type, i)
		module:Debug("CallCompanion", type, i, name)
		SendAddonMessage("HydraMount", name, "PARTY")
	end
end)

------------------------------------------------------------------------