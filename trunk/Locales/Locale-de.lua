--[[--------------------------------------------------------------------
	Hydra
	Multibox leveling helper.
	Copyright (c) 2010-2014 Phanx <addons@phanx.net>. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info17572-Hydra.html
	http://www.curse.com/addons/wow/hydra
------------------------------------------------------------------------
	German localization
	Last updated 2014-01-04 by Phanx
	***
----------------------------------------------------------------------]]

if GetLocale() ~= "deDE" then return end
local HYDRA, core = ...
local L = core.L

-----------------
-- Core/Common --
-----------------

L.AddedTrusted = "%s wurde auf der Vertrauensliste hinzugefügt."
L.AddGroup = "Gruppe hinzufügen"
L.AddGroup_Info = "Fügt alle Spieler aus die Gruppe auf der Vertrauensliste hinzu."
L.AddName = "Name hinzufügen"
L.AddName_Info = "Fügt einen Name auf der Vertrauensliste hinzu."
L.ClickForOptions = "Klick für optionen."
L.CoreHelpText = [[Hydra funktioniert auf einer Vertrauensbasis. Legt fest, welche Spieler zu vertrauen, und Hydra aktiviert oder deaktiviert Funktionen auf der Grundlage, ob alle Spieler in der Gruppe auf der Vertrauensliste sind.

Zum Beispiel, Flüstern werden zu die Gruppe nur weitergeleitet, wenn jeder in der Gruppe ist auf der Vertrauensliste.]]
L.Enable = ENABLE
L.Enable_Info = "Aktiviert dieses Modul."
L.Hydra_Info = "Hydra ist ein Helfer für Multiboxing und Stufenaufstiegen als Gruppe, der versucht, die Notwendigkeit zu minimieren, um die Sekundärcharakteren kontrollieren."
L.RemoveAll = "Alle entfernen"
L.RemoveAll_Info = "Entfernt alle Namen aus der Vertrauensliste."
L.RemovedTrusted = "%s wurde aus der Vertrauensliste entfernt."
L.RemoveName = "Name enterfernen"
L.RemoveName_Info = "Enterfernt einen Name aus der Vertrauensliste."
L.Timeout = "Ablauf"
L.Verbose = "Wortreich"
L.Verbose_Info = "Aktiviert Benachrichtigungen von diesem Modul."

----------------
-- Automation --
----------------

L.AcceptCombatRes = "Wiederbelebungen im Kampf annehmen"
L.AcceptCombatRes_Info = "Nehmt Wiederbelebungen im Kampf von allen Gruppenmitglieder an."
L.AcceptedRes = "Eine Wiederbelebung von %s wurde angenommen."
L.AcceptedSummon = "Eine Beschwörung von %1$s nach %2$s wurde angenommen."
L.AcceptedSummonCombat = "Eine Beschwörung wird nach dem Kampf angenommen..."
L.AcceptRes = "Wiederbelebungen annehmen"
L.AcceptRes_Info = "Nehmt Wiederbelebungen außerhalb des Kampfes von allen Gruppenmitglieder an."
L.AcceptSummons = "Beschwörungen annehmen"
L.AcceptSummons_Info = "Nehmt Beschwörungen von vertrauenswürdige Spieler an."
L.Automation = "Automatisierung"
L.Automation_Info = "Automatisiert einige einfache wiederholende Aktionen, wie das Klicken auf häufige Dialoge."
--L.AutomationHelpText = ""
L.DeclineArenas = "Arenateams blockieren"
L.DeclineArenas_Info = "Blockiert Arenateameinladungen ab."
L.DeclinedArena = "Arenateameinladung von %s wurde blockiert."
L.DeclinedArenaPetition = "Arenateamsatzung von %s wurde blockiert."
L.DeclinedDuel = "Duellanfrage von %s wurde blockiert."
L.DeclinedGuild = "Gildenanfrage von %s wurde blockiert."
L.DeclinedGuildPetition = "Gildensatzung von %s wurde blockiert."
L.DeclineDuels = "Duelle blockieren"
L.DeclineDuels_Info = "Duellanfragen von allen Spielder blockieren."
L.DeclineGuilds = "Gilde blockieren"
L.DeclineGuilds_Info = "Gildenanfragen und -satzung von allen Spieler blockieren."
L.NoRepairMoney = "Nicht genug Geld für Reparaturen zu bezahlen!"
L.NoRepairMoneyGuild = "Nicht genug Gildenbankgeld für Reparaturen zu bezahlen!"
L.Repair = "Gegenstände reparieren"
L.Repair_Info = "Repariert alle Gegenstände auf die Interaktion mit einem Händler."
L.RepairGuild = "Gildenbankgeld ausgeben"
L.RepairGuild_Info = "Bezahlt für Reparaturen aus der Gildenbank, wenn möglich."
L.Repaired = "Alle Gegenstände wurden für %s repariert."
L.RepairedGuild = "Alle Gegenstände wurden für %s aus der Gildenbank repariert."
L.SellJunk = "Müll verkaufen"
L.SellJunk_Info = "Verkauft alle grau Artikel auf die Interaktion mit einem Händler."
L.SoldJunk = "%1$d |4Stück Müll wurde:Stücke Müll wurden; für %2$s verkauft."
L.SummonExpired = "Beschwörung abgelaufen!"

----------
-- Chat --
----------

L.AppFocus = "Spiel im Fokus"
L.Chat = "Chat"
L.Chat_Info = "Flüstern, die durch inaktive Charaktere eingehen, werden an Gruppenchat weitergeleitet, und Antworten werden an den eigentlichen Absender weitergeleitet."
L.ChatHelpText = [[Gebt eine Nachricht in Gruppenchat ein, um zum letzten Flüstern von jedem Gruppenmitglieder weitergeleitet zu antworten.

Gebt "|cffffffff@Name Nachricht hier|r" in Gruppenchat ein, um zum letzten Flüstern von "Name" weitergeleitet zu antworten.

Flüstert "|cffffffff@Name Nachricht hier|r" einen Charakter, um der zu befehlen, die Nachricht an "Name" zu flüstern.]]
L.DetectionMethod = "Wahrnehmungsmethode"
L.DetectionMethod_Info = "Wählt die Methode zur Erfassung der Hauptcharakter aus.\n\nWenn Ihr mehrere Computer verwendet, oder mehrere Instanzen des Spiels führt aus, der \"Spiel im Fokus\" Methode wird wahrscheinlich für Euch nicht funktionen, und Ihr müsst sicherstellen, dass Eure Hauptcharakter der Gruppenleiter ist."
L.GroupLeader = "Gruppenleiter"
L.GroupTimeout_Info = "Wenn diese viele Sekunden sind vergangen, seit die letzte Nachricht weitergeleitet wurde, neue Nachrichten in Gruppenchat werden nicht weitergeleitet, außer wenn die Ziel explizit angegeben wird."
L.GroupTimeoutError = "Gruppenweiterleitungsablauf überschritten."
L.WhisperFrom = "%1$s hat ein Flüstern von %2$s erhalten."
L.WhisperFromBnet = "%1$s hat ein Battle.net-Flustern von %2$s erhalten:\n%3$s"
L.WhisperFromConvo = "%1$s hat eine Battle.net-Nachricht von %2$s erhalten:\n%3$s"
L.WhisperFromGM = "%s hat eine Nachrict von einem GM erhalten!"
L.WhisperTimeoutError = "Flüsternablauf überschritten."

------------
-- Follow --
------------

L.AcceptCorpse = "Zu Leichnam wiederbeleben"
L.AcceptCorpse_Info = "Belegt eine Taste, um tote Gruppenmitglieder befehlen, in ihre Leichnam wiederzubeleben."
L.CanReincarnate = "%s kann wiederbeleben."
L.CanSelfRes = "%s kann selbst wiederbeleben."
L.CantRes = "%s kann nicht wiederbeleben!"
L.CantResDelay = "%1$s kann nicht für %2$d Sekuden mehr wiederbeleben."
L.CanUseSoulstone = "%s kann einen Seelenstein verwenden."
L.CmdAccept = "a[kn]?[zn]?e?[ph]?[tm]?i?e?r?e?n?"
L.CmdRelease = "f?r?e?i?l?a?s?s?e?n?"
L.Follow = "Folgen"
L.Follow_Info = "Dieses Modul gehorcht auf die Folgeantragen von vertrauenswürdige Gruppenmitglieder."
L.FollowHelpText = [[Gebt "|cffffffff/folgenmich|r" ein, um nahe Gruppenmitglieder zu befehlen, Euch zu folgen.

Gebt "|cffffffff/leichnam freilassen|r" ein, um tote Gruppenmitglieder befehlen, ihre Geister zu freilassen.

Gebt "|cffffffff/leichnam annehmen|r" ein, um tote Gruppenmitglieder befehlen, in ihre Leichnam wiederzubeleben.]]
L.FollowingYouStart = "%s folgt Euch jetzt."
L.FollowingYouStop = "%s folgt Euch nicht mehr."
L.FollowMe = "Folgende anfordern"
L.FollowMe_Info = "Belegt eine Taste, um nahe Gruppenmitglieder befehlen, Euch zu folgen."
L.FollowTarget = "Ziel folgen"
L.FollowTarget_Info = "Belegt eine Taste, um Eure aktuelle Ziel folgen."
L.FollowTooFar = "%s ist zu weit weg, um zu folgen!"
L.RefollowAfterCombat = "Nach dem Kampf wiederfolgen"
L.RefollowAfterCombat_Info = "Versucht automatisch Eure letzte folgende Ziel nach dem Kampf wieder zu folgen."
L.ReleaseCorpse = "Geister freilassen"
L.ReleaseCorpse_Info = "Belegt eine Taste, um tote Gruppenmitglieder befehlen, ihre Geister zu freilassen."
L.Reincarnate = "Reincarnate" -- Must match Blizzard self-res dialog!
L.SlashCorpse = "/leichnam"
L.SlashFollowMe = "/folgenmich"
L.TargetedFollowMe = "Anzielbare /folgenmich"
L.TargetedFollowMe_Info = "Wenn Eure aktuelle Ziel ist ein vertrauenswürdiges Gruppenmitglied, Eure \"/folgenmich\"-Befehl wird nur auf diese Ziel gesendet."
L.UseSoulstone = "Use Soulstone" -- Must match Blizzard self-res dialog!

-----------
-- Mount --
-----------

L.Dismount = "Absitzen bei Gruppe"
L.Dismount_Info = "Sitzt ab, wenn ein anderes vertrauenswürdiges Gruppenmitglied sitzt ab."
L.Mount = "Aufsitzen"
L.Mount_Info = "Mit diesem Modul kann die Gruppe zusammen aufsizten und absitzen."
--L.MountHelpText = ""
L.MountMissing = "%s hat keine verfügbaren Reittiere!"
L.MountRandom = "Zufälliges Reittier verwenden"
L.MountRandom_Info = "Verwendet ein zufälliges Reittier der gleichen Art wie Eure vertrauenswürdigen Gruppenmitglied.\nWenn diese Option deaktiviert, werdet Ihr das gleiche Reittier verwenden, wenn Ihr das habt, oder sonst das erste Reittier der gleichen Art."
L.MountTogether = "Mit Gruppe aufsitzen"
L.MountTogether_Info = "Sitzt auf, wenn ein anderes vertrauenswürdiges Gruppenmitglied sitzt auf."

-----------
-- Group --
-----------

L.CantInviteNotLeader = "Ich kann Euch nicht einladen, weil ich der Gruppenanführer nicht bin."
L.CantInviteNotTrusted = "Ich kann Euch nicht einladen, weil Ihr auf meiner Vertrauensliste nicht seid."
L.CantPromoteNotLeader = "Ich kann Euch nicht befördern, weil ich der Gruppenanführer nicht bin."
L.CantPromoteNotTrusted = "Ich kann Euch nicht befördern, weil Ihr auf meiner Vertrauensliste nicht seid."
L.CmdNoPromote = "[Nn][Ii][Cc][Hh][Tt][Bb][Ee][Ff][Öö][Rr][Dd][Ee][Rr][Nn]"
L.Group = "Gruppe"
L.Group_Info = "Dieses Modul gehorcht auf Gruppeneinladungen und Förderungsantragen von vertrauenswürdige Spieler."
L.GroupHelpText = [[Gebt "|cffffffff/ladetmich|r" ein, um eine Gruppeneinladung von Eure aktuellen Ziel zu anfordern.

Gebt "|cffffffff/ladetmich Name|r" ein, um eine Gruppeneinladung von "Name" zu anfordern.

Gebt "|cffffffff/befördernmich|r" ein, während Ihr in einer Gruppe seid, um eine Förderung als Gruppenanführer zu anforden.]]
L.SlashInviteMe = "/einladenmich"
L.SlashPromoteMe = "/befördernmich"

-----------
-- Quest --
-----------

L.AbandonQuests = "Quests abbrechen"
L.AbandonQuests_Info = "Automatisch brecht die Quests ab, die vertrauenswürdige Gruppenmitglieder abbrechen."
L.AcceptQuests = "Quests annehmen"
L.AcceptQuests_Info = "Automatisch nehmt alle Quests ab."
L.OnlySharedQuests = "Nur gemeinsame Quests"
L.OnlySharedQuests_Info = "Nur Quests annehmen, die von Gruppenmitgliedern geteilt werden, die Escort-Quests von Gruppenmitgliedern gestartet sind, die eine vertrauenswürdige Gruppenmitglied bereits von einem NSC nahm an."
L.Quest = "Quests"
L.Quest_Info = "Mit diesem Modul kann die Gruppe Quests zusammen machen."
L.QuestAbandoned = "%1$s hat die Quest '%2$s' abgebrochen."
L.QuestAccepted = "%1$s had die Quest '%2$s' angenommen."
L.QuestHelpText = "Wenn Ihr eine Liste der Quests Euer weiteren Charaktere wollt, ich empfehle, dass Ihr das Addon 'Quecho' von Tekkub verwendet."
L.QuestNotShareable = "Diese Quest kann nicht geteilt werden."
L.QuestTurnedIn = "%1$s hat die Quest '%2$s'  abgeschlossen."
L.ShareQuests = "Quests teilen"
L.ShareQuests_Info = "Automatisch teilt die Quests, die Ihr von NSCs nehmt an."
L.TurnInQuests = "Quests abschließen"
L.TurnInQuests_Info = "Automatisch schließt die Quests zu NSCs ab."


----------
-- Taxi --
----------

L.SlashClearTaxi = "/fluglöschen"
L.Taxi = "Fliegen"
L.Taxi_Info = "Mit diesem Modul kann die Gruppe zusammen fliegen."
L.TaxiCleared = "Gruppenflugziel erlöscht."
L.TaxiHelpText = [[Drückt die SHIFT-Taste auf die Interaktion mit einem Flugmeister, um die automatische Auswahl vorübergehend deaktivieren.

Gebt "|cffffffff/fluglöschen|r" ein, um die Gruppenflugziel vor der üblichen Ablaufzeit zu löschen.]]
L.TaxiMismatchError = "%s: Flugziele stimmen nicht überein!"
L.TaxiSet = "%1$s hat die Gruppenflugziel auf %2$s festgelegt."
L.TaxiTimeout_Info = "Wenn diese viele Sekunden sind vergangen, die Gruppenflugziel wird gelöscht."
L.TaxiTimeoutError = "%s: Ablaufzeit des Gruppenflugziels ist vorbei."