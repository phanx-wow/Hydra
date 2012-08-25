--[[--------------------------------------------------------------------
	Hydra
	Multibox leveling helper.
	Copyright (c) 2010-2012 Phanx <addons@phanx.net>. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info17572-Hydra.html
	http://www.curse.com/addons/wow/hydra
----------------------------------------------------------------------]]

local WoW5 = select(4, GetBuildInfo()) >= 50000

local HYDRA, core = ...

local L = setmetatable(core.L or {}, { __index = function(t, k)
	if k == nil then return "" end
	local v = tostring(k)
	rawset(t, k, v)
	return v
end })
core.L = L

core.modules = {}

BINDING_HEADER_HYDRA = HYDRA

------------------------------------------------------------------------

local throttle, myRealm, myName = 0, GetRealmName(), UnitName("player")
local SOLO, INSECURE, SECURE, LEADER = 0, 1, 2, 3

------------------------------------------------------------------------

function core:Debug(str, ...)
	if not str or (not self.debug and not core.debugall) then return end
	str = tostring(str)
	if str:match("%%[dsx%d%.]") then
		print("|cffff9999Hydra:|r", format(str, ...))
	else
		print("|cffff9999Hydra:|r", str, ...)
	end
end

function core:Print(str, ...)
	if str:match("%%[dsx%d%.]") then
		str = format(str, ...)
	end
	print("|cffffcc00Hydra:|r", str)
end

function core:Alert(message, flash, r, g, b)
	UIErrorsFrame:AddMessage(message, r or 1, g or 1, b or 0, 1, UIERRORS_HOLD_TIME)
end

------------------------------------------------------------------------

function core:IsTrusted(name, realm)
	if realm and strlen(realm) > 0 and realm ~= myRealm then
		return
	end
	if strmatch(name, "%-") then
		return
	end
	local trusted = self.trusted[name]
	self:Debug("IsTrusted", name, tostring(trusted))
	return trusted
end

function core:AddTrusted(name, realm)
	self:Debug("AddTrusted", name, realm)
	if realm and realm:len() > 0 and realm ~= myRealm then
		return
	end
	assert(type(name) == "string" and strlen(name) >= 2 and strlen(name) <= 12 and strupper(strsub(name, 1, 1)) == strsub(name, 1, 1), "Invalid name.")
	self.trusted[name] = name
	HydraTrustList[myRealm][name] = name
	self:Print("%s has been added to the trusted list.", name)
	if WoW5 then
		self:TriggerEvent("GROUP_ROSTER_UPDATE")
	elseif GetNumRaidMembers() > 0 then
		self:TriggerEvent("RAID_ROSTER_UPDATE")
	else
		self:TriggerEvent("PARTY_MEMBERS_CHANGED")
	end
end

function core:RemoveTrusted(name, realm)
	if realm and strlen(realm) > 0 and realm ~= myRealm then
		return
	end
	assert(type(name) == "string" and self.trusted[name], "Invalid name.")
	self.trusted[name] = nil
	HydraTrustList[myRealm][name] = nil
	self:Print("%s has been removed from the trusted list.", name)
	if WoW5 then
		self:TriggerEvent("GROUP_ROSTER_UPDATE")
	elseif GetNumRaidMembers() > 0 then
		self:TriggerEvent("RAID_ROSTER_UPDATE")
	else
		self:TriggerEvent("PARTY_MEMBERS_CHANGED")
	end
end

------------------------------------------------------------------------

local noop = function() end
function core:RegisterModule(name, module)
	assert(not self.modules[name], "Module %s is already registered!", name)
	if not module then module = {} end

	module.name = name
	module.CheckState = noop
	module.Alert, module.Debug, module.Print = self.Alert, self.Debug, self.Print

	self.modules[name] = module

	return module
end

function core:GetModule(name)
	local module = self.modules[name]
	assert(module, "Module %s is not registered!", name)
	return module
end

------------------------------------------------------------------------

local function copyTable(a, b)
	if not a then return {} end
	if not b then b = {} end
	for k, v in pairs(a) do
		if type(v) == "table" then
			b[k] = copyTable(v, b[k])
		elseif type(v) ~= type(b[k]) then
			b[k] = v
		end
	end
	return b
end

local f = CreateFrame("Frame")
f:SetScript("OnEvent", function(f, e, ...) return f[e] and f[e](f, ...) end)
f:RegisterEvent("PLAYER_LOGIN")

function f:PLAYER_LOGIN()
	core:Debug("Loading...")
	f:UnregisterEvent("PLAYER_LOGIN")

	HydraTrustList = copyTable({ [myRealm] = { [myName] = myName } }, HydraTrustList)
	core.trusted = copyTable(HydraTrustList[myRealm])

	HydraSettings = copyTable({}, HydraSettings)
	core.db = HydraSettings

	for name, module in pairs(core.modules) do
		if module.defaults then
			core:Debug("Initializing settings for module", name)
			core.db[name] = copyTable(module.defaults, core.db[name])
			module.db = core.db[name]
			for k, v in pairs(module.db) do core:Debug(k, "=", v) end
		end
	end

	if WoW5 then
		f:RegisterEvent("GROUP_ROSTER_UPDATE")
	else
		f:RegisterEvent("PARTY_MEMBERS_CHANGED")
		f:RegisterEvent("RAID_ROSTER_UPDATE")
	end
	f:RegisterEvent("PARTY_LEADER_CHANGED")
	f:RegisterEvent("PARTY_LOOT_METHOD_CHANGED")
	f:RegisterEvent("UNIT_NAME_UPDATE")

	f:CheckParty()
end

------------------------------------------------------------------------

function f:CheckParty(unit)
	if unit and not strmatch(unit, "^party%d$") then return end -- irrelevant UNIT_NAME_UPDATE

	local newstate = SOLO
	if WoW5 then
		if IsInGroup() then
			local u, n = "party", GetNumGroupMembers()
			if IsInRaid() then
				u = "raid"
			else
				n = n - 1
			end
			for i = 1, n do
				if not core:IsTrusted(UnitName(u .. i)) then
					newstate = INSECURE
					break
				end
			end
			if newstate == SOLO then
				newstate = UnitIsGroupLeader("player") and LEADER or SECURE
			end
		end
	else
		if GetNumRaidMembers() > 0 then
			for i = 1, GetNumRaidMembers() do
				if not core:IsTrusted(UnitName("raid" .. i)) then
					newstate = INSECURE
					break
				end
			end
			if newstate == SOLO then
				newstate = UnitIsRaidLeader("player") and LEADER or SECURE
			end
		elseif GetNumPartyMembers() > 0 then
			for i = 1, GetNumPartyMembers() do
				if not core:IsTrusted(UnitName("party" .. i)) then
					newstate = INSECURE
					break
				end
			end
			if newstate == SOLO then
				newstate = UnitIsPartyLeader("player") and LEADER or SECURE
			end
		end
	end

	core:Debug("Party changed:", core.state, "->", newstate)

	local UnitIsGroupLeader
	if WoW5 then
		UnitIsGroupLeader = _G.UnitIsGroupLeader
	else
		UnitIsGroupLeader = GetNumRaidMembers() > 0 and UnitIsRaidLeader or UnitIsPartyLeader
	end

	if UnitIsGroupLeader("player") then
		local loot = GetLootMethod()
		if newstate >= SECURE then
			if loot ~= "freeforall" then
				core:Debug("Setting loot method to Free For All.")
				SetLootMethod("freeforall")
			end
		elseif newstate > SOLO then
			if loot == "freeforall" then
				core:Debug("Setting loot method to Group.")
				SetLootMethod("group")
			end
		end
	end

	if newstate ~= core.state then
		core.state = newstate
		for name, module in pairs(core.modules) do
			core:Debug("Checking state for module:", name)
			module:CheckState()
		end
	end
end

if WoW5 then
	f.GROUP_ROSTER_UPDATE = f.CheckParty
else
	f.PARTY_MEMBERS_CHANGED = f.CheckParty
	f.RAID_ROSTER_UPDATE = f.CheckParty
end
f.PARTY_LEADER_CHANGED = f.CheckParty
f.PARTY_LOOT_METHOD_CHANGED = f.CheckParty
f.UNIT_NAME_UPDATE = f.CheckParty

------------------------------------------------------------------------

function core:TriggerEvent(event, ...)
	if f:IsEventRegistered(event) then
		f:GetScript("OnEvent")(f, event, ...)
	end
end

------------------------------------------------------------------------

function core:SetupOptions(panel)
	local title, notes = LibStub("PhanxConfig-Header").CreateHeader(panel, panel.name,
		L["Hydra is a multibox leveling helper that aims to minimize the need to actively control secondary characters."])
	notes:SetHeight(notes:GetHeight() * 1.5)

	local add = LibStub("PhanxConfig-EditBox").CreateEditBox(panel, L["Add Name"], L["Add a name to your trusted list."], 12)
	add:SetPoint("TOPLEFT", notes, "BOTTOMLEFT", 0, -12)
	add:SetPoint("TOPRIGHT", notes, "BOTTOM", -8, -12)
	add.OnValueChanged = function(self, name)
		name = name and gsub(strtrim(name), "%a", strupper, 1)
		if strlen(name) > 1 then
			core:AddTrusted(name)
		end
		self:SetText("")
	end

	local addParty = LibStub("PhanxConfig-Button").CreateButton(panel, L["Add Party"], L["Add all the characters in your current party group to your trusted list."])
	addParty:SetPoint("BOTTOMLEFT", add, "BOTTOMRIGHT", 20, 8)
	addParty.OnClick = function(self)
		local u, n = "party"
		if WoW5 then
			n = GetNumGroupMembers()
			if IsInRaid() then
				u = "raid"
			else
				n = n - 1
			end
		else
			if GetNumRaidMembers() > 0 then
				n = GetNumRaidMembers()
				u = "party"
			elseif GetNumPartyMembers() > 0 then
				n = GetNumPartyMembers()
			end
		end
		if n > 0 then
			for i = 1, n do
				local name, realm = UnitName(u..i)
				if not realm or realm == myRealm or strlen(realm) == 0 then
					core:AddTrusted(name)
				end
			end
			core:TriggerEvent("PARTY_MEMBERS_CHANGED")
		end
	end

	local remove = LibStub("PhanxConfig-Dropdown").CreateDropdown(panel, L["Remove Name"], nil, L["Remove a name from your trusted list."])
	remove:SetPoint("TOPLEFT", add, "BOTTOMLEFT", 0, -16)
	remove:SetPoint("TOPRIGHT", add, "BOTTOMRIGHT", 0, -16)
	do
		local info, temp = {}, {}
		local sortNames = function(a, b)
			if a == myName then
				return false
			elseif b == myName then
				return true
			end
			return a < b
		end
		local OnClick = function(self)
			core:RemoveTrusted(self.value)
		end
		UIDropDownMenu_Initialize(remove.dropdown, function()
			for name in pairs(core.trusted) do
				temp[#temp + 1] = name
			end
			sort(temp, sortNames)
			for i = 1, #temp do
				local name = temp[i]
				info.text  = name
				info.value = name
				info.func  = OnClick
				info.notCheckable = 1
				info.disabled = name == myName
				UIDropDownMenu_AddButton(info)
			end
			wipe(temp)
		end)
	end

	local removeAll = LibStub("PhanxConfig-Button").CreateButton(panel, L["Remove All"], L["Remove all names from your trusted list for this server."])
	removeAll:SetPoint("BOTTOMLEFT", remove, "BOTTOMRIGHT", 20, 1)
	removeAll.OnClick = function(self)
		for name in pairs(core.trusted) do
			core:RemoveTrusted(name)
		end
	end

	local help = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	help:SetPoint("BOTTOMLEFT", 16, 16)
	help:SetPoint("BOTTOMRIGHT", -16, 16)
	help:SetHeight(112)
	help:SetJustifyH("LEFT")
	help:SetJustifyV("BOTTOM")
	help:SetText(L.HELP_TRUST)

	function panel:refresh()
		local buttonWidth = max(addParty:GetTextWidth(), removeAll:GetTextWidth()) + 48
		addParty:SetSize(buttonWidth, 26)
		removeAll:SetSize(buttonWidth, 26)
	end
end