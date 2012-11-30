local HYDRA, core = ...
local L = core.L

local FLAG_NONE, FLAG_TRUSTED, FLAG_GROUP, FLAG_FRIENDS, FLAG_GUILD, FLAG_ALL = 2, 4, 8, 16, 32, 64+32+16+8+4
local PLAYER_REALM = GetRealmName()

	L.FLAG_DEFAULT = "Default"
	L.FLAG_NONE = "None"
	L.FLAG_TRUSTED = "Trusted"
	L.FLAG_GROUP = "Group"
	L.FLAG_FRIENDS = "Friends"
	L.FLAG_GUILD = "Guild"
	L.FLAG_ALL = "All"

	L.AUTO_DESC = "Automates some things."

	L.AUTO_ARENA = "Allow arena teams"
	L.AUTO_ARENA_DESC = "Allow arena teams"
	L.AUTO_DUEL = "Allow duels"
	L.AUTO_DUEL_DESC = "Allow duels"
	L.AUTO_GUILD = "Allow guilds"
	L.AUTO_GUILD_DESC = "Allow guilds"
	L.AUTO_RES = "Accept resurrections"
	L.AUTO_RES_DESC = "Accept resurrections"
	L.AUTO_RESIC = "In combat"
	L.AUTO_RESIC_DESC = "In combat"
	L.AUTO_SUMMON = "Accept summons"
	L.AUTO_SUMMON_DESC = "Accept summons"
	L.AUTO_SUMMONDELAY = "Delay"
	L.AUTO_SUMMONDELAY_DESC = "Delay"
	L.AUTO_REPAIR = "Repair items"
	L.AUTO_REPAIR_DESC = "Repair items"
	L.AUTO_REPAIRGUILD = "Use guild funds"
	L.AUTO_REPAIRGUILD_DESC = "Use guild funds"
	L.AUTO_SELL = "Sell junk items"
	L.AUTO_SELL_DESC = "Sell junk items"

	L.VERBOSE = "Verbose"

------------------------------------------------------------------------

local module = core:RegisterModule("Automation", CreateFrame("Frame"))
module:SetScript("OnEvent", function(self, event, ...) return self[event] and self[event](self, ...) end)

module.defaults = {
	allowArenaTeams = FLAG_NONE,
	allowDuels = FLAG_NONE,
	allowGuilds = FLAG_NONE,
	acceptResurrections = FLAG_TRUSTED + FLAG_GROUP,
	acceptResurrectionsInCombat = FLAG_TRUSTED,
	acceptSummons = FLAG_TRUSTED,
	summonDelay = 0,
	repair = true,
	repairFromGuild = true,
	sellJunk = true,
	verbose = true,
}

------------------------------------------------------------------------
--	Base
------------------------------------------------------------------------

function module:CheckState()
	self:UnregisterAllEvents()
	self:Debug("Enable module: Automation")
	if self.db.allowArenaTeams then
		self:RegisterEvent("ARENA_TEAM_INVITE_REQUEST")
	end
	if self.db.allowDuels then
		self:RegisterEvent("DUEL_REQUESTED")
	end
	if self.db.allowGuilds then
		self:RegisterEvent("GUILD_INVITE_REQUEST")
	end
	if self.db.acceptSummons then
		self:RegisterEvent("CONFIRM_SUMMON")
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
end

------------------------------------------------------------------------
--	Utility
------------------------------------------------------------------------

function module:Print(...)
	if self.db.verbose then
		core:Print(...)
	end
end

function module:GetAction(flag, name, realm)
	if not flag then
		return
	elseif flag == FLAG_NONE then
		return "DECLINE"
	elseif flag == FLAG_ALL then
		return "ACCEPT"
	elseif bit.band(flag, FLAG_TRUSTED) == FLAG_TRUSTED then
		return core:IsTrusted(name, realm) and "ACCEPT"
	elseif bit.band(flag, FLAG_GROUP) == FLAG_GROUP then
		name = format("%s-%s", name, realm)
		return UnitInParty(name) or UnitInRaid(name) and "ACCEPT"
	elseif bit.band(flag, FLAG_FRIENDS) == FLAG_FRIENDS then
		if not realm or strlen(realm) == 0 then
			realm = PLAYER_REALM
		end
		if realm == PLAYER_REALM then
			for i = 1, GetNumFriends() do
				if name == GetFriendInfo(i) then
					return "ACCEPT"
				end
			end
		end
		for i = 1, BNGetNumFriends() do
			for j = 1, BNGetNumFriendToons(i) do
				local _, name2, _, realm2 = BNGetFriendToonInfo(i, j)
				if name == name2 and realm == realm2 then
					return "ACCEPT"
				end
			end
		end
	elseif bit.band(flag, FLAG_GUILD) then
		if not realm or strlen(realm) == 0 or realm == PLAYER_REALM then
			return UnitIsInMyGuild(name) and "ACCEPT"
		end
	end
end

------------------------------------------------------------------------
--	Arena team, duel, and guild requests
------------------------------------------------------------------------

function module:PETITION_SHOW()
	local type, title, _, _, sender, mine = GetPetitionInfo()
	self:Debug("PETITION_SHOW", type, title, sender, mine)
	if mine then return end
	if type == "arena" and self:GetAction(self.db.allowArenaTeams, sender) == "DECLINE" then
		self:Print(L.AUTO_ARENA_DECLINED, sender)
		ClosePetition()
	elseif type == "guild" and self:GetAction(self.db.allowGuilds, sender) == "DECLINE" then
		self:Print(L.AUTO_GUILD_DECLINED, sender)
		ClosePetition()
	end
end

function module:ARENA_TEAM_INVITE_REQUEST(sender, team)
	self:Debug("ARENA_TEAM_INVITE_REQUEST", sender, team)
	if self:GetAction(self.db.allowArenaTeams, sender) == "DECLINE" then
		self:Print(L.AUTO_ARENA_DECLINED, sender)
		DeclineArenaTeam()
		StaticPopup_Hide("ARENA_TEAM_INVITE")
	end
end

function module:DUEL_REQUESTED(sender)
	self:Debug("DUEL_REQUESTED", sender)
	if self:GetAction(self.db.allowDuels, sender) == "DECLINE" then
		self:Print(L.AUTO_DUEL_DECLINED, sender)
		CancelDuel()
		StaticPopup_Hide("DUEL_REQUESTED")
	end
end

function module:GUILD_INVITE_REQUEST(sender, guild)
	self:Debug("GUILD_INVITE_REQUEST", sender, guild)
	if self:GetAction(self.db.allowGuilds, sender) == "DECLINE" then
		self:Print(L.AUTO_GUILD_DECLINED, sender)
		DeclineGuild()
		StaticPopup_Hide("GUILD_INVITE")
	end
end

------------------------------------------------------------------------
--	Resurrections
------------------------------------------------------------------------

function module:RESURRECT_REQUEST(sender)
	self:Debug("RESURRECT_REQUEST", sender)

	local action
	local _, class = UnitClass(sender)
	if class and not UnitAffectingCombat(sender) and not UnitAffectingCombat("player") then
		action = self:GetAction(self.db.acceptResurrections, sender)
	else
		action = self:GetAction(self.db.acceptResurrectionsInCombat, sender)
	end

	if action == "ACCEPT" then
		self:Print(L.AUTO_RES_ACCEPTED, sender)
		AcceptResurrect()
		StaticPopup_Hide("RESURRECT_NO_SICKNESS")
	elseif action == "DECLINE" then
		self:Print(L.AUTO_RES_DECLINED, sender)
		StaticPopup_Hide("RESURRECT_NO_SICKNESS")
	end
end

------------------------------------------------------------------------
--	Summons
------------------------------------------------------------------------

function module:PLAYER_REGEN_ENABLED()
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	self:CONFIRM_SUMMON()
end

function module:CONFIRM_SUMMON()
	local sender, location = GetSummonConfirmSummoner(), GetSummonConfirmAreaName()
	self:Debug("CONFIRM_SUMMON", sender, location)
	local action = sender and location and self:GetAction(self.db.acceptSummons, sender)
	if action == "ACCEPT" then
		if UnitAffectingCombat("player") or not PlayerCanTeleport() then
			self:Print(L.AUTO_SUMMON_COMBAT)
			self:RegisterEvent("PLAYER_REGEN_ENABLED")
		elseif GetSummonConfirmTimeLeft() > 0 then
			self:Print(L.AUTO_SUMMON_ACCEPTED, sender, location)
			ConfirmSummon()
			StaticPopup_Hide("CONFIRM_SUMMON")
		else
			self:Print(L.AUTO_SUMMON_EXPIRED)
		end
	elseif action == "DECLINE" then
		self:Print(L.AUTO_SUMMON_DECLINED, sender, location)
		StaticPopup_Hide("CONFIRM_SUMMON")
	end
end

------------------------------------------------------------------------
--	Repair and sell
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

	if self.db.repair then
		local cost = GetRepairAllCost()
		if cost > 0 then
			local money = GetMoney()
			local guildmoney = GetGuildBankWithdrawMoney()
			if guildmoney == -1 then
				guildmoney = GetGuildBankMoney()
			end

			if guildmoney >= cost and self.db.repairFromGuild and IsInGuild() then
				RepairAllItems(1)
				self:Print(L.AUTO_REPAIR_SUCCESS_GUILD, formatMoney(cost))
			elseif money > cost then
				RepairAllItems()
				self:Print(L.AUTO_REPAIR_SUCCESS, formatMoney(cost))
			else
				self:Print(L.AUTO_REPAIR_FAILED)
			end
		end
	end
end

------------------------------------------------------------------------
--	Options
------------------------------------------------------------------------

function module:SetupOptions(panel)
	local CreateCheckbox = LibStub("PhanxConfig-Checkbox").CreateCheckbox

	local FLAGOPTIONS = {
		{ flag = false,        name = L.FLAG_DEFAULT, desc = L.FLAG_DEFAULT_DESC },
		{ flag = FLAG_NONE,    name = L.FLAG_NONE,    desc = L.FLAG_NONE_DESC    },
		{ flag = FLAG_TRUSTED, name = L.FLAG_TRUSTED, desc = L.FLAG_TRUSTED_DESC },
		{ flag = FLAG_GROUP,   name = L.FLAG_GROUP,   desc = L.FLAG_GROUP_DESC   },
		{ flag = FLAG_FRIENDS, name = L.FLAG_FRIENDS, desc = L.FLAG_FRIENDS_DESC },
		{ flag = FLAG_GUILD,   name = L.FLAG_GUILD,   desc = L.FLAG_GUILD_DESC   },
		{ flag = FLAG_ALL,     name = L.FLAG_ALL,     desc = L.FLAG_ALL_DESC     },
	}

	local function GetFlagOption(self) -- self is the checkbox
		local key = self.parent.key
		local flag = self.flag
		local current = module.db[key]
		return type(current) == "number" and bit.band(current, flag) == flag
	end

	local function SetFlagOption(self, checked) -- self is the checkbox
		local key = self.parent.key
		local flag = self.flag
		local current = bit.band(module.db[key], flag) == flag
		if checked and not current then
			if not module.db[key] then
				module.db[key] = flag
			else
				module.db[key] = module.db[key] + flag
			end
		elseif current and not checked then
			module.db[key] = module.db[key] - flag
			if module.db[key] == 0 then
				module.db[key] = false
			end
		end
		module:CheckState()
		panel:refresh()
	end

	local function ShowFlagTooltip(self) -- self can be row or checkbox
		local owner = self.parent or self
		if owner.desc then
			GameTooltip:SetOwner(owner, "ANCHOR_RIGHT")
			GameTooltip:SetText(owner.desc, nil, nil, nil, nil, true)
			GameTooltip:AddLine(" ")
			if self.parent then
				GameTooltip:AddLine(self.name)
				GameTooltip:AddLine(self.desc)
			else
				for i = 1, #FLAGOPTIONS do
					GameTooltip:AddLine(FLAGOPTIONS[i].name)
					GameTooltip:AddLine(FLAGOPTIONS[i].desc)
				end
			end
			GameTooltip:Show()
		end
	end

	local function RefreshFlagOptions(self) -- self is the row
		if module.db[self.key] then
			for i = 1, #self do
				self[i]:SetChecked(GetFlagOption(self[i]))
			end
		else
			for i = 1, #self do
				self[i]:SetChecked(false)
			end
		end
	end

	local function CreateFlagOptions(self, key, name, desc) -- self is the panel
		local row = CreateFrame("Frame", nil, self)
		row:SetPoint("LEFT", 8, 0)
		row:SetPoint("RIGHT", -8, 0)
		row:SetHeight(20)

		local title = row:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		title:SetPoint("LEFT", 8, 0)
		title:SetText(name)
		self.title = title

		local options = {}
		for i = 1, #FLAGOPTIONS do
			local option = FLAGOPTIONS[i]
			local check = CreateCheckbox(row, option.name)
			check:SetScript("OnClick", SetFlagOption)
			check:SetScript("OnEnter", ShowFlagTooltip)
			if i > 1 then
				check:SetPoint("LEFT", options[i-1], "RIGHT", 70, 0)
			else
				check:SetPoint("LEFT", row, "LEFT", 78, 0)
			end
			check.parent = row
			check.flag = option.flag
			options[i] = check
		end
		self.options = options

		row:EnableMouse(true)
		row:SetScript("OnEnter", ShowFlagTooltip)
		row:SetScript("OnLeave", GameTooltip_Hide)

		row.key = key
		row.name = name
		row.desc = desc
		return row
	end

	local function GetBooleanOption(self)
		return module.db[self.key]
	end

	local function SetBooleanOption(self, checked)
		module.db[self.key] = checked
		module:CheckState()
	end

	local title, notes = LibStub("PhanxConfig-Header").CreateHeader(panel, panel.name, L.AUTO_DESC)

	local allowArenaTeams = CreateFlagOptions(panel, "allowArenaTeams", L.AUTO_ARENA, L.AUTO_ARENA_DESC)
	allowArenaTeams:SetPoint("TOP", notes, "BOTTOM", 0, -8)

	local allowDuels = CreateFlagOptions(panel, "allowDuels", L.AUTO_DUEL, L.AUTO_DUEL_DESC)
	allowDuels:SetPoint("TOP", allowArenaTeams, "BOTTOM", 0, -8)

	local allowGuilds = CreateFlagOptions(panel, "allowGuilds", L.AUTO_GUILD, L.AUTO_GUILD_DESC)
	allowGuilds:SetPoint("TOP", allowDuels, "BOTTOM", 0, -8)

	local acceptResurrections = CreateFlagOptions(panel, "acceptResurrections", L.AUTO_RES, L.AUTO_RES_DESC)
	acceptResurrections:SetPoint("TOP", allowGuilds, "BOTTOM", 0, -8)

	local acceptResurrectionsInCombat = CreateFlagOptions(panel, "acceptResurrectionsInCombat", L.AUTO_RESIC, L.AUTO_RESIC_DESC)
	acceptResurrectionsInCombat:SetPoint("TOP", acceptResurrections, "BOTTOM", 0, -8)

	local acceptSummons = CreateFlagOptions(panel, "acceptSummons", L.AUTO_SUMMON, L.AUTO_SUMMON_DESC)
	acceptSummons:SetPoint("TOP", acceptResurrectionsInCombat, "BOTTOM", 0, -8)

	local summonDelay = LibStub("PhanxConfig-Slider").CreateSlider(panel, L.AUTO_SUMMONDELAY, 0, 90, 5)
	summonDelay:SetPoint("TOPLEFT", acceptSummons, "BOTTOMLEFT", 0, -12)
	summonDelay.desc = L.AUTO_SUMMONDELAY_DESC
	summonDelay.OnValueChanged = function(self, value)
		module.db.summonDelay = value
	end

	local repair = CreateCheckbox(panel, L.AUTO_REPAIR, L.AUTO_REPAIR_DESC)
	repair:SetPoint("TOPLEFT", summonDelay, "BOTTOMLEFT", 0, -8)
	repair.key = "reqpairEquipment"
	repair.OnClick = SetBooleanOption

	local repairFromGuild = CreateCheckbox(panel, L.AUTO_REPAIRGUILD, L.AUTO_REPAIRGUILD_DESC)
	repairFromGuild:SetPoint("TOPLEFT", repair, "BOTTOMLEFT", 0, -8)
	repairFromGuild.key = "repairFromGuild"
	repairFromGuild.OnClick = SetBooleanOption

	local sellJunk = CreateCheckbox(panel, L.AUTO_SELL, L.AUTO_SELL_DESC)
	sellJunk:SetPoint("TOPLEFT", repairFromGuild, "BOTTOMLEFT", 0, -8)
	sellJunk.key = "sellJunk"
	sellJunk.OnClick = SetBooleanOption

	local verbose = CreateCheckbox(panel, L.VERBOSE, L.VERBOSE_DESC)
	verbose:SetPoint("TOPLEFT", sellJunk, "BOTTOMLEFT", 0, -8)
	verbose.key = "verbose"
	verbose.OnClick = SetBooleanOption

	local help = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	help:SetPoint("BOTTOMLEFT", 16, 16)
	help:SetPoint("BOTTOMRIGHT", -16, 16)
	help:SetHeight(112)
	help:SetJustifyH("LEFT")
	help:SetJustifyV("BOTTOM")
	help:SetText(L.HELP_AUTO)

	panel.refresh = function()
		RefreshFlagOptions(allowArenaTeams)
		RefreshFlagOptions(allowDuels)
		RefreshFlagOptions(allowGuilds)
		RefreshFlagOptions(acceptResurrections)
		RefreshFlagOptions(acceptResurrectionsInCombat)
		RefreshFlagOptions(acceptSummons)
		summonDelay:SetValue(module.db.summonDelay)
		summonDelay:SetEnabled(module.db.acceptSummons and bit.band(module.db.acceptSummons, FLAG_NONE) ~= FLAG_NONE)
		repair:SetChecked(module.db.repair)
		repairFromGuild:SetChecked(module.db.repairFromGuild)
		repairFromGuild:SetEnabled(module.db.repair)
		sellJunk:SetChecked(module.db.sellJunk)
		verbose:SetChecked(module.db.verbose)
	end
end