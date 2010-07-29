--[[--------------------------------------------------------------------
	HYDRA QUEST
	* Shares quests accepted from NPCs with party members
	* Accepts quests shared by party members
	* Accepts quests from NPCs that another party member already accepted
	* Accepts shared starts for escort-type quests
	* Turns in completed quests
	* Abandons quests abandoned by party members

	CREDITS:
	* Industrial - idQuestAutomation
	* Shadowed - GetToThePoint
	* Tekkub - Quecho
----------------------------------------------------------------------]]

local _, core = ...
local SOLO, PARTY, TRUSTED, LEADER = 0, 1, 2, 3
local playerName = UnitName("player")

local accept, accepted = {}, {}

local module = core:RegisterModule("Quest", CreateFrame("Frame"))
module:SetScript("OnEvent", function(f, e, ...) return f[e] and f[e](f, ...) end)

------------------------------------------------------------------------

function module:CheckState()
	if core.state == SOLO then
		self:Debug("Disable module: Quest")
		self:UnregisterAllEvents()
	else
		self:Debug("Enable module: Quest")
		self:RegisterEvent("CHAT_MSG_ADDON")
		self:RegisterEvent("QUEST_ACCEPT_CONFIRM")
		self:RegisterEvent("QUEST_COMPLETE")
		self:RegisterEvent("QUEST_DETAIL")
		self:RegisterEvent("QUEST_GREETING")
		self:RegisterEvent("QUEST_LOG_UPDATE")
		self:RegisterEvent("QUEST_PROGRESS")
	end
end

------------------------------------------------------------------------

local function strip(text)
	if not text then return "" end
	text = text:gsub("%[.*%]%s*","")
	text = text:gsub("|c%x%x%x%x%x%x%x%x(.+)|r","%1")
	text = text:gsub("(.+) %(.+%)", "%1")
	text = text:trim()
	text = text:lower()
	return text
end

------------------------------------------------------------------------

function module:QUEST_ACCEPT_CONFIRM(name, qname)
	if not UnitInParty(name) then return end
	self:Debug("Accepting quest", qname, "started by", name)
	ConfirmAcceptQuest()
	StaticPopup_Hide("QUEST_ACCEPT")
end

------------------------------------------------------------------------
--	Respond to comms from others
------------------------------------------------------------------------

function module:CHAT_MSG_ADDON(prefix, message, channel, sender)
	if sender == playerName or channel ~= "PARTY" or not core:IsTrusted(sender) then return end

	if prefix == "AcceptQuest" then
		local name = message:match("%[(.-)%]"):lower()
		self:Debug(sender, "accepted quest", message, name)
		accept[name] = message

	elseif prefix == "AbandonQuest" then
		for i = 1, GetNumQuestLogEntries() do
			local link = GetQuestLink(i)
			if link == message then
				self:Debug(sender, "abandoned quest", message)
				SelectQuestLogEntry(i)
				SetAbandonQuest()
				return AbandonQuest()
			end
		end
	end
end

------------------------------------------------------------------------
--	Accept quests accepted by other party members
------------------------------------------------------------------------

local function IsQuestComplete(text)
	module:Debug("Checking for complete quest:", text)
	for i = 1, GetNumQuestLogEntries() do
		local qname, _, _, _, _, _, complete = GetQuestLogTitle(i)
		if text == strip(qname) then
			if (complete and complete > 0) or GetNumQuestLeaderBoards(i) == 0 then
				module:Debug("Quest complete.")
				return true
			end
		end
	end
	module:Debug("Quest not complete.")
end

function module:GOSSIP_SHOW()
	if not GossipFrame.buttonIndex or IsShiftKeyDown() then return end
	self:Debug("GOSSIP_SHOW")

	for i = 1, 32 do
		local button = _G["GossipTitleButton" .. i]
		if button and button:IsVisible() then
			local text = strip(button:GetText())
			self:Debug(i, button.type, "::", button:GetText(), "->", text)
			if (button.type == "Available" and accept[text]) or (button.type == "Active" and IsQuestComplete(text)) then
				print(button.type == "Active" and "Completing quest" or "Accepting quest", button:GetText())
				button:Click()
			end
		end
	end
end

function module:QUEST_GREETING()
	if not IsShiftKeyDown() then return end

	for i = 1, 32 do
		local button = _G["QuestTitleButton" .. i]
		if button and button:IsVisible() then
			local text = strip(button:GetText())
			if IsQuestComplete(text) or accept[text] then
				self:Debug(IsQuestComplete(text) and "Completing quest" or "Accepting quest", button:GetText())
				button:Click()
			end
		end
	end

end

function module:QUEST_DETAIL()
	if IsShiftKeyDown() then return end

	local qname = strip(GetTitleText())
	if not accept[qname] and not UnitInParty("questnpc") then return end

	if UnitInParty("questnpc") then
		accepted[qname] = true
	end

	self:Debug("Accepting quest", GetTitleText(), "from", UnitName("questnpc"))
	AcceptQuest()
end

------------------------------------------------------------------------
--	Turn in completed quests
------------------------------------------------------------------------

function module:QUEST_PROGRESS()
	if IsShiftKeyDown() then return end

	if IsQuestCompletable() then
		CompleteQuest()
	end
end

function module:QUEST_COMPLETE()
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
		if not currentquests[id] and abandoning then
			self:Debug("Abandoned quest", link)
			SendAddonMessage("AbandonQuest", link, "PARTY")
		end
	end

	abandoning = nil

	for id, link in pairs(currentquests) do
		if not oldquests[id] then
			local qname = link:match("%[(.-)%]"):lower()
			if accepted[qname] then
				self:Debug("Quest accepted from a player; not sharing.")
				accepted[qname] = nil
				return
			end

			self:Debug("Accepted quest", link)

			if accept[qname] then
				accept[qname] = nil
				return
			end

			SendAddonMessage("AcceptQuest", link, "PARTY")

			for i = 1, GetNumQuestLogEntries() do
				if link == GetQuestLink(i) then
					SelectQuestLogEntry(i)
					if GetQuestLogPushable() then
						self:Debug("Sharing quest...")
						QuestLogPushQuest()
					else
						self:Debug("Quest not sharable!")
						core:Print("That quest cannot be shared.")
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