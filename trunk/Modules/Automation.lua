--[[--------------------------------------------------------------------
	Hydra
	Multibox leveling helper.
	Copyright (c) 2010-2013 Phanx <addons@phanx.net>. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info17572-Hydra.html
	http://www.curse.com/addons/wow/hydra
------------------------------------------------------------------------
	Hydra Automation
	* Declines arena team invitations and charters
	* Declines duel requests
	* Declines guild invitations and charters
	* Accepts summons
	* Accepts non-combat resurrections
	* Repairs equipment
	* Sells junk
----------------------------------------------------------------------]]

local _, core = ...

local L = core.L

local module = core:RegisterModule("Automation", CreateFrame("Frame"))
module:SetScript("OnEvent", function(f, e, ...) return f[e] and f[e](f, ...) end)

module.defaults = {
	acceptResurrections = true,
	acceptResurrectionsInCombat = true,
	acceptSummons = true,
	declineArenaTeams = true,
	declineDuels = true,
	repairEquipment = true,
	repairWithGuildFunds = false,
	sellJunk = true,
}

------------------------------------------------------------------------

function module:CheckState()
	return true
end

function module:Enable()
	if self.db.declineArenaTeams then
		self:RegisterEvent("ARENA_TEAM_INVITE_REQUEST")
	end
	if self.db.acceptSummons then
		self:RegisterEvent("CONFIRM_SUMMON")
	end
	if self.db.declineDuels then
		self:RegisterEvent("DUEL_REQUESTED")
	end
	if self.db.repairEquipment or self.db.sellJunk then
		self:RegisterEvent("MERCHANT_SHOW")
	end
	if self.db.declineArenaTeams or GetAutoDeclineGuildInvites() == 1 then
		self:RegisterEvent("PETITION_SHOW")
	end
	if self.db.acceptResurrections then
		self:RegisterEvent("RESURRECT_REQUEST")
	end
end

function module:Disable()
	self:UnregisterAllEvents()
end

function module:Print(...)
	if self.db.verbose then
		core.Print(self, ...)
	end
end

------------------------------------------------------------------------

function module:PETITION_SHOW()
	local type, _, _, _, sender, mine = GetPetitionInfo()
	if not mine then
		if type == "arena" and self.db.declineArenaTeams then
			self:Print(L.DeclinedArenaPetition, sender)
			ClosePetition()
		elseif type == "guild" and GetAutoDeclineGuildInvites() == 1 then -- #TODO: check if this is needed
			self:Print(L.DeclinedGuildPetition, sender)
			ClosePetition()
		end
	end
end

function module:ARENA_TEAM_INVITE_REQUEST(sender)
	self:Print(L.DeclinedArena, sender)
	DeclineArenaTeam()
	StaticPopup_Hide("ARENA_TEAM_INVITE")
end

function module:DUEL_REQUESTED(sender)
	self:Print(L.DeclinedDuel, sender)
	CancelDuel()
	StaticPopup_Hide("DUEL_REQUESTED")
end

------------------------------------------------------------------------

local function formatMoney(value)
	-- coin icons with _AMOUNT_TEXTURE
	if value >= 10000 then
		return format("|cffffd700%d|r%s |cffc7c7cf%d|r%s %d%s", abs(value / 10000), GOLD_AMOUNT_SYMBOL, abs(mod(value / 100, 100)), SILVER_AMOUNT_SYMBOL, abs(mod(value, 100)), COPPER_AMOUNT_SYMBOL)
	elseif value >= 100 then
		return format("|cffc7c7cf%d|r%s %d%s", abs(mod(value / 100, 100)), SILVER_AMOUNT_SYMBOL, abs(mod(value, 100)), COPPER_AMOUNT_SYMBOL)
	else
		return format("%d%s", abs(mod(value, 100)), COPPER_AMOUNT_SYMBOL)
	end
end

function module:MERCHANT_SHOW()
	if IsShiftKeyDown() then return end

	if self.db.sellJunk then
		local num, value = 0, 0
		for bag = 0, 4 do
			for slot = 0, GetContainerNumSlots(bag) do
				local link = GetContainerItemLink(bag, slot)
				if link then
					local _, _, q, _, _, _, _, _, _, _, v = GetItemInfo(link)
					if q == ITEM_QUALITY_POOR then
						local _, n = GetContainerItemInfo(bag, slot)
						num = num + n
						value = value + v
						UseContainerItem(bag, slot)
					end
				end
			end
		end
		if num > 0 then
			self:Print(L.SoldJunk, num, formatMoney(value))
		end
	end

	if self.db.repairEquipment then
		local cost = GetRepairAllCost()
		if cost > 0 then
			local money = GetMoney()
			local guildmoney = GetGuildBankWithdrawMoney()
			if guildmoney == -1 then
				guildmoney = GetGuildBankMoney()
			end

			if guildmoney >= cost and self.db.repairWithGuildFunds and IsInGuild() then
				RepairAllItems(1)
				self:Print(L.RepairedGuild, formatMoney(cost))
			elseif self.db.repairWithGuildFunds and IsInGuild() then
				self:Print(L.NoRepairMoneyGuild)
			elseif money > cost then
				RepairAllItems()
				self:Print(L.Repaired, formatMoney(cost))
			else
				self:Print(L.NoRepairMoney)
			end
		end
	end
end

------------------------------------------------------------------------

function module:RESURRECT_REQUEST(sender) -- #TODO: Check if sender includes the server name for cross-realm players
	local _, class = UnitClass(sender)
	if class and class ~= "DRUID" or self.db.acceptResurrectionsInCombat or not UnitAffectingCombat(sender) then
		self:Print(L.AcceptedRes, sender)
		AcceptResurrect()
		StaticPopup_Hide("RESURRECT_NO_SICKNESS")
	end
end

------------------------------------------------------------------------

function module:PLAYER_REGEN_ENABLED()
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	self:CONFIRM_SUMMON()
end

function module:CONFIRM_SUMMON() -- #TODO: Check if sender includes the server name for cross-realm players
	local sender, location = GetSummonConfirmSummoner(), GetSummonConfirmAreaName()
	if sender and location and core:IsTrusted(sender) then
		if UnitAffectingCombat("player") or not PlayerCanTeleport() then
			self:Print(L.AcceptedSummonCombat)
			self:RegisterEvent("PLAYER_REGEN_ENABLED")
		elseif GetSummonConfirmTimeLeft() > 0 then
			self:Print(L.AcceptedSummon, sender, location)
			ConfirmSummon()
			StaticPopup_Hide("CONFIRM_SUMMON")
		else
			self:Print(L.SummonExpired)
		end
	end
end

------------------------------------------------------------------------

module.displayName = L.Automation
function module:SetupOptions(panel)
	local title, notes = LibStub("PhanxConfig-Header").CreateHeader(panel, L.Automation, L.Automation_Info)

	panel.CreateCheckbox = LibStub("PhanxConfig-Checkbox").CreateCheckbox

	local function OnValuechanged(self, value)
		module.db[self.key] = value
		if self.child then
			self.child:SetEnabled(value)
		end
		if self.key ~= "verbose" then
			module:Refresh()
		end
	end

	local declineDuels = panel:CreateCheckbox(L.DeclineDuels, L.DeclineDuels_Info)
	declineDuels:SetPoint("TOPLEFT", notes, "BOTTOMLEFT", 0, -12)
	declineDuels.OnValueChanged = OnValueChanged
	declineDuels.key = "declineDuels"

	local declineGuilds = panel:CreateCheckbox(L.DeclineGuilds, L.DeclineGuilds_Info)
	declineGuilds:SetPoint("TOPLEFT", declineDuels, "BOTTOMLEFT", 0, -8)
	function declineGuilds:OnValueChanged(self, value)
		SetAutoDeclineGuildInvites(value and 1 or 0)
	end

	local declineArenaTeams = panel:CreateCheckbox(L.DeclineArenas, L.DeclineArenas_Info)
	declineArenaTeams:SetPoint("TOPLEFT", declineGuilds, "BOTTOMLEFT", 0, -8)
	declineArenaTeams.OnValueChanged = OnValueChanged
	declineArenaTeams.key = "declineArenaTeams"

	local acceptSummons = panel:CreateCheckbox(L.AcceptSummons, L.AcceptSummons_Info)
	acceptSummons:SetPoint("TOPLEFT", declineArenaTeams, "BOTTOMLEFT", 0, -8)
	acceptSummons.OnValueChanged = OnValueChanged
	acceptSummons.key = "acceptSummons"

	local acceptResurrections = panel:CreateCheckbox(L.AcceptRes, L.AcceptRes_Info)
	acceptResurrections:SetPoint("TOPLEFT", acceptSummons, "BOTTOMLEFT", 0, -8)
	acceptResurrections.OnValueChanged = OnValueChanged
	acceptResurrections.key = "acceptResurrections"

	local acceptResurrectionsInCombat = panel:CreateCheckbox(L.AcceptCombatRes, L.AcceptCombatRes_Info)
	acceptResurrectionsInCombat:SetPoint("TOPLEFT", acceptResurrections, "BOTTOMLEFT", 0, -8)
	acceptResurrectionsInCombat.OnValueChanged = OnValueChanged
	acceptResurrectionsInCombat.key = "acceptResurrectionsInCombat"

	local repairEquipment = panel:CreateCheckbox(L.Repair, L.Repair_Info)
	repairEquipment:SetPoint("TOPLEFT", acceptResurrectionsInCombat, "BOTTOMLEFT", 0, -8)
	repairEquipment.OnValueChanged = OnValueChanged
	repairEquipment.key = "repairEquipment"

	local repairWithGuildFunds = panel:CreateCheckbox(L.RepairGuild, L.RepairGuild_Info)
	repairWithGuildFunds:SetPoint("TOPLEFT", repairEquipment, "BOTTOMLEFT", 24, -8)
	repairWithGuildFunds.OnValueChanged = OnValueChanged
	repairWithGuildFunds.key = "repairWithGuildFunds"

	repairEquipment.child = repairWithGuildFunds

	local sellJunk = panel:CreateCheckbox(L.SellJunk, L.SellJunk_Info)
	sellJunk:SetPoint("TOPLEFT", repairWithGuildFunds, "BOTTOMLEFT", -24, -8)
	sellJunk.OnValueChanged = OnValueChanged
	sellJunk.key = "sellJunk"

	local verbose = panel:CreateCheckbox(L.Verbose, L.Verbose_Info)
	verbose:SetPoint("TOPLEFT", sellJunk, "BOTTOMLEFT", 0, -24)
	verbose.OnValueChanged = OnValueChanged
	verbose.key = "verbose"

	local help = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	help:SetPoint("BOTTOMLEFT", 16, 16)
	help:SetPoint("BOTTOMRIGHT", -16, 16)
	help:SetHeight(112)
	help:SetJustifyH("LEFT")
	help:SetJustifyV("BOTTOM")
	help:SetText(L.AutomationHelpText)

	function panel:refresh()
		declineDuels:SetChecked(module.db.declineDuels)
		declineArenaTeams:SetChecked(module.db.declineArenaTeams)
		declineGuilds:SetChecked(GetAutoDeclineGuildInvites() == 1)
		acceptSummons:SetChecked(module.db.acceptSummons)
		acceptResurrections:SetChecked(module.db.acceptResurrections)
		acceptResurrectionsInCombat:SetChecked(module.db.acceptResurrectionsInCombat)
		repairEquipment:SetChecked(module.db.repairEquipment)
		repairWithGuildFunds:SetChecked(module.db.repairWithGuildFunds)
		repairWithGuildFunds:SetEnabled(module.db.repairEquipment)
		sellJunk:SetChecked(module.db.sellJunk)
		verbose:SetChecked(module.db.verbose)
	end
end