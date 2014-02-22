--[[--------------------------------------------------------------------
	Hydra
	Multibox leveling helper.
	Copyright (c) 2010-2014 Phanx <addons@phanx.net>. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info17572-Hydra.html
	http://www.curse.com/addons/wow/hydra
------------------------------------------------------------------------
	English localization
	Last updated 2014-02-22 by Phanx
	***
----------------------------------------------------------------------]]

local HYDRA, core = ...
local L = {}
core.L = L

-----------------
-- Core/Common --
-----------------

L.AddedTrusted = "%s has been added to your trusted list."
L.AddGroup = "Add Group"
L.AddGroup_Info = "Add everyone in your current group to your trusted list."
L.AddName = "Add a name"
L.AddName_Info = "Add a name to your trusted list."
L.ClickForOptions = "Click for options."
L.CoreHelpText = [[Hydra operates on the basis of "trust". You tell it which characters you trust, whether they're your multibox characters or just your questing buddies, and features are enabled or disabled depending on whether you're in a group with trusted characters or not.

For example, whispers are only forwarded to group chat if everyone in the group is on your trusted list.]]
L.Enable = ENABLE
L.Enable_Info = "Enable this module."
L.Hydra_Info = "Hydra is a multiboxing and group leveling helper that aims to minimize the need to actively control secondary characters."
L.RemoveAll = "Remove All"
L.RemoveAll_Info = "Clear your existing trusted list, removing all characters from all servers."
L.RemovedTrusted = "%s has been removed from your trusted list."
L.RemoveName = "Remove a name"
L.RemoveName_Info = "Remove a name from your trusted list."
L.Timeout = "Timeout"
L.Verbose = "Verbose"
L.Verbose_Info = "Enable notification messages from this module."

------------
-- Assist --
------------

L.Assist = "Assist"
L.Assist_Info = "Synchronizes an assist target across trusted group members."
L.AssistFailed = "%s could not assist you due to an unknown error."
L.AssistFailedCombat = "%s will assist you after combat."
L.AssistFailedTrust = "%s cannot assist you because you are not on their trusted list."
L.AssistGetMacro = "Get Macro"
L.AssistGetMacro_Info = "If you prefer to activate the Assist function from your action bars, you can use this button to get a macro you can drop onto any action button."
L.AssistHelpText = "This module is really only useful in combination with key cloning software. You should set your selected |cffffffffAssist|r key to be sent to your secondary clients."
L.AssistMacro = "Assist"
L.AssistMacro_Info = "Set a key binding to assist your current assist target."
L.AssistRespond = "Assist"
L.AssistRespond_Info = "Respond to assist requests from trusted group members."
L.AssistSet = "%s will now assist you."
L.AssistUnset = "%s is now assisting %s instead of you."
L.NobodyAssisting = "Nobody is currently assisting you."
L.RequestAssist = "Request Assist"
L.RequestAssist_Info = "Set a key binding to request that all group members set you as their assist target."
L.SlashAssistMe = "/assistme"

----------------
-- Automation --
----------------

L.AcceptCombatRes = "Accept combat resurrections"
L.AcceptCombatRes_Info = "Accept resurrections in combat from all group members."
L.AcceptedRes = "Accepted a resurrection from %s."
L.AcceptedSummon = "Accepting a summon from %1$s to %2$s."
L.AcceptedSummonCombat = "Accepting a summon when combat ends..."
L.AcceptRes = "Accept resurrections"
L.AcceptRes_Info = "Accept resurrections out of combat from all group members."
L.AcceptSummons = "Accept summons"
L.AcceptSummons_Info = "Accept summons from trusted players."
L.Automation = "Automation"
L.Automation_Info = "Automates simple repetetive tasks, such as clicking common dialogs."
L.AutomationHelpText = "" -- #TODO: Add text here
L.DeclineArenas = "Decline arena teams"
L.DeclineArenas_Info = "Decline arena team invitations and petitions from all players."
L.DeclinedArena = "Declined an arena team invitation from %s."
L.DeclinedArenaPetition = "Declined an arena team petition from %s."
L.DeclinedDuel = "Declined a duel request from %s."
L.DeclinedGuild = "Declined a guild invitation from %s."
L.DeclinedGuildPetition = "Declined a guild petition from %s."
L.DeclineDuels = "Decline duels"
L.DeclineDuels_Info = "Decline duel requests from all players."
L.DeclineGuilds = "Decline guilds"
L.DeclineGuilds_Info = "Decline guild invitations and petitions from all players."
L.NoRepairMoney = "Insufficient funds to repair!"
L.NoRepairMoneyGuild = "Insufficient guild bank funds to repair!"
L.Repair = "Repair equipment"
L.Repair_Info = "Repair all equipment when interacting with a repair vendor."
L.RepairGuild = "Use guild funds"
L.RepairGuild_Info = "Pay for repairs out of the guild bank when possible."
L.Repaired = "Repaired all items for %s."
L.RepairedGuild = "Repaired all items with guild bank funds for %s."
L.SellJunk = "Sell junk"
L.SellJunk_Info = "Sell junk (gray) items when interacting with a vendor."
L.SoldJunk = "Sold %1$d junk |4item:items; for %2$s."
L.SummonExpired = "Summon expired!"

----------
-- Chat --
----------

L.AppFocus = "Application focus"
L.Chat = "Chat"
L.Chat_Info = "Forwards whispers sent to inactive characters to group chat, and forwards replies to the original sender."
L.ChatHelpText = [[Type a message in group chat to reply to the last forwarded whisper from any character.

Type "|cffffffff@name Your message here|r" in group chat to reply to the last forwarded whisper from the character "name".

Type "|cffffffff@name Your message here|r" in a whisper to a character to direct that character to send the message as a whisper to "name".]]
L.DetectionMethod = "Detection method"
L.DetectionMethod_Info = "Select the method to use for detecting the primary character.\n\nIf you are multiboxing on multiple physical machines, or are running multiple copies of WoW in windowed mode, the \"Application Focus\" mode will probably not work for you, and you should make sure that your primary character is the group leader."
L.GroupLeader = "Group leader"
L.GroupTimeout_Info = "If this many seconds have elapsed since the last forwarded message, don't forward messages typed in group chat to the last whisperer unless the target is explicitly specified."
L.GroupTimeoutError = "Group chat forwarding timeout reached."
L.WhisperFrom = "%1$s received a whisper from %2$s."
L.WhisperFromBnet = "%1$s received a Battle.net whisper from %2$s:\n%3$s"
L.WhisperFromConvo = "%1$s received a Battle.net message from %2$s:\n%3$s"
L.WhisperFromGM = "%s has received a whisper from a GM!"
L.WhisperTimeoutError = "Whisper timeout reached."

------------
-- Follow --
------------

L.AcceptCorpse = "Resurrect to corpse"
L.AcceptCorpse_Info = "Set a key binding to direct dead group members to accept resurrection to their corpse."
L.CanReincarnate = "%s can use Reincarnation."
L.CanSelfRes = "%s can self-ressurect."
L.CantRes = "%s cannot be resurrected!"
L.CantResDelay = "%1$s cannot be resurrected for %2$d more seconds!"
L.CanUseSoulstone = "%s can use a Soulstone."
L.CmdAccept = "ac?c?e?p?t?"
L.CmdRelease = "re?l?e?a?s?e?"
L.Follow = "Follow"
L.Follow_Info = "Responds to follow requests from trusted group members."
L.FollowHelpText = [[Type "|cffffffff/followme|r" to direct nearby group members to follow you.

Type "|cffffffff/corpse release|r" to direct dead group members to release their spirits.

Type "|cffffffff/corpse accept|r" to direct dead group members to accept resurrection to their corpse.]]
L.FollowingYouStart = "%s is now following you."
L.FollowingYouStop = "%s is no longer following you."
L.FollowMe = "Request follow"
L.FollowMe_Info = "Set a key binding to direct nearby group members to follow you."
L.FollowTarget = "Follow target"
L.FollowTarget_Info = "Set a key binding to follow your current target."
L.FollowTooFar = "%s is too far away to follow!"
L.RefollowAfterCombat = "Refollow after combat"
L.RefollowAfterCombat_Info = "Automatically try to follow your last followed target when leaving combat."
L.ReleaseCorpse = "Release spirit"
L.ReleaseCorpse_Info = "Set a key binding to direct dead group members to release their spirit."
L.Reincarnate = "Reincarnate" -- Must match Blizzard self-res dialog!
L.SlashCorpse = "/corpse"
L.SlashFollowMe = "/followme"
L.TargetedFollowMe = "Targetable /followme"
L.TargetedFollowMe_Info = "If your current target is a trusted group member, your /followme command will be sent only to that target."
L.UseSoulstone = "Use Soulstone" -- Must match Blizzard self-res dialog!

-----------
-- Group --
-----------

L.CantInviteNotLeader = "I cannot invite you, because I am not the group leader."
L.CantInviteNotTrusted = "I cannot invite you, because you are not on my trusted list."
L.CantPromoteNotLeader = "I cannot promote you, because I am not the group leader."
L.CantPromoteNotTrusted = "I cannot promote you, because you are not on my trusted list."
L.CmdNoPromote = "[Nn][Oo][Pp][Rr][Oo][Mm][Oo][Tt][Ee]"
L.Group = "Group"
L.Group_Info = "Responds to group invite and promote requests from trusted players."
L.GroupHelpText = [[Type "|cffffffff/inviteme|r" to request a group invitation from your current target.

Type "|cffffffff/inviteme Name|r" to request a group invitation from "Name".

Type "|cffffffff/promoteme|r" while in a group to request to be promoted to group leader.]]
L.SlashInviteMe = "/inviteme"
L.SlashPromoteMe = "/promoteme"

-----------
-- Mount --
-----------

L.Dismount = "Dismount with group"
L.Dismount_Info = "Dismount when another trusted group member dismounts."
L.Mount = "Mount"
L.Mount_Info = "Group mounting and dismounting."
L.MountHelpText = "" -- #TODO: Add text here
L.MountMissing = "%s has no available mount!"
L.MountRandom = "Use random mount"
L.MountRandom_Info = "Use a random mount of the same type as your trusted group member.\nIf this is disabled, you will use the same mount if you have it, or the first equivalent mount otherwise."
L.MountTogether = "Mount with group"
L.MountTogether_Info = "Mount when another trusted group member mounts."

-----------
-- Quest --
-----------

L.AbandonQuests = "Abandon quests"
L.AbandonQuests_Info = "Automatically abandon quests abandoned by trusted group members."
L.AcceptQuests = "Accept quests"
L.AcceptQuests_Info = "Automatically accept all quests."
L.OnlySharedQuests = "Only shared quests"
L.OnlySharedQuests_Info = "Only accept quests shared by group members, escort quests started by group members, and quests from NPCs that trusted group members have already accepted."
L.Quest = "Quest"
L.Quest_Info = "Helps keep group members' quests in sync."
L.QuestAbandoned = "%1$s abandoned %2$s."
L.QuestAccepted = "%1$s accepted %2$s."
L.QuestHelpText = "If you want an on-screen list of your other characters' quests, I recommend the addon Quecho, by Tekkub."
L.QuestNotShareable = "That quest cannot be shared."
L.QuestTurnedIn = "%1$s turned in %2$s."
L.ShareQuests = "Share quests"
L.ShareQuests_Info = "Automatically share quests you pick up from NPCs."
L.TurnInQuests = "Turn in quests"
L.TurnInQuests_Info = "Automatically turn in completed quests to NPCs."

----------
-- Taxi --
----------

L.SlashClearTaxi = "/cleartaxi"
L.Taxi = "Taxi"
L.Taxi_Info = "Selects the same taxi destination as other group members."
L.TaxiCleared = "Group taxi destination cleared."
L.TaxiHelpText = [[Hold the Shift key while speaking to a flight master to temporarily disable auto-selection.

Type "|cffffffff/cleartaxi|r" to clear the group taxi selection before the normal timeout.]]
L.TaxiMismatchError = "%s: Taxi node mismatch."
L.TaxiSet = "%1$s set the group taxi to %2$s."
L.TaxiTimeout_Info = "Clear the taxi selection after this many seconds."
L.TaxiTimeoutError = "%s: Taxi timeout reached."

-----------
-- Debug --
-----------

L.Debug = "Debug"
L.Debug_Info = "Enable debugging messages for the selected parts of Hydra."
L.DebugCore = "Core"