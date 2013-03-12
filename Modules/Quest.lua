--[[--------------------------------------------------------------------
	Hydra
	Multibox leveling helper.
	Copyright (c) 2010-2013 Phanx <addons@phanx.net>. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info17572-Hydra.html
	http://www.curse.com/addons/wow/hydra
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

local _, core = ...

local L = core.L

local SOLO, PARTY, TRUSTED, LEADER = 0, 1, 2, 3
local playerName = UnitName("player")

local accept, accepted = {}, {}

local module = core:RegisterModule("Quest", CreateFrame("Frame"))
module:SetScript("OnEvent", function(f, e, ...) return f[e] and f[e](f, ...) end)

module.defaults = { enable = true, accept = true, acceptOnlyShared = false, turnin = true, share = true, abandon = true }

------------------------------------------------------------------------

function module:CheckState()
	self:UnregisterAllEvents()
	if self.db.enable then
		self:Debug("Enable module: Quest")

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

		if core.state > SOLO then
			self:RegisterEvent("CHAT_MSG_ADDON")
			self:RegisterEvent("QUEST_ACCEPT_CONFIRM")
			self:RegisterEvent("QUEST_LOG_UPDATE")

			if not IsAddonMessagePrefixRegistered("HydraQuest") then
				RegisterAddonMessagePrefix("HydraQuest")
			end
		end
	else
		self:Debug("Quest module disabled.")
	end
end

------------------------------------------------------------------------

local function strip(text)
	if not text then return "" end
	text = gsub(text, "%[.*%]%s*","")
	text = gsub(text, "|c%x%x%x%x%x%x%x%x(.+)|r","%1")
	text = gsub(text, "(.+) %(.+%)", "%1")
	return strtrim(text)
end

------------------------------------------------------------------------

function module:QUEST_ACCEPT_CONFIRM(name, qname)
	if self.db.accept and (UnitInRaid(name) or UnitInParty(name)) then
		self:Debug("Accepting quest", qname, "started by", name)
		ConfirmAcceptQuest()
		StaticPopup_Hide("QUEST_ACCEPT")
	end
end

------------------------------------------------------------------------
--	Respond to comms from others
------------------------------------------------------------------------

function module:CHAT_MSG_ADDON(prefix, message, channel, sender)
	if prefix ~= "HydraQuest" or sender == playerName or not core:IsTrusted(sender) then return end

	local action, qlink = message:match("^(%S+) (.+)$")

	if action == "ACCEPT" then
		local qname = qlink:match("%[(.-)%]"):lower()
		if not accepted[qname] then
			accept[qname] = qlink
		end
		return self:Print(L.QuestAccepted, sender, qlink)

	elseif action == "TURNIN" then
		return self:Print(L.QuestTurnedIn, sender, qlink)

	elseif action == "ABANDON" and self.db.abandon then
		for i = 1, GetNumQuestLogEntries() do
			local link = GetQuestLink(i)
			if link == qlink then
				SelectQuestLogEntry(i)
				SetAbandonQuest()
				AbandonQuest()
				return self:Print(L.QuestAbandoned, sender, qlink)
			end
		end
	end
end

------------------------------------------------------------------------
--	Accept quests accepted by other party members
------------------------------------------------------------------------

local function IsTrackingTrivial()
	for i = 1, GetNumTrackingTypes() do
		local name, _, active = GetTrackingInfo(i)
		if name == MINIMAP_TRACKING_TRIVIAL_QUESTS then
			return active
		end
	end
end

local function GetGossipAvailableQuestTitle(i)
	return (select(((i * 6) - 6) + 1, GetGossipAvailableQuests()))
end

local function IsGossipAvailableQuestTrivial(i)
	return not not select(((i * 6) - 6) + 3, GetGossipAvailableQuests())
end

local function IsGossipActiveQuestCompleted(i)
	return not not select(((i * 5) - 5) + 4, GetGossipActiveQuests())
end

function module:GOSSIP_SHOW()
	self:Debug("GOSSIP_SHOW")
	if IsShiftKeyDown() then return end

	-- Turn in complete quests:
	if self.db.turnin then
		for i = 1, GetNumGossipActiveQuests() do
			if IsGossipActiveQuestCompleted(i) then
				SelectGossipActiveQuest(i)
			end
		end
	end

	-- Pick up available quests:
	for i = 1, GetNumGossipAvailableQuests() do
		local go
		if self.db.acceptOnlyShared then
			go = accept[strlower(GetGossipAvailableQuestTitle(i))]
		elseif self.db.accept then
			go = not IsGossipAvailableQuestTrivial(i) or IsTrackingTrivial()
		end
		if go then
			SelectGossipAvailableQuest(i)
		end
	end
end

function module:QUEST_GREETING()
	self:Debug("QUEST_GREETING")
	if IsShiftKeyDown() then return end

	-- Turn in complete quests:
	if self.db.turnin then
		for i = 1, GetNumActiveQuests() do
			local title, complete = GetActiveTitle(i)
			if complete then
				self:Debug("Selecting complete quest", strip(title))
				SelectActiveQuest(i)
			end
		end
	end

	-- Pick up available quests:
	if self.db.accept then
		for i = 1, GetNumAvailableQuests() do
			local title = strip(GetActiveTitle(i))

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

function module:QUEST_DETAIL()
	self:Debug("QUEST_DETAIL")
	if IsShiftKeyDown() then return end

	local quest = strip(GetTitleText())
	local giver = UnitName("questnpc")

	if QuestGetAutoAccept() then
		self:Debug("Hiding window for auto-accepted quest", quest)
		QuestFrame:Hide()
	elseif self.db.accept then
		local go
		if self.db.acceptOnlyShared then
			go = accept[strlower(quest)]
			accepted[strlower(quest)] = true
		else
			local item, _, _, _, minLevel = GetItemInfo(giver or "")
			if item and minLevel and minLevel > 1 then
				-- Guess based on the item's required level.
				go = IsTrackingTrivial() or (UnitLevel("player") - minLevel <= GetQuestGreenRange())
			else
				-- No way to check the level from here.
				go = true
			end
		end

		if go then
			self:Debug("Accepting quest", quest, "from", giver)
			AcceptQuest()
		end
	end
end

function module:QUEST_ACCEPT_CONFIRM(giver, quest)
	self:Debug("QUEST_ACCEPT_CONFIRM", giver, quest)
	if not self.db.accept or IsShiftKeyDown() then return end

	local go
	if self.db.acceptOnlyShared then
		go = accept[strlower(quest)]
		accepted[strlower(quest)] = true
	else
		go = true
	end

	if go then
		self:Debug("Accepting quest", quest, "from", giver)
		AcceptQuest()
	end
end

function module:QUEST_ACCEPTED(id)
	self:Debug("QUEST_ACCEPTED", id)
	if GetCVarBool("autoQuestWatch") and not IsQuestWatched(id) and GetNumQuestWatches() < MAX_WATCHABLE_QUESTS then
		self:Debug("Adding quest to tracker")
		AddQuestWatch(id)
	end
end

------------------------------------------------------------------------
--	Start quests from items
------------------------------------------------------------------------

local ignoreItems = {
	[79340] = true, -- Inscribed Crane Staff
	[79341] = true, -- Inscribed Serpent Staff
	[79343] = true, -- Inscribed Tiger Staff
	[74034] = true, -- Pit Fighter
}

------------------------------------------------------------------------
--	Turn in completed quests
------------------------------------------------------------------------

function module:QUEST_PROGRESS()
	self:Debug("QUEST_PROGRESS")
	if not self.db.turnin or IsShiftKeyDown() then return end

	if IsQuestCompletable() then
		self:Debug("Completing quest", strip(GetTitleText()))
		CompleteQuest()
	end
end

local choicePending, choiceFinished

function module:QUEST_ITEM_UPDATE()
	if choicePending then
		self:QUEST_COMPLETE("QUEST_ITEM_UPDATE")
	end
end

function module:QUEST_COMPLETE(source)
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
				if strmatch(link, "item:45724") then
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
			_G["QuestInfoItem"..bestID]:Click()
		end
	else
		self:Debug("Completing quest", strip(GetTitleText()), choices == 1 and "with only reward" or "with no reward")
		GetQuestReward(1)
	end
end

function module:QUEST_FINISHED()
	self:Debug("QUEST_FINISHED")
	if choiceFinished then
		choicePending = false
	end
end

function module:QUEST_AUTOCOMPLETE(id)
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

function module:QUEST_LOG_UPDATE()
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
				self:SendAddonMessage("HydraQuest", "ABANDON " .. link)
			else
				self:Debug("Turned in quest", link)
				self:SendAddonMessage("HydraQuest", "TURNIN " .. link)
			end
		end
	end

	abandoning = nil

	for id, link in pairs(currentquests) do
		if not oldquests[ id ] then
			self:Debug("Accepted quest", link)
			self:SendAddonMessage("HydraQuest", "ACCEPT " .. link)

			local qname = link:match("%[(.-)%]"):lower()
			if self.db.share and not accept[ qname ] and not accepted[ qname ] then
				for i = 1, GetNumQuestLogEntries() do
					if link == GetQuestLink(i) then
						SelectQuestLogEntry(i)
						if GetQuestLogPushable() then
							self:Debug("Sharing quest...")
							QuestLogPushQuest()
						else
							core:Print(L.QuestNotShareable)
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

module.displayName = L.Quest
function module:SetupOptions(panel)
	local title, notes = LibStub("PhanxConfig-Header").CreateHeader(panel, L.Quest, L.Quest_Info)

	local enable, accept, acceptOnlyShared, turnin, share, abandon

	local CreateCheckbox = LibStub("PhanxConfig-Checkbox").CreateCheckbox
	local CreateCheckbox = LibStub("PhanxConfig-Checkbox").CreateCheckbox

	local function OnClick(this, checked)
		self.db[ this.key ] = checked

		if this.key == "enable" then
			accept:SetEnabled( checked )
			acceptOnlyShared:SetEnabled( checked )
			turnin:SetEnabled( checked )
			share:SetEnabled( checked )
			abandon:SetEnabled( checked )
			module:CheckState()

		elseif this.key == "accept" then
			acceptOnlyShared:SetEnabled( checked )
		end
	end

	enable = CreateCheckbox(panel, L.Enable, L.Enable_Info)
	enable:SetPoint("TOPLEFT", notes, "BOTTOMLEFT", 0, -8)
	enable.OnClick = OnClick
	enable.key = "enable"

	accept = CreateCheckbox(panel, L.AcceptQuests, L.AcceptQuests_Info)
	accept:SetPoint("TOPLEFT", enable, "BOTTOMLEFT", 0, -8)
	accept.OnClick = OnClick
	accept.key = "accept"

	acceptOnlyShared = CreateCheckbox(panel, L.OnlySharedQuests, L.OnlySharedQuests_Info)
	acceptOnlyShared:SetPoint("TOPLEFT", accept, "BOTTOMLEFT", 26, -8)
	acceptOnlyShared.OnClick = OnClick
	acceptOnlyShared.key = "acceptOnlyShared"

	turnin = CreateCheckbox(panel, L.TurnInQuests, L.TurnInQuests_Info)
	turnin:SetPoint("TOPLEFT", acceptOnlyShared, "BOTTOMLEFT", -26, -8)
	turnin.OnClick = OnClick
	turnin.key = "turnin"

	share = CreateCheckbox(panel, L.ShareQuests, L.ShareQuests_Info)
	share:SetPoint("TOPLEFT", turnin, "BOTTOMLEFT", 0, -8)
	share.OnClick = OnClick
	share.key = "share"

	abandon = CreateCheckbox(panel, L.AbandonQuests, L.AbandonQuests_Info)
	abandon:SetPoint("TOPLEFT", share, "BOTTOMLEFT", 0, -8)
	abandon.OnClick = OnClick
	abandon.key = "abandon"

	local help = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	help:SetPoint("BOTTOMLEFT", 16, 16)
	help:SetPoint("BOTTOMRIGHT", -16, 16)
	help:SetHeight(112)
	help:SetJustifyH("LEFT")
	help:SetJustifyV("BOTTOM")
	help:SetText(L.QuestHelpText)

	panel.refresh = function()
		local enabled = self.db.enable

		enable:SetChecked(enabled)
		accept:SetChecked(self.db.accept)
		acceptOnlyShared:SetChecked(self.db.acceptOnlyShared)
		turnin:SetChecked(self.db.turnin)
		share:SetChecked(self.db.share)
		abandon:SetChecked(self.db.abandon)

		accept:SetEnabled(enabled)
		acceptOnlyShared:SetEnabled(enabled and self.db.accept)
		turnin:SetEnabled(enabled)
		share:SetEnabled(enabled)
		abandon:SetEnabled(enabled)
	end
end