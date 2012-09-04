--[[--------------------------------------------------------------------
	Hydra
	Multibox leveling helper.
	Copyright (c) 2010-2012 Phanx <addons@phanx.net>. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info17572-Hydra.html
	http://www.curse.com/addons/wow/hydra
------------------------------------------------------------------------
	French Localization (Français)
	Last updated 2012-02-2012 by Araldwenn on CurseForge
----------------------------------------------------------------------]]

if GetLocale() ~= "frFR" then return end
local L, _, core = { }, ...
core.L = L

----------
-- Core --
----------

L["Hydra is a multibox leveling helper that aims to minimize the need to actively control secondary characters."] = "Hydra est une aide au leveling en multibox dont le but est de minimiser le besoin de contrôler activement les personnages secondaires."
L["Trust List"] = "Liste de confiance"
L["Add Name"] = "Ajouter le nom"
L["Add a name to your trusted list."] = "Ajouter un nom à votre liste de confiance."
L["Remove Name"] = "Supprimer le nom"
L["Remove a name from your trusted list."] = "Supprime un nom de votre liste de confiance."
L["Add Party"] = "Ajouter le groupe"
L["Adds all the characters in your current party group to your trusted list."] = "Ajouter tous les personnages de votre groupe actuel à votre liste de confiance."
-- L["Remove All"] = ""
-- L["Remove all names from your trusted list for this server."] = ""

L["Added %s to the trusted list."] = "%s ajouté à la liste de confiance."
L["Removed %s from the trusted list."] = "%s supprimé de la liste de confiance."

L.HELP_TRUST = [[Hydra fonctionne sur la base de la "confiance". Vous lui dites à quels personnages faire confiance, qu'ils soient vos personnages de multibox ou des compagnons de quête, et les fonctionnalités sont activées ou désactivées selon que vous êtes dans un groupe avec des personnages de confiance ou pas. Par exemple, les chuchotement sont seulement transférés dans le canal de groupe si tout le monde dans votre groupe est dans votre liste de confiance.]]

------------
-- Common --
------------

L["Enable"] = "Activer"
L["Enable this module."] = "Activer ce module."

L["Verbose mode"] = "Mode verbose"
L["Enable notification messages from this module."] = "Activer les messages de notification de ce module."

L["Timeout"] = ""

----------------
-- Automation --
----------------

L["Automation"] = "Automatisation"
L["Automates simple repetetive tasks, such as clicking common dialogs."] = "Automatise certaines tâches répétitives, comme cliquer sur les dialogues communs."
L["Decline duels"] = "Décliner les duels"
--L["Decline duel requests."] = ""
L["Decline arena teams"] = "Décliner les équipes d'arêne"
--L["Decline arena team invitations and petitions."] = ""
L["Decline guilds"] = "Décliner les guildages"
--L["Decline guild invitations and petitions."] = ""
L["Accept summons"] = "Accepte les invocations"
--L["Accept summon requests."] = ""
L["Accept resurrections"] = "Accepte les résurrections"
--L["Accept resurrections from players not in combat."] = ""
L["Accept combat resurrections"] = "Accepter les résurrection de combat"
--L["Accept resurrections from players in combat."] = ""
L["Repair equipment"] = "Réparer l'équipement"
--L["Repair all equipment when interacting with a repair vendor."] = ""
L["Sell junk"] = "Vendre les objets gris"
--L["Sell all junk (gray) items when interacting with a vendor."] = ""

L["Declined an arena team invitation from %s."] = "Décliner une invitation dans une équipe d'arêne de %s."
L["Declined an arena team petition from %s."] = "Décliner une signature de charte d'équipe d'arêne de %s."
L["Declined a guild invitation from %s."] = "Décliner une invitation de guilde de %s."
L["Declined a guild petition from %s."] = "Décliner une signature de charte de guilde de %s."
L["Declined a duel request from %s."] = "Décliner une demande de duel de %s."
L["Sold %1$d junk |4item:items; for %2$s."] = "Vendu %1$d junk |4item:items; pour %2$s."
L["Repaired all items with guild bank funds for %s."] = "Tous les items réparés avec les fonds de la banque de guilde pour %s."
L["Insufficient guild bank funds to repair!"] = "Fonds de banque de guilde insuffisants pour réparer !"
L["Repaired all items for %s."] = "Tous les items réparés pour %s."
L["Insufficient funds to repair!"] = "Fonds insuffisants pour réparer !"
L["Accepted a resurrection from %s."] = "Accepter une résurrection de %s."
L["Accepting a summon from %1$s to %2$s."] = "Accepter une invocation de %1$s vers %2$s."
L["Accepting a summon when combat ends..."] = "Accepter une invocation à la fin du combat..."
L["Summon expired!"] = "Invocation expirée !"

--L.HELP_AUTO = [[]]

----------
-- Chat --
----------

L["Chat"] = "Discussion"
L["Forwards whispers sent to inactive characters to party chat, and forwards replies to the original sender."] = "Transférer les chuchotements au personnage inactif vers le canal de groupe, et transférer les réponses à l'envoyeur original."
L["Detection method"] = "Mode"
--L["Select the method to use for detecting the primary character."] = ""
L["If you are multiboxing on multiple physical machines, or are running multiple copies of WoW in windowed mode, the \"Application Focus\" mode will probably not work for you, and you should make sure that your primary character is the party leader."] = ""
L["Application Focus"] = "Application de la focalisation"
L["Party Leader"] = "Chef du groupe"
--L["If this many seconds have elapsed since the last forwarded message, don't forward messages typed in party chat to the last whisperer unless the target is explicitly specified."] = ""

L["|TInterface\\ChatFrame\\UI-ChatIcon-Blizz.blp:0:2:0:-3|t %s has received a whisper from a GM!"] = "|TInterface\\ChatFrame\\UI-ChatIcon-Blizz.blp:0:2:0:-3|t %s a reçu un message d'un GM !"
L["%1$s has received a Battle.net whisper from %2$s."] = "%1$s a reçu un chuchotement Battle.net de %2$s."
L["%1$s has received a whisper from %2$s."] = "%1$s a reçu un chuchotement de %2$s."
L["!ERROR: Party forwarding timeout reached."] = "!ERREUR: délai de groupage expiré !"
L["!ERROR: Whisper timeout reached."] = "!ERREUR: délai de chuchotement expirée !"

L.HELP_CHAT = [[Ecrivez un message dans le canal de groupe pour répondre au dernier message chuchotté transféré de n'importe quel personne.

Ecrivez "|cffffffff@name Votre message ici|r" dans un chuchotement à un personnage pour ordonner à ce personnage d'envoyer en chuchotement le message à "name".]]

------------
-- Follow --
------------

L["Follow"] = "Suivre"
L["Responds to follow requests from trusted party members."] = "Répondre aux requêtes de suivi des membres du groupe de confiance."
--L["Set a key binding to follow your current target."] = ""
--L["Set a key binding direct all characters in your party to follow you."] = ""
--L["Set a key binding to direct all dead characters in your party to release their spirit."] = ""
--L["Set a key binding to direct all ghost characters in your party to accept resurrection to their corpse."] = ""

L["%s is now following you."] = "%s vous suit à présent."
L["%s is no longer following you."] = "%s ne vous suit plus."
L["%s is no longer following you!"] = "%s ne vous suit plus !"
L["%s is too far away to follow!"] = "%s est trop loin pour vous suivre !"
L["Use Soulstone"] = "Utiliser une pierre d'âme" -- Needs check
L["Reincarnate"] = "Réincarnation" -- Needs check
L["I have a soulstone."] = "J'ai une pierre d'âme."
L["I can reincarnate."] = "Je peux me réincarner."
L["I can resurrect myself."] = "Je peux me ressuciter par moi-même."
L["I cannot resurrect!"] = "Je ne peux pas ressuciter !"

L.HELP_FOLLOW = [[Type "|cffffffff/suivezmoi|r" pour demander à tous les membres du groupe à proximité de vous suivre.

Tapez "|cffffffff/corps libérer|r" pour demander à tous les membres du groupe mort de libérer l'esprit.

Type "|cffffffff/corps accepter|r" pour demander à tous les membres du groupe en fantôme d'accepter la résurrection.]]

L.SLASH_HYDRA_FOLLOWME3 = "/suivezmoi"

L.SLASH_HYDRA_CORPSE2 = "/corps"
L["release"] = "libérer"
L["accept"] = "accepter"

L.BINDING_NAME_HYDRA_FOLLOW_TARGET = "Suivre la cible"
L.BINDING_NAME_HYDRA_FOLLOW_ME = "Suivez-moi"
L.BINDING_NAME_HYDRA_RELEASE_CORPSE = "Libérer l'esprit"
L.BINDING_NAME_HYDRA_ACCEPT_CORPSE = "Ressuciter"

-----------
-- Mount --
-----------

L["Mount"] = "Monture"
L["Summons your mount when another party member mounts."] = "Invoque votre monture quand un autre membre du goupe invoque la sienne."

L["ERROR: %s is missing that mount!"] = "ERREUR : %s ne connaît pas cette monture !"

--L.HELP_MOUNT = [[]]

-----------
-- Party --
-----------

L["Party"] = "Groupe"
L["Responds to invite and promote requests from trusted players."] = "Répond aux invitations et requêtes des joueurs de confiance."

L["I cannot invite you, because you are not on my trusted list."] = "Je ne peux pas vous inviter, car vous n'êtes pas dans ma liste de confiance."
L["I cannot invite you, because I am not the party leader."] = "Je ne peux pas vous inviter, car je ne suis pas le chef du groupe."
L["I cannot promote you, because you are not on my trusted list."] = "Je ne peux pas vous promouvoir, car vous n'êtes pas dans ma liste de confiance."
L["I cannot promote you, because I am not the party leader."] = "Je ne peux pas vous promouvoir, car je ne suis pas le chef du groupe."

L.HELP_PARTY = [[Type "|cffffffff/invitezmoi|r" pour demander un groupage à votre cible actuelle.

Type "|cffffffff/invitezmoi Nom|r" pour demander un groupage à  "Nom".

Type "|cffffffff/promouvezmoi|r" en étant groupé pour demander une promotion comme chef du groupe.]]

L.SLASH_HYDRA_INVITEME3 = "/invitezmoi"
L.SLASH_HYDRA_PROMOTEME3 = "/promouvezmoi"

-----------
-- Quest --
-----------

L["Quest"] = "Quête"
L["Helps keep party members' quests in sync."] = "Permet de garder les quêtes des membres du groupe synchronisées."
L["Turn in quests"] = "Valider les quêtes"
L["Turn in complete quests."] = "Valider les quêtes achevées."
L["Accept quests"] = "Accepter les quêtes"
L["Accept quests shared by party members, quests from NPCs that other party members have already accepted, and escort-type quests started by another party member."] = "Accepter les quêtes partagées par les membres du groupe, quêtes de PNJ que les autres membres du groupe ont déjà accepté, et quête type escorte commencées par un autre membre du groupe."
L["Share quests"] = "Partager les quêtes"
L["Share quests you accept from NPCs."] = "Partage les quêtes que vous avez acceptées des PnJ."
L["Abandon quests"] = "Abandonner les quêtes"
L["Abandon quests abandoned by a trusted party member."] = "Abandonner les quêtes abandonnées par un membre du groupe de confiance."

L["%1$s accepted %2$s."] = "%1$s a accepté %2$s."
L["%1$s turned in %2$s."] = "%1$s a validé %2$s."
L["%1$s abandoned %2$s."] = "%1$s a abandonné %2$s."
L["That quest cannot be shared."] = "Cette quête ne peux pas être partagée."

--L.HELP_QUEST = [[]]

----------
-- Taxi --
----------

--L["Taxi"] = ""
L["Selects the same taxi destination as other party members."] = "Sélectionne la même destination de taxi que les autres membre du groupe."
L["Clear the taxi selection after this many seconds."] = "Effacer la sélection de taxi après ce nombre de secondes."

L["ERROR: %s: Taxi timeout reached."] = "ERREUR : %s : délai de taxi expiré."
L["ERROR: %s: Taxi node mismatch."] = "ERREUR : %s : noeud de taxi inadéquat."
L["%1$s set the party taxi to %2$s."] = "%1$s a défini le taxi du groupe sur %2$s."
L["Party taxi cleared."] = "Taxi du groupe effacé."

L.HELP_TAXI = [[Garder la touche Maj appuyée en parlant au maître de vol pour désactiver temporairement la sélection automatique.

Tapez "|cffffffff/cleartaxi" pour effacer la sélection de trajet du groupe avant la fin du délai.]]

L.SLASH_HYDRA_CLEARTAXI2 = "/effacertaxi"