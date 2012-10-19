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
	acceptArenaTeams = {},
	acceptDuels = {},
	acceptGuilds = {},
	acceptResurrections = {},
	acceptResurrectionsInCombat = {},
	acceptSummons = {},
	repairEquipment = true,
	repairWithGuildFunds = false,
	sellJunk = true,
}
--module.debug = true
------------------------------------------------------------------------

function module:CheckState()
	self:UnregisterAllEvents()

	self:Debug("Enable module: Automation")

	if self.db.acceptArenaTeams then
		self:RegisterEvent("ARENA_TEAM_INVITE_REQUEST")
	end
	if self.db.acceptSummons then
		self:RegisterEvent("CONFIRM_SUMMON")
	end
	if self.db.acceptDuels then
		self:RegisterEvent("DUEL_REQUESTED")
	end
	if self.db.acceptGuilds then
		self:RegisterEvent("GUILD_INVITE_REQUEST")
	end
	if self.db.repairEquipment or self.db.sellJunk then
		self:RegisterEvent("MERCHANT_SHOW")
	end
	if self.db.acceptArenaTeams or self.db.acceptGuilds then
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

local myRealm = GetRealmName()
local allow = {
	trusted = function(name, realm)
		return core:IsTrusted(name, realm)
	end,
	friends = function(name, realm)
		if (not realm or realm == "" or realm == myRealm) then
			for i = 1, GetNumFriends() do
				if name == GetFriendInfo(i) then
					return true
				end
			end
		end
		for i = 1, select(2, BNGetNumFriends()) do
			for j = 1, BNGetNumFriendToons(i) do
				local _, name2, game, realm2 = BNGetFriendToonInfo(i, j)
				if game == "WoW" and name == name2 then
					return true
				end
			end
		end
	end,
	guild = function(name, realm)
		return (not realm or realm == "" or realm == myRealm) and UnitIsInMyGuild(name)
	end,
	group = function(name, realm)
		local unit = IsInRaid() and "raid" or "party"
		for i = 1, GetNumGroupMembers() do
			local name2, realm2 = UnitName(unit..i)
			if name == name2 and (not realm or realm == "" or realm == myRealm) then
				return true
			end
		end
	end,
}

------------------------------------------------------------------------

function module:PETITION_SHOW()
	local type, _, _, _, sender, mine = GetPetitionInfo()
	if not mine then
		if type == "arena" then
			for k, v in pairs(self.db.acceptArenaTeams) do
				if v and allow[k](sender) then
					return
				end
			end
			self:Print(L["Declined an arena team petition from %s."], sender)
			ClosePetition()
		elseif type == "guild" then
			for k, v in pairs(self.db.acceptArenaTeams) do
				if v and allow[k](sender) then
					return
				end
			end
			self:Print(L["Declined a guild petition from %s."], sender)
			ClosePetition()
		end
	end
end

function module:ARENA_TEAM_INVITE_REQUEST(sender)
	for k, v in pairs(self.db.acceptArenaTeams) do
		if v and allow[k](sender) then
			return
		end
	end
	self:Print(L["Declined an arena team invitation from %s"], sender)
	DeclineArenaTeam()
	StaticPopup_Hide("ARENA_TEAM_INVITE")
end

function module:DUEL_REQUESTED(sender)
	for k, v in pairs(self.db.acceptDuels) do
		if v and allow[k](sender) then
			return
		end
	end
	self:Print(L["Declined a duel request from %s."], sender)
	CancelDuel()
	StaticPopup_Hide("DUEL_REQUESTED")
end

function module:GUILD_INVITE_REQUEST(sender)
	for k, v in pairs(self.db.acceptGuilds) do
		if v and allow[k](sender) then
			return
		end
	end
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

			if guildmoney >= cost and self.db.repairWithGuildFunds and IsInGuild() and CanGuildBankRepair() then
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
	for k, v in pairs(self.db.acceptResurrections) do
		if v and allow[k](sender) then
			local _, class = UnitClass(sender)
			if class ~= "DRUID" or self.db.acceptResurrectionsInCombat or not UnitAffectingCombat(sender) then
				self:Print(L["Accepted a resurrection from %s."], sender)
				AcceptResurrect()
				StaticPopup_Hide("RESURRECT_NO_SICKNESS")
			end
			return
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
		for k, v in pairs(self.db.acceptSummons) do
			if v and allow[k](sender) then
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
				return
			end
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

	local CreateCheckbox = LibStub("PhanxConfig-Checkbox").CreateCheckbox

	local function row_OnEnter(self)
		if self.desc then
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetText(self.desc, nil, nil, nil, nil, true)
		end
	end

	local function check_OnClick(self, checked)
		if self.flag then
			module.db[self.key][self.flag] = checked
		else
			module.db[self.key] = checked
		end
		if self.key ~= "verbose" then
			module:CheckState()
		end
	end

	local options = {}

	local flags = { "trusted", "friends", "guild", "group" }
	local function CreateOptionsRow(key, name, desc)
		local row = CreateFrame("Frame", nil, panel)
		row:SetHeight(26)
		if #options > 0 then
			row:SetPoint("TOPLEFT", options[#options], "BOTTOMLEFT", 0, -8)
			row:SetPoint("TOPRIGHT", options[#options], "BOTTOMRIGHT", 0, -8)
		else
			row:SetPoint("TOPLEFT", notes, "BOTTOMLEFT", 0, -12)
			row:SetPoint("TOPRIGHT", notes, "BOTTOMRIGHT", 0, -12)
		end

		local label = row:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
		label:SetPoint("TOPLEFT")
		label:SetText(name)

		for i = 1, #flags do
			local flag = flags[i]
			local check = CreateCheckbox(row, L[flag])
			check.flag = flag
			check.key = key
			check.OnClick = check_OnClick
			check:SetHitRectInsets(0, -100, 0, 0)
			if i > 1 then
				check:SetPoint("LEFT", row[i-1], "RIGHT", 100, 0)
			else
				check:SetPoint("LEFT", row, "LEFT", 150, 0)
			end
		end

		row:EnableMouse(true)
		row:SetScript("OnEnter", row_OnEnter)
		row:SetScript("OnLeave", GameTooltip_Hide)
		options[#options+1] = row

		return row
	end

	local acceptArenaTeams = CreateOptionsRow("declineArenas", L["Accept arena teams"],
		L["Accept arena team invitations and petitions."])

	local acceptDuels = CreateOptionsRow("acceptDuels", L["Decline duels"],
		L["Accept duel requests."])

	local acceptGuilds = CreateOptionsRow("acceptGuilds", L["Decline guilds"],
		L["Accept guild invitations and petitions."])

	local acceptSummons = CreateOptionsRow("acceptSummons", L["Accept summons"],
		L["Accept summons from warlocks and meeting stones."])

	local acceptResurrections = CreateOptionsRow("acceptResurrections", L["Accept resurrections"],
		L["Accept resurrections from players out of combat."])

	local acceptResurrectionsInCombat = CreateCheckbox(panel, L["Accept combat resurrections"],
		L["Accept resurrections from players in combat."])
	acceptResurrectionsInCombat:SetPoint("TOPLEFT", acceptResurrections, "BOTTOMLEFT", 0, -8)
	acceptResurrectionsInCombat.OnClick = check_OnClick
	acceptResurrectionsInCombat.key = "acceptResurrectionsInCombat"

	local repairEquipment = CreateCheckbox(panel, L["Repair equipment"],
		L["Repair all equipment when interacting with a repair vendor."])
	repairEquipment:SetPoint("TOPLEFT", acceptResurrectionsInCombat, "BOTTOMLEFT", 0, -8)
	repairEquipment.OnClick = check_OnClick
	repairEquipment.key = "repairEquipment"

	local sellJunk = CreateCheckbox(panel, L["Sell junk"],
		L["Sell all junk (gray) items when interacting with a vendor."])
	sellJunk:SetPoint("TOPLEFT", repairEquipment, "BOTTOMLEFT", 0, -8)
	sellJunk.OnClick = check_OnClick
	sellJunk.key = "sellJunk"

	local verbose = CreateCheckbox(panel, L["Verbose mode"],
		L["Enable notification messages from this module."])
	verbose:SetPoint("TOPLEFT", sellJunk, "BOTTOMLEFT", 0, -24)
	verbose.OnClick = check_OnClick
	verbose.key = "verbose"

	local help = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	help:SetPoint("BOTTOMLEFT", 16, 16)
	help:SetPoint("BOTTOMRIGHT", -16, 16)
	help:SetHeight(112)
	help:SetJustifyH("LEFT")
	help:SetJustifyV("BOTTOM")
	help:SetText(L.HELP_AUTO)

	function panel:refresh()
		for i = 1, #options do
			local row = options[i]
			for j = 1, #row do
				local check = row[i]
				check:SetChecked(module.db[check.key][check.flag])
			end
		end
		acceptResurrectionsInCombat:SetChecked(module.db.acceptResurrectionsInCombat)
		repairEquipment:SetChecked(module.db.repairEquipment)
		sellJunk:SetChecked(module.db.sellJunk)
		verbose:SetChecked(module.db.verbose)
	end
end