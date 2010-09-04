--[[--------------------------------------------------------------------
	HYDRA AUTOMATION
	* Declines arena team invitations and charters
	* Declines duel requests
	* Declines guild invitations and charters
	* Accepts summons
	* Accepts non-combat resurrections
	* Accepts corpse resurrections [NYI]
	* Releases spirit upon death [NYI]
	* Repairs equipment
	* Sells junk
----------------------------------------------------------------------]]

local _, core = ...
if not core then core = _G.Hydra end

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
	if not mine and not UnitInParty(sender) then
		if (type == "arena" and self.db.declineArenaTeams) or (type == "guild" and self.db.declineGuilds) then
			self:Print("Declined", type, "petition from", sender)
			ClosePetition()
		end
	end
end

function module:ARENA_TEAM_INVITE_REQUEST(sender)
	self:Print("Declined arena team invite from", sender)
	DeclineArenaTeam()
	StaticPopup_Hide("ARENA_TEAM_INVITE")
end

function module:DUEL_REQUESTED(sender)
	self:Print("Declined duel request from", sender)
	CancelDuel()
	StaticPopup_Hide("DUEL_REQUESTED")
end

function module:GUILD_INVITE_REQUEST(sender)
	self:Print("Declined guild invite from", sender)
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
			self:Print("Sold", num, "junk |4item:items; for", formatMoney(value))
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
				self:Print("Repaired all items with guild bank funds for", formatMoney(cost))
			elseif self.db.repairWithGuildFunds and IsInGuild() then
				self:Print("Insufficient guild bank funds to repair!")
			elseif money > cost then
				RepairAllItems()
				self:Print("Repaired all items for", formatMoney(cost))
			else
				self:Print("Insufficient funds to repair!")
			end
		end
	end
end

------------------------------------------------------------------------

function module:RESURRECT_REQUEST(sender)
	if not UnitInParty(sender) then return end

	local _, class = UnitClass(sender)
	if class == "DRUID" and not self.db.acceptResurrectionsInCombat and UnitAffectingCombat(sender) then return end

	self:Print("Accepted resurrection from", sender)
	AcceptResurrect()
	StaticPopup_Hide("RESURRECT_NO_SICKNESS")
end

------------------------------------------------------------------------

function module:PLAYER_REGEN_ENABLED()
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	self:CONFIRM_SUMMON()
end

function module:CONFIRM_SUMMON()
	local sender, location = GetSummonConfirmSummoner(), GetSummonConfirmAreaName()
	if not sender or not location then return end

	if UnitAffectingCombat("player") or not PlayerCanTeleport() then
		self:Print("Accepting summon when combat ends...")
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
	elseif GetSummonConfirmTimeLeft() > 0 then
		self:Print("Accepting summon from", sender, "to", location)
		ConfirmSummon()
		StaticPopup_Hide("CONFIRM_SUMMON")
	else
		self:Print("Summon expired!")
	end
end

------------------------------------------------------------------------

function module:TRAINER_SHOW()
	SetTrainerServiceTypeFilter("unavailable", 0)
	SetTrainerServiceTypeFilter("used", 0)
end
