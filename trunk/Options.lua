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

tinsert(panels, LibStub("LibAboutPanel").new(HYDRA, HYDRA))

------------------------------------------------------------------------

tinsert(panels, OptionsPanel:New(L.Debug, HYDRA, function(self)
	local title, notes = LibStub("PhanxConfig-Header"):New(self, L.Debug, L.Debug_Info)

	local CreateCheckbox = LibStub("PhanxConfig-Checkbox").CreateCheckbox

	local boxes = {}
	local function change(this, value)
		local name = this.module
		local module = core.modules[name]
		core.db.debug[name] = value
	end

	local corebox = CreateCheckbox(self, L.DebugCore)
	corebox:SetPoint("TOPLEFT", notes, "BOTTOMLEFT", 0, -12)
	corebox.module = HYDRA
	corebox.OnValueChanged = change
	tinsert(boxes, corebox)

	local breakpoint = floor((#names + 1) / 2) + 1
	for i = 1, #names do
		local name = names[i]
		local box = CreateCheckbox(self, L[name] or name)
		if i == breakpoint then
			box:SetPoint("TOPLEFT", notes, "BOTTOM", 0, -12)
		else
			box:SetPoint("TOPLEFT", boxes[i], "BOTTOMLEFT", 0, -8) -- i, not i-1, because [1] = corebox
		end
		box.module = name
		box.OnValueChanged = change
		tinsert(boxes, box)
	end

	self.refresh = function()
		for i = 1, #boxes do
			local box = boxes[i]
			box:SetChecked(core.db.debug[box.module])
		end
	end
end))

------------------------------------------------------------------------

SLASH_HYDRA1 = "/hydra"
SlashCmdList.HYDRA = function()
	InterfaceOptionsFrame_OpenToCategory(panels[#panels])
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