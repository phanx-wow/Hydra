--[[--------------------------------------------------------------------
	Hydra
	Multibox leveling helper.
	Copyright (c) 2010-2013 Phanx <addons@phanx.net>. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info17572-Hydra.html
	http://www.curse.com/addons/wow/hydra
----------------------------------------------------------------------]]

local HYDRA, core = ...

local L = core.L
local panels = {}
local noop = function() end
local OptionsPanel = LibStub("PhanxConfig-OptionsPanel")

------------------------------------------------------------------------

panels[1] = OptionsPanel:New(HYDRA, nil, function(self)
	core:SetupOptions(self)
	core.SetupOptions = noop
	core.OptionsPanel = self
end)

------------------------------------------------------------------------

local names = {}

for name in pairs(core.modules) do
	tinsert(names, name)
end
sort(names)

for i = 1, #names do
	local name = names[i]
	local module = core.modules[name]
	if module.SetupOptions then
		panels[#panels + 1] = OptionsPanel:New(module.displayName or module.name, HYDRA, function(self)
			module:SetupOptions(self)
			module.SetupOptions = noop
			module.OptionsPanel = self
		end)
	end
end

------------------------------------------------------------------------

tinsert(panels, OptionsPanel:New(L.Debug, HYDRA, function(self)
	local title, notes = LibStub("PhanxConfig-Header"):New(self, L.Debug, L.Debug_Info)

	local CreateCheckbox = LibStub("PhanxConfig-Checkbox").CreateCheckbox

	local boxes = {}
	local function change(this, value)
		local name = this.name
		local module = core.modules[name]
		module.db.debug = value
	end

	local corebox = CreateCheckbox(self, L.DebugCore)
	corebox.module = core
	corebox.OnValueChanged = change
	tinsert(boxes, corebox)

	for i = 1, #modules do
		local name = modules[i]
		local box = CreateCheckbox(self, L[name])
		box:SetPoint("TOPLEFT", boxes[i-1], "BOTTOMLEFT", 0, -8)
		box.module = core.modules[name]
		box.OnValueChanged = change
		tinsert(boxes, box)
	end

	self.refresh = function()
		for i = 1, #boxes do
			box:SetChecked(box.module.db.debug)
		end
	end
end))

tinsert(panels, LibStub("LibAboutPanel").new(HYDRA, HYDRA))

------------------------------------------------------------------------

SLASH_HYDRA1 = "/hydra"
SlashCmdList.HYDRA = function()
	InterfaceOptionsFrame_OpenToCategory(panels[1])
end

------------------------------------------------------------------------

local LDB = LibStub("LibDataBroker-1.1", true)
if LDB then
	LDB:NewDataObject(HYDRA, {
		type = "launcher",
		icon = "Interface\\Icons\\Achievement_Boss_Bazil_Akumai",
		label = HYDRA,
		OnClick = SlashCmdList.HYDRA,
		OnTooltipShow = function(tooltip)
			tooltip:AddLine(HYDRA, 1, 1, 1)
			tooltip:AddLine(L.ClickForOptions)
			tooltip:Show()
		end,
	})
end