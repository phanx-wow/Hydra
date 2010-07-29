
= Hydra

Hydra is a multibox leveling helper that aims to minimize the number of times you need to actively control secondary characters. The goal is that you only need to control a secondary character when it is necessary to interact with an NPC (eg. loot a quest item, turn in a quest, or take a taxi flight).

This release should be considered a stable alpha, or a rough beta. It works, but some of the modules are fairly unpolished, and there are no options yet. I don't plan to add any major features that aren't listed here, but if you have an awesome idea, let me know, and if it's something I think I'd use, I'll probably add it.

== Core

Maintains a list of characters who are "trusted", and activates or deactivates modules depending on whether or not everyone in the party is on the trusted list. For example, whisper forwarding to party chat is deactivated if someone joins the party who isn't on the trusted list. Other modules remain active, but ignore the actions of party members who aren't on the trusted list.

== Automation

Declines duels, guilds, and arena teams. Accepts summons and resurrections. Repairs equipment and sells junk to vendors.

Will eventually accept corpse resurrections if another party member is alive and within range, and release spirit upon death if all party members are dead. Alternatively, I may simply add commands to tell other party members to take their corpse or release their spirit.

== Chat

Forwards whispers sent to characters without application focus to party chat, and forwards responses in party chat back to the original sender as a whisper from the character they whispered.

Respond to a message forwarded by a character other than the last by typing "@name message" in party chat, where "name" is the name of the character that forwarded the message.

Respond to a message other than the last forwarded by a character by whispering the character with "@name message", where "name" is the name of the person to send the message to. This also works to send whispers to arbitrary recipients.

//Known Issues//

The module deactivates in non-trusted parties, and there is currently no notification if someone whispers a secondary character in this situation. I may just abandon the party chat idea entirely, and create a custom chat type.

== Follow

Notifies you when a party member starts or stops following you. Type "/followme" or "/fme" to command all party members to follow you.

== Mount

Causes other characters in the party (and in range) to mount when you mount.

== Party

Accepts party invitations from trusted characters.

Request a party invitation by typing "/inviteme name", where "name" is the target. If no target is specified, your current target unit will be used.

Request a party promotion by typing "/promoteme".

== Quest

Attempts to keep quests in sync between party members, by sharing quests accepted from NPCs, accepting quests shared from players, accepting escort type quest starts, and abandoning quests that a trusted party member abandoned.

When manual interaction with an NPC is required, the module automatically turns in complete quests (you still need to choose a reward if there's a choice) and accepts quests that another party member already accepted.

== Taxi

Autoselects the last taxi node selected by anyone in the party in the last 60 seconds. You can manually clear the selection by typing "/cleartaxi". Hold the Shift key when interacting with the flight master to bypass this module.