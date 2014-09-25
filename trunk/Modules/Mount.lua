--[[--------------------------------------------------------------------
	Hydra
	Multibox leveling helper.
	Copyright (c) 2010-2014 Phanx. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info17572-Hydra.html
	http://www.curse.com/addons/wow/hydra
------------------------------------------------------------------------
	Hydra Mount
	* Mount and dismount together.
----------------------------------------------------------------------]]

local _, core = ...
local L = core.L
local SOLO, PARTY, TRUSTED, LEADER = core.STATE_SOLO, core.STATE_PARTY, core.STATE_TRUSTED, core.STATE_LEADER
SOLO = -1 -- #DEBUG
local module = core:NewModule("Mount")
module.defaults = {
	mount = true,
	dismount = true,
}

local ACTION_DISMOUNT, ACTION_MOUNT = "DISMOUNT", "MOUNT"
local MESSAGE_ERROR = "ERROR"

local isCasting, isMounted, responding

------------------------------------------------------------------------

function module:ShouldEnable()
	return core.state > SOLO and (self.db.mount or self.db.dismount)
end

function module:OnEnable()
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	if not UnitAffectingCombat("player") then
		self:PLAYER_REGEN_ENABLED()
	end

	if IsMounted() then
		for i = 1, GetNumCompanions("MOUNT") do
			local _, _, id = GetCompanionInfo("MOUNT", i)
			local name = GetSpellInfo(id)
			if UnitBuff("player", name) then
				self:Debug("Already mounted:", name)
				isMounted = name
				self:RegisterUnitEvent("UNIT_AURA", "player")
				break
			end
		end
	end
end

------------------------------------------------------------------------

local mountTypeString = {
	-- http://www.wowinterface.com/forums/showthread.php?p=294988#post294988
	[230] = "GROUND",
	[231] = "TURTLE",
	[232] = "VASHJIR",
	[241] = "AQ40",
	[242] = "GHOST",
	[247] = "AIR",
	[248] = "AIR",
	[254] = "VASHJIR",
	[269] = "WATER_WALKING",
}

function module:OnAddonMessage(message, channel, sender)
	local target = Ambiguate(sender, "none")
	if not core:IsTrusted(sender) or not (UnitInParty(target) or UnitInRaid(target)) then return end
	self:Debug("OnAddonMessage", message, channel, sender)

	local action, remoteID, remoteName = strsplit(" ", message, 3)

	if action == MESSAGE_ERROR then
		self:Print("ERROR: " .. L.MountMissing, sender)
		return
	elseif action == ACTION_DISMOUNT then
		self:Debug(sender, "dismounted")
		if self.db.dismount then
			responding = true
			Dismount()
			responding = nil
		end
		return
	end

	if action ~= ACTION_MOUNT or not remoteID or not remoteName or not self.db.mount then return end

	remoteID = tonumber(remoteID)
	self:Debug(sender, "mounted on", remoteID, remoteName)

	if IsMounted() then return self:Debug("Already mounted.") end
	if not UnitIsVisible(target) then return self:Debug("Not mounting because", sender, "is out of range.") end

	responding = true

	-- 1. Look for same mount
	if not self.db.mountRandom then
		if C_MountJournal then
			for i = 1, C_MountJournal.GetNumMounts() do
				local name, id = C_MountJournal.GetMountInfo(i)
				if id == remoteID then
					self:Debug("Found same mount", name)
					C_MountJournal.Summon(i)
					responding = nil
					return
				end
			end
		else
			for i = 1, GetNumCompanions("MOUNT") do
				local _, name, id = GetCompanionInfo("MOUNT", i)
				if id == remoteID then
					self:Debug("Found same mount", name)
					CallCompanion("MOUNT", i)
					responding = nil
					return
				end
			end
		end
	end

	-- 2. Look for equivalent mount
	if C_MountJournal then
		local numMounts = C_MountJournal.GetNumMounts()
		local mountType
		local equivalent
		for i = 1, numMounts do
			local _, id = C_MountJournal.GetMountInfo(i)
			if id == remoteID then
				local _, _, _, _, mountTypeID = C_MountJournal.GetMountInfoExtra(i)
				mountType = mountTypeString[mountTypeID]
				break
			end
		end
		if not mountType then
			return self:Debug("Mount type not recognized")
		end
		for i = 1, numMounts do
			local _, id, _, _, usable = C_MountJournal.GetMountInfo(i)
			if usable then
				local _, _, _, _, mountTypeID = C_MountJournal.GetMountInfoExtra(i)
				if mountTypeString[mountTypeID] == mountType then
					if not equivalent then
						equivalent = i
						if not self.db.mountRandom then
							break
						end
					elseif type(equivalent) == "table" then
						tinsert(equivalent, i)
					else
						equivalent = { equivalent, i }
					end
				end
			end
		end
		local i = type(equivalent) == "table" and equivalent[random(#equivalent)] or equivalent
		if i then
			local name = C_MountJournal.GetMountInfo(i)
			self:Debug("Found equivalent mount", name)
			C_MountJournal.Summon(i)
			responding = nil
			return
		end
	else
		local mountType = self:GetMountInfo(remoteID)
		local mounts = self.mountData[mountType]
		local equivalent
		for i = 1, GetNumCompanions("MOUNT") do
			local _, name, id = GetCompanionInfo("MOUNT", i)
			--self:Debug("Checking mount", name)
			local _, _, usable = self:GetMountInfo(id)
			if usable and mounts[id] then
				if not equivalent then
					equivalent = i
					if not self.db.mountRandom then
						break
					end
				elseif type(equivalent) == "table" then
					tinsert(equivalent, i)
				else
					equivalent = { equivalent, i }
				end
			end
		end
		local i = type(equivalent) == "table" and equivalent[random(#equivalent)] or equivalent
		if i then
			local _, name = GetCompanionInfo("MOUNT", i)
			self:Debug("Found equivalent mount", name)
			CallCompanion("MOUNT", i)
			responding = nil
			return
		end
	end

	-- 3. Admit defeat
	self:SendAddonMessage(MESSAGE_ERROR)
	responding = nil
end

------------------------------------------------------------------------

function module:PLAYER_REGEN_DISABLED()
	self:RegisterUnitEvent("UNIT_SPELLCAST_START", "player")
end

function module:PLAYER_REGEN_ENABLED()
	self:UnregisterEvent("UNIT_SPELLCAST_START")
end

if C_MountJournal then
	function module:UNIT_SPELLCAST_START(unit, spellName, _, castID, spellID)
		self:Debug("UNIT_SPELLCAST_START", spellName)
		for i = 1, C_MountJournal.GetNumMounts() do
			local name, id = C_MountJournal.GetMountInfo(i)
			if id == spellID then
				if not responding then
					self:Debug("Summoning mount", name, id)
					self:SendAddonMessage(ACTION_MOUNT .. " " .. id .. " " .. name)
					isCasting = spellName
				end
				self:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
				self:RegisterUnitEvent("UNIT_SPELLCAST_STOP", "player")
			end
		end
	end
else
	function module:UNIT_SPELLCAST_START(unit, spellName, _, castID, spellID)
		self:Debug("UNIT_SPELLCAST_START", spellName)
		for i = 1, GetNumCompanions("MOUNT") do
			local _, name, id = GetCompanionInfo("MOUNT", i)
			if id == spellID then
				if not responding then
					self:Debug("Summoning mount", name, id)
					self:SendAddonMessage(ACTION_MOUNT .. " " .. id .. " " .. name)
				end
				isCasting = spellName
				self:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
				self:RegisterUnitEvent("UNIT_SPELLCAST_STOP", "player")
			end
		end
	end
end

function module:UNIT_SPELLCAST_SUCCEEDED(unit, spellName, _, castID, spellID)
	self:Debug("UNIT_SPELLCAST_SUCCEEDED", spellName)
	if spellName == isCasting then
		isMounted = spellName
		self:RegisterUnitEvent("UNIT_AURA", "player")
	end
end

function module:UNIT_SPELLCAST_STOP(unit, spellName, _, castID, spellID)
	self:Debug("UNIT_SPELLCAST_STOP", spellName)
	self:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	self:UnregisterEvent("UNIT_SPELLCAST_STOP")
end

function module:UNIT_AURA(unit)
	if not UnitBuff(unit, isMounted) then
		if not responding then
			self:Debug("Dismounted")
			self:SendAddonMessage(ACTION_DISMOUNT)
		end
		self:UnregisterEvent("UNIT_AURA")
		isMounted = nil
	end
end

------------------------------------------------------------------------

module.displayName = L.Mount
function module:SetupOptions(panel)
	local title, notes = panel:CreateHeader(L.Mount, L.Mount_Info)

	local mount = panel:CreateCheckbox(L.MountTogether, L.MountTogether_Info)
	mount:SetPoint("TOPLEFT", notes, "BOTTOMLEFT", 0, -12)
	function mount.Callback(this, value)
		self.db.mount = value
		self:IsEnabled()
	end

	local mountRandom = panel:CreateCheckbox(L.MountRandom, L.MountRandom)
	mountRandom:SetPoint("TOPLEFT", mount, "BOTTOMLEFT", 0, -8)
	function mountRandom.Callback(this, value)
		self.db.mountRandom = value
		self:IsEnabled()
	end

	local dismount = panel:CreateCheckbox(L.Dismount, L.Dismount_Info)
	dismount:SetPoint("TOPLEFT", mountRandom, "BOTTOMLEFT", 0, -8)
	function dismount.Callback(this, value)
		self.db.dismount = value
		self:IsEnabled()
	end

	local help = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	help:SetPoint("BOTTOMLEFT", 16, 16)
	help:SetPoint("BOTTOMRIGHT", -16, 16)
	help:SetHeight(112)
	help:SetJustifyH("LEFT")
	help:SetJustifyV("BOTTOM")
	help:SetText(L.MountHelpText)

	panel.refresh = function()
		mount:SetChecked(self.db.mount)
		mountRandom:SetChecked(self.db.mountRandom)
		dismount:SetChecked(self.db.dismount)
	end
end

------------------------------------------------------------------------

module.mountData = {
	air = {
		[32235]  = "AIR", -- Golden Gryphon
		[32239]  = "AIR", -- Ebon Gryphon
		[32240]  = "AIR", -- Snowy Gryphon
		[32242]  = "AIR", -- Swift Blue Gryphon
		[32243]  = "AIR", -- Tawny Wind Rider
		[32244]  = "AIR", -- Blue Wind Rider
		[32245]  = "AIR", -- Green Wind Rider
		[32246]  = "AIR", -- Swift Red Wind Rider
		[32289]  = "AIR", -- Swift Red Gryphon
		[32290]  = "AIR", -- Swift Green Gryphon
		[32292]  = "AIR", -- Swift Purple Gryphon
		[32295]  = "AIR", -- Swift Green Wind Rider
		[32296]  = "AIR", -- Swift Yellow Wind Rider
		[32297]  = "AIR", -- Swift Purple Wind Rider
		[32345]  = "AIR", -- Peep the Phoenix Mount
		[37015]  = "AIR", -- Swift Nether Drake
		[39798]  = "AIR", -- Green Riding Nether Ray
		[39800]  = "AIR", -- Red Riding Nether Ray
		[39801]  = "AIR", -- Purple Riding Nether Ray
		[39802]  = "AIR", -- Silver Riding Nether Ray
		[39803]  = "AIR", -- Blue Riding Nether Ray
		[40192]  = "AIR", -- Ashes of Al'ar
		[41513]  = "AIR", -- Onyx Netherwing Drake
		[41514]  = "AIR", -- Azure Netherwing Drake
		[41515]  = "AIR", -- Cobalt Netherwing Drake
		[41516]  = "AIR", -- Purple Netherwing Drake
		[41517]  = "AIR", -- Veridian Netherwing Drake
		[41518]  = "AIR", -- Violet Netherwing Drake
		[43927]  = "AIR", -- Cenarion War Hippogryph
		[44151]  = "AIR", -- Turbo-Charged Flying Machine
		[44153]  = "AIR", -- Flying Machine
		[44744]  = "AIR", -- Merciless Nether Drake
		[46197]  = "AIR", -- X-51 Nether-Rocket
		[46199]  = "AIR", -- X-51 Nether-Rocket X-TREME
		[48025]  = "AIR", -- Headless Horseman's Mount
		[49193]  = "AIR", -- Vengeful Nether Drake
		[54729]  = "AIR", -- Winged Steed of the Ebon Blade
		[58615]  = "AIR", -- Brutal Nether Drake
		[59567]  = "AIR", -- Azure Drake
		[59568]  = "AIR", -- Blue Drake
		[59569]  = "AIR", -- Bronze Drake
		[59570]  = "AIR", -- Red Drake
		[59571]  = "AIR", -- Twilight Drake
		[59650]  = "AIR", -- Black Drake
		[59961]  = "AIR", -- Red Proto-Drake
		[59976]  = "AIR", -- Black Proto-Drake
		[59996]  = "AIR", -- Blue Proto-Drake
		[60002]  = "AIR", -- Time-Lost Proto-Drake
		[60021]  = "AIR", -- Plagued Proto-Drake
		[60024]  = "AIR", -- Violet Proto-Drake
		[60025]  = "AIR", -- Albino Drake
		[61229]  = "AIR", -- Armored Snowy Gryphon
		[61230]  = "AIR", -- Armored Blue Wind Rider
		[61294]  = "AIR", -- Green Proto-Drake
		[61309]  = "AIR", -- Magnificent Flying Carpet
		[61451]  = "AIR", -- Flying Carpet
		[61996]  = "AIR", -- Blue Dragonhawk
		[61997]  = "AIR", -- Red Dragonhawk
		[63796]  = "AIR", -- Mimiron's Head
		[63844]  = "AIR", -- Argent Hippogryph
		[63956]  = "AIR", -- Ironbound Proto-Drake
		[63963]  = "AIR", -- Rusted Proto-Drake
		[64927]  = "AIR", -- Deadly Gladiator's Frost Wyrm
		[65439]  = "AIR", -- Furious Gladiator's Frost Wyrm
		[66087]  = "AIR", -- Silver Covenant Hippogryph
		[66088]  = "AIR", -- Sunreaver Dragonhawk
		[67336]  = "AIR", -- Relentless Gladiator's Frost Wyrm
		[69395]  = "AIR", -- Onyxian Drake
		[71342]  = "AIR", -- Big Love Rocket
		[71810]  = "AIR", -- Wrathful Gladiator's Frost Wyrm
		[72286]  = "AIR", -- Invincible
		[72807]  = "AIR", -- Icebound Frostbrood Vanquisher
		[72808]  = "AIR", -- Bloodbathed Frostbrood Vanquisher
		[74856]  = "AIR", -- Blazing Hippogryph
		[75596]  = "AIR", -- Frosty Flying Carpet
		[75614]  = "AIR", -- Celestial Steed
		[75973]  = "AIR", -- X-53 Touring Rocket
		[88331]  = "AIR", -- Volcanic Stone Drake
		[88335]  = "AIR", -- Drake of the East Wind
		[88718]  = "AIR", -- Phosphorescent Stone Drake
		[88741]  = "AIR", -- Drake of the West Wind
		[88742]  = "AIR", -- Drake of the North Wind
		[88744]  = "AIR", -- Drake of the South Wind
		[88746]  = "AIR", -- Vitreous Stone Drake
		[88990]  = "AIR", -- Dark Phoenix
		[93326]  = "AIR", -- Sandstone Drake
		[93463]  = "AIR", -- Mottled Drake
		[93623]  = "AIR", -- Mottled Drake
		[96503]  = "AIR", -- Amani Dragonhawk
		[97359]  = "AIR", -- Flameward Hippogryph
		[97493]  = "AIR", -- Crimson Fire Hawk
		[97493]  = "AIR", -- Pureblood Fire Hawk
		[97501]  = "AIR", -- Beryl Fire Hawk
		[97501]  = "AIR", -- Green Fire Hawk
		[97560]  = "AIR", -- Corrupted Fire Hawk
		[98727]  = "AIR", -- Winged Guardian
		[101282] = "AIR", -- Vicious Gladiator's Twilight Drake
		[101821] = "AIR", -- Ruthless Gladiator's Twilight Drake
		[102514] = "AIR", -- Corrupted Hippogryph
		[107203] = "AIR", -- Tyrael's Charger
		[107516] = "AIR", -- Spectral Gryphon
		[107517] = "AIR", -- Spectral Wind Rider
		[107842] = "AIR", -- Blazing Drake
		[107844] = "AIR", -- Twilight Harbinger
		[107845] = "AIR", -- Life-Binder's Handmaiden
		[110039] = "AIR", -- Experiment 12-B
		[110051] = "AIR", -- Heart of the Aspects
		[113120] = "AIR", -- Feldrake
		[113199] = "AIR", -- Jade Cloud Serpent
		[118737] = "AIR", -- Pandaren Kite (Horde)
		[120043] = "AIR", -- Jeweled Onyx Panther
		[121820] = "AIR", -- Obsidian Nightwing
		[121836] = "AIR", -- Sapphire Panther
		[121837] = "AIR", -- Jade Panther
		[121838] = "AIR", -- Ruby Panther
		[121839] = "AIR", -- Sunstone Panther
		[123992] = "AIR", -- Azure Cloud Serpent
		[123993] = "AIR", -- Golden Cloud Serpent
		[124408] = "AIR", -- Thundering Jade Cloud Serpent
		[124550] = "AIR", -- Cataclysmic Gladiator's Twilight Drake
		[124659] = "AIR", -- Imperial Quilen
		[126507] = "AIR", -- Depleted-Kyparium Rocket
		[126508] = "AIR", -- Geosynchronous World Spinner
		[127154] = "AIR", -- Onyx Cloud Serpent
		[127156] = "AIR", -- Crimson Cloud Serpent
		[127158] = "AIR", -- Heavenly Onyx Cloud Serpent
		[127161] = "AIR", -- Heavenly Crimson Cloud Serpent
		[127164] = "AIR", -- Heavenly Golden Cloud Serpent
		[127165] = "AIR", -- Heavenly Jade Cloud Serpent
		[127169] = "AIR", -- Heavenly Azure Cloud Serpent
		[127170] = "AIR", -- Astral Cloud Serpent
		[129552] = "AIR", -- Crimson Pandaren Phoenix
		[129918] = "AIR", -- Thundering August Cloud Serpent
		[130092] = "AIR", -- Red Flying Cloud
		[130985] = "AIR", -- Pandaren Kite (Alliance)
		[133023] = "AIR", -- Jade Pandaren Kite
		[134573] = "AIR", -- Swift Windsteed
		[135416] = "AIR", -- Grand Armored Gryphon
		[135418] = "AIR", -- Grand Armored Wyvern
		[136163] = "AIR", -- Grand Gryphon
		[136164] = "AIR", -- Grand Wyvern
		-- Patch 5.2
		[134359] = "AIR", -- Sky Golem
		[136400] = "AIR", -- Armored Skyscreamer
		[136505] = "AIR", -- Ghastly Charger
		[139407] = "AIR", -- Malevolent Gladiator's Cloud Serpent
		[139442] = "AIR", -- Thundering Cobalt Cloud Serpent
		[139448] = "AIR", -- Clutch of Ji-Kun
		[139595] = "AIR", -- Armored Bloodwing
		-- Patch 5.3
		[142073] = "AIR", -- Hearthsteed
		[142266] = "AIR", -- Armored Red Dragonhawk
		[142478] = "AIR", -- Armored Blue Dragonhawk
		[142878] = "AIR", -- Enchanted Fey Dragon
		-- Patch 5.4
		[148392] = "AIR", -- Spawn of Galakras
		[148476] = "AIR", -- Thundering Onyx Cloud Serpent
		[148618] = "AIR", -- Tyrannical Gladiator's Cloud Serpent
		[148619] = "AIR", -- Grievous Gladiator's Cloud Serpent
		[148620] = "AIR", -- Prideful Gladiator's Cloud Serpent
		[149801] = "AIR", -- Emerald Hippogryph
		[153489] = "AIR", -- Iron Skyreaver
		[155741] = "AIR", -- Dread Raven
		-- Patch 5.4.8
		[163024] = "AIR", -- Warforged Nightmare
		-- UNKNOWN
		[147595] = "AIR", -- Stormcrow
	},
	ground = {
		[458]    = "GROUND", -- Brown Horse
		[470]    = "GROUND", -- Black Stallion
		[472]    = "GROUND", -- Pinto
		[580]    = "GROUND", -- Timber Wolf
		[5784]   = "GROUND", -- Felsteed
		[6648]   = "GROUND", -- Chestnut Mare
		[6653]   = "GROUND", -- Dire Wolf
		[6654]   = "GROUND", -- Brown Wolf
		[6777]   = "GROUND", -- Gray Ram
		[6898]   = "GROUND", -- White Ram
		[6899]   = "GROUND", -- Brown Ram
		[8394]   = "GROUND", -- Striped Frostsaber
		[8395]   = "GROUND", -- Emerald Raptor
		[10789]  = "GROUND", -- Spotted Frostsaber
		[10793]  = "GROUND", -- Striped Nightsaber
		[10796]  = "GROUND", -- Turquoise Raptor
		[10799]  = "GROUND", -- Violet Raptor
		[10873]  = "GROUND", -- Red Mechanostrider
		[10969]  = "GROUND", -- Blue Mechanostrider
		[13819]  = "GROUND", -- Warhorse
		[15779]  = "GROUND", -- White Mechanostrider Mod B
		[16055]  = "GROUND", -- Black Nightsaber
		[16056]  = "GROUND", -- Ancient Frostsaber
		[16080]  = "GROUND", -- Red Wolf
		[16081]  = "GROUND", -- Winter Wolf
		[16082]  = "GROUND", -- Palomino
		[16083]  = "GROUND", -- White Stallion
		[16084]  = "GROUND", -- Mottled Red Raptor
		[17229]  = "GROUND", -- Winterspring Frostsaber
		[17450]  = "GROUND", -- Ivory Raptor
		[17453]  = "GROUND", -- Green Mechanostrider
		[17454]  = "GROUND", -- Unpainted Mechanostrider
		[17459]  = "GROUND", -- Icy Blue Mechanostrider Mod A
		[17460]  = "GROUND", -- Frost Ram
		[17461]  = "GROUND", -- Black Ram
		[17462]  = "GROUND", -- Red Skeletal Horse
		[17463]  = "GROUND", -- Blue Skeletal Horse
		[17464]  = "GROUND", -- Brown Skeletal Horse
		[17465]  = "GROUND", -- Green Skeletal Warhorse
		[17481]  = "GROUND", -- Rivendare's Deathcharger
		[18989]  = "GROUND", -- Gray Kodo
		[18990]  = "GROUND", -- Brown Kodo
		[18991]  = "GROUND", -- Green Kodo
		[18992]  = "GROUND", -- Teal Kodo
		[22717]  = "GROUND", -- Black War Steed
		[22718]  = "GROUND", -- Black War Kodo
		[22719]  = "GROUND", -- Black Battlestrider
		[22720]  = "GROUND", -- Black War Ram
		[22721]  = "GROUND", -- Black War Raptor
		[22722]  = "GROUND", -- Red Skeletal Warhorse
		[22723]  = "GROUND", -- Black War Tiger
		[22724]  = "GROUND", -- Black War Wolf
		[23161]  = "GROUND", -- Dreadsteed
		[23214]  = "GROUND", -- Charger
		[23219]  = "GROUND", -- Swift Mistsaber
		[23221]  = "GROUND", -- Swift Frostsaber
		[23222]  = "GROUND", -- Swift Yellow Mechanostrider
		[23223]  = "GROUND", -- Swift White Mechanostrider
		[23225]  = "GROUND", -- Swift Green Mechanostrider
		[23227]  = "GROUND", -- Swift Palomino
		[23228]  = "GROUND", -- Swift White Steed
		[23229]  = "GROUND", -- Swift Brown Steed
		[23238]  = "GROUND", -- Swift Brown Ram
		[23239]  = "GROUND", -- Swift Gray Ram
		[23240]  = "GROUND", -- Swift White Ram
		[23241]  = "GROUND", -- Swift Blue Raptor
		[23242]  = "GROUND", -- Swift Olive Raptor
		[23243]  = "GROUND", -- Swift Orange Raptor
		[23246]  = "GROUND", -- Purple Skeletal Warhorse
		[23247]  = "GROUND", -- Great White Kodo
		[23248]  = "GROUND", -- Great Gray Kodo
		[23249]  = "GROUND", -- Great Brown Kodo
		[23250]  = "GROUND", -- Swift Brown Wolf
		[23251]  = "GROUND", -- Swift Timber Wolf
		[23252]  = "GROUND", -- Swift Gray Wolf
		[23338]  = "GROUND", -- Swift Stormsaber
		[23509]  = "GROUND", -- Frostwolf Howler
		[23510]  = "GROUND", -- Stormpike Battle Charger
		[24242]  = "GROUND", -- Swift Razzashi Raptor
		[24252]  = "GROUND", -- Swift Zulian Tiger
		[25953]  = "GROUND", -- Blue Qiraji Battle Tank
		[26054]  = "GROUND", -- Red Qiraji Battle Tank
		[26055]  = "GROUND", -- Yellow Qiraji Battle Tank
		[26056]  = "GROUND", -- Green Qiraji Battle Tank
		[26656]  = "GROUND", -- Black Qiraji Battle Tank
		[30174]  = "GROUND", -- Riding Turtle
		[33660]  = "GROUND", -- Swift Pink Hawkstrider
		[34406]  = "GROUND", -- Brown Elekk
		[34767]  = "GROUND", -- Summon Charger
		[34769]  = "GROUND", -- Summon Warhorse
		[34790]  = "GROUND", -- Dark War Talbuk
		[34795]  = "GROUND", -- Red Hawkstrider
		[34896]  = "GROUND", -- Cobalt War Talbuk
		[34897]  = "GROUND", -- White War Talbuk
		[34898]  = "GROUND", -- Silver War Talbuk
		[34899]  = "GROUND", -- Tan War Talbuk
		[35018]  = "GROUND", -- Purple Hawkstrider
		[35020]  = "GROUND", -- Blue Hawkstrider
		[35022]  = "GROUND", -- Black Hawkstrider
		[35025]  = "GROUND", -- Swift Green Hawkstrider
		[35027]  = "GROUND", -- Swift Purple Hawkstrider
		[35028]  = "GROUND", -- Swift Warstrider
		[35710]  = "GROUND", -- Gray Elekk
		[35711]  = "GROUND", -- Purple Elekk
		[35712]  = "GROUND", -- Great Green Elekk
		[35713]  = "GROUND", -- Great Blue Elekk
		[35714]  = "GROUND", -- Great Purple Elekk
		[36702]  = "GROUND", -- Fiery Warhorse
		[39315]  = "GROUND", -- Cobalt Riding Talbuk
		[39316]  = "GROUND", -- Dark Riding Talbuk
		[39317]  = "GROUND", -- Silver Riding Talbuk
		[39318]  = "GROUND", -- Tan Riding Talbuk
		[39319]  = "GROUND", -- White Riding Talbuk
		[41252]  = "GROUND", -- Raven Lord
		[42776]  = "GROUND", -- Spectral Tiger
		[42777]  = "GROUND", -- Swift Spectral Tiger
		[43688]  = "GROUND", -- Amani War Bear
		[43899]  = "GROUND", -- Brewfest Ram
		[43900]  = "GROUND", -- Swift Brewfest Ram
		[48027]  = "GROUND", -- Black War Elekk
		[48778]  = "GROUND", -- Acherus Deathcharger
		[49322]  = "GROUND", -- Swift Zhevra
		[49379]  = "GROUND", -- Great Brewfest Kodo
		[50869]  = "GROUND", -- Brewfest Kodo
		[51412]  = "GROUND", -- Big Battle Bear
		[54753]  = "GROUND", -- White Polar Bear
		[55531]  = "GROUND", -- Mechano-hog
		[58983]  = "GROUND", -- Big Blizzard Bear
		[59785]  = "GROUND", -- Black War Mammoth
		[59788]  = "GROUND", -- Black War Mammoth
		[59791]  = "GROUND", -- Wooly Mammoth
		[59793]  = "GROUND", -- Wooly Mammoth
		[59797]  = "GROUND", -- Ice Mammoth
		[59799]  = "GROUND", -- Ice Mammoth
		[60114]  = "GROUND", -- Armored Brown Bear
		[60116]  = "GROUND", -- Armored Brown Bear
		[60118]  = "GROUND", -- Black War Bear
		[60119]  = "GROUND", -- Black War Bear
		[60424]  = "GROUND", -- Mekgineer's Chopper
		[61229]  = "GROUND", -- Armored Snowy Gryphon
		[61230]  = "GROUND", -- Armored Blue Wind Rider
		[61309]  = "GROUND", -- Magnificent Flying Carpet
		[61425]  = "GROUND", -- Traveler's Tundra Mammoth
		[61447]  = "GROUND", -- Traveler's Tundra Mammoth
		[61465]  = "GROUND", -- Grand Black War Mammoth
		[61467]  = "GROUND", -- Grand Black War Mammoth
		[61469]  = "GROUND", -- Grand Ice Mammoth
		[61470]  = "GROUND", -- Grand Ice Mammoth
		[63232]  = "GROUND", -- Stormwind Steed
		[63635]  = "GROUND", -- Darkspear Raptor
		[63636]  = "GROUND", -- Ironforge Ram
		[63637]  = "GROUND", -- Darnassian Nightsaber
		[63638]  = "GROUND", -- Gnomeregan Mechanostrider
		[63639]  = "GROUND", -- Exodar Elekk
		[63640]  = "GROUND", -- Orgrimmar Wolf
		[63641]  = "GROUND", -- Thunder Bluff Kodo
		[63642]  = "GROUND", -- Silvermoon Hawkstrider
		[63643]  = "GROUND", -- Forsaken Warhorse
		[64656]  = "GROUND", -- Blue Skeletal Warhorse
		[64657]  = "GROUND", -- White Kodo
		[64658]  = "GROUND", -- Black Wolf
		[64659]  = "GROUND", -- Venomhide Ravasaur
		[64977]  = "GROUND", -- Black Skeletal Horse
		[65637]  = "GROUND", -- Great Red Elekk
		[65638]  = "GROUND", -- Swift Moonsaber
		[65639]  = "GROUND", -- Swift Red Hawkstrider
		[65640]  = "GROUND", -- Swift Gray Steed
		[65641]  = "GROUND", -- Great Golden Kodo
		[65642]  = "GROUND", -- Turbostrider
		[65643]  = "GROUND", -- Swift Violet Ram
		[65644]  = "GROUND", -- Swift Purple Raptor
		[65645]  = "GROUND", -- White Skeletal Warhorse
		[65646]  = "GROUND", -- Swift Burgundy Wolf
		[65917]  = "GROUND", -- Magic Rooster
		[66090]  = "GROUND", -- Quel'dorei Steed
		[66091]  = "GROUND", -- Sunreaver Hawkstrider
		[66846]  = "GROUND", -- Ochre Skeletal Warhorse
		[66847]  = "GROUND", -- Striped Dawnsaber
		[66906]  = "GROUND", -- Argent Charger
		[66907]  = "GROUND", -- Argent Warhorse
		[67466]  = "GROUND", -- Argent Warhorse
		[68056]  = "GROUND", -- Swift Horde Wolf
		[68057]  = "GROUND", -- Swift Alliance Steed
		[68187]  = "GROUND", -- Crusader's White Warhorse
		[68188]  = "GROUND", -- Crusader's Black Warhorse
		[69820]  = "GROUND", -- Summon Sunwalker Kodo
		[69826]  = "GROUND", -- Summon Great Sunwalker Kodo
		[73629]  = "GROUND", -- Summon Exarch's Elekk
		[73630]  = "GROUND", -- Summon Great Exarch's Elekk
		[74918]  = "GROUND", -- Wooly White Rhino
		[84751]  = "GROUND", -- Fossilized Raptor
		[87090]  = "GROUND", -- Goblin Trike
		[87091]  = "GROUND", -- Goblin Turbo-Trike
		[88748]  = "GROUND", -- Brown Riding Camel
		[88749]  = "GROUND", -- Tan Riding Camel
		[88750]  = "GROUND", -- Grey Riding Camel
		[89520]  = "GROUND", -- Goblin Mini Hotrod
		[90621]  = "GROUND", -- Golden King
		[92155]  = "GROUND", -- Ultramarine Qiraji Battle Tank
		[92231]  = "GROUND", -- Spectral Steed
		[92232]  = "GROUND", -- Spectral Wolf
		[93644]  = "GROUND", -- Kor'kron Annihilator
		[96491]  = "GROUND", -- Armored Razzashi Raptor
		[96499]  = "GROUND", -- Swift Zulian Panther
		[97581]  = "GROUND", -- Savage Raptor
		[98204]  = "GROUND", -- Amani Battle Bear
		[100332] = "GROUND", -- Vicious War Steed
		[100333] = "GROUND", -- Vicious War Wolf
		[101542] = "GROUND", -- Flametalon of Alyzrazor
		[101573] = "GROUND", -- Swift Shorestrider
		[102346] = "GROUND", -- Swift Forest Strider
		[102349] = "GROUND", -- Swift Springstrider
		[102350] = "GROUND", -- Swift Lovebird
		[102488] = "GROUND", -- White Riding Camel
		[103081] = "GROUND", -- Darkmoon Dancing Bear
		[103195] = "GROUND", -- Mountain Horse
		[103196] = "GROUND", -- Swift Mountain Horse
		[118089] = "GROUND", -- Azure Water Strider
		[120395] = "GROUND", -- Green Dragon Turtle
		[120822] = "GROUND", -- Great Red Dragon Turtle
		[122708] = "GROUND", -- Grand Expedition Yak
		[123160] = "GROUND", -- Crimson Riding Crane
		[123182] = "GROUND", -- White Riding Yak
		[123886] = "GROUND", -- Amber Scorpion
		[127174] = "GROUND", -- Azure Riding Crane
		[127176] = "GROUND", -- Golden Riding Crane
		[127177] = "GROUND", -- Regal Riding Crane
		[127178] = "GROUND", -- Jungle Riding Crane
		[127180] = "GROUND", -- Albino Riding Crane
		[127209] = "GROUND", -- Black Riding Yak
		[127213] = "GROUND", -- Brown Riding Yak
		[127216] = "GROUND", -- Grey Riding Yak
		[127220] = "GROUND", -- Blonde Riding Yak
		[127271] = "GROUND", -- Crimson Water Strider
		[127272] = "GROUND", -- Orange Water Strider
		[127274] = "GROUND", -- Jade Water Strider
		[127278] = "GROUND", -- Golden Water Strider
		[127286] = "GROUND", -- Black Dragon Turtle
		[127287] = "GROUND", -- Blue Dragon Turtle
		[127288] = "GROUND", -- Brown Dragon Turtle
		[127289] = "GROUND", -- Purple Dragon Turtle
		[127290] = "GROUND", -- Red Dragon Turtle
		[127293] = "GROUND", -- Great Green Dragon Turtle
		[127295] = "GROUND", -- Great Black Dragon Turtle
		[127302] = "GROUND", -- Great Blue Dragon Turtle
		[127308] = "GROUND", -- Great Brown Dragon Turtle
		[127310] = "GROUND", -- Great Purple Dragon Turtle
		[129932] = "GROUND", -- Green Shado-Pan Riding Tiger
		[129934] = "GROUND", -- Blue Shado-Pan Riding Tiger
		[129935] = "GROUND", -- Red Shado-Pan Riding Tiger
		[130138] = "GROUND", -- Black Riding Goat
		-- Patch 5.2
		[138423] = "GROUND", -- Cobalt Primordial Direhorn
		[138424] = "GROUND", -- Amber Primordial Direhorn
		[138425] = "GROUND", -- Slate Primordial Direhorn
		[138426] = "GROUND", -- Jade Primordial Direhorn
		[138449] = "GROUND", -- Golden Primordial Direhorn
		[138450] = "GROUND", -- Crimson Primordial Direhorn
		[138640] = "GROUND", -- Bone-White Primal Raptor
		[138641] = "GROUND", -- Red Primal Raptor
		[138642] = "GROUND", -- Black Primal Raptor
		[138643] = "GROUND", -- Green Primal Raptor
		[136471] = "GROUND", -- Spawn of Horridon
		-- Patch 5.3
		[142641] = "GROUND", -- Brawler's Burly Mushan Beast
		-- Patch 5.4
		[146622] = "GROUND", -- Vicious Skeletal Warhorse
		[146615] = "GROUND", -- Vicious Warsaber
		[148428] = "GROUND", -- Ashhide Mushan Beast
		[148396] = "GROUND", -- Kor'kron War Wolf
		[148417] = "GROUND", -- Kor'kron Juggernaut
		[145133] = "GROUND", -- Moonfang
	},
	water = {
		[75207] = "WATER", -- Abyssal Seahorse
		[64731] = "WATER", -- Sea Turtle
		[98718] = "WATER", -- Subdued Seahorse
	},
}

module.mountSpecial = {
	passengers = {
		[61467]  = 2, -- Grand Black War Mammoth (horde)
		[61465]  = 2, -- Grand Black War Mammoth (alliance)
		[122708] = 2, -- Grand Expedition Yak
		[61469]  = 2, -- Grand Ice Mammoth (horde)
		[61470]  = 2, -- Grand Ice Mammoth (alliance)
		[55531]  = 1, -- Mechano-hog
		[60424]  = 1, -- Mekgineer's Chopper
		[121820] = 1, -- Obsidian Nightwing
		[93326]  = 1, -- Sandstone Drake
		[61447]  = 2, -- Traveler's Tundra Mammoth (horde)
		[61425]  = 2, -- Traveler's Tundra Mammoth (alliance)
		[75973]  = 1, -- X-53 Touring Rocket
	},
	zoneRestricted = {
		[75207]  = 613, -- Abyssal Seahorse (Vashj'ir)
		[25953]  = 766, -- Blue Qiraji Battle Tank (Temple of Ahn'Qiraj)
		[26054]  = 766, -- Red Qiraji Battle Tank (Temple of Ahn'Qiraj)
		[26055]  = 766, -- Yellow Qiraji Battle Tank (Temple of Ahn'Qiraj)
		[26056]  = 766, -- Green Qiraji Battle Tank (Temple of Ahn'Qiraj)
	},
	professionRestricted = {
		[61451] = { 110426, 300 }, -- Flying Carpet (Tailoring)
		[44153] = { 110403, 300 }, -- Flying Machine (Engineering)
		[75596] = { 110426, 425 }, -- Frosty Flying Carpet (Tailoring)
		[61309] = { 110426, 425 }, -- Magnificent Flying Carpet (Tailoring)
		[44151] = { 110403, 375 }, -- Turbo-Charged Flying Machine (Engineering)
	},
}

local function GetProfessionSkill(profession)
	for i = 1, 6 do
		local index = select(i, GetProfessions())
		if index then
			local name, _, skill = GetProfessionInfo(index)
			if name == profession then
				return skill
			end
		end
	end
end

function module:GetMountInfo(id)
	for mountType, mounts in pairs(self.mountData) do
		if mounts[id] then
			local usable = IsUsableSpell(id)

			local requiresZone = self.mountSpecial.zoneRestricted[id]
			if requiresZone and GetCurrentMapAreaID() ~= requiresZone then
				usable = nil
			end

			local requiresProfession = self.mountSpecial.professionRestricted[id]
			if requiresProfession and GetProfessionSkill(requiresProfession[1]) < requiresProfession[2] then
				usable = nil
			end

			return mountType, self.mountSpecial.passengers[id], usable
		end
	end
end