--[[--------------------------------------------------------------------
	Hydra
	Multibox leveling helper.
	Copyright (c) 2010-2012 Phanx <addons@phanx.net>. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info17572-Hydra.html
	http://www.curse.com/addons/wow/hydra
------------------------------------------------------------------------
	Localization: enUS | English
	Last updated 2011-02-18 by Akkorian
----------------------------------------------------------------------]]

if not string.match( GetLocale(), "^en" ) then return end
local L, _, core = { }, ...
core.L = L

----------
-- Core --
----------

L.HELP_TRUST = [[Hydra operates on the basis of "trust". You tell it which characters you trust, whether they're your multibox characters or just your questing buddies, and features are enabled or disabled depending on whether you're in a party with trusted characters or not.

For example, whispers are only forwarded to party chat if everyone in the party is on your trusted list.]]

----------------
-- Automation --
----------------

L.HELP_AUTO = [[ ]]

----------
-- Chat --
----------

L.HELP_CHAT = [[Type a message in party chat to reply to the last forwarded whisper from any character.

Type "|cffffffff@name Your message here|r" in party chat to reply to the last forwarded whisper from the character "name".

Type "|cffffffff@name Your message here|r" in a whisper to a character to direct that character to send the message as a whisper to "name".]]

------------
-- Follow --
------------

L.HELP_FOLLOW = [[Type "|cffffffff/followme|r" to request that nearby party members follow you.

Type "|cffffffff/corpse release|r" to request that all dead party members release their spirits.

Type "|cffffffff/corpse accept|r" to request that all ghost party members accept resurrection.]]

-----------
-- Mount --
-----------

L.HELP_MOUNT = [[ ]]

-----------
-- Party --
-----------

L.HELP_PARTY = [[Type "|cffffffff/inviteme|r" to request a party invitation from your current target.

Type "|cffffffff/inviteme Name|r" to request a party invitation from "Name".

Type "|cffffffff/promoteme|r" while in a group to request a promotion to Party Leader.]]

-----------
-- Quest --
-----------

L.HELP_QUEST = [[ ]]

----------
-- Taxi --
----------

L.HELP_TAXI = [[Hold the Shift key while speaking to a flight master to temporarily disable auto-selection.

Type "|cffffffff/cleartaxi|r" to clear the party taxi selection before it times out.]]