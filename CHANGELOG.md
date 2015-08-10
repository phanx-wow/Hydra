### Version 6.2.0.30

* Updated for WoW 6.2
* Added an option to disable automatic loot method switching
* Fixed an issue with taxi destination sharing
* Fixed some issues with option checkboxes
* Renamed the "Party" module to "Group" since it also works for raids

### Version 6.0.2.206

* Updated for WoW 6.0
* Taxi sharing now works immediately for secondary characters who already have the taxi map open
* Improved dismount detection for noobs who click off auras to dismount
* Fixed junk selling profit report for stacked items
* Added alchemy and engineering specialization quests to the ignore list

### Version 5.4.8.187

* Fixed textures overlapping on the "remove name" dropdown when there are no names to remove

### Version 5.4.8.186

* Fixed automatic re-follow after combat
* Fixed automatic quest abandoning for characters with significant level differences
* Fixed taxi sharing for characters with different known flight paths
* More fixes for Blizzard's lazy API inconsistencies

### Version 5.4.8.175

* The dropdown menu for removing trusted names now scrolls when necessary to accomodate users with over 9000 alts
* [Chat] Fixed the enable checkbox
* [Group] Promotion requests are now targeted while in a group to avoid spam from non-leader characters
* [Mount] Fixed a reversion causing comm messages to be incorrectly ignored under certain conditions

### Version 5.4.7.169

* Ambiguate names where necessary to work around annoyingly inconsistent API functions that break when realm names are passed
* Clear abandoned quests from the accept/accepted lists to they can be automated again later
* Block automation of the Allegiance to the Aldor/Scryers quests, and the Little Orphan quests in Dalaran

### Version 5.4.7.162

* Fixed problems with cross-realm player names
* Fixed notifications in the Follow module
* Fixed the wrong text being used on some options for the Quest module
* Added an in-game panel for enabling debugging messages on a per-module basis
* Updated German translations

### Version 5.4.2.151

* Fixed more issues with the Mount module
* Fixed an issue in the Chat module where "/w Player1 @Player2 message" would cause an infinite loop of whispers when Player1 and Player2 were both trusted group members
* Adjusted default options for the Automation and Quest modules (eg. "Accept combat resurrections" is no longer enabled by default)

### Version 5.4.2.139

* Added an option to repair using guild funds when possible
* Fixed an issue with the Mount module

### Version 5.4.2.136

* Fixed some more issues with the Follow module
* Fixed the options UI for adding/removing trusted names

### Version 5.4.1.132

* Fixed sending /followme without a target
* Fixed instance chat channel detection
* Fixed chat master detection method option dropdown
* Added "Work Order" quests to the automation blacklist
* Added missing Spanish translations
* Updated for WoW 5.4

### Version 5.2.0.119

* Added an option to resume following when leaving combat
* Added a quest blacklist to prevent automating certain quests (eg. suboptimal Tillers turnins)
* Added checks to prevent attempting to turn in repeatable quests that aren't complete (eg. you need 6 Dread Amber Shards to turn in Seeds of Fear)
* Fixed an issue with realm names containing spaces
* Fixed an issue preventing guild invite declining from fully disabling until a reload/relog

### Version 5.1.0.103

* Chat: Added support for forwarding Battle.net whispers and conversations
* Follow: Fixed the follow key binding
* Mount: Removed dependency on LibMountInfo, since changes in the library make it useless for Hydra's purposes
* Quest: Added an option to accept all quests, in addition to shared quests
* Quest: Added support for starting quests from items
* Quest: Hide the useless gossip window for auto-pickup quests
* Quest: Fixed turnin of quests with multiple valueless rewards
* Quest: Fixed turnin of auto-completing quests
* Quest: Fixed quest reward selection for class-filtered rewards in MoP
* Quest: Fixed accepting escort quests started by others

### Version 5.0.4.82

* Fixed a call to a function that was removed in WoW 5.0
* Added French translations from Araldwenn
* Added Russian translations from Piton4
* Updated Spanish translations from Valdesca

### Version 5.0.4.80

* Updated for WoW 5.0
* Removed an unused library

### Version 4.3.4.78

* Updated for WoW 5.x (Mists of Pandaria).
* Added basic support for raids. Not really tested. Please report issues.
* Added an option for "/followme" auto-targeting: When this option is enabled and you are targeting a group member, the command will be sent only to that group member.
* Added "/followme" targeting: If names are entered with the command, the command will be sent only to the specified character(s). Example: "/followme Charone Charthree".
* Fixed multiple options panel issues.

### Version 4.3.3.67

* Fixed party invitations from trusted characters not being accepted automatically for some people due to inconsistencies in Blizzard UI/API behavior between different WoW installations

### Version 4.3.2.64

* Fixed the "Add Current Group" button for adding all members of the current group to the trusted list
* Fixed party invitations from trusted characters not being accepted automatically due to changes in the Blizzard UI code

### Version 4.3.0.62

* Fixed class coloring of sender names in whisper forwarding
* Slightly improved the efficiency of spam checking in whisper forwarding

### Version 4.3.0.59

* Updated for WoW 4.3
* Fixed the "Add Name" input option

### Version 4.2.0.56

* Updated for WoW 4.2

### Version 4.1.0.52

* Updated for WoW 4.1
* Updated and fixed the localization of all modules

### Version 4.0.6.43

* Reworked the options layout
* Added in-game help text for some modules (more to come)
* Added Spanish localization

### Version 4.0.3.32

* Fixed a bug in the mount module

### Version 4.0.3.31

* Fixed the auto quest turnin option
* Fixed a bug in the quest module when turning a quest to an NPC who offered multiple quests
* Added embedded copies of the libraries needed for the options panel, so you don’t need to download Ace3 separately or depend on other addons including it
* Added LibMounts-1.0 to mount module for improved mount selection support between characters who don’t have the same mount
* Added an optional DataBroker launcher

### Version 3.3.5.24

* Fixed names added to/removed from trust list via options panel not saving between sessions
* Limited quest automation to one pickup/turnin per click on NPC to prevent some bugs

### Version 3.3.5.23

* Added "/corpse release" and "/corpse accept" commands
* Added option to the Follow module to show/hide chat messages
* Added basic spam detection to try to prevent forwarding spam whispers
* Added trust list management functions to the options panel
* Settings are now saved on a per-character basis
* Added backwards compatibility for WoW 3.2 (still live in China)

### Version 3.3.5.15

* Added mount speed data so my blood elf paladin and warlock don't have to ride around on rainbow cocks 
* Added quest turnin notification to quest module
* Fixed completed quest turnins (no idea how that "not" got in there)
* Fixed global nil value error in automation module
* Fixed application focus detection in chat module
* Fixed party module trying to respond to the player's promotion request
* Fixed "/promoteme" command
* Changed "/inviteme" command to accept a name, but still fall back on using the current target
* Changed quest module comm prefixes to be more distinctive
* Turned off debugging for all modules

### Version 3.3.5.8

* Added options (requires standalone Ace3, and not extensively tested)
* Fixed quest turn-ins

### Version 3.3.5.3

* First public release
