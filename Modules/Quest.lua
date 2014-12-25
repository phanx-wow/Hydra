--[[--------------------------------------------------------------------
	Hydra
	Multibox leveling helper.
	Copyright (c) 2010-2014 Phanx <addons@phanx.net>. All rights reserved.
	http://www.wowinterface.com/downloads/info17572-Hydra.html
	http://www.curse.com/addons/wow/hydra
	https://github.com/Phanx/Hydra
------------------------------------------------------------------------
	Hydra Quest
	* Shares quests accepted from NPCs with party members
	* Accepts quests shared by party members
	* Accepts quests from NPCs that another party member already accepted
	* Accepts shared starts for escort-type quests
	* Turns in completed quests
	* Abandons quests abandoned by party members

	To do:
	* Hide "X has already completed that quest" messages for autoshared quests

	Credits:
	* Industrial - idQuestAutomation
	* p3lim - Monomyth
	* Shadowed - GetToThePoint
	* Tekkub - Quecho
----------------------------------------------------------------------]]

local _, Hydra = ...
local L = Hydra.L
local SOLO, PARTY, TRUSTED, LEADER = Hydra.STATE_SOLO, Hydra.STATE_PARTY, Hydra.STATE_TRUSTED, Hydra.STATE_LEADER
local PLAYER_FULLNAME, PLAYER_NAME, PLAYER_REALM = Hydra.PLAYER_FULLNAME, Hydra.PLAYER_NAME, Hydra.PLAYER_REALM

local Quest = Hydra:NewModule("Quest")
Quest.defaults = {
	enable = true,
	accept = true,
	acceptOnlyShared = false,
	turnin = true,
	share = false,
	abandon = false,
}

local ACTION_ABANDON, ACTION_ACCEPT, ACTION_TURNIN = "ABANDON", "ACCEPT", "TURNIN"
local accept, accepted = {}, {}
local PopulateQuestNames

------------------------------------------------------------------------

function Quest:ShouldEnable()
	return self.db.enable
end

function Quest:OnEnable()
	-- Fill in quest names that the client was too slow to get in the main chunk:
	if PopulateQuestNames and PopulateQuestNames() then
		PopulateQuestNames = nil
	end

	self:RegisterEvent("GOSSIP_SHOW")
	self:RegisterEvent("QUEST_GREETING")
	self:RegisterEvent("QUEST_DETAIL")
	self:RegisterEvent("QUEST_ACCEPT_CONFIRM")
	self:RegisterEvent("QUEST_ACCEPTED")
	self:RegisterEvent("QUEST_PROGRESS")
	self:RegisterEvent("QUEST_COMPLETE")
	self:RegisterEvent("QUEST_ITEM_UPDATE")
	self:RegisterEvent("QUEST_FINISHED")
	self:RegisterEvent("QUEST_AUTOCOMPLETE")

	if Hydra.state > SOLO then
		self:RegisterEvent("QUEST_ACCEPT_CONFIRM")
		self:RegisterEvent("QUEST_LOG_UPDATE")
	end
end

------------------------------------------------------------------------

local function GetQuestName(id)
	GameTooltip:SetOwner(UIParent, "ANCHOR_NONE")
	GameTooltip:SetHyperlink("quest:" .. id)
	local name = GameTooltipTextLeft1:GetText()
	GameTooltip:Hide()
	return name or id
end

local function CleanLink(link)
	link = gsub("|c%x%x%x%x%x%x%x%x", "")
	link = gsub("|r", "")
	return link
end

--	No API to see if a repeatable quest can be completed.
local repeatableQuestComplete = {
	-- Replenishing the Pantry
	[GetQuestName(31535)] = function() return GetItemCount(87557) >= 1 end, -- Bundle of Groceries
	-- Seeds of Fear
	[GetQuestName(31603)] = function() return GetItemCount(87903) >= 6 end, -- Dread Amber Shards
}

local ignoredQuests = {
	-- Manual
	[GetQuestName(32296)] = true, -- Treasures of the Thunder King
	-- Suboptimal rewards: Blue Feather, Jade Cat, Lovely Apple, Marsh Lily, Ruby Shard
	[GetQuestName(30382)] = true, [GetQuestName(30419)] = true, [GetQuestName(30425)] = true, [GetQuestName(30388)] = true, [GetQuestName(30412)] = true, [GetQuestName(30437)] = true, [GetQuestName(30406)] = true, [GetQuestName(30431)] = true,
	[GetQuestName(30399)] = true, [GetQuestName(30418)] = true, [GetQuestName(30387)] = true, [GetQuestName(30411)] = true, [GetQuestName(30436)] = true, [GetQuestName(30393)] = true, [GetQuestName(30405)] = true, [GetQuestName(30430)] = true,
	[GetQuestName(30398)] = true, [GetQuestName(30189)] = true, [GetQuestName(30417)] = true, [GetQuestName(30423)] = true, [GetQuestName(30380)] = true, [GetQuestName(30410)] = true, [GetQuestName(30392)] = true, [GetQuestName(30429)] = true,
	[GetQuestName(30401)] = true, [GetQuestName(30383)] = true, [GetQuestName(30426)] = true, [GetQuestName(30413)] = true, [GetQuestName(30438)] = true, [GetQuestName(30395)] = true, [GetQuestName(30407)] = true, [GetQuestName(30432)] = true,
	[GetQuestName(30397)] = true, [GetQuestName(30160)] = true, [GetQuestName(30416)] = true, [GetQuestName(30422)] = true, [GetQuestName(30379)] = true, [GetQuestName(30434)] = true, [GetQuestName(30391)] = true, [GetQuestName(30403)] = true,
	-- Mutually exclusive: Work Order
	[GetQuestName(32642)] = true, [GetQuestName(32647)] = true, [GetQuestName(32645)] = true, [GetQuestName(32649)] = true, [GetQuestName(32653)] = true, [GetQuestName(32658)] = true,
	-- Mutually exclusive: Fiona's Caravan
	[GetQuestName(27560)] = true, [GetQuestName(27562)] = true, [GetQuestName(27555)] = true, [GetQuestName(27556)] = true, [GetQuestName(27558)] = true, [GetQuestName(27561)] = true, [GetQuestName(27557)] = true, [GetQuestName(27559)] = true,
	-- Mutually exclusive: Allegiance to the Aldor/Scryers
	[GetQuestName(10551)] = true, [GetQuestName(10552)] = true,
	-- Mutually exclusive: Little Orphan Kekek/Roo of the Wolvar/Oracles
	[GetQuestName(13927)] = true, [GetQuestName(13926)] = true,
	-- No reward: Return to the Abyssal Shelf (Alliance/Horde)
	[GetQuestName(10346)] = true, [GetQuestName(10347)] = true,
	-- Stuck on 5-minute flight: To Venomspite!
	[GetQuestName(12182)] = true,
	-- Profession specializations: Elixir/Potion/Transmutation Master, Goblin/Gnomish Engineering
	[GetQuestName(29481)] = true, [GetQuestName(29067)] = true, [GetQuestName(29482)] = true,
	[GetQuestName(29475)] = true, [GetQuestName(29477)] = true,
}

HQIGNORE = ignoredQuests -- debugging

function PopulateQuestNames() -- local at top of file
	Quest:Debug("PopulateQuestNames")
	local complete = true
	for id, func in pairs(repeatableQuestComplete) do
		if type(id) == "number" then
			local name = GetQuestName(id)
			if name then
				repeatableQuestComplete[name] = func
				repeatableQuestComplete[id] = nil
			else
				Quest:Debug("Repeatable quest name not found: |Hquest:"..id.."|h[quest:"..id.."]|h")
				complete = false
			end
		end
	end
	for id in pairs(ignoredQuests) do
		if type(id) == "number" then
			local name = GetQuestName(id)
			if name then
				ignoredQuests[name] = true
				ignoredQuests[id] = nil
			else
				Quest:Debug("Ignored quest name not found: |Hquest:"..id.."|h[quest:"..id.."]|h")
				complete = false
			end
		end
	end
	return complete
end

------------------------------------------------------------------------

function Quest:QUEST_ACCEPT_CONFIRM(name, qname)
	local target = Ambiguate(name, "none")
	if self.db.accept and (UnitInRaid(target) or UnitInParty(target)) then
		self:Debug("Accepting quest", qname, "started by", name)
		ConfirmAcceptQuest()
		StaticPopup_Hide("QUEST_ACCEPT")
	end
end

------------------------------------------------------------------------
--	Respond to comms from others
------------------------------------------------------------------------

function Quest:OnAddonMessage(message, channel, sender)
	if not Hydra:IsTrusted(sender) then return end
	self:Debug("OnAddonMessage", sender, message)

	local action, qlink = strsplit(" ", message, 2)
	local qid, qname = strmatch(strlower(qlink), "quest:(%d+).*%[(.-)%]")

	if action == ACTION_ACCEPT then
		if not accepted[qname] then
			accept[qname] = qlink
		end
		return self:Print(L.QuestAccepted, sender, qlink)

	elseif action == ACTION_TURNIN then
		return self:Print(L.QuestTurnedIn, sender, qlink)

	elseif action == ACTION_ABANDON and self.db.abandon then
		for i = 1, GetNumQuestLogEntries() do
			local link = GetQuestLink(i)
			if link then
				local id, name = strmatch(strlower(link), "quest:(%d+).*%[(.-)%]")
				if id == qid then
					SelectQuestLogEntry(i)
					SetAbandonQuest()
					AbandonQuest()
					PlaySound("igQuestLogAbandonQuest")
					accept[qname], accepted[qname] = nil, nil
					return self:Print(L.QuestAbandoned, sender, qlink)
				end
			end
		end
	end
end

------------------------------------------------------------------------
--	Accept quests accepted by other party members
------------------------------------------------------------------------

local function StripTitle(text)
	if not text then return "" end
	text = gsub(text, "%[.*%]%s*","")
	text = gsub(text, "|c%x%x%x%x%x%x%x%x(.+)|r","%1")
	text = gsub(text, "(.+) %(.+%)", "%1")
	return strtrim(text)
end

local function IsTrackingTrivial()
	for i = 1, GetNumTrackingTypes() do
		local name, _, active = GetTrackingInfo(i)
		if name == MINIMAP_TRACKING_TRIVIAL_QUESTS then
			return active
		end
	end
end

function Quest:GOSSIP_SHOW()
	self:Debug("GOSSIP_SHOW")
	if IsShiftKeyDown() then return end

	-- Turn in complete quests:
	if self.db.turnin then
		for i = 1, GetNumGossipActiveQuests() do
			local title, level, isLowLevel, isComplete, isLegendary = select(i * 5 - 4, GetGossipActiveQuests())
			if isComplete and not ignoredQuests[title] then
				return SelectGossipActiveQuest(i)
			end
		end
	end

	-- Pick up available quests:
	for i = 1, GetNumGossipAvailableQuests() do
		local title, level, isLowLevel, isDaily, isRepeatable, isLegendary = select(i * 6 - 5, GetGossipAvailableQuests())
		self:Debug(i, '"'..title..'"', isLowLevel, isRepeatable)
		if not ignoredQuests[title] then
			local go
			if isRepeatable and repeatableQuestComplete[title] then
				go = repeatableQuestComplete[title]()
				self:Debug("Repeatable", go)
			elseif self.db.acceptOnlyShared then
				go = accept[strlower(title)]
				self:Debug("Shared", go)
			elseif self.db.accept then
				go = not isLowLevel or IsTrackingTrivial()
				self:Debug("Accept", go)
			end
			if go then
				self:Debug("Go!")
				return SelectGossipAvailableQuest(i)
			end
		end
	end
end

function Quest:QUEST_GREETING()
	self:Debug("QUEST_GREETING")
	if IsShiftKeyDown() then return end

	-- Turn in complete quests:
	if self.db.turnin then
		for i = 1, GetNumActiveQuests() do
			local title, complete = GetActiveTitle(i)
			title = StripTitle(title)
			self:Debug("Checking active quest:", title)
			if complete and not ignoredQuests[title] then
				self:Debug("Selecting complete quest", title)
				SelectActiveQuest(i)
			end
		end
	end

	-- Pick up available quests:
	if self.db.accept then
		for i = 1, GetNumAvailableQuests() do
			local title = StripTitle(GetAvailableTitle(i))
			self:Debug("Checking available quest:", title)
			if not ignoredQuests[title] then
				local go
				if self.db.acceptOnlyShared then
					go = accept[strlower(title)]
				else
					go = not IsAvailableQuestTrivial(i) or not IsTrackingTrivial()
				end
				if go then
					self:Debug("Selecting available quest", (GetActiveTitle(i)))
					SelectAvailableQuest(i)
				end
			end
		end
	end
end

function Quest:QUEST_DETAIL()
	self:Debug("QUEST_DETAIL")
	if IsShiftKeyDown() then return end

	local quest = StripTitle(GetTitleText())
	local giver = UnitName("questnpc")

	if QuestGetAutoAccept() then
		self:Debug("Hiding window for auto-accepted quest", quest)
		QuestFrame:Hide()
	elseif self.db.accept then
		local go
		if self.db.acceptOnlyShared then
			if not UnitInParty(giver) and not UnitInRaid(giver) and not accept[strlower(quest)] then return end
			accepted[strlower(quest)] = true
		else
			local item, _, _, _, minLevel = GetItemInfo(giver or "")
			if item and minLevel and minLevel > 1 and (UnitLevel("player") - minLevel > GetQuestGreenRange()) and not IsTrackingTrivial() then return end
			-- No way to get the quest level from the item, so if the item
			-- doesn't have a level requirement, we just have to try.
		end
		self:Debug("Accepting quest", quest, "from", giver)
		AcceptQuest()
	end
end

function Quest:QUEST_ACCEPT_CONFIRM(giver, quest)
	self:Debug("QUEST_ACCEPT_CONFIRM", giver, quest)
	if not self.db.accept or IsShiftKeyDown() then return end

	if self.db.acceptOnlyShared then
		if not accept[strlower(quest)] then return end
		accepted[strlower(quest)] = true
	end

	self:Debug("Accepting quest", quest, "from", giver)
	AcceptQuest()
end

function Quest:QUEST_ACCEPTED(id)
	self:Debug("QUEST_ACCEPTED", id)
	if not GetCVarBool("autoQuestWatch") or IsQuestWatched(id) or GetNumQuestWatches() >= MAX_WATCHABLE_QUESTS then return end

	self:Debug("Adding quest to tracker")
	AddQuestWatch(id)
end

------------------------------------------------------------------------
--	Turn in completed quests
------------------------------------------------------------------------

function Quest:QUEST_PROGRESS()
	self:Debug("QUEST_PROGRESS")
	if not self.db.turnin or IsShiftKeyDown() or not IsQuestCompletable() then return end

	self:Debug("Completing quest", StripTitle(GetTitleText()))
	CompleteQuest()
end

local choicePending, choiceFinished

function Quest:QUEST_ITEM_UPDATE()
	if choicePending then
		self:QUEST_COMPLETE("QUEST_ITEM_UPDATE")
	end
end

function Quest:QUEST_COMPLETE(source)
	if source ~= "QUEST_ITEM_UPDATE" then
		self:Debug("QUEST_COMPLETE")
		if not self.db.turnin or IsShiftKeyDown() then return end
	end
	local choices = GetNumQuestChoices()
	if choices > 1 then
		self:Debug("Quest has multiple rewards, not automating")
		QuestRewardScrollFrame:SetVerticalScroll(QuestRewardScrollFrame:GetVerticalScrollRange())

		local best, bestID = 0
		for i = 1, choices do
			local link = GetQuestItemLink("choice", i)
			if link then
				local _, _, _, _, _, _, _, _, _, _, value = GetItemInfo(link)
				if strmatch(link, "item:45724%D") then
					-- Champion's Purse, 10g
					value = 100000
				end
				if value and value > 0 and value > best then
					best, bestID = value, i
				end
			else
				choicePending = true
				return GetQuestItemInfo("choice", i)
			end
		end
		if bestID then
			choiceFinished = true
			QuestInfoItem_OnClick(_G["QuestInfoRewardsFrameQuestInfoItem"..bestID])
		end
	else
		self:Debug("Completing quest", StripTitle(GetTitleText()), choices == 1 and "with only reward" or "with no reward")
		GetQuestReward(1)
	end
end

function Quest:QUEST_FINISHED()
	self:Debug("QUEST_FINISHED")
	if choiceFinished then
		choicePending = false
	end
end

function Quest:QUEST_AUTOCOMPLETE(id)
	self:Debug("QUEST_AUTOCOMPLETE", id)
	local index = GetQuestLogIndexByID(id)
	if GetQuestLogIsAutoComplete(index) then
		ShowQuestComplete(index)
	end
end

------------------------------------------------------------------------
--	Communicate my actions
------------------------------------------------------------------------

local currentquests, oldquests, firstscan, abandoning = {}, {}, true

local qids = setmetatable({}, { __index = function(t,i)
	local v = tonumber(i:match("|Hquest:(%d+):"))
	t[i] = v
	return v
end })

function Quest:QUEST_LOG_UPDATE()
	currentquests, oldquests = oldquests, currentquests
	wipe(currentquests)

	for i = 1, GetNumQuestLogEntries() do
		local link = GetQuestLink(i)
		if link then
			currentquests[qids[link]] = link
		end
	end

	if firstscan then
		firstscan = nil
		return
	end

	for id, link in pairs(oldquests) do
		if not currentquests[id] then
			if abandoning then
				self:Debug("Abandoned quest", link)
				self:SendAddonMessage(ACTION_ABANDON .. " " .. link)
			else
				self:Debug("Turned in quest", link)
				self:SendAddonMessage(ACTION_TURNIN .. " " .. link)
			end
		end
	end

	abandoning = nil

	for id, link in pairs(currentquests) do
		if not oldquests[id] then
			self:Debug("Accepted quest", link)
			self:SendAddonMessage(ACTION_ACCEPT .. " " .. link)

			local qname = link:match("%[(.-)%]"):lower()
			if self.db.share and not accept[qname] and not accepted[qname] then
				for i = 1, GetNumQuestLogEntries() do
					if link == GetQuestLink(i) then
						SelectQuestLogEntry(i)
						if GetQuestLogPushable() then
							self:Debug("Sharing quest...")
							QuestLogPushQuest()
						else
							Hydra:Print(L.QuestNotShareable)
						end
					end
				end
			end
		end
	end
end

local abandon = AbandonQuest
function AbandonQuest(...)
	abandoning = true
	return abandon(...)
end

------------------------------------------------------------------------

Quest.displayName = L.Quest
function Quest:SetupOptions(panel)
	local title, notes = panel:CreateHeader(L.Quest, L.Quest_Info)

	local enable, accept, acceptOnlyShared, turnin, share, abandon

	local function OnValueChanged(self, value)
		Quest.db[self.key] = value
		if self.key == "enable" then
			accept:SetEnabled(value)
			acceptOnlyShared:SetEnabled(value and Quest.db.accept)
			turnin:SetEnabled(value)
			share:SetEnabled(value)
			abandon:SetEnabled(value)
			Quest:Refresh()
		elseif self.key == "accept" then
			acceptOnlyShared:SetEnabled(value)
		end
	end

	enable = panel:CreateCheckbox(L.Enable, L.Enable_Info)
	enable:SetPoint("TOPLEFT", notes, "BOTTOMLEFT", 0, -8)
	enable.OnValueChanged = OnValueChanged
	enable.key = "enable"

	accept = panel:CreateCheckbox(L.AcceptQuests, L.AcceptQuests_Info)
	accept:SetPoint("TOPLEFT", enable, "BOTTOMLEFT", 0, -8)
	accept.OnValueChanged = OnValueChanged
	accept.key = "accept"

	acceptOnlyShared = panel:CreateCheckbox(L.OnlySharedQuests, L.OnlySharedQuests_Info)
	acceptOnlyShared:SetPoint("TOPLEFT", accept, "BOTTOMLEFT", 26, -8)
	acceptOnlyShared.OnValueChanged = OnValueChanged
	acceptOnlyShared.key = "acceptOnlyShared"

	turnin = panel:CreateCheckbox(L.TurnInQuests, L.TurnInQuests_Info)
	turnin:SetPoint("TOPLEFT", acceptOnlyShared, "BOTTOMLEFT", -26, -8)
	turnin.OnValueChanged = OnValueChanged
	turnin.key = "turnin"

	share = panel:CreateCheckbox(L.ShareQuests, L.ShareQuests_Info)
	share:SetPoint("TOPLEFT", turnin, "BOTTOMLEFT", 0, -8)
	share.OnValueChanged = OnValueChanged
	share.key = "share"

	abandon = panel:CreateCheckbox(L.AbandonQuests, L.AbandonQuests_Info)
	abandon:SetPoint("TOPLEFT", share, "BOTTOMLEFT", 0, -8)
	abandon.OnValueChanged = OnValueChanged
	abandon.key = "abandon"

	local help = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	help:SetPoint("BOTTOMLEFT", 16, 16)
	help:SetPoint("BOTTOMRIGHT", -16, 16)
	help:SetHeight(112)
	help:SetJustifyH("LEFT")
	help:SetJustifyV("BOTTOM")
	help:SetText(L.QuestHelpText)

	panel.refresh = function()
		local enabled = Quest.db.enable

		enable:SetChecked(enabled)
		accept:SetChecked(Quest.db.accept)
		acceptOnlyShared:SetChecked(Quest.db.acceptOnlyShared)
		turnin:SetChecked(Quest.db.turnin)
		share:SetChecked(Quest.db.share)
		abandon:SetChecked(Quest.db.abandon)

		accept:SetEnabled(enabled)
		acceptOnlyShared:SetEnabled(enabled and Quest.db.accept)
		turnin:SetEnabled(enabled)
		share:SetEnabled(enabled)
		abandon:SetEnabled(enabled)
	end
end