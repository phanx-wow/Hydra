--[[--------------------------------------------------------------------
	Hydra
	Multibox leveling helper.
	Copyright (c) 2010-2012 Phanx <addons@phanx.net>. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info17572-Hydra.html
	http://www.curse.com/addons/wow/hydra
----------------------------------------------------------------------]]

local HYDRA, core = ...

local L = core.L
local panels = {}
local noop = function() end
local CreateOptionsPanel = LibStub("PhanxConfig-OptionsPanel").CreateOptionsPanel

------------------------------------------------------------------------

if core.SetupOptions then
	panels[#panels + 1] = CreateOptionsPanel(HYDRA, nil, function(self)
		core:SetupOptions(self)
		core.SetupOptions = noop
	end)
end

------------------------------------------------------------------------

local names = {}

for name in pairs(core.modules) do
	names[#names + 1] = name
end
table.sort(names)

for i = 1, #names do
	local name = names[i]
	local module = core.modules[name]
	if module.SetupOptions then
		panels[#panels + 1] = CreateOptionsPanel(module.name, HYDRA, function(self)
			module:SetupOptions(self)
			module.SetupOptions = noop
		end)
	end
end

------------------------------------------------------------------------

panels[ #panels + 1 ] = LibStub("LibAboutPanel").new(HYDRA, HYDRA)

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
			tooltip:AddLine(L["Click for options."])
			tooltip:Show()
		end,
	})
end