--[[--------------------------------------------------------------------
	Hydra
	Multibox leveling helper.
	Copyright (c) 2010-2012 Phanx <addons@phanx.net>. All rights reserved.
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
	declineGuilds = true,
	repairEquipment = true,
	repairWithGuildFunds = false,
	sellJunk = true,
}
--module.debug = true
------------------------------------------------------------------------

function module:CheckState()
	self:UnregisterAllEvents()

	self:Debug("Enable module: Automation")

	if self.db.declineArenaTeams then
		self:RegisterEvent("ARENA_TEAM_INVITE_REQUEST")
	end
	if self.db.acceptSummons then
		self:RegisterEvent("CONFIRM_SUMMON")
	end
	if self.db.declineDuels then
		self:RegisterEvent("DUEL_REQUESTED")
	end
	if self.db.declineGuilds then
		self:RegisterEvent("GUILD_INVITE_REQUEST")
	end
	if self.db.repairEquipment or self.db.sellJunk then
		self:RegisterEvent("MERCHANT_SHOW")
	end
	if self.db.declineArenaTeams or self.db.declineGuilds then
		self:RegisterEvent("PETITION_SHOW")
	end
	if self.db.acceptResurrections then
		self:RegisterEvent("RESURRECT_REQUEST")
	end
	self:RegisterEvent("TRAINER_SHOW")
end

function module:Print(...)
	if self.db.verbose then
		core:Print(...)
	end
end

------------------------------------------------------------------------

function module:PETITION_SHOW()
	local type, _, _, _, sender, mine = GetPetitionInfo()
	if not mine then
		if type == "arena" and self.db.declineArenaTeams then
			self:Print(L["Declined an arena team petition from %s."], sender)
			ClosePetition()
		elseif type == "guild" and self.db.declineGuilds then
			self:Print(L["Declined a guild petition from %s."], sender)
			ClosePetition()
		end
	end
end

function module:ARENA_TEAM_INVITE_REQUEST(sender)
	self:Print(L["Declined an arena team invitation from %s"], sender)
	DeclineArenaTeam()
	StaticPopup_Hide("ARENA_TEAM_INVITE")
end

function module:DUEL_REQUESTED(sender)
	self:Print(L["Declined a duel request from %s."], sender)
	CancelDuel()
	StaticPopup_Hide("DUEL_REQUESTED")
end

function module:GUILD_INVITE_REQUEST(sender)
	self:Print(L["Declined a guild invitation from %s."], sender)
	DeclineGuild()
	StaticPopup_Hide("GUILD_INVITE")
end

------------------------------------------------------------------------

local function formatMoney(value)
	-- coin icons with _AMOUNT_TEXTURE
	if value >= 10000 then
		return format("|cffffd700%d|r%s |cffc7c7cf%d|r%s |cffeda55f%d|r%s", abs(value / 10000), GOLD_AMOUNT_SYMBOL, abs(mod(value / 100, 100)), SILVER_AMOUNT_SYMBOL, abs(mod(value, 100)), COPPER_AMOUNT_SYMBOL)
	elseif value >= 100 then
		return format("|cffc7c7cf%d|r%s |cffeda55f%d|r%s", abs(mod(value / 100, 100)), SILVER_AMOUNT_SYMBOL, abs(mod(value, 100)), COPPER_AMOUNT_SYMBOL)
	else
		return format("|cffeda55f%d|r%s", abs(mod(value, 100)), COPPER_AMOUNT_SYMBOL)
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
			self:Print(L["Sold %1$d junk |4item:items; for %2$s."], num, formatMoney(value))
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
				self:Print(L["Repaired all items with guild bank funds for %s."], formatMoney(cost))
			elseif self.db.repairWithGuildFunds and IsInGuild() then
				self:Print(L["Insufficient guild bank funds to repair!"])
			elseif money > cost then
				RepairAllItems()
				self:Print(L["Repaired all items for %s."], formatMoney(cost))
			else
				self:Print(L["Insufficient funds to repair!"])
			end
		end
	end
end

------------------------------------------------------------------------

function module:RESURRECT_REQUEST(sender)
	if UnitInRaid(sender) or UnitInParty(sender) then
		local _, class = UnitClass(sender)
		if class ~= "DRUID" or self.db.acceptResurrectionsInCombat or not UnitAffectingCombat(sender) then
			self:Print(L["Accepted a resurrection from %s."], sender)
			AcceptResurrect()
			StaticPopup_Hide("RESURRECT_NO_SICKNESS")
		end
	end
end

------------------------------------------------------------------------

function module:PLAYER_REGEN_ENABLED()
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	self:CONFIRM_SUMMON()
end

function module:CONFIRM_SUMMON()
	local sender, location = GetSummonConfirmSummoner(), GetSummonConfirmAreaName()
	if sender and location then
		if UnitAffectingCombat("player") or not PlayerCanTeleport() then
			self:Print(L["Accepting a summon when combat ends..."])
			self:RegisterEvent("PLAYER_REGEN_ENABLED")

		elseif GetSummonConfirmTimeLeft() > 0 then
			self:Print(L["Accepting a summon from %1$s to %2$s."], sender, location)
			ConfirmSummon()
			StaticPopup_Hide("CONFIRM_SUMMON")

		else
			self:Print(L["Summon expired!"])
		end
	end
end

------------------------------------------------------------------------

function module:TRAINER_SHOW()
	SetTrainerServiceTypeFilter("unavailable", 0)
	SetTrainerServiceTypeFilter("used", 0)
end

------------------------------------------------------------------------

function module:SetupOptions(panel)
	local title, notes = LibStub("PhanxConfig-Header").CreateHeader(panel, panel.name, L["Automates simple repetetive tasks, such as clicking common dialogs."])

	panel.CreateCheckbox = LibStub("PhanxConfig-Checkbox").CreateCheckbox

	local function OnClick(self, checked)
		module.db[self.key] = checked
		if self.key ~= "verbose" then
			module:CheckState()
		end
	end

	local declineDuels = panel:CreateCheckbox(L["Decline duels"], L["Decline duel requests."])
	declineDuels:SetPoint("TOPLEFT", notes, "BOTTOMLEFT", 0, -12)
	declineDuels.OnClick = OnClick
	declineDuels.key = "declineDuels"

	local declineGuilds = panel:CreateCheckbox(L["Decline guilds"], L["Decline guild invitations and petitions."])
	declineGuilds:SetPoint("TOPLEFT", declineDuels, "BOTTOMLEFT", 0, -8)
	declineGuilds.OnClick = OnClick
	declineGuilds.key = "declineGuilds"

	local declineArenaTeams = panel:CreateCheckbox(L["Decline arena teams"], L["Decline arena team invitations and petitions."])
	declineArenaTeams:SetPoint("TOPLEFT", declineGuilds, "BOTTOMLEFT", 0, -8)
	declineArenaTeams.OnClick = OnClick
	declineArenaTeams.key = "declineArenaTeams"

	local acceptSummons = panel:CreateCheckbox(L["Accept summons"], L["Accept summon requests."])
	acceptSummons:SetPoint("TOPLEFT", declineArenaTeams, "BOTTOMLEFT", 0, -8)
	acceptSummons.OnClick = OnClick
	acceptSummons.key = "acceptSummons"

	local acceptResurrections = panel:CreateCheckbox(L["Accept resurrections"], L["Accept resurrections from players not in combat."])
	acceptResurrections:SetPoint("TOPLEFT", acceptSummons, "BOTTOMLEFT", 0, -8)
	acceptResurrections.OnClick = OnClick
	acceptResurrections.key = "acceptResurrections"

	local acceptResurrectionsInCombat = panel:CreateCheckbox(L["Accept combat resurrections"], L["Accept resurrections from players in combat."])
	acceptResurrectionsInCombat:SetPoint("TOPLEFT", acceptResurrections, "BOTTOMLEFT", 0, -8)
	acceptResurrectionsInCombat.OnClick = OnClick
	acceptResurrectionsInCombat.key = "acceptResurrectionsInCombat"

	local repairEquipment = panel:CreateCheckbox(L["Repair equipment"], L["Repair all equipment when interacting with a repair vendor."])
	repairEquipment:SetPoint("TOPLEFT", acceptResurrectionsInCombat, "BOTTOMLEFT", 0, -8)
	repairEquipment.OnClick = OnClick
	repairEquipment.key = "repairEquipment"

	local sellJunk = panel:CreateCheckbox(L["Sell junk"], L["Sell all junk (gray) items when interacting with a vendor."])
	sellJunk:SetPoint("TOPLEFT", repairEquipment, "BOTTOMLEFT", 0, -8)
	sellJunk.OnClick = OnClick
	sellJunk.key = "sellJunk"

	local verbose = panel:CreateCheckbox(L["Verbose mode"], L["Enable notification messages from this module."])
	verbose:SetPoint("TOPLEFT", sellJunk, "BOTTOMLEFT", 0, -24)
	verbose.OnClick = OnClick
	verbose.key = "verbose"

	local help = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	help:SetPoint("BOTTOMLEFT", 16, 16)
	help:SetPoint("BOTTOMRIGHT", -16, 16)
	help:SetHeight(112)
	help:SetJustifyH("LEFT")
	help:SetJustifyV("BOTTOM")
	help:SetText(L.HELP_AUTO)

	function panel:refresh()
		declineDuels:SetChecked(module.db.declineDuels)
		declineArenaTeams:SetChecked(module.db.declineArenaTeams)
		declineGuilds:SetChecked(module.db.declineGuilds)
		acceptSummons:SetChecked(module.db.acceptSummons)
		acceptResurrections:SetChecked(module.db.acceptResurrections)
		acceptResurrectionsInCombat:SetChecked(module.db.acceptResurrectionsInCombat)
		repairEquipment:SetChecked(module.db.repairEquipment)
		sellJunk:SetChecked(module.db.sellJunk)
		verbose:SetChecked(module.db.verbose)
	end
end