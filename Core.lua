--[[--------------------------------------------------------------------
	HYDRA
	Makes multi-box leveling easier.
	by Phanx < addons@phanx.net >
	http://www.wowinterface.com/downloads/info-Hydra.html
	http://wow.curseforge.com/projects/hydra/
----------------------------------------------------------------------]]

local _, core = ...
core.modules = { }
core.trusted = core.trusted or { }

------------------------------------------------------------------------

local trusted, throttle, realmName, playerName = nil, 0, GetRealmName(), UnitName("player")
local SOLO, INSECURE, SECURE, LEADER = 0, 1, 2, 3

------------------------------------------------------------------------

function core:Debug(...)
	if not self.debug then return end
	print("|cffffcc00Hydra:|r", ...)
end

function core:Print(...)
	print("|cffffcc00Hydra:|r", ...)
end

function core:Alert(message, flash, r, g, b)
	UIErrorsFrame:AddMessage(message, r or 1, g or 1, b or 0, 1, UIERRORS_HOLD_TIME)
end

function core:IsTrusted(name, realm)
	if (realm and realm ~= "" and realm ~= realmName) or name:match("%-") then return end
	return trusted[name]
end

local noop = function() end
function core:RegisterModule(name, object)
	assert(not self.modules[name], "Module %s is already registered!", name)
	if not object then object = { } end

	object.name = name
	object.CheckState = noop
	object.Alert, object.Debug, object.Print = self.Alert, self.Debug, self.Print

	self.modules[name] = object

	return object
end

------------------------------------------------------------------------

local f = CreateFrame("Frame")
f:SetScript("OnEvent", function(f, e, ...) return f[e] and f[e](f, ...) end)
f:RegisterEvent("PLAYER_LOGIN")

function f:PLAYER_LOGIN()
	core:Debug("Loading...")

	trusted = core.trusted[realmName]
	core.trusted = nil
	if not trusted then return core:Debug("No trusted names for this server.") end

	f:UnregisterEvent("PLAYER_LOGIN")

	f:RegisterEvent("PARTY_LEADER_CHANGED")
	f:RegisterEvent("PARTY_MEMBERS_CHANGED")
	f:RegisterEvent("UNIT_NAME_UPDATE")

	f:PARTY_LEADER_CHANGED()
end

------------------------------------------------------------------------

function f:PARTY_LEADER_CHANGED(unit)
	if unit and not unit:match("^party%d$") then return end

	local newstate = SOLO
	if GetNumRaidMembers() == 0 and GetNumPartyMembers() > 0 then
		for i = 1, GetNumPartyMembers() do
			if not core:IsTrusted(UnitName("party" .. i)) then
				newstate = INSECURE
				break
			end
		end
		if newstate == SOLO then
			newstate = IsPartyLeader() and LEADER or SECURE
		end
	end

	core:Debug("Party changed:", core.state, "->", newstate)

	if newstate ~= core.state then
		core.state = newstate

		if newstate >= SECURE then
			if IsPartyLeader() and GetLootMethod() ~= "freeforall" then
				core:Debug("Setting loot method to Free For All.")
				SetLootMethod("freeforall")
			end
		elseif newstate > SOLO then
			if IsPartyLeader() and GetLootMethod() == "freeforall" then
				core:Debug("Setting loot method to Group.")
				SetLootMethod("group")
			end
		end

		for name, module in pairs(core.modules) do
			core:Debug("Checking state for module:", name)
			module:CheckState()
		end
	end
end

f.PARTY_MEMBERS_CHANGED = f.PARTY_LEADER_CHANGED
f.UNIT_NAME_UPDATE = f.PARTY_LEADER_CHANGED
