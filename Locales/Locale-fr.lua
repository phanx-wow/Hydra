--[[--------------------------------------------------------------------
	Hydra
	Multibox leveling helper.
	Copyright (c) 2010-2014 Phanx <addons@phanx.net>. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info17572-Hydra.html
	http://www.curse.com/addons/wow/hydra
------------------------------------------------------------------------
	French localization
	Last updated 2012-02-27 by Araldwenn
	***
----------------------------------------------------------------------]]

if GetLocale() ~= "frFR" then return end
local HYDRA, core = ...
local L = core.L

-----------------
-- Core/Common --
-----------------

--L.AddedTrusted = "%s has been added to your trusted list."
L.AddGroup = "Ajouter le groupe"
L.AddGroup_Info = "Ajouter tous les personnages de votre groupe actuel à votre liste de confiance."
L.AddName = "Ajouter le nom"
L.AddName_Info = "Ajouter un nom à votre liste de confiance."
L.ClickForOptions = "Click for options."
L.CoreHelpText = [[Hydra fonctionne sur la base de la "confiance". Vous lui dites à quels personnages faire confiance, qu'ils soient vos personnages de multibox ou des compagnons de quête, et les fonctionnalités sont activées ou désactivées selon que vous êtes dans un groupe avec des personnages de confiance ou pas.

Par exemple, les chuchotement sont seulement transférés dans le canal de groupe si tout le monde dans votre groupe est dans votre liste de confiance.]]
L.Enable = ENABLE
L.Enable_Info = "Activer ce module."
L.Hydra_Info = "Hydra est une aide au leveling en multibox dont le but est de minimiser le besoin de contrôler activement les personnages secondaires."
--L.RemoveAll = "Remove All"
--L.RemoveAll_Info = "Clear your existing trusted list, removing all characters from all servers."
--L.RemoveEmpty = "Your trusted list is empty."
--L.RemovedTrusted = "%s has been removed from your trusted list."
L.RemoveName = "Supprimer le nom"
L.RemoveName_Info = "Supprime un nom de votre liste de confiance."
L.Timeout = "Délai"
L.Verbose = "Mode verbose"
L.Verbose_Info = "Activer les messages de notification de ce module."

------------
-- Assist --
------------

--L.Assist = "Assist"
--L.Assist_Info = "Synchronizes an assist target across trusted group members."
--L.AssistFailed = "%s could not assist you due to an unknown error."
--L.AssistFailedCombat = "%s will assist you after combat."
--L.AssistFailedTrust = "%s cannot assist you because you are not on their trusted list."
--L.AssistGetMacro = "Get Macro"
--L.AssistGetMacro_Info = "If you prefer to activate the Assist function from your action bars, you can use this button to get a macro you can drop onto any action button."
--L.AssistHelpText = "This module is really only useful in combination with key cloning software. You should set your selected |cffffffffAssist|r key to be sent to your secondary clients."
--L.AssistMacro = "Assist"
--L.AssistMacro_Info = "Set a key binding to assist your current assist target."
--L.AssistRespond = "Assist"
--L.AssistRespond_Info = "Respond to assist requests from trusted group members."
--L.AssistSet = "%s will now assist you."
--L.AssistUnset = "%s is now assisting %s instead of you."
--L.NobodyAssisting = "Nobody is currently assisting you."
--L.RequestAssist = "Request Assist"
--L.RequestAssist_Info = "Set a key binding to request that all group members set you as their assist target."
--L.SlashAssistMe = "/assistme"

----------------
-- Automation --
----------------

L.AcceptCombatRes = "...de combat"
L.AcceptCombatRes_Info = "Accepter les résurrection de combat."
L.AcceptedRes = "Accepter une résurrection de %s."
L.AcceptedSummon = "Accepter une invocation de %1$s vers %2$s."
L.AcceptedSummonCombat = "Accepter une invocation à la fin du combat..."
L.AcceptRes = "Accepte les résurrections"
--L.AcceptRes_Info = "Accept resurrections out of combat from all group members."
L.AcceptSummons = "Accepte les invocations"
--L.AcceptSummons_Info = "Accept summons from trusted players."
L.Automation = "Automatisation"
L.Automation_Info = "Automatise certaines tâches répétitives, comme cliquer sur les dialogues communs."
--L.AutomationHelpText = ""
L.DeclineArenas = "Décliner les équipes d'arêne"
--L.DeclineArenas_Info = "Decline arena team invitations and petitions from all players."
L.DeclinedArena = "Décliner une invitation dans une équipe d'arêne de %s."
L.DeclinedArenaPetition = "Décliner une signature de charte d'équipe d'arêne de %s."
L.DeclinedDuel = "Décliner une demande de duel de %s."
L.DeclinedGuild = "Décliner une invitation de guilde de %s."
L.DeclinedGuildPetition = "Décliner une signature de charte de guilde de %s."
L.DeclineDuels = "Décliner les duels"
--L.DeclineDuels_Info = "Decline duel requests from all players."
L.DeclineGuilds = "Décliner les guildages"
--L.DeclineGuilds_Info = "Decline guild invitations and petitions from all players."
L.NoRepairMoney = "Fonds insuffisants pour réparer !"
L.NoRepairMoneyGuild = "Fonds de banque de guilde insuffisants pour réparer !"
L.Repair = "Réparer l'équipement"
--L.Repair_Info = "Repair all equipment when interacting with a repair vendor."
L.RepairGuild = "Utiliser l'or de guilde"
L.RepairGuild_Info = "Payer les réparations avec la banque de guilde quand possible."
L.Repaired = "Tous les items réparés pour %s."
L.RepairedGuild = "Tous les items réparés avec les fonds de la banque de guilde pour %s."
L.SellJunk = "Vendre les objets gris"
--L.SellJunk_Info = "Sell junk (gray) items when interacting with a vendor."
L.SoldJunk = "Vendu %1$d junk |4item:items; pour %2$s."

----------
-- Chat --
----------

L.AppFocus = "Application de la focalisation"
L.Chat = "Discussion"
L.Chat_Info = "Transférer les chuchotements au personnage inactif vers le canal de groupe, et transférer les réponses à l'envoyeur original."
L.ChatHelpText = [[Ecrivez un message dans le canal de groupe pour répondre au dernier message chuchotté transféré de n'importe quel personne.

Ecrivez "|cffffffff@name Votre message ici|r" dans un chuchotement à un personnage pour ordonner à ce personnage d'envoyer en chuchotement le message à "name".]]
L.DetectionMethod = "Mode"
--[=[ L.DetectionMethod_Info = [[Select the method to use for detecting the primary character.

If you are multiboxing on multiple physical machines, or are running multiple copies of WoW in windowed mode, the "Application Focus" mode will probably not work for you, and you should make sure that your primary character is the group leader.]] ]=]
L.GroupLeader = "Chef du groupe"
--L.GroupTimeout_Info = "If this many seconds have elapsed since the last forwarded message, don't forward messages typed in group chat to the last whisperer unless the target is explicitly specified."
L.GroupTimeoutError = "Délai de groupage expiré !"
L.WhisperFrom = "%1$s received a whisper from %2$s."
L.WhisperFromBnet = "%1$s a reçu un chuchotement Battle.net de %2$s :\n%3$s"
L.WhisperFromConvo = "%1$s a reçu un chuchotement de %2$s :\n%3$s"
L.WhisperFromGM = "%s a reçu un message d'un GM !"
L.WhisperTimeoutError = "Délai de chuchotement expirée !"

------------
-- Follow --
------------

L.AcceptCorpse = "Ressuciter"
--L.AcceptCorpse_Info = "Set a key binding to direct dead group members to accept resurrection to their corpse."
--L.CanReincarnate = "%s can use Reincarnation."
--L.CanSelfRes = "%s can self-ressurect."
--L.CantRes = "%s cannot be resurrected!"
--L.CantResDelay = "%1$s cannot be resurrected for %2$d more seconds!"
--L.CanUseSoulstone = "%s can use a Soulstone."
L.CmdAccept = "accepter"
L.CmdRelease = "lib[ée]rer"
L.Follow = "Suivre"
L.Follow_Info = "Répondre aux requêtes de suivi des membres du groupe de confiance."
L.FollowHelpText = [[Tapez "|cffffffff/suivezmoi|r" pour demander à tous les membres du groupe à proximité de vous suivre.

Tapez "|cffffffff/corps libérer|r" pour demander à tous les membres du groupe mort de libérer l'esprit.

Tapez "|cffffffff/corps accepter|r" pour demander à tous les membres du groupe en fantôme d'accepter la résurrection.]]
L.FollowingYouStart = "%s vous suit à présent."
L.FollowingYouStop = "%s ne vous suit plus."
L.FollowMe = "Suivez-moi"
--L.FollowMe_Info = "Set a key binding to direct nearby group members to follow you."
L.FollowTarget = "Suivre la cible"
--L.FollowTarget_Info = "Set a key binding to follow your current target."
L.FollowTooFar = "%s est trop loin pour vous suivre !"
L.ReleaseCorpse = "Libérer l'esprit"
--L.ReleaseCorpse_Info = "Set a key binding to direct dead group members to release their spirit."
--L.RefollowAfterCombat = "Refollow after combat"
--L.RefollowAfterCombat_Info = "Automatically try to follow your last followed target when leaving combat."
L.Reincarnate = "Réincarnation" -- Must match Blizzard self-res dialog!
L.SlashCorpse = "/corps"
L.SlashFollowMe = "/suivezmoi"
--L.TargetedFollowMe = "Targetable /followme"
--L.TargetedFollowMe_Info = "If your current target is a trusted group member, your /followme command will be sent only to that target."
L.UseSoulstone = "Utiliser une pierre d'âme" -- Must match Blizzard self-res dialog!

-----------
-- Group --
-----------

L.CantInviteNotLeader = "Je ne peux pas vous inviter, car je ne suis pas le chef du groupe."
L.CantInviteNotTrusted = "Je ne peux pas vous inviter, car vous n'êtes pas dans ma liste de confiance."
L.CantPromoteNotLeader = "Je ne peux pas vous promouvoir, car je ne suis pas le chef du groupe."
L.CantPromoteNotTrusted = "Je ne peux pas vous promouvoir, car vous n'êtes pas dans ma liste de confiance."
L.CmdNoPromote = "[Nn][Oo][Pp][Rr][Oo][Mm][Oo][Uu][Vv][Oo][Ii][Rr]"
L.Group = "Groupe"
L.Group_Info = "Répond aux invitations et requêtes des joueurs de confiance."
L.GroupHelpText = [[Tapez "|cffffffff/invitezmoi|r" pour demander un groupage à votre cible actuelle.

Tapez "|cffffffff/invitezmoi Nom|r" pour demander un groupage à "Nom".

Tapez "|cffffffff/promouvezmoi|r" en étant groupé pour demander une promotion comme chef du groupe.]]
L.SlashInviteMe = "/invitezmoi"
L.SlashPromoteMe = "/promouvezmoi"

-----------
-- Mount --
-----------

--L.Dismount = "Dismount with group"
--L.Dismount_Info = "Dismount when another trusted group member dismounts."
L.Mount = "Monture"
--L.Mount_Info = "Group mounting and dismounting."
--L.MountHelpText = ""
L.MountMissing = "%s ne connaît pas cette monture !"
--L.MountRandom = "Use random mount"
--L.MountRandom_Info = "Use a random mount of the same type as your trusted group member.\nIf this is disabled, you will use the same mount if you have it, or the first equivalent mount otherwise."
L.MountTogether = "Monture"
L.MountTogether_Info = "Invoque votre monture quand un autre membre du goupe invoque la sienne."

-----------
-- Quest --
-----------

L.AbandonQuests = "Abandonner les quêtes"
L.AbandonQuests_Info = "Abandonner les quêtes abandonnées par un membre du groupe de confiance."
L.AcceptQuests = "Accepter les quêtes"
--L.AcceptQuests_Info = "Automatically accept all quests."
--L.OnlySharedQuests = "Only shared quests"
L.OnlySharedQuests_Info = "Accepter les quêtes partagées par les membres du groupe, quêtes de PNJ que les autres membres du groupe ont déjà accepté, et quête type escorte commencées par un autre membre du groupe."
L.Quest = "Quête"
L.Quest_Info = "Permet de garder les quêtes des membres du groupe synchronisées."
L.QuestAbandoned = "%1$s a abandonné %2$s."
L.QuestAccepted = "%1$s a accepté %2$s."
--L.QuestHelpText = "If you want an on-screen list of your other characters' quests, I recommend the addon Quecho, by Tekkub."
L.QuestNotShareable = "Cette quête ne peux pas être partagée."
L.QuestTurnedIn = "%1$s a validé %2$s."
L.ShareQuests = "Partager les quêtes"
L.ShareQuests_Info = "Partage les quêtes que vous avez acceptées des PnJ."
L.TurnInQuests = "Valider les quêtes"
L.TurnInQuests_Info = "Valider les quêtes achevées."

----------
-- Taxi --
----------

L.SlashClearTaxi = "/effacertaxi"
L.Taxi = "Taxi"
L.Taxi_Info = "Sélectionne la même destination de taxi que les autres membre du groupe."
L.TaxiCleared = "Taxi du groupe effacé."
L.TaxiHelpText = [[Garder la touche Maj appuyée en parlant au maître de vol pour désactiver temporairement la sélection automatique.

Tapez "|cffffffff/effacertaxi" pour effacer la sélection de trajet du groupe avant la fin du délai.]]
L.TaxiMismatchError = "%s : noeud de taxi inadéquat."
L.TaxiSet = "%1$s a défini le taxi du groupe sur %2$s."
L.TaxiTimeout_Info = "Effacer la sélection de taxi après ce nombre de secondes."
L.TaxiTimeoutError = "%s : délai de taxi expiré."

-----------
-- Debug --
-----------

--L.Debug = "Debug"
--L.Debug_Info = "Enable debugging messages for the selected parts of Hydra."
--L.DebugCore = "Core"