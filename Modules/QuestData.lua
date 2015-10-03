local _, private = ...
-- This file contains useful data for gossip and quest automation

-- Localized strings are added at the bottom of this file
local L = setmetatable({}, { __index = function(t, k) t[k] = k; return k end })

------------------------------------------------------------------------
-- Gossip titles that should not be automatically selected

private.GossipToIgnore = {
	-- Pandaria: Klaxxi
	[L["Grant me your assistance, Bloodseeker. [Klaxxi Augmentation]"]] = true,
	[L["Grant me your assistance, Dissector. [Klaxxi Enhancement]"]] = true,
	[L["Grant me your assistance, Iyyokuk. [Klaxxi Enhancement]"]] = true,
	[L["Grant me your assistance, Locust. [Klaxxi Augmentation]"]] = true,
	[L["Grant me your assistance, Malik. [Klaxxi Enhancement]"]] = true,
	[L["Grant me your assistance, Manipulator. [Klaxxi Augmentation]"]] = true,
	[L["Grant me your assistance, Prime. [Klaxxi Augmentation]"]] = true,
	[L["Grant me your assistance, Wind-Reaver. [Klaxxi Enhancement]"]] = true,
	[L["Please fly me to the Terrace of Gurthan"]] = true,
	-- Pandaria: Tillers
	[L["What kind of gifts do you like?"]] = true,
}

------------------------------------------------------------------------
-- Gossip titles that require dismounting, but don't dismount you automatically.

private.GossipNeedsDismount = {
	-- Pandaria
	[L["I am ready to go."]] = true, -- Jade Forest, Fei, quest "Es geht voran" -- CHECK ENGLISH
	[L["Please fly me to the Terrace of Gurthan"]] = true,
	[L["Send me to Dawn's Blossom."]] = true, -- CHECK ENGLISH
	-- Northrend
	[L["I am ready to fly to Sholazar Basin."]] = true, -- CHECK ENGLISH
	[L["I need a bat to intercept the Alliance reinforcements."]] = true, -- CHECK ENGLISH
	-- Outland
	[L["Absolutely!  Send me to the Skyguard Outpost."]] = true,
	[L["I'm on a bombing mission for Forward Command To'arch.  I need a wyvern destroyer!"]] = true,
	[L["Lend me a Windrider.  I'm going to Spinebreaker Post!"]] = true,
	[L["Send me to the Abyssal Shelf!"]] = true,
	[L["Send me to Thrallmar!"]] = true,
	[L["Yes, I'd love a ride to Blackwind Landing."]] = true,
	[L["Send me to Honor Post!"]] = true, -- Hellfire Peninusla, Gryphoneer Windbellow -- CHECK ENGLISH
	[L["Send me to Shatter Point."]] = true, -- Hellfire Peninsula, Wing Command Dabir'ee -- CHECK ENGLISH
	[L["Send me to Shatter Point."]] = true, -- Hellfire Peninusla, Gryphoneer Leafbeard -- CHECK ENGLISH
	-- Isle of Quel'Danas
	[L["I need to intercept the Dawnblade reinforcements."]] = true,
	[L["Speaking of action, I've been ordered to undertake an air strike."]] = true,
}

------------------------------------------------------------------------
-- Gossip titles to select automatically even though there are other choices

private.GossipToSelect = {
	[57850] = 1, -- Teleportologist Fozlebub, "Teleport me to the cannon."
}

------------------------------------------------------------------------
-- NPC IDs whose gossips require confirmation that should be automated

private.GossipNPCsToConfirm = {
	[54334] = true, -- Darkmoon Faire Mystic Mage (Alliance)
	[55382] = true, -- Darkmoon Faire Mystic Mage (Horde)
	[57850] = true, -- Teleportologist Fozlebub
}

------------------------------------------------------------------------
-- NPC IDs whose gossips should not be automated

private.GossipNPCsToIgnore = {
	-- Bodyguards
	[86945] = true, -- Aeda Brightdawn (Horde)
	[86927] = true, -- Delvar Ironfist (Alliance)
	[86934] = true, -- Defender Illona (Alliance)
	[86964] = true, -- Leorajh
	[86946] = true, -- Talonpriest Ishaal
	[86682] = true, -- Tormmok
	[86933] = true, -- Vivianne (Horde)
	-- Misc NPCs
	[79953] = true, -- Lieutenant Thorn (Alliance)
	[79740] = true, -- Warmaster Zog (Horde)
}

------------------------------------------------------------------------
-- Quest IDs that should not be automatically accepted

private.QuestsToIgnore = {
	-- Manual
	[29393] = true, -- Brew For Brewfest (Horde)
	[29394] = true, -- Brew For Brewfest (Alliance)
	[32296] = true, -- Treasures of the Thunder King
	-- Suboptimal rewards: Blue Feather, Jade Cat, Lovely Apple, Marsh Lily, Ruby Shard
	[30382] = true, [30419] = true, [30425] = true, [30388] = true, [30412] = true, [30437] = true, [30406] = true, [30431] = true,
	[30399] = true, [30418] = true, [30387] = true, [30411] = true, [30436] = true, [30393] = true, [30405] = true, [30430] = true,
	[30398] = true, [30189] = true, [30417] = true, [30423] = true, [30380] = true, [30410] = true, [30392] = true, [30429] = true,
	[30401] = true, [30383] = true, [30426] = true, [30413] = true, [30438] = true, [30395] = true, [30407] = true, [30432] = true,
	[30397] = true, [30160] = true, [30416] = true, [30422] = true, [30379] = true, [30434] = true, [30391] = true, [30403] = true,
	-- Mutually exclusive: Work Order
	[32642] = true, [32647] = true, [32645] = true, [32649] = true, [32653] = true, [32658] = true,
	-- Mutually exclusive: Fiona's Caravan
	[27560] = true, [27562] = true, [27555] = true, [27556] = true, [27558] = true, [27561] = true, [27557] = true, [27559] = true,
	-- Mutually exclusive: Allegiance to the Aldor/Scryers
	[10551] = true, [10552] = true,
	-- Mutually exclusive: Little Orphan Kekek/Roo of the Wolvar/Oracles
	[13927] = true, [13926] = true,
	-- No reward: Return to the Abyssal Shelf (Alliance/Horde)
	[10346] = true, [10347] = true,
	-- Stuck on 5-minute flight: To Venomspite!
	[12182] = true,
	-- Profession specializations: Elixir/Potion/Transmutation Master, Goblin/Gnomish Engineering
	[29481] = true, [29067] = true, [29482] = true,
	[29475] = true, [29477] = true,
}

------------------------------------------------------------------------
-- NPC IDs who have no quests that should be automated

private.QuestNPCsToIgnore = {
	[88570] = true, -- Fate-Twister Tiklal
	[87391] = true, -- Fate-Twister Seress
}

------------------------------------------------------------------------
-- Information about repeatable quests

private.RepeatableQuestRequirements = {
	-- Draenor
	[35147] = {118099,20}, -- Fragments of the Past -> 20 Gorian Artifact Fragment
	[37125] = 118100, -- A Rare Find -> Highmaul Relic
	[37210] = 118654, -- Aogexon's Fang
	[37211] = 118655, -- Bergruu's Horn
	[37221] = 118656, -- Dekorhan's Tusk
	[37222] = 118657, -- Direhoof's Hide
	[37223] = 118658, -- Gagrog's Skull
	[37224] = 118659, -- Mu'gra's Head
	[37225] = 118660, -- Thek'talon's Talon
	[37226] = 118661, -- Xelganak's Stinger
	[37520] = 120172, -- Vileclaw's Claw
	-- Pandaria
	[31535] = 87557, -- Replenishing the Pantry -> Bundle of Groceries
	[31603] = {87903,6}, -- Seeds of Fear -> 6 Dread Amber Shards
}

------------------------------------------------------------------------
-- Values for quest reward containers that contain cash

private.QuestRewardValues = {
	[45724] = 100000,  --  10g: Champion's Purse
	[64491] = 2000000, -- 200g: Royal Reward
}

------------------------------------------------------------------------
-- Transform quest IDs into localized quest names

local queue = {}
local toLocalize = {
	private.QuestsToIgnore,
	private.RepeatableQuestRequirements,
}
for _, t in pairs(toLocalize) do
	for id in pairs(t) do
		if type(id) == "number" then
			queue[id] = t
		end
	end
end

local GetQuestName
do
	local tooltip
	function GetQuestName(id)
		if not tooltip then
			tooltip = CreateFrame("GameTooltip")
			tooltip.title = tooltip:CreateFontString(nil, "OVERLAY", "GameTooltipHeaderText")
			tooltip:AddFontStrings(tooltip.title, tooltip:CreateFontString(nil, "OVERLAY", "GameTooltipHeaderText"))
			tooltip:SetOwner(UIParent, "ANCHOR_NONE")
		end
		tooltip:SetHyperlink("quest:" .. id)
		return tooltip.title:GetText()
	end
end

function private.LocalizeQuestNames()
	for id, t in pairs(queue) do
		local name = GetQuestName(id)
		if name then
			t[name] = t[id]
			queue[id] = nil
		end
	end
end

------------------------------------------------------------------------
-- Determine whether repeatable quest is complete

function private.IsRepeatableQuestCompletable(name)
	local requires = private.RepeatableQuestRequirements[name]
	if type(requires) == "table" then
		for i = 1, #requires, 2 do
			local item, count = requires[i], requires[i+1]
			if GetItemCount(item) < count then
				return false
			end
		end
		return true
	elseif type(requires) == "number" then
		return GetItemCount(requires) >= 1
	end
	-- No data, or invalid data
	return true
end

------------------------------------------------------------------------
-- Localization

local LOCALE = GetLocale()

if LOCALE == "deDE" then
	--L["Absolutely!  Send me to the Skyguard Outpost."] = ""
	--L["Grant me your assistance, Bloodseeker. [Klaxxi Augmentation]"] = ""
	--L["Grant me your assistance, Dissector. [Klaxxi Enhancement]"] = ""
	--L["Grant me your assistance, Iyyokuk. [Klaxxi Enhancement]"] = ""
	--L["Grant me your assistance, Locust. [Klaxxi Augmentation]"] = ""
	--L["Grant me your assistance, Malik. [Klaxxi Enhancement]"] = ""
	--L["Grant me your assistance, Manipulator. [Klaxxi Augmentation]"] = ""
	--L["Grant me your assistance, Prime. [Klaxxi Augmentation]"] = ""
	--L["Grant me your assistance, Wind-Reaver. [Klaxxi Enhancement]"] = ""
	L["I am ready to fly to Sholazar Basin."] = "Ich bin bereit, ins Sholazarbecken zu fliegen."
	L["I am ready to go."] = "Ich bin bereit zu gehen."
	L["I need a bat to intercept the Alliance reinforcements."] = "Ich brauche eine Reitfledermaus, um die Verstärkung der Allianz abzufangen."
	--L["I need to intercept the Dawnblade reinforcements."] = ""
	L["I'm on a bombing mission for Forward Command To'arch.  I need a wyvern destroyer!"] = "Ich habe einen Bomberauftrag von Vorpostenkommandant To'arch. Ich brauche einen Wyverzerstörer!"
	L["Lend me a Windrider.  I'm going to Spinebreaker Post!"] = "Gebt mir ein Windreiter. Ich werde zum Rückenbrecherposten fliegen!"
	--L["Please fly me to the Terrace of Gurthan"] = ""
	L["Send me to Dawn's Blossom."] = "Schickt mich nach Morgenblüte."
	L["Send me to Honor Post!"] = "Schick mich zum Ehrenposten!"
	L["Send me to Shatter Point."] = "Schick mich zum Trümmerposten."
	L["Send me to the Abyssal Shelf!"] = "Schickt mich zur abyssischen Untiefe!"
	L["Send me to Thrallmar!"] = "Schickt mich nach Thrallmar!"
	--L["Speaking of action, I've been ordered to undertake an air strike."] = ""
	--L["What kind of gifts do you like?"] = ""
	--L["Yes, I'd love a ride to Blackwind Landing."] = ""
return end