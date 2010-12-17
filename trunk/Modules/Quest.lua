--[[--------------------------------------------------------------------
	Hydra
	Multibox leveling helper.
	by Phanx < addons@phanx.net >
	Copyright © 2010 Phanx. Some rights reserved. See LICENSE.txt for details.
	http://www.wowinterface.com/downloads/info17572-Hydra.html
	http://wow.curseforge.com/projects/hydra/
------------------------------------------------------------------------
	Hydra Quest
	* Shares quests accepted from NPCs with party members
	* Accepts quests shared by party members
	* Accepts quests from NPCs that another party member already accepted
	* Accepts shared starts for escort-type quests
	* Turns in completed quests
	* Abandons quests abandoned by party members

	Credits:
	* Industrial - idQuestAutomation
	* Shadowed - GetToThePoint
	* Tekkub - Quecho
----------------------------------------------------------------------]]

local _, core = ...
if not core then core = _G.Hydra end

local SOLO, PARTY, TRUSTED, LEADER = 0, 1, 2, 3
local playerName = UnitName("player")

local accept, accepted = {}, {}

local module = core:RegisterModule("Quest", CreateFrame("Frame"))
module:SetScript("OnEvent", function(f, e, ...) return f[e] and f[e](f, ...) end)

module.defaults = { share = true, accept = true, turnin = true, abandon = true }

------------------------------------------------------------------------

function module:CheckState()
	self:UnregisterAllEvents()
	self:Debug("Enable module: Quest")

	self:RegisterEvent("GOSSIP_SHOW")
	self:RegisterEvent("QUEST_COMPLETE")
	self:RegisterEvent("QUEST_DETAIL")
	self:RegisterEvent("QUEST_GREETING")
	self:RegisterEvent("QUEST_PROGRESS")

	if core.state > SOLO then
		self:RegisterEvent("CHAT_MSG_ADDON")
		self:RegisterEvent("QUEST_ACCEPT_CONFIRM")
		self:RegisterEvent("QUEST_LOG_UPDATE")
	end
end

------------------------------------------------------------------------

local function strip(text)
	if not text then return "" end
	text = text:gsub("%[.*%]%s*","")
	text = text:gsub("|c%x%x%x%x%x%x%x%x(.+)|r","%1")
	text = text:gsub("(.+) %(.+%)", "%1")
	text = text:trim()
	return text
end

------------------------------------------------------------------------

function module:QUEST_ACCEPT_CONFIRM(name, qname)
	if not UnitInParty(name) or not self.db.accept then return end
	-- self:Debug("Accepting quest", qname, "started by", name)
	ConfirmAcceptQuest()
	StaticPopup_Hide("QUEST_ACCEPT")
end

------------------------------------------------------------------------
--	Respond to comms from others
------------------------------------------------------------------------

function module:CHAT_MSG_ADDON(prefix, message, channel, sender)
	if sender == playerName or channel ~= "PARTY" or not core:IsTrusted(sender) then return end

	if prefix == "HydraQuest_Accept" then
		local qname = message:match("%[(.-)%]"):lower()
		if not accepted[qname] then
			accept[qname] = message
		end
		return self:Print(sender, "accepted", message)

	elseif prefix == "HydraQuest_TurnIn" then
		return self:Print(sender, "turned in", message)

	elseif prefix == "HydraQuest_Abandon" and self.db.abandon then
		for i = 1, GetNumQuestLogEntries() do
			local link = GetQuestLink(i)
			if link == message then
				SelectQuestLogEntry(i)
				SetAbandonQuest()
				AbandonQuest()
				return self:Print(sender, "abandoned", message)
			end
		end
	end
end

------------------------------------------------------------------------
--	Accept quests accepted by other party members
------------------------------------------------------------------------

local function IsQuestComplete(text)
	module:Debug("IsQuestComplete", text)
	for i = 1, GetNumQuestLogEntries() do
		local qname, _, _, _, _, _, complete = GetQuestLogTitle(i)
		if text == strip(qname):lower() then
			if (complete and complete > 0) or GetNumQuestLeaderBoards(i) == 0 then
				module:Debug("true")
				return true
			end
		end
	end
	module:Debug("false")
end

function module:GOSSIP_SHOW()
	self:Debug("GOSSIP_SHOW")
	if not GossipFrame.buttonIndex or IsShiftKeyDown() then return end

	for i = 1, 32 do
		local button = _G["GossipTitleButton" .. i]
		if button and button:IsVisible() then
			local text = strip(button:GetText()):lower()
			self:Debug(i, button.type, "=", button:GetText(), "->", text)
			if (button.type == "Available" and accept[text] and self.db.accept) or (button.type == "Active" and IsQuestComplete(text) and self.db.turnin) then
				self:Debug(button.type == "Active" and "Completing quest" or "Accepting quest", strip(button:GetText()))
				return button:Click()
			end
		end
	end
end

function module:QUEST_GREETING()
	self:Debug("QUEST_GREETING")
	if IsShiftKeyDown() then return end

	for i = 1, 32 do
		local button = _G["QuestTitleButton" .. i]
		if button and button:IsVisible() then
			local text = strip(button:GetText()):lower()
			self:Debug(i, button:GetText(), "->", text)
			if (IsQuestComplete(text) and self.db.turnin) or (accept[text] and self.db.accept) then
				self:Debug(IsQuestComplete(text) and "Completing quest" or "Accepting quest", strip(button:GetText()))
				return button:Click()
			end
		end
	end
end

function module:QUEST_DETAIL()
	self:Debug("QUEST_DETAIL")
	if IsShiftKeyDown() then return end

	local qname = strip(GetTitleText()):lower()
	if not accept[qname] and not UnitInParty("questnpc") then return end

	if UnitInParty("questnpc") then
		accepted[qname] = true
	end

	self:Debug("Accepting quest", strip(GetTitleText()), "from", (UnitName("questnpc")))
	AcceptQuest()
end

------------------------------------------------------------------------
--	Turn in completed quests
------------------------------------------------------------------------

function module:QUEST_PROGRESS()
	self:Debug("QUEST_PROGRESS")
	if IsShiftKeyDown() then return end

	if IsQuestCompletable() then
		CompleteQuest()
	end
end

function module:QUEST_COMPLETE()
	self:Debug("QUEST_COMPLETE")
	if IsShiftKeyDown() then return end

	if GetNumQuestChoices() <= 1 then
		GetQuestReward(QuestFrameRewardPanel.itemChoice)
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
				SendAddonMessage("HydraQuest_Abandon", link, "PARTY")
			else
				self:Debug("Turned in quest", link)
				SendAddonMessage("HydraQuest_TurnIn", link, "PARTY")
			end
		end
	end

	abandoning = nil

	for id, link in pairs(currentquests) do
		if not oldquests[id] then
			self:Debug("Accepted quest", link)
			SendAddonMessage("HydraQuest_Accept", link, "PARTY")

			local qname = link:match("%[(.-)%]"):lower()
			if self.db.share and not accept[qname] and not accepted[qname] then
				for i = 1, GetNumQuestLogEntries() do
					if link == GetQuestLink(i) then
						SelectQuestLogEntry(i)
						if GetQuestLogPushable() then
							self:Debug("Sharing quest...")
							QuestLogPushQuest()
						else
							core:Print("That quest cannot be shared.")
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