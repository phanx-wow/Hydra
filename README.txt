Hydra
========

Multiboxing and group leveling helper that aims to minimize the number
of times you need to actively control secondary characters.


Download
-----------

* [WoWInterface](http://www.wowinterface.com/downloads/info17572-Hydra.html)
* [Curse](http://www.curse.com/addons/wow/hydra)


Usage
--------

Type "/hydra" for options, or browse to the Hydra panel in the
standard Interface Options window.

Many of Hydra's features are only active in parties consisting of
characters on your "trusted" list, or only respond to characters on
this list. The first time you run Hydra, you will need to define
this list in the options panel.


Features
-----------

### Core

* Automatically enables or disables features depending on whether or
  not the current party consists of trusted characters.

### Automation

* Accepts resurrections and summons
* Declines duels, guilds, and arena teams
* Repairs equipment and sells junk to vendors
* Hold Shift to bypass repairing and selling
* "/corpse release" causes all dead party members release their spirit
* "/corpse accept causes all party members to accept resurrection

### Chat

* Forwards whispers to secondary characters to party chat.
* Forwards responses from party chat back to the original whisperer
  as a whisper from the character they messaged.
* Messages in party chat that do not being with "@" or "!" are
  assumed to be a response to the last forwarded whisper.
* Type "@partymember message here" in party chat to respond to the
  last message forwarded to party chat by "partymember".
* Type "@target message here" in a whisper to a trusted character to
  have that character whisper "message here" to the player "target".

### Follow

* Notifies you when a party member starts or stops following you.
* Command all party members to follow you by typing "/followme".
* Command dead party members to release their spirit by typing
  "/corpse release".
* Command party members to resurrect to their corpse (or by using their
  soulstone or other self-resurrection ability) by typing "/corpse
  accept".

### Mount

* Mounts other party members when you mount.

### Party

* Accepts party invitations from trusted characters.
* Type "/inivteme" to request a party invitation from your target.
* Type "/inviteme name" to request a party invitation from "name".
* Type "/promoteme" to request a promotion to party leader.

### Quest

* Shares quests accepted from NPCs and objects.
* Accepts quests shared by players.
* Accepts start confirmations for escort-type quests.
* Abandons quests abandoned by trusted party members.
* Accepts quests from NPCs that another party member accepted.
* Turns in completed quests that don't have reward choices.

### Taxi

* Selects the last taxi node selected by another party member in the
  last 60 seconds.
* Type "/cleartaxi" to clear the taxi selection for the character.
* Hold Shift when speaking to a flight master to bypass autoselect.


Localization
------------

Works in all languages.

Translated into English, Deutsch, Español, Français, Русский and 한국어.

Add or update translations on the [CurseForge project page] [1]:

	[1]: http://wow.curseforge.com/addons/hydra/localization/


Feedback
-----------

Post a ticket on either download site, or a comment on WoWInterface.

If you are reporting a bug, please include directions I can follow to
reproduce the bug, whether it still happens when all other addons are
disabled, and the exact text of the related error message (if any) from 
[Bugger](http://www.wowinterface.com/downloads/info23144-Bugger.html).

If you need to contact me privately, you can send me a private message
on either download site, or email me at <addons@phanx.net>.


License
----------

Copyright (c) 2010-2014 Phanx. All rights reserved.  
See the accompanying LICENSE file for information about the conditions
under which redistribution and modification may be allowed.
