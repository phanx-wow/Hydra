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

local ACCEPT_BATTLE_RES = false
local USE_GUILD_REPAIR = false

------------------------------------------------------------------------

local _, core = ...
local module = core:RegisterModule("Automation", CreateFrame("Frame"))
module:SetScript("OnEvent", function(f, e, ...) return f[e] and f[e](f, ...) end)

module.debug = true

------------------------------------------------------------------------

function module:CheckState()
	self:Debug("Enable module: Automation")

	self:RegisterEvent("ARENA_TEAM_INVITE_REQUEST")
	self:RegisterEvent("CONFIRM_SUMMON")
	self:RegisterEvent("DUEL_REQUESTED")
	self:RegisterEvent("GUILD_INVITE_REQUEST")
	self:RegisterEvent("MERCHANT_SHOW")
	self:RegisterEvent("PETITION_SHOW")
	self:RegisterEvent("RESURRECT_REQUEST")
	self:RegisterEvent("TRAINER_SHOW")
end

------------------------------------------------------------------------

function module:PETITION_SHOW()
	local type, _, _, _, sender, mine = GetPetitionInfo()
	if not mine and not UnitInParty(sender) then
		self:Debug("Declined", type, "petition from", sender)
		ClosePetition()
	end
end

function module:ARENA_TEAM_INVITE_REQUEST(sender)
	self:Debug("Declined arena team invite from", sender)
	DeclineArenaTeam()
	StaticPopup_Hide("ARENA_TEAM_INVITE")
end

function module:DUEL_REQUESTED(sender)
	self:Debug("Declined duel request from", sender)
	CancelDuel()
	StaticPopup_Hide("DUEL_REQUESTED")
end

function module:GUILD_INVITE_REQUEST(sender)
	self:Debug("Declined guild invite from", sender)
	DeclineGuild()
	StaticPopup_Hide("GUILD_INVITE")
end

function module:MERCHANT_SHOW()
	if IsShiftKeyDown() then return end

	local i = 0
	for bag = 0, 4 do
		for slot = 0, GetContainerNumSlots(bag) do
			local link = GetContainerItemLink(bag, slot)
			if link then
				local _, _, q = GetItemInfo(link)
				if q == 0 then
					i = i + 1
					UseContainerItem(bag, slot)
				end
			end
		end
	end
	if i > 0 then
		self:Debug("Sold", i, "junk items")
	end

	local cost = GetRepairAllCost()
	if cost > 0 then
		local money = GetMoney()
	--	local guildmoney = GetGuildBankWithdrawMoney()
	--	if guildmoney == -1 then
	--		guildmoney = GetGuildBankMoney()
	--	end

	--	if USE_GUILD_REPAIR and guildmoney >= cost and IsInGuild() then
	--		RepairAllItems(1)
	--		self:Debug("Repaired all items for %s from guild bank funds.", FormatMoney(cost))
	--	elseif db.repairFromGuild and IsInGuild() then
	--		self:Debug("Insufficient guild bank funds to repair! Hold Shift to repair anyway.")
		if money > cost then
			RepairAllItems()
			self:Debug("Repaired all items.")
		else
			self:Debug("Insufficient funds to repair!")
		end
	end
end

function module:RESURRECT_REQUEST(sender)
	local _, class = UnitClass(sender)
	if class == "DRUID" and not ACCEPT_BATTLE_RES and UnitAffectingCombat(sender) then return end

	self:Debug("Accepted resurrection from", sender)
	AcceptResurrect()
	StaticPopup_Hide("RESURRECT_NO_SICKNESS")
end

function module:PLAYER_REGEN_ENABLED()
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	self:CONFIRM_SUMMON()
end

function module:CONFIRM_SUMMON()
	local sender, location = GetSummonConfirmSummoner(), GetSummonConfirmAreaName()
	if not sender or not location then return end

	if UnitAffectingCombat("player") or not PlayerCanTeleport() then
		self:Debug("Will try to accept summon when combat ends.")
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
	elseif GetSummonConfirmTimeLeft() > 0 then
		self:Debug("Accepting summon to", location, "from", sender)
		ConfirmSummon()
		StaticPopup_Hide("CONFIRM_SUMMON")
	end
end

function module:TRAINER_SHOW()
	SetTrainerServiceTypeFilter("unavailable", 0)
	SetTrainerServiceTypeFilter("used", 0)
end
