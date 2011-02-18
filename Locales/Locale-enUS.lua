--[[--------------------------------------------------------------------
	Hydra
	Multibox leveling helper.
	Written by Phanx <addons@phanx.net>
	Maintained by Akkorian <akkorian@hotmail.com>
	Copyright © 2010–2011 Phanx. Some rights reserved. See LICENSE.txt for details.
	http://www.wowinterface.com/downloads/info17572-Hydra.html
	http://wow.curse.com/downloads/wow-addons/details/hydra.aspx
------------------------------------------------------------------------
	Localization: enUS/enGB/enCN | English
	Last updated 2011-02-18 by Akkorian
----------------------------------------------------------------------]]

if not string.match( GetLocale(), "^en" ) then return end
local L, _, core = { }, ...
core.L = L

----------
-- Core --
----------

L.HELP_TRUST = [[]]

----------------
-- Automation --
----------------

L.HELP_AUTO = [[]]

----------
-- Chat --
----------

L.HELP_CHAT = [[]]

------------
-- Follow --
------------

L.HELP_FOLLOW = [[Type "|cffffffff/followme|r" to request that nearby party members follow you.

Type "|cffffffff/corpse release|r" to request that all dead party members release their spirits.

Type "|cffffffff/corpse accept|r" to request that all ghost party members accept resurrection.]]

BINDING_NAME_HYDRA_FOLLOW_TARGET = "Follow target"
BINDING_NAME_HYDRA_FOLLOW_ME = "Request follow"
BINDING_NAME_HYDRA_RELEASE_CORPSE = "Release spirit"
BINDING_NAME_HYDRA_ACCEPT_CORPSE = "Resurrect"

-----------
-- Mount --
-----------

L.HELP_MOUNT = [[]]

-----------
-- Party --
-----------

L.HELP_PARTY = [[Type "|cffffffff/inviteme|r" to request a party invitation from your current target.

Type "|cffffffff/inviteme Name|r" to request a party invitation from "Name".

Type "|cffffffff/promoteme|r" while in a group to request a promotion to Party Leader.]]

-----------
-- Quest --
-----------

L.HELP_QUEST = [[]]

----------
-- Taxi --
----------

L.HELP_TAXI = [[]]