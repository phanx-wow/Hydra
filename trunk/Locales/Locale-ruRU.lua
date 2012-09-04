--[[--------------------------------------------------------------------
	Hydra
	Multibox leveling helper.
	Copyright (c) 2010-2012 Phanx <addons@phanx.net>. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info17572-Hydra.html
	http://www.curse.com/addons/wow/hydra
------------------------------------------------------------------------
	Russian Localization (Русский)
	Last updated 2012-04-22 by Piton4
----------------------------------------------------------------------]]

if GetLocale() ~= "ruRU" then return end
local L, _, core = { }, ...
core.L = L

----------
-- Core --
----------

L["Hydra is a multibox leveling helper that aims to minimize the need to actively control secondary characters."] = "Hydra - это помощник для multibox, который направлен для минимизации действий, требуемых для контроля вторичных персонажей."
L["Trust List"] = "Список доверенных имен"
L["Add Name"] = "Добавить имя"
L["Add a name to your trusted list."] = "Добавить имя в список доверенных имен."
L["Remove Name"] = "Удалить имя"
L["Remove a name from your trusted list."] = "Удалить имя из списка доверенных имен."
L["Add Party"] = "Добавить группу"
L["Adds all the characters in your current party group to your trusted list."] = "Добавить всех персонажей текущей группы в список доверенных имен."
L["Remove All"] = "Удалить все"
L["Remove all names from your trusted list for this server."] = "Удалить все имена из списка доверенных имен."

L["Added %s to the trusted list."] = "%s был добавлен в список доверенных имен."
L["Removed %s from the trusted list."] = "%s был удален из списка доверенных имен."

-- L.HELP_TRUST = [[]]

------------
-- Common --
------------

L["Enable"] = "Включить"
L["Enable this module."] = "Включить этот модуль."

L["Verbose mode"] = "Подробном режиме"
L["Enable notification messages from this module."] = "Включить сообщения оповещения от этого модуля."

L["Timeout"] = "Просрочка"

----------------
-- Automation --
----------------

L["Automation"] = "Автоматизация"
L["Automates simple repetetive tasks, such as clicking common dialogs."] = "Автоматизация простых повторяемых заданий, таких как нажатие на стандартные диалоги."
L["Decline duels"] = "Отказываться от дуэлей"
-- L["Decline duel requests."] = ""
L["Decline arena teams"] = "Отказываться от приглашений в арена-команды"
-- L["Decline arena team invitations and petitions."] = ""
L["Decline guilds"] = "Отказываться от приглашений в гильдию"
-- L["Decline guild invitations and petitions."] = ""
L["Accept summons"] = "Принимать призывы"
-- L["Accept summon requests."] = ""
L["Accept resurrections"] = "Принимать воскрешения(вне боя)"
-- L["Accept resurrections from players not in combat."] = ""
L["Accept combat resurrections"] = "Принимать воскрешения в бою"
-- L["Accept resurrections from players in combat."] = ""
L["Repair equipment"] = "Починить снаряжение"
-- L["Repair all equipment when interacting with a repair vendor."] = ""
L["Sell junk"] = "Продать серые вещи(мусор)"
-- L["Sell all junk (gray) items when interacting with a vendor."] = ""

L["Declined an arena team invitation from %s."] = "Отказался от приглашения в команду арены от %s."
L["Declined an arena team petition from %s."] = "Отказался от регистрационной подписи команды арены от %s."
L["Declined a guild invitation from %s."] = "Отказался от приглашения в гильдию от %s."
L["Declined a guild petition from %s."] = "Отказался от регистрационной подписи гильдии от %s."
L["Declined a duel request from %s."] = "Отказался от дуэли с %s."
L["Sold %1$d junk |4item:items; for %2$s."] = ""
L["Repaired all items with guild bank funds for %s."] = "Починил все снаряжение за счет гильдии на %s."
L["Insufficient guild bank funds to repair!"] = "Недостаточно средств гильдии для починки!"
L["Repaired all items for %s."] = "Починил все снаряжение на %s."
L["Insufficient funds to repair!"] = "Недостаточно средств для починки!"
L["Accepted a resurrection from %s."] = "Принял воскрешение от %s."
L["Accepting a summon from %1$s to %2$s."] = "Принимаю призыв от %1$s в %2$s."
L["Accepting a summon when combat ends..."] = "Принимаю призыв когда кончится битва..."
L["Summon expired!"] = "Призыв истек!"

-- L.HELP_AUTO = [[]]

----------
-- Chat --
----------

L["Chat"] = "Чат"
L["Forwards whispers sent to inactive characters to party chat, and forwards replies to the original sender."] = "Перенаправляет шепот, посланный неактивным персонажам в чат группы и перенаправляет ответы оригинальному отправителю."
L["Detection method"] = "Метод обнаружения"
-- L["Select the method to use for detecting the primary character."] = ""
-- L["If you are multiboxing on multiple physical machines, or are running multiple copies of WoW in windowed mode, the \"Application Focus\" mode will probably not work for you, and you should make sure that your primary character is the party leader."] = ""
-- L["Application Focus"] = ""
L["Party Leader"] = "Лидер группы"
-- L["If this many seconds have elapsed since the last forwarded message, don't forward messages typed in party chat to the last whisperer unless the target is explicitly specified."] = ""

L["|TInterface\\ChatFrame\\UI-ChatIcon-Blizz.blp:0:2:0:-3|t %s has received a whisper from a GM!"] = "|TInterface\\ChatFrame\\UI-ChatIcon-Blizz.blp:0:2:0:-3|t %s получил шепот от ГМа!"
L["%1$s has received a Battle.net whisper from %2$s."] = "%1$s получил Battle.net шепот от %2$s."
L["%1$s has received a whisper from %2$s."] = "%1$s получил шепот от %2$s."
-- L["!ERROR: Party forwarding timeout reached."] = ""
-- L["!ERROR: Whisper timeout reached."] = ""

-- L.HELP_CHAT = [[]]

------------
-- Follow --
------------

L["Follow"] = "Следить"
-- L["Responds to follow requests from trusted party members."] = ""
-- L["Set a key binding to follow your current target."] = ""
-- L["Set a key binding direct all characters in your party to follow you."] = ""
-- L["Set a key binding to direct all dead characters in your party to release their spirit."] = ""
-- L["Set a key binding to direct all ghost characters in your party to accept resurrection to their corpse."] = ""

L["%s is now following you."] = "%s следует за вами."
L["%s is no longer following you."] = "%s больше не следует за вами."
L["%s is no longer following you!"] = "%s больше не следует за вами!"
L["%s is too far away to follow!"] = "%s слишком далеко, чтобы следовать."
-- L["Use Soulstone"] = ""
-- L["Reincarnate"] = ""
-- L["I have a soulstone."] = ""
L["I can reincarnate."] = "Я могу переродиться."
L["I can resurrect myself."] = "Я могу воскресить себя."
L["I cannot resurrect!"] = "Я не могу воскреситься!"

-- L.HELP_FOLLOW = [[]]

-- L.SLASH_HYDRA_FOLLOWME3 = ""

-- L.SLASH_HYDRA_CORPSE2 = ""
-- L["release"] = ""
-- L["accept"] = ""

-- L.BINDING_NAME_HYDRA_FOLLOW_TARGET = ""
-- L.BINDING_NAME_HYDRA_FOLLOW_ME = ""
-- L.BINDING_NAME_HYDRA_RELEASE_CORPSE = ""
-- L.BINDING_NAME_HYDRA_ACCEPT_CORPSE = ""

-----------
-- Mount --
-----------

L["Mount"] = "Транспорт"
-- L["Summons your mount when another party member mounts."] = ""

-- L["ERROR: %s is missing that mount!"] = ""

-- L.HELP_MOUNT = [[]]

-----------
-- Party --
-----------

L["Party"] = "Группа"
-- L["Responds to invite and promote requests from trusted players."] = ""

-- L["I cannot invite you, because you are not on my trusted list."] = ""
-- L["I cannot invite you, because I am not the party leader."] = ""
-- L["I cannot promote you, because you are not on my trusted list."] = ""
-- L["I cannot promote you, because I am not the party leader."] = ""

-- L.HELP_PARTY = [[]]

-- L.SLASH_HYDRA_INVITEME3 = ""
-- L.SLASH_HYDRA_PROMOTEME3 = ""

-----------
-- Quest --
-----------

L["Quest"] = "Задание"
-- L["Helps keep party members' quests in sync."] = ""
L["Turn in quests"] = "Сдавать задания"
L["Turn in complete quests."] = "Сдавать завершенные задания."
-- L["Accept quests"] = ""
-- L["Accept quests shared by party members, quests from NPCs that other party members have already accepted, and escort-type quests started by another party member."] = ""
L["Share quests"] = "Делиться заданиями"
L["Share quests you accept from NPCs."] = "Делиться заданиями, полученными от NPCs."
L["Abandon quests"] = "Отказываться от заданий"
L["Abandon quests abandoned by a trusted party member."] = "Отказываться от заданий, которые были брошены доверенным членом группы."

-- L["%1$s accepted %2$s."] = ""
-- L["%1$s turned in %2$s."] = ""
-- L["%1$s abandoned %2$s."] = ""
L["That quest cannot be shared."] = "Этим заданием невозможно поделиться."

-- L.HELP_QUEST = [[]]

----------
-- Taxi --
----------

-- L["Taxi"] = ""
-- L["Selects the same taxi destination as other party members."] = ""
-- L["Clear the taxi selection after this many seconds."] = ""

-- L["ERROR: %s: Taxi timeout reached."] = ""
-- L["ERROR: %s: Taxi node mismatch."] = ""
-- L["%1$s set the party taxi to %2$s."] = ""
-- L["Party taxi cleared."] = ""

-- L.HELP_TAXI = [[]]

-- L.SLASH_HYDRA_CLEARTAXI2 = ""