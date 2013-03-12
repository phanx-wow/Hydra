--[[--------------------------------------------------------------------
	Hydra
	Multibox leveling helper.
	Copyright (c) 2010-2013 Phanx <addons@phanx.net>. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info17572-Hydra.html
	http://www.curse.com/addons/wow/hydra
------------------------------------------------------------------------
	Hydra Taxi
	* Autoselect the last taxi node selected by anyone in the party
----------------------------------------------------------------------]]

local _, core = ...

local L = core.L

local SOLO, PARTY, TRUSTED, LEADER = 0, 1, 2, 3
local playerName = UnitName("player")

local taxiTime, taxiNode, taxiNodeName = 0

local module = core:RegisterModule("Taxi", CreateFrame("Frame"))
module:SetScript("OnEvent", function(f, e, ...) return f[e] and f[e](f, ...) end)

module.defaults = { enable = true, timeout = 60 }

------------------------------------------------------------------------

function module:CheckState()
	if core.state == SOLO or not self.db.enable then
		self:Debug("Disable module: Taxi")
		self:UnregisterAllEvents()
	else
		self:Debug("Enable module: Taxi")
		self:RegisterEvent("CHAT_MSG_ADDON")
		self:RegisterEvent("TAXIMAP_OPENED")
		if not IsAddonMessagePrefixRegistered("HydraTaxi") then
			RegisterAddonMessagePrefix("HydraTaxi")
		end
	end
	taxiNode, taxiNodeName, taxiTime = nil, nil, 0
end

------------------------------------------------------------------------

function module:CHAT_MSG_ADDON(prefix, message, channel, sender)
	if prefix ~= "HydraTaxi" or sender == playerName or not core:IsTrusted(sender) then return end
	self:Debug("Comm received from", sender, "->", message)

	if message == "TIMEOUT" then
		return core:Print("ERROR: " .. L.TaxiTimeoutError, sender)
	elseif message == "MISMATCH" then
		return core:Print("ERROR: " . L.TaxiMismatchError, sender)
	end

	local node, nodeName = strmatch(strtrim(message), "^(%d+) (.+)$")
	if node and nodeName then
		core:Print(L.TaxiSet, sender, nodeName)
		taxiNode, taxiNodeName, taxiTime = node, nodeName, GetTime()
	end
end

function module:TAXIMAP_OPENED()
	if not taxiNode or taxiNode == "INVALID" then return end -- we're picking the taxi
	if IsShiftKeyDown() then return end -- we're doing something else

	if GetTime() - taxiTime > self.db.timeout then
		taxiNode, taxiNodeName, taxiTime = nil, nil, 0
		return self:SendAddonMessage("HydraTaxi", "TIMEOUT")
	end

	if TaxiNodeName(taxiNode) ~= taxiNodeName then
		local found
		for i = 1, NumTaxiNodes() do
			if TaxiNodeName(i) == taxiNodeName then
				taxiNode = i
				found = true
			end
		end
		if not found then
			taxiNode, taxiNodeName, taxiTime = nil, nil, 0
			return self:SendAddonMessage("HydraTaxi", "MISMATCH")
		end
	end

	if IsMounted() then Dismount() end -- #TODO: druids unshift?
	TakeTaxiNode(taxiNode)
	taxiNode, taxiNodeName, taxiTime = nil, nil, 0
end

------------------------------------------------------------------------

hooksecurefunc("TakeTaxiNode", function(i)
	if taxiNode then return end -- we're following someone
	if IsShiftKeyDown() then return end -- we're doing something else
	local name = TaxiNodeName(i)
	module:Debug("Broadcasting taxi node", i, name)
	module:SendAddonMessage("HydraTaxi", i .. " " .. name)
end)

------------------------------------------------------------------------

SLASH_HYDRA_CLEARTAXI1 = "/cleartaxi"

if L.SlashClearTaxi ~= SLASH_HYDRA_CLEARTAXI1 then
	SLASH_HYDRA_CLEARTAXI2 = L.SlashClearTaxi
end

function SlashCmdList.HYDRA_CLEARTAXI()
	if taxiNode then
		taxiTime, taxiNode, taxiNodeName = 0, nil, nil
		module:Print(L.TaxiCleared)
	end
end

------------------------------------------------------------------------

module.displayName = L.Taxi
function module:SetupOptions(panel)
	local title, notes = LibStub("PhanxConfig-Header").CreateHeader(panel, L.Taxi, L.Taxi_Info)

	local enable = LibStub("PhanxConfig-Checkbox").CreateCheckbox(panel, L.Enable, L.Enable_info)
	enable:SetPoint("TOPLEFT", notes, "BOTTOMLEFT", 0, -12)
	enable.OnClick = function(_, checked)
		self.db.enable = checked
		self:CheckState()
	end

	local timeout = LibStub("PhanxConfig-Slider").CreateSlider(panel, L.Timeout, L.TaxiTimeout_Info, 30, 600, 30)
	timeout:SetPoint("TOPLEFT", enable, "BOTTOMLEFT", 0, -16)
	timeout:SetPoint("TOPRIGHT", notes, "BOTTOM", -8, -28 - enable:GetHeight())
	timeout.OnValueChanged = function(_, value)
		value = floor((value + 1) / 30) * 30
		self.db.timeout = value
		return value
	end

	local help = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	help:SetPoint("BOTTOMLEFT", 16, 16)
	help:SetPoint("BOTTOMRIGHT", -16, 16)
	help:SetHeight(112)
	help:SetJustifyH("LEFT")
	help:SetJustifyV("BOTTOM")
	help:SetText(L.TaxiHelpText)

	panel.refresh = function()
		enable:SetChecked(self.db.enable)
		timeout:SetValue(self.db.timeout)
	end
end