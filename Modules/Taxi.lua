--[[--------------------------------------------------------------------
	Hydra
	Multibox leveling helper.
	Copyright (c) 2010-2014 Phanx <addons@phanx.net>. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info17572-Hydra.html
	http://www.curse.com/addons/wow/hydra
------------------------------------------------------------------------
	Hydra Taxi
	* Autoselect the last taxi node selected by anyone in the party
----------------------------------------------------------------------]]

local _, core = ...
local L = core.L
local SOLO, PARTY, TRUSTED, LEADER = core.STATE_SOLO, core.STATE_PARTY, core.STATE_TRUSTED, core.STATE_LEADER

local module = core:NewModule("Taxi")
module.defaults = {
	enable = true,
	timeout = 60,
}

local MESSAGE_UNKNOWN, MESSAGE_TIMEOUT = "UNKNOWN", "TIMEOUT"
local taxiTime, taxiName = 0

------------------------------------------------------------------------

function module:ShouldEnable()
	return core.state > SOLO and self.db.enable
end

function module:OnEnable()
	self:RegisterEvent("TAXIMAP_OPENED")
end

function module:OnDisable()
	taxiTime, taxiName = 0, nil
end

------------------------------------------------------------------------

function module:OnAddonMessage(message, channel, sender)
	if not core:IsTrusted(sender) then return end
	self:Debug("Comm received from", sender, "->", message)

	if message == MESSAGE_TIMEOUT then
		return core:Print("ERROR:", format(L.TaxiTimeoutError, sender))
	elseif message == MESSAGE_UNKNOWN then
		return core:Print("ERROR:", format(L.TaxiMismatchError, sender)) -- #TODO: update message text
	else
		core:Print(L.TaxiSet, sender, message)
		taxiName, taxiTime = message, GetTime()
	end
end

function module:TAXIMAP_OPENED()
	if not taxiName or taxiName == "INVALID" then return end -- we're picking the taxi
	if IsShiftKeyDown() then return end -- we're doing something else

	if GetTime() - taxiTime > self.db.timeout then
		taxiTime, taxiName = 0, nil
		return self:SendAddonMessage(MESSAGE_TIMEOUT)
	end

	for i = 1, NumTaxiNodes() do
		if TaxiNodeName(i) == taxiName then
			if IsMounted() then Dismount() end -- #TODO: druids unshift?
			TakeTaxiNode(i)
			taxiTime, taxiName = 0, nil
			return
		end
	end

	taxiTime, taxiName = 0, nil
	return self:SendAddonMessage(MESSAGE_UNKNOWN)
end

------------------------------------------------------------------------

hooksecurefunc("TakeTaxiNode", function(i)
	if taxiName then return end -- we're following someone
	if IsShiftKeyDown() then return end -- we're doing something else
	local name = TaxiNodeName(i)
	module:Debug("Broadcasting taxi node", i, name)
	module:SendAddonMessage(name)
end)

------------------------------------------------------------------------

SLASH_HYDRA_CLEARTAXI1 = "/cleartaxi"

if L.SlashClearTaxi ~= SLASH_HYDRA_CLEARTAXI1 then
	SLASH_HYDRA_CLEARTAXI2 = L.SlashClearTaxi
end

function SlashCmdList.HYDRA_CLEARTAXI()
	if taxiName then
		taxiTime, taxiName = 0, nil
		module:Print(L.TaxiCleared)
	end
end

------------------------------------------------------------------------

module.displayName = L.Taxi
function module:SetupOptions(panel)
	local title, notes = panel:CreateHeader(L.Taxi, L.Taxi_Info)

	local enable = panel:CreateCheckbox(L.Enable, L.Enable_Info)
	enable:SetPoint("TOPLEFT", notes, "BOTTOMLEFT", 0, -12)
	function enable.Callback(this, value)
		self.db.enable = value
		self:Refresh()
	end

	local timeout = panel:CreateSlider(L.Timeout, L.TaxiTimeout_Info, 30, 600, 30)
	timeout:SetPoint("TOPLEFT", enable, "BOTTOMLEFT", 0, -16)
	timeout:SetPoint("TOPRIGHT", notes, "BOTTOM", -8, -28 - enable:GetHeight())
	function timeout.Callback(this, value)
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