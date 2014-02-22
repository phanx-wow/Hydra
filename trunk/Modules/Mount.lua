--[[--------------------------------------------------------------------
	Hydra
	Multibox leveling helper.
	Copyright (c) 2010-2014 Phanx <addons@phanx.net>. All rights reserved.
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

local module = core:NewModule("Mount")
module.defaults = {
	mount = true,
	dismount = true,
}

local ACTION_DISMOUNT, ACTION_MOUNT = "DISMOUNT", "MOUNT"
local MESSAGE_ERROR = "ERROR"

local responding

------------------------------------------------------------------------

function module:ShouldEnable()
	return core.state > SOLO and (self.db.mount or self.db.dismount)
end

function module:Enable()
	self:RegisterEvent("UNIT_SPELLCAST_SENT")
end

function module:Disable()
	self:UnregisterAllEvents()
end

------------------------------------------------------------------------

function module:ReceiveAddonMessage(message, channel, sender)
	if not core:IsTrusted(sender) or not (UnitInParty(sender) or UnitInRaid(sender)) then return end
	self:Debug("ReceiveAddonMessage", message, channel, sender)

	local remoteID, remoteName = strsplit(" ", message, 2)

	if remoteID == MESSAGE_ERROR then
		self:Print("ERROR: " .. L.MountMissing, sender)
		return
	elseif remoteID == "DISMOUNT" then
		self:Debug(sender, "dismounted")
		if self.db.dismount then
			responding = true
			Dismount()
			responding = nil
		end
		return
	end

	if not remoteID or not remoteName or not self.db.mount then return end

	remoteID = tonumber(remoteID)
	self:Debug(sender, "mounted on", remoteID, remoteName)

	if IsMounted() then return self:Debug("Already mounted.") end

	local target = Ambiguate(sender, "none")
	if not UnitIsVisible(target) then return self:Debug("Not mounting because", sender, "is out of range.") end

	responding = true

	-- 1. Look for same mount
	if not self.db.mountRandom then
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

	-- 2. Look for equivalent mount
	local mountType, passengers = self:GetMountType(remoteID)
	local mounts = self.mountData[mountType]
	local equivalent
	for i = 1, GetNumCompanions("MOUNT") do
		local _, name, id = GetCompanionInfo("MOUNT", i)
		--self:Debug("Checking mount", name)
		if mounts[id] and IsUsableSpell(id) then
			if type(equivalent) == "table" then
				tinsert(equivalent, i)
			elseif type(equivalent) == "number" then
				equivalent = { equivalent, i }
			else
				equivalent = i
				if not self.db.mountRandom then
					break
				end
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

	self:SendAddonMessage(MESSAGE_ERROR)
	responding = nil
end

------------------------------------------------------------------------

function module:UNIT_SPELLCAST_SENT(unit, spell)
	if responding or unit ~= "player" or core.state == SOLO or UnitAffectingCombat("player") then return end
	for i = 1, GetNumCompanions("MOUNT") do
		local _, name, id = GetCompanionInfo("MOUNT", i)
		if name == spell or GetSpellInfo(id) == spell then -- stupid paladin mount summon spell doesn't match companion name
			self:Debug("Summoning mount", name, id)
			self:SendAddonMessage(id .. " " .. name)
		end
	end
end

hooksecurefunc("CallCompanion", function(type, i)
	if responding or core.state == SOLO then return end
	if type == "MOUNT" then
		local _, name, id = GetCompanionInfo(type, i)
		module:Debug("CallCompanion", type, i, name, id)
		module:SendAddonMessage(id .. " " .. name)
	end
end)

hooksecurefunc("Dismount", function()
	if responding or core.state == SOLO then return end
	module:Debug("Dismount")
	module:SendAddonMessage(ACTION_DISMOUNT)
end)

------------------------------------------------------------------------

module.displayName = L.Mount
function module:SetupOptions(panel)
	local title, notes = LibStub("PhanxConfig-Header").CreateHeader(panel, L.Mount, L.Mount_Info)

	local CreateCheckbox = LibStub("PhanxConfig-Checkbox").CreateCheckbox

	local mount = CreateCheckbox(panel, L.MountTogether, L.MountTogether_Info)
	mount:SetPoint("TOPLEFT", notes, "BOTTOMLEFT", 0, -12)
	mount.OnValueChanged = function(this, value)
		self.db.mount = value
		self:IsEnabled()
	end

	local mountRandom = CreateCheckbox(panel, L.MountRandom, L.MountRandom)
	mountRandom:SetPoint("TOPLEFT", mount, "BOTTOMLEFT", 0, -8)
	mountRandom.OnValueChanged = function(this, value)
		self.db.mountRandom = value
		self:IsEnabled()
	end

	local dismount = CreateCheckbox(panel, L.Dismount, L.Dismount_Info)
	dismount:SetPoint("TOPLEFT", mountRandom, "BOTTOMLEFT", 0, -8)
	dismount.OnValueChanged = function(this, value)
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
		[32235]  = true, -- Golden Gryphon
		[32239]  = true, -- Ebon Gryphon
		[32240]  = true, -- Snowy Gryphon
		[32242]  = true, -- Swift Blue Gryphon
		[32243]  = true, -- Tawny Wind Rider
		[32244]  = true, -- Blue Wind Rider
		[32245]  = true, -- Green Wind Rider
		[32246]  = true, -- Swift Red Wind Rider
		[32289]  = true, -- Swift Red Gryphon
		[32290]  = true, -- Swift Green Gryphon
		[32292]  = true, -- Swift Purple Gryphon
		[32295]  = true, -- Swift Green Wind Rider
		[32296]  = true, -- Swift Yellow Wind Rider
		[32297]  = true, -- Swift Purple Wind Rider
		[32345]  = true, -- Peep the Phoenix Mount
		[37015]  = true, -- Swift Nether Drake
		[39798]  = true, -- Green Riding Nether Ray
		[39800]  = true, -- Red Riding Nether Ray
		[39801]  = true, -- Purple Riding Nether Ray
		[39802]  = true, -- Silver Riding Nether Ray
		[39803]  = true, -- Blue Riding Nether Ray
		[40192]  = true, -- Ashes of Al'ar
		[41513]  = true, -- Onyx Netherwing Drake
		[41514]  = true, -- Azure Netherwing Drake
		[41515]  = true, -- Cobalt Netherwing Drake
		[41516]  = true, -- Purple Netherwing Drake
		[41517]  = true, -- Veridian Netherwing Drake
		[41518]  = true, -- Violet Netherwing Drake
		[43927]  = true, -- Cenarion War Hippogryph
		[44151]  = true, -- Turbo-Charged Flying Machine
		[44153]  = true, -- Flying Machine
		[44744]  = true, -- Merciless Nether Drake
		[46197]  = true, -- X-51 Nether-Rocket
		[46199]  = true, -- X-51 Nether-Rocket X-TREME
		[48025]  = true, -- Headless Horseman's Mount
		[49193]  = true, -- Vengeful Nether Drake
		[54729]  = true, -- Winged Steed of the Ebon Blade
		[58615]  = true, -- Brutal Nether Drake
		[59567]  = true, -- Azure Drake
		[59568]  = true, -- Blue Drake
		[59569]  = true, -- Bronze Drake
		[59570]  = true, -- Red Drake
		[59571]  = true, -- Twilight Drake
		[59650]  = true, -- Black Drake
		[59961]  = true, -- Red Proto-Drake
		[59976]  = true, -- Black Proto-Drake
		[59996]  = true, -- Blue Proto-Drake
		[60002]  = true, -- Time-Lost Proto-Drake
		[60021]  = true, -- Plagued Proto-Drake
		[60024]  = true, -- Violet Proto-Drake
		[60025]  = true, -- Albino Drake
		[61229]  = true, -- Armored Snowy Gryphon
		[61230]  = true, -- Armored Blue Wind Rider
		[61294]  = true, -- Green Proto-Drake
		[61309]  = true, -- Magnificent Flying Carpet
		[61451]  = true, -- Flying Carpet
		[61996]  = true, -- Blue Dragonhawk
		[61997]  = true, -- Red Dragonhawk
		[63796]  = true, -- Mimiron's Head
		[63844]  = true, -- Argent Hippogryph
		[63956]  = true, -- Ironbound Proto-Drake
		[63963]  = true, -- Rusted Proto-Drake
		[64927]  = true, -- Deadly Gladiator's Frost Wyrm
		[65439]  = true, -- Furious Gladiator's Frost Wyrm
		[66087]  = true, -- Silver Covenant Hippogryph
		[66088]  = true, -- Sunreaver Dragonhawk
		[67336]  = true, -- Relentless Gladiator's Frost Wyrm
		[69395]  = true, -- Onyxian Drake
		[71342]  = true, -- Big Love Rocket
		[71810]  = true, -- Wrathful Gladiator's Frost Wyrm
		[72286]  = true, -- Invincible
		[72807]  = true, -- Icebound Frostbrood Vanquisher
		[72808]  = true, -- Bloodbathed Frostbrood Vanquisher
		[74856]  = true, -- Blazing Hippogryph
		[75596]  = true, -- Frosty Flying Carpet
		[75614]  = true, -- Celestial Steed
		[75973]  = true, -- X-53 Touring Rocket
		[88331]  = true, -- Volcanic Stone Drake
		[88335]  = true, -- Drake of the East Wind
		[88718]  = true, -- Phosphorescent Stone Drake
		[88741]  = true, -- Drake of the West Wind
		[88742]  = true, -- Drake of the North Wind
		[88744]  = true, -- Drake of the South Wind
		[88746]  = true, -- Vitreous Stone Drake
		[88990]  = true, -- Dark Phoenix
		[93326]  = true, -- Sandstone Drake
		[93463]  = true, -- Mottled Drake
		[93623]  = true, -- Mottled Drake
		[96503]  = true, -- Amani Dragonhawk
		[97359]  = true, -- Flameward Hippogryph
		[97493]  = true, -- Crimson Fire Hawk
		[97493]  = true, -- Pureblood Fire Hawk
		[97501]  = true, -- Beryl Fire Hawk
		[97501]  = true, -- Green Fire Hawk
		[97560]  = true, -- Corrupted Fire Hawk
		[98727]  = true, -- Winged Guardian
		[101282] = true, -- Vicious Gladiator's Twilight Drake
		[101821] = true, -- Ruthless Gladiator's Twilight Drake
		[102514] = true, -- Corrupted Hippogryph
		[107203] = true, -- Tyrael's Charger
		[107516] = true, -- Spectral Gryphon
		[107517] = true, -- Spectral Wind Rider
		[107842] = true, -- Blazing Drake
		[107844] = true, -- Twilight Harbinger
		[107845] = true, -- Life-Binder's Handmaiden
		[110039] = true, -- Experiment 12-B
		[110051] = true, -- Heart of the Aspects
		[113120] = true, -- Feldrake
		[113199] = true, -- Jade Cloud Serpent
		[118737] = true, -- Pandaren Kite (Horde)
		[120043] = true, -- Jeweled Onyx Panther
		[121820] = true, -- Obsidian Nightwing
		[121836] = true, -- Sapphire Panther
		[121837] = true, -- Jade Panther
		[121838] = true, -- Ruby Panther
		[121839] = true, -- Sunstone Panther
		[123992] = true, -- Azure Cloud Serpent
		[123993] = true, -- Golden Cloud Serpent
		[124408] = true, -- Thundering Jade Cloud Serpent
		[124550] = true, -- Cataclysmic Gladiator's Twilight Drake
		[124659] = true, -- Imperial Quilen
		[126507] = true, -- Depleted-Kyparium Rocket
		[126508] = true, -- Geosynchronous World Spinner
		[127154] = true, -- Onyx Cloud Serpent
		[127156] = true, -- Crimson Cloud Serpent
		[127158] = true, -- Heavenly Onyx Cloud Serpent
		[127161] = true, -- Heavenly Crimson Cloud Serpent
		[127164] = true, -- Heavenly Golden Cloud Serpent
		[127165] = true, -- Heavenly Jade Cloud Serpent
		[127169] = true, -- Heavenly Azure Cloud Serpent
		[127170] = true, -- Astral Cloud Serpent
		[129552] = true, -- Crimson Pandaren Phoenix
		[129918] = true, -- Thundering August Cloud Serpent
		[130092] = true, -- Red Flying Cloud
		[130985] = true, -- Pandaren Kite (Alliance)
		[133023] = true, -- Jade Pandaren Kite
		[134573] = true, -- Swift Windsteed
		[135416] = true, -- Grand Armored Gryphon
		[135418] = true, -- Grand Armored Wyvern
		[136163] = true, -- Grand Gryphon
		[136164] = true, -- Grand Wyvern
		[136400] = true, -- Armored Skyscreamer
		[136505] = true, -- Ghastly Charger
		[139407] = true, -- Malevolent Gladiator's Cloud Serpent
		[139442] = true, -- Thundering Cobalt Cloud Serpent
		[139448] = true, -- Clutch of Ji-Kun
		[139595] = true, -- Armored Bloodwing
	},
	--[[
	airground = {
		[32235]  = true, -- Golden Gryphon
		[32239]  = true, -- Ebon Gryphon
		[32240]  = true, -- Snowy Gryphon
		[32242]  = true, -- Swift Blue Gryphon
		[32243]  = true, -- Tawny Wind Rider
		[32244]  = true, -- Blue Wind Rider
		[32245]  = true, -- Green Wind Rider
		[32246]  = true, -- Swift Red Wind Rider
		[32289]  = true, -- Swift Red Gryphon
		[32290]  = true, -- Swift Green Gryphon
		[32292]  = true, -- Swift Purple Gryphon
		[32295]  = true, -- Swift Green Wind Rider
		[32296]  = true, -- Swift Yellow Wind Rider
		[32297]  = true, -- Swift Purple Wind Rider
		[43927]  = true, -- Cenarion War Hippogryph
		[44151]  = true, -- Turbo-Charged Flying Machine
		[46628]  = true, -- Swift White Hawkstrider
		[48025]  = true, -- Headless Horseman's Mount
		[61451]  = true, -- Flying Carpet
		[63844]  = true, -- Argent Hippogryph
		[66087]  = true, -- Silver Covenant Hippogryph
		[71342]  = true, -- Big Love Rocket
		[72286]  = true, -- Invincible
		[73313]  = true, -- Crimson Deathcharger
		[74856]  = true, -- Blazing Hippogryph
		[75596]  = true, -- Frosty Flying Carpet
		[75614]  = true, -- Celestial Steed
		[75973]  = true, -- X-53 Touring Rocket
		[97359]  = true, -- Flameward Hippogryph
		[98727]  = true, -- Winged Guardian
		[102514] = true, -- Corrupted Hippogryph
		[107203] = true, -- Tyrael's Charger
		[107516] = true, -- Spectral Gryphon
		[107517] = true, -- Spectral Wind Rider
		[110051] = true, -- Heart of the Aspects
		[124659] = true, -- Imperial Quilen
		[126507] = true, -- Depleted-Kyparium Rocket
		[120043] = true, -- Jeweled Onyx Panther
		[121836] = true, -- Sapphire Panther
		[121837] = true, -- Jade Panther
		[121838] = true, -- Ruby Panther
		[121839] = true, -- Sunstone Panther
		[126508] = true, -- Geosynchronous World Spinner
		[130092] = true, -- Red Flying Cloud
	},
	]]
	ground = {
		[458]    = true, -- Brown Horse
		[470]    = true, -- Black Stallion
		[472]    = true, -- Pinto
		[580]    = true, -- Timber Wolf
		[5784]   = true, -- Felsteed
		[6648]   = true, -- Chestnut Mare
		[6653]   = true, -- Dire Wolf
		[6654]   = true, -- Brown Wolf
		[6777]   = true, -- Gray Ram
		[6898]   = true, -- White Ram
		[6899]   = true, -- Brown Ram
		[8394]   = true, -- Striped Frostsaber
		[8395]   = true, -- Emerald Raptor
		[10789]  = true, -- Spotted Frostsaber
		[10793]  = true, -- Striped Nightsaber
		[10796]  = true, -- Turquoise Raptor
		[10799]  = true, -- Violet Raptor
		[10873]  = true, -- Red Mechanostrider
		[10969]  = true, -- Blue Mechanostrider
		[13819]  = true, -- Warhorse
		[15779]  = true, -- White Mechanostrider Mod B
		[16055]  = true, -- Black Nightsaber
		[16056]  = true, -- Ancient Frostsaber
		[16080]  = true, -- Red Wolf
		[16081]  = true, -- Winter Wolf
		[16082]  = true, -- Palomino
		[16083]  = true, -- White Stallion
		[16084]  = true, -- Mottled Red Raptor
		[17229]  = true, -- Winterspring Frostsaber
		[17450]  = true, -- Ivory Raptor
		[17453]  = true, -- Green Mechanostrider
		[17454]  = true, -- Unpainted Mechanostrider
		[17459]  = true, -- Icy Blue Mechanostrider Mod A
		[17460]  = true, -- Frost Ram
		[17461]  = true, -- Black Ram
		[17462]  = true, -- Red Skeletal Horse
		[17463]  = true, -- Blue Skeletal Horse
		[17464]  = true, -- Brown Skeletal Horse
		[17465]  = true, -- Green Skeletal Warhorse
		[17481]  = true, -- Rivendare's Deathcharger
		[18989]  = true, -- Gray Kodo
		[18990]  = true, -- Brown Kodo
		[18991]  = true, -- Green Kodo
		[18992]  = true, -- Teal Kodo
		[22717]  = true, -- Black War Steed
		[22718]  = true, -- Black War Kodo
		[22719]  = true, -- Black Battlestrider
		[22720]  = true, -- Black War Ram
		[22721]  = true, -- Black War Raptor
		[22722]  = true, -- Red Skeletal Warhorse
		[22723]  = true, -- Black War Tiger
		[22724]  = true, -- Black War Wolf
		[23161]  = true, -- Dreadsteed
		[23214]  = true, -- Charger
		[23219]  = true, -- Swift Mistsaber
		[23221]  = true, -- Swift Frostsaber
		[23222]  = true, -- Swift Yellow Mechanostrider
		[23223]  = true, -- Swift White Mechanostrider
		[23225]  = true, -- Swift Green Mechanostrider
		[23227]  = true, -- Swift Palomino
		[23228]  = true, -- Swift White Steed
		[23229]  = true, -- Swift Brown Steed
		[23238]  = true, -- Swift Brown Ram
		[23239]  = true, -- Swift Gray Ram
		[23240]  = true, -- Swift White Ram
		[23241]  = true, -- Swift Blue Raptor
		[23242]  = true, -- Swift Olive Raptor
		[23243]  = true, -- Swift Orange Raptor
		[23246]  = true, -- Purple Skeletal Warhorse
		[23247]  = true, -- Great White Kodo
		[23248]  = true, -- Great Gray Kodo
		[23249]  = true, -- Great Brown Kodo
		[23250]  = true, -- Swift Brown Wolf
		[23251]  = true, -- Swift Timber Wolf
		[23252]  = true, -- Swift Gray Wolf
		[23338]  = true, -- Swift Stormsaber
		[23509]  = true, -- Frostwolf Howler
		[23510]  = true, -- Stormpike Battle Charger
		[24242]  = true, -- Swift Razzashi Raptor
		[24252]  = true, -- Swift Zulian Tiger
		[25953]  = true, -- Blue Qiraji Battle Tank
		[26054]  = true, -- Red Qiraji Battle Tank
		[26055]  = true, -- Yellow Qiraji Battle Tank
		[26056]  = true, -- Green Qiraji Battle Tank
		[26656]  = true, -- Black Qiraji Battle Tank
		[30174]  = true, -- Riding Turtle
		[33660]  = true, -- Swift Pink Hawkstrider
		[34406]  = true, -- Brown Elekk
		[34767]  = true, -- Summon Charger
		[34769]  = true, -- Summon Warhorse
		[34790]  = true, -- Dark War Talbuk
		[34795]  = true, -- Red Hawkstrider
		[34896]  = true, -- Cobalt War Talbuk
		[34897]  = true, -- White War Talbuk
		[34898]  = true, -- Silver War Talbuk
		[34899]  = true, -- Tan War Talbuk
		[35018]  = true, -- Purple Hawkstrider
		[35020]  = true, -- Blue Hawkstrider
		[35022]  = true, -- Black Hawkstrider
		[35025]  = true, -- Swift Green Hawkstrider
		[35027]  = true, -- Swift Purple Hawkstrider
		[35028]  = true, -- Swift Warstrider
		[35710]  = true, -- Gray Elekk
		[35711]  = true, -- Purple Elekk
		[35712]  = true, -- Great Green Elekk
		[35713]  = true, -- Great Blue Elekk
		[35714]  = true, -- Great Purple Elekk
		[36702]  = true, -- Fiery Warhorse
		[39315]  = true, -- Cobalt Riding Talbuk
		[39316]  = true, -- Dark Riding Talbuk
		[39317]  = true, -- Silver Riding Talbuk
		[39318]  = true, -- Tan Riding Talbuk
		[39319]  = true, -- White Riding Talbuk
		[41252]  = true, -- Raven Lord
		[42776]  = true, -- Spectral Tiger
		[42777]  = true, -- Swift Spectral Tiger
		[43688]  = true, -- Amani War Bear
		[43899]  = true, -- Brewfest Ram
		[43900]  = true, -- Swift Brewfest Ram
		[48027]  = true, -- Black War Elekk
		[48778]  = true, -- Acherus Deathcharger
		[49322]  = true, -- Swift Zhevra
		[49379]  = true, -- Great Brewfest Kodo
		[50869]  = true, -- Brewfest Kodo
		[51412]  = true, -- Big Battle Bear
		[54753]  = true, -- White Polar Bear
		[55531]  = true, -- Mechano-hog
		[58983]  = true, -- Big Blizzard Bear
		[59785]  = true, -- Black War Mammoth
		[59788]  = true, -- Black War Mammoth
		[59791]  = true, -- Wooly Mammoth
		[59793]  = true, -- Wooly Mammoth
		[59797]  = true, -- Ice Mammoth
		[59799]  = true, -- Ice Mammoth
		[60114]  = true, -- Armored Brown Bear
		[60116]  = true, -- Armored Brown Bear
		[60118]  = true, -- Black War Bear
		[60119]  = true, -- Black War Bear
		[60424]  = true, -- Mekgineer's Chopper
		[61229]  = true, -- Armored Snowy Gryphon
		[61230]  = true, -- Armored Blue Wind Rider
		[61309]  = true, -- Magnificent Flying Carpet
		[61425]  = true, -- Traveler's Tundra Mammoth
		[61447]  = true, -- Traveler's Tundra Mammoth
		[61465]  = true, -- Grand Black War Mammoth
		[61467]  = true, -- Grand Black War Mammoth
		[61469]  = true, -- Grand Ice Mammoth
		[61470]  = true, -- Grand Ice Mammoth
		[63232]  = true, -- Stormwind Steed
		[63635]  = true, -- Darkspear Raptor
		[63636]  = true, -- Ironforge Ram
		[63637]  = true, -- Darnassian Nightsaber
		[63638]  = true, -- Gnomeregan Mechanostrider
		[63639]  = true, -- Exodar Elekk
		[63640]  = true, -- Orgrimmar Wolf
		[63641]  = true, -- Thunder Bluff Kodo
		[63642]  = true, -- Silvermoon Hawkstrider
		[63643]  = true, -- Forsaken Warhorse
		[64656]  = true, -- Blue Skeletal Warhorse
		[64657]  = true, -- White Kodo
		[64658]  = true, -- Black Wolf
		[64659]  = true, -- Venomhide Ravasaur
		[64977]  = true, -- Black Skeletal Horse
		[65637]  = true, -- Great Red Elekk
		[65638]  = true, -- Swift Moonsaber
		[65639]  = true, -- Swift Red Hawkstrider
		[65640]  = true, -- Swift Gray Steed
		[65641]  = true, -- Great Golden Kodo
		[65642]  = true, -- Turbostrider
		[65643]  = true, -- Swift Violet Ram
		[65644]  = true, -- Swift Purple Raptor
		[65645]  = true, -- White Skeletal Warhorse
		[65646]  = true, -- Swift Burgundy Wolf
		[65917]  = true, -- Magic Rooster
		[66090]  = true, -- Quel'dorei Steed
		[66091]  = true, -- Sunreaver Hawkstrider
		[66846]  = true, -- Ochre Skeletal Warhorse
		[66847]  = true, -- Striped Dawnsaber
		[66906]  = true, -- Argent Charger
		[66907]  = true, -- Argent Warhorse
		[67466]  = true, -- Argent Warhorse
		[68056]  = true, -- Swift Horde Wolf
		[68057]  = true, -- Swift Alliance Steed
		[68187]  = true, -- Crusader's White Warhorse
		[68188]  = true, -- Crusader's Black Warhorse
		[69820]  = true, -- Summon Sunwalker Kodo
		[69826]  = true, -- Summon Great Sunwalker Kodo
		[73629]  = true, -- Summon Exarch's Elekk
		[73630]  = true, -- Summon Great Exarch's Elekk
		[74918]  = true, -- Wooly White Rhino
		[84751]  = true, -- Fossilized Raptor
		[87090]  = true, -- Goblin Trike
		[87091]  = true, -- Goblin Turbo-Trike
		[88748]  = true, -- Brown Riding Camel
		[88749]  = true, -- Tan Riding Camel
		[88750]  = true, -- Grey Riding Camel
		[89520]  = true, -- Goblin Mini Hotrod
		[90621]  = true, -- Golden King
		[92155]  = true, -- Ultramarine Qiraji Battle Tank
		[92231]  = true, -- Spectral Steed
		[92232]  = true, -- Spectral Wolf
		[93644]  = true, -- Kor'kron Annihilator
		[96491]  = true, -- Armored Razzashi Raptor
		[96499]  = true, -- Swift Zulian Panther
		[97581]  = true, -- Savage Raptor
		[98204]  = true, -- Amani Battle Bear
		[100332] = true, -- Vicious War Steed
		[100333] = true, -- Vicious War Wolf
		[101542] = true, -- Flametalon of Alyzrazor
		[101573] = true, -- Swift Shorestrider
		[102346] = true, -- Swift Forest Strider
		[102349] = true, -- Swift Springstrider
		[102350] = true, -- Swift Lovebird
		[102488] = true, -- White Riding Camel
		[103081] = true, -- Darkmoon Dancing Bear
		[103195] = true, -- Mountain Horse
		[103196] = true, -- Swift Mountain Horse
		[118089] = true, -- Azure Water Strider
		[120395] = true, -- Green Dragon Turtle
		[120822] = true, -- Great Red Dragon Turtle
		[122708] = true, -- Grand Expedition Yak
		[123160] = true, -- Crimson Riding Crane
		[123182] = true, -- White Riding Yak
		[123886] = true, -- Amber Scorpion
		[127174] = true, -- Azure Riding Crane
		[127176] = true, -- Golden Riding Crane
		[127177] = true, -- Regal Riding Crane
		[127178] = true, -- Jungle Riding Crane
		[127180] = true, -- Albino Riding Crane
		[127209] = true, -- Black Riding Yak
		[127213] = true, -- Brown Riding Yak
		[127216] = true, -- Grey Riding Yak
		[127220] = true, -- Blonde Riding Yak
		[127271] = true, -- Crimson Water Strider
		[127272] = true, -- Orange Water Strider
		[127274] = true, -- Jade Water Strider
		[127278] = true, -- Golden Water Strider
		[127286] = true, -- Black Dragon Turtle
		[127287] = true, -- Blue Dragon Turtle
		[127288] = true, -- Brown Dragon Turtle
		[127289] = true, -- Purple Dragon Turtle
		[127290] = true, -- Red Dragon Turtle
		[127293] = true, -- Great Green Dragon Turtle
		[127295] = true, -- Great Black Dragon Turtle
		[127302] = true, -- Great Blue Dragon Turtle
		[127308] = true, -- Great Brown Dragon Turtle
		[127310] = true, -- Great Purple Dragon Turtle
		[129932] = true, -- Green Shado-Pan Riding Tiger
		[129934] = true, -- Blue Shado-Pan Riding Tiger
		[129935] = true, -- Red Shado-Pan Riding Tiger
		[130138] = true, -- Black Riding Goat
		[138423] = true, -- Cobalt Primordial Direhorn
		[138424] = true, -- Amber Primordial Direhorn
		[138425] = true, -- Slate Primordial Direhorn
		[138426] = true, -- Jade Primordial Direhorn
		[138449] = true, -- Golden Primordial Direhorn
		[138450] = true, -- Crimson Primordial Direhorn
		[138640] = true, -- Bone-White Primal Raptor
		[138641] = true, -- Red Primal Raptor
		[138642] = true, -- Black Primal Raptor
		[138643] = true, -- Green Primal Raptor
		[136471] = true, -- Spawn of Horridon
	},
	water = {
		[75207] = true, -- Abyssal Seahorse
		[64731] = true, -- Sea Turtle
		[98718] = true, -- Subdued Seahorse
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

function module:GetMountType(id)
	for mountType, mounts in pairs(self.mountData) do
		if mounts[id] then
			-- #TODO: Handle ground/flying combo mounts + profesion restrictions
			return mountType, self.mountSpecial.passengers[id]
		end
	end
end