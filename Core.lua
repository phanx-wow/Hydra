--[[--------------------------------------------------------------------
	Hydra
	Multibox leveling helper.
	Copyright (c) 2010-2014 Phanx <addons@phanx.net>. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info17572-Hydra.html
	http://www.curse.com/addons/wow/hydra
----------------------------------------------------------------------]]

local HYDRA, core = ...
core.name = HYDRA
core.modules = {}

local L = setmetatable(core.L or {}, { __index = function(t, k)
	if k == nil then return "" end
	local v = tostring(k)
	rawset(t, k, v)
	return v
end })
core.L = L

BINDING_HEADER_HYDRA = GetAddOnMetadata(HYDRA, "Title")

------------------------------------------------------------------------

local SOLO, INSECURE, SECURE, LEADER = 0, 1, 2, 3
core.STATE_SOLO, core.STATE_PARTY, core.STATE_TRUSTED, core.STATE_LEADER = SOLO, INSECURE, SECURE, LEADER

local PLAYER, REALM = UnitName("player"), gsub(GetRealmName(), "%s+", "")
local FULLNAME = format("%s-%s", PLAYER, REALM)
core.PLAYER_NAME, core.REALM_NAME, core.PLAYER_FULLNAME = PLAYER, REALM, FULLNAME

local REALM_S = "%-" .. REALM .. "$"

------------------------------------------------------------------------

function core:Debug(str, ...)
	if not str or not core.db.debug[self.name] then return end
	if strmatch(str, "%%[dsx%d%.]") then
		print("|cffff9999Hydra:|r", format(str, ...))
	else
		print("|cffff9999Hydra:|r", str, ...)
	end
end

function core:Print(str, ...)
	if strmatch(str, "%%[dsx%d%.]") then
		print("|cffffcc00Hydra:|r", format(str, ...))
	else
		print("|cffffcc00Hydra:|r", str, ...)
	end
end

function core:Alert(message, flash, r, g, b)
	UIErrorsFrame:AddMessage(message, r or 1, g or 1, b or 0, 1, UIERRORS_HOLD_TIME)
end

function core:SendAddonMessage(message, target)
	if not message then
		return
	end
	if target then
		self:Debug("SendAddonMessage", self.name, message, "WHISPER", target)
		return SendAddonMessage("Hydra", self.name .. " " .. message, "WHISPER", target)
	end
	local channel = IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and "INSTANCE_CHAT" or IsInRaid() and "RAID" or IsInGroup() and "PARTY"
	if channel then
		self:Debug("SendAddonMessage", self.name, message, channel)
		return SendAddonMessage("Hydra", self.name .. " " .. message, channel)
	end
end

function core:SendChatMessage(message, target)
	if not message then
		return
	end
	if target then
		return SendChatMessage(message, "WHISPER", nil, target)
	end
	local channel = IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and "INSTANCE_CHAT" or IsInRaid() and "RAID" or IsInGroup() and "PARTY"
	if channel then
		return SendChatMessage(message, channel)
	end
end

------------------------------------------------------------------------

local function Capitalize(str, firstOnly)
	local a = strsub(str, 1, 1)
	local b = strsub(str, 2)
	local firstByte = strbyte(a)
	if firstByte >= 192 and firstByte <= 223 then
		a = strsub(str, 1, 2)
		b = strsub(str, 3)
	elseif firstByte >= 224 and firstByte <= 239 then
		a = strsub(str, 1, 3)
		b = strsub(str, 4)
	elseif firstByte >= 240 and firstByte <= 244 then
		a = strsub(str, 1, 4)
		b = strsub(str, 5)
	end
	return strupper(a)..(firstOnly and b or strlower(b))
end

function core:ValidateName(name, realm)
	--assert(type(name) == "string" and strlen(name) >= 2, "Invalid name!")
	name = name and strtrim(name)
	realm = realm and strtrim(realm)
	if not name or strlen(name) == 0 then
		return
	end
	if strmatch(name, "%-") then
		name, realm = strsplit("-", name, 2)
	end
	--name = Capitalize(name)
	if realm and strlen(realm) > 0 then
		realm = gsub(realm, "%s+", "") -- Capitalize(gsub(realm, "%s+", ""))
		self:Debug("ValidateName", name, realm, format("%s-%s", name, realm))
		return format("%s-%s", name, realm), name
	else
		self:Debug("ValidateName", name, REALM, format("%s-%s", name, REALM))
		return format("%s-%s", name, REALM), name
	end
end

function core:IsTrusted(name, realm)
	if name == FULLNAME or (name == PLAYER and realm == REALM) then
		return PLAYER
	end
	local name, displayName = self:ValidateName(name, realm)
	if not name then return end
	local trusted = self.trusted[name]
	self:Debug("IsTrusted", name, not not trusted)
	return trusted and displayName
end

function core:AddTrusted(name, realm, silent)
	local name, displayName = self:ValidateName(name, realm)
	self:Debug("AddTrusted", name)
	if not name or self.trusted[name] then return end
	self.trusted[name] = true
	if not silent then
		self:Print(L.AddedTrusted, displayName)
	end
	self:TriggerEvent("GROUP_ROSTER_UPDATE")
end

function core:RemoveTrusted(name, realm, skipValidation)
	local displayName = name
	--if not skipValidation then
		name, displayName = self:ValidateName(name, realm)
	--end
	if not name or not self.trusted[name] then return end
	self.trusted[name] = nil
	self:Print(L.RemovedTrusted, displayName)
	self:TriggerEvent("GROUP_ROSTER_UPDATE")
end

------------------------------------------------------------------------

local modulePrototype = {
	Alert = core.Alert,
	Debug = core.Debug,
	Print = core.Print,
	SendAddonMessage = core.SendAddonMessage,
	SendChatMessage = core.SendChatMessage,
	IsEnabled = function(self)
		return self.enabled
	end,
	Enable = function(self, silent)
		if not silent then
			core:Debug("Enabling module:", self.name)
		end
		self.enabled = true
		if self.OnEnable then
			self:OnEnable()
		end
	end,
	Disable = function(self, silent)
		if not silent then
			core:Debug("Disabling module:", self.name)
		end
		self.enabled = nil
		self:UnregisterAllEvents()
		if self.OnDisable then
			self:OnDisable()
		end
	end,
	Refresh = function(self)
		local enable = self:ShouldEnable()
		core:Debug("Refreshing module:", self.name, enable)
		self:Disable(true)
		if enable then
			self:Enable(true)
		end
	end,
	ShouldEnable = function(self)
		-- most modules should overwrite this
		return true
	end,
}

function core:NewModule(name)
	assert(type(name) == "string", "Module name must be a string!")
	assert(not self.modules[name], "Module " .. name .. " is already registered!")

	local module = CreateFrame("Frame")
	module:SetScript("OnEvent", function(self, event, ...)
		return self[event] and self[event](self, ...)
	end)
	for k, v in pairs(modulePrototype) do
		module[k] = v
	end

	module.name = name
	self.modules[name] = module
	return module
end

function core:GetModule(name)
	local module = self.modules[name]
	assert(module, "Module " .. name .. " is not registered!")
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
f:SetScript("OnEvent", function(self, event, ...) return self[event] and self[event](self, ...) end)
f:RegisterEvent("PLAYER_LOGIN")

function f:PLAYER_LOGIN()
	f:UnregisterEvent("PLAYER_LOGIN")

	HydraTrustList = HydraTrustList or {}
	HydraTrustList[format("%s-%s", PLAYER, REALM)] = true
	core.trusted = HydraTrustList

	HydraSettings = copyTable({ debug = {} }, HydraSettings)
	core.db = HydraSettings

	core:Debug("Loading...")

	for name, module in pairs(core.modules) do
		if module.defaults then
			core:Debug("Initializing settings for module", name)
			module.db = copyTable(module.defaults, core.db[name])
			--for k, v in pairs(module.db) do core:Debug(k, "=", v) end
		else
			core:Debug("No defaults for module", name)
			module.db = core.db[name]
		end
		module.db.debug = nil -- TEMP
		if next(module.db) then
			core.db[name] = module.db
		else
			module.db = nil -- remove empty
			core.db[name] = nil
		end
	end

	RegisterAddonMessagePrefix("Hydra")
	f:RegisterEvent("CHAT_MSG_ADDON")
	f:RegisterEvent("GROUP_ROSTER_UPDATE")
	f:RegisterEvent("PARTY_LEADER_CHANGED")
	f:RegisterEvent("PARTY_LOOT_METHOD_CHANGED")
	f:RegisterEvent("UNIT_NAME_UPDATE")

	f:CheckParty()
end

------------------------------------------------------------------------

function f:CHAT_MSG_ADDON(prefix, message, channel, sender)
	if sender == FULLNAME or prefix ~= "Hydra" then return end
	prefix, message = strsplit(" ", message, 2)
	local module = core.modules[prefix]
	if not module or not module.enabled or not module.ReceiveAddonMessage then end
	module:ReceiveAddonMessage(message, channel, sender)
end

------------------------------------------------------------------------

local groupUnits = {}
for i = 1, 4 do groupUnits["party"..i] = true end
for i = 1, 40 do groupUnits["raid"..i] = true end

function f:CheckParty(unit)
	if unit and not groupUnits[unit] then return end -- irrelevant UNIT_NAME_UPDATE

	local newstate = SOLO
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

	core:Debug("Party changed:", core.state, "->", newstate)

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
			local enable = module:ShouldEnable()
			if enable ~= module.enabled then
				if enable then
					module:Enable()
				else
					module:Disable()
				end
			end
		end
	end
end

f.GROUP_ROSTER_UPDATE = f.CheckParty
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
	local title, notes = LibStub("PhanxConfig-Header").CreateHeader(panel, panel.name, L.Hydra_Info)
	notes:SetHeight(notes:GetHeight() * 1.5)

	local addName = LibStub("PhanxConfig-EditBox").CreateEditBox(panel, L.AddName, L.AddName_Info, 12)
	addName:SetPoint("TOPLEFT", notes, "BOTTOMLEFT", 0, -12)
	addName:SetPoint("TOPRIGHT", notes, "BOTTOM", -8, -12)
	function addName:OnValueChanged(name)
		name = strtrim(name)
		if strlen(name) > 2 then
			core:AddTrusted(name)
		end
		self:SetText("")
	end

	local addGroup = LibStub("PhanxConfig-Button").CreateButton(panel, L.AddGroup, L.AddGroup_Info)
	addGroup:SetPoint("BOTTOMLEFT", addName, "BOTTOMRIGHT", 20, 8)
	function addGroup:OnClick()
		local unit = IsInRaid() and "raid" or "party"
		for i = 1, GetNumGroupMembers() do
			core:AddTrusted(UnitName(unit..i))
		end
		core:TriggerEvent("GROUP_ROSTER_UPDATE")
	end

	local removeName = LibStub("PhanxConfig-Dropdown").CreateDropdown(panel, L.RemoveName, L.RemoveName_Info)
	removeName:SetPoint("TOPLEFT", addName, "BOTTOMLEFT", 0, -16)
	removeName:SetPoint("TOPRIGHT", addName, "BOTTOMRIGHT", 0, -16)
	do
		local info, temp = {}, {}
		local sortNames = function(a, b)
			if a == PLAYER then
				return false
			elseif b == PLAYER then
				return true
			end
			return a < b
		end
		local OnClick = function(self)
			core:RemoveTrusted(self.value, nil, true)
		end
		UIDropDownMenu_Initialize(removeName.dropdown, function()
			for name in pairs(core.trusted) do
				name = gsub(name, REALM_S, "")
				temp[#temp + 1] = name
			end
			sort(temp, sortNames)
			for i = 1, #temp do
				local name = temp[i]
				info.text  = name
				info.value = name
				info.func  = OnClick
				info.notCheckable = 1
				info.disabled = name == PLAYER
				UIDropDownMenu_AddButton(info)
			end
			wipe(temp)
		end)
	end

	local removeAll = LibStub("PhanxConfig-Button").CreateButton(panel, L.RemoveAll, L.RemoveAll_Info)
	removeAll:SetPoint("BOTTOMLEFT", removeName, "BOTTOMRIGHT", 20, 1)
	removeAll.OnClick = function(self)
		for name in pairs(core.trusted) do
			if gsub(name, REALM_S, "") ~= PLAYER then
				core:RemoveTrusted(name, nil, true)
			end
		end
	end

	local help = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	help:SetPoint("BOTTOMLEFT", 16, 16)
	help:SetPoint("BOTTOMRIGHT", -16, 16)
	help:SetHeight(112)
	help:SetJustifyH("LEFT")
	help:SetJustifyV("BOTTOM")
	help:SetText(L.CoreHelpText)

	function panel:refresh()
		local buttonWidth = max(addGroup:GetTextWidth(), removeAll:GetTextWidth()) + 48
		addGroup:SetSize(buttonWidth, 26)
		removeAll:SetSize(buttonWidth, 26)
	end
end