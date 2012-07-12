--[[--------------------------------------------------------------------
	Hydra
	Multibox leveling helper.
	Copyright (c) 2010-2012 Phanx <addons@phanx.net>. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info17572-Hydra.html
	http://www.curse.com/addons/wow/hydra
------------------------------------------------------------------------
	Localization: esMX | Español (AL) | Spanish (Latin America)
	Last updated 2012-04-22 by Phanx
----------------------------------------------------------------------]]

if not string.match( GetLocale(), "^es" ) then return end
local L, _, core = { }, ...
core.L = L

----------
-- Core --
----------

L["Hydra is a multibox leveling helper that aims to minimize the need to actively control secondary characters."] = "Hydra es un ayudante para la nivelación multibox que tiene como objetivo reducir al mínimo la necesidad de controlar activamente personajes secundarios."
L["Trust List"] = "Lista de confianza"
L["Add Name"] = "Añadir nombre"
L["Add a name to your trusted list."] = "Añadir a la lista de confianza un nombre."
L["Add Party"] = "Añadir grupo"
L["Add all the characters in your current party group to your trusted list."] = "Añadir a la lista de confianza los nombres de todos en tu grupo."
L["Remove Name"] = "Eliminar nombre"
L["Remove a name from your trusted list."] = "Eliminar de la lista de confianza un nombre."
L["Remove All"] = "Eliminar todos"
L["Remove all names from your trusted list for this server."] = "Eliminar de la lista de todos los nombres en este reino."

L["Added %s to the trusted list."] = "Añadido %s a la lista de confianza."
L["Removed %s from the trusted list."] = "Eliminado %s de la lista de confianza."

L.HELP_TRUST = [[Hydra opera sobre la base de "confianza". Te añada una lista de personajes de tu confianza, si son tus personajes multibox, o tus amigos, y las funciones se activan o desactivan si estás en una grupo con personajes de confianza o no.

Por ejemplo, los susurros son sólo reenvió al chat de grupo si todos en el grupo que está en la lista de confianza.]]

------------
-- Common --
------------

L["Enable"] = "Activar"
L["Enable this module."] = "Activar este módulo."

L["Verbose mode"] = "Verboso"
L["Enable notification messages from this module."] = "Activar mensajes de notificación de este módulo."

L["Timeout"] = "Tiempo de espera"

----------------
-- Automation --
----------------

L["Automation"] = "Automatización"
L["Automates simple repetetive tasks, such as clicking common dialogs."] = "Automatiza tareas repetitivas simples, como hacer clic en los cuadros de diálogo comunes."
L["Decline duels"] = "Rechazar duelos"
L["Decline duel requests."] = "Rechazar invitaciones a duelos."
L["Decline arena teams"] = "Rechazar equipos de arena"
L["Decline arena team invitations and petitions."] = "Rechazar invitaciones y peticiones de equipos de arena."
L["Decline guilds"] = "Rechazar invitaciones de hermandad"
L["Decline guild invitations and petitions."] = "Rechazar invitaciones y peticiones de hermandades."
L["Accept summons"] = "Aceptar invocaciones"
L["Accept summon requests."] = "Aceptar invocaciones ofrecidos."
L["Accept resurrections"] = "Aceptar resurecciones"
L["Accept resurrections from players not in combat."] = "Aceptar resurecciones ofrecidos por jugadores que no están en combate."
L["Accept combat resurrections"] = "Aceptar resurecciones en combate"
L["Accept resurrections from players in combat."] = "Aceptar resurecciones ofrecidos por jugadores que están en combate."
L["Repair equipment"] = "Reparar equipos"
L["Repair all equipment when interacting with a repair vendor."] = "Reparar todos equipos cuando hablas con un vendedor."
L["Sell junk"] = "Vender chatarra"
L["Sell all junk (gray) items when interacting with a vendor."] = "Venda todas las chatarra (objetos gris) en el inventario cuando hablas con un vendedor."

L["Declined an arena team invitation from %s."] = "Rechazó una invitación a equipo de arena de %s"
L["Declined an arena team petition from %s."] = "Rechazó una petición de equipo de arena de %s."
L["Declined a guild invitation from %s."] = "Rechazó una invitación a hermandad de %s"
L["Declined a guild petition from %s."] = "Rechazó una petición de hermandad de %s."
L["Declined a duel request from %s."] = "Rechazó una invitación a duelo de X."
L["Sold %1$d junk |4item:items; for %2$s."] = "Vendió %1$d |4artículo:artículos; chatarra por %2$s."
L["Repaired all items with guild bank funds for %s."] = "Reparado todos los objetos con dinero del banco de hermandad por %s."
L["Insufficient guild bank funds to repair!"] = "Insuficiente dinero en el banco de hermandad para reparar!"
L["Repaired all items for %s."] = "Reparado todos los objetos por %s."
L["Insufficient funds to repair!"] = "Insuficiente dinero para reparar!"
L["Accepted a resurrection from %s."] = "Aceptada la resurrección de %s."
L["Accepting a summon from %1$s to %2$s."] = "Aceptando invocar por %1$s a %2$s."
L["Accepting a summon when combat ends..."] = "Aceptando invocar cuando el combate termina ..."
L["Summon expired!"] = "Invocar caducado!"

L.HELP_AUTO = [[]]

----------
-- Chat --
----------

L["Chat"] = "Chat"
L["Forwards whispers sent to inactive characters to party chat, and forwards replies to the original sender."] = "Reenvía susurros enviado a los personajes inactivos por el chat del grupo, y reenvía las respuestas al remitente original."
L["Detection method"] = "Método de detección"
L["Select the method to use for detecting the primary character."] = "Elegir el método a utilizar para detectar el personaje principal."
L["If you are multiboxing on multiple physical machines, or are running multiple copies of WoW in windowed mode, the \"Application Focus\" mode will probably not work for you, and you should make sure that your primary character is the party leader."] = "Si estás jugando en más de una computadora, o estás ejecutando varias copias de WoW en modo ventana en la misma computadora, el modo de \"Programa en primer plano\" probablemente no funciona, y tendrá que promover tu personaje principal al líder del grupo."
L["Application Focus"] = "Programa en primer plano"
L["Party Leader"] = "Líder del grupo"
L["If this many seconds have elapsed since the last forwarded message, don't forward messages typed in party chat to the last whisperer unless the target is explicitly specified."] = "Si esta cantidad de segundos transcurridos desde el mensaje reenviado pasado, no reenviar mensajes escritos en el chat de grupo al remitente susurro última a menos que el objetivo se especifica explícitamente."

L["|TInterface\\ChatFrame\\UI-ChatIcon-Blizz.blp:0:2:0:-3|t %s has received a whisper from a GM!"] = "|TInterface\\ChatFrame\\UI-ChatIcon-Blizz.blp:0:2:0:-3|t %s ha recibido un susurro de un GM!"
L["%1$s has received a Battle.net whisper from %2$s."] = "%1$s ha recibido un susurro de Battle.net por %2$s."
L["%1$s has received a whisper from %2$s."] = "%1$s ha recibido un susurro por %2$s."
L["!ERROR: Party timeout reached."] = "!ERROR: Tiempo de espira caducado para reenvíar respuestas por el chat de grupo."
L["!ERROR: Whisper timeout reached."] = "!ERROR: Tiempo de espira caducado para reenvíar susurros."

L.HELP_CHAT = [[Tipo un mensaje en el chat de grupo para repuesta a la última susurro enviado desde cualquier personaje.

Tipo "|cffffffff@nombre Tu mensaje aquí|r" en el chat de grupo para repuesta a la última susurro enviado desde el personaje "nombre".

Tipo "|cffffffff@name Tu mensaje aquí|r" en un susurro a un personaje para ordenándole enviar el mensaje por un susurro a "nombre".]]

------------
-- Follow --
------------

L["Follow"] = "Seguir"
L["Responds to follow requests from trusted party members."] = "Responde a las peticiones para seguimientar de los miembros del partido que están en tu lista de confianza."
L["Set a key binding to follow your current target."] = "Asignar una tecla para seguir el objetivo actual."
L["Set a key binding to direct all characters in your party to follow you."] = "Asignar una tecla para dirigir a tu grupo para siguir."
L["Set a key binding to direct all dead characters in your party to release their spirit."] = "Asignar una tecla para dirigir a tu grupo para liberar los espíritus."
L["Set a key binding to direct all ghost characters in your party to accept resurrection to their corpse."] = "Asignar una tecla para dirigir a tu grupo para recuperar los cadáveres."

L["%s is now following you."] = "%s te siguiendo."
L["%s is no longer following you."] = "%s ha dejado de seguir a tu."
L["%s is no longer following you!"] = "%s ha dejado de seguir a tu!"
L["%s is too far away to follow!"] = "%s está demasiado lejos para seguir."
L["Use Soulstone"] = "Uso Piedra de alma"
L["Reincarnate"] = "Reencarnarse"
L["I have a soulstone."] = "Tengo una piedra de alma."
L["I can reincarnate."] = "Puedo reencarnarme."
L["I can resurrect myself."] = "Puedo reencarnarme."
L["I cannot resurrect!"] = "No puedo reencarnarme."

L.HELP_FOLLOW = [[Escriba "|cffffffff/seguirme|r" para solicitar que todos en tu grupo seguirte.

Escriba "|cffffffff/cadaver lib|r" para solicitar que todos en tu grupo liberar sus espíritus.

Escriba "|cffffffff/cadaver res|r" para solicitar que todos en tu grupo resucitar sobre sus cadáveres.]]

L.SLASH_HYDRA_FOLLOWME3 = "/seguirme"

L.SLASH_HYDRA_CORPSE2 = "/cadaver"
L["release"] = "li?b?e?r?a?r?" -- liberar
L["accept"] = "re?[cs]?u?[pc]?[ei]?[rt]?a?r?" -- recuperar o resucitar

L.BINDING_NAME_HYDRA_FOLLOW_TARGET = "Seguir objetivo"
L.BINDING_NAME_HYDRA_FOLLOW_ME = "Dirigir: Sígueme"
L.BINDING_NAME_HYDRA_RELEASE_CORPSE = "Dirigir: Liberar espíritu"
L.BINDING_NAME_HYDRA_ACCEPT_CORPSE = "Dirigir: Recuperar cadáver"

-----------
-- Mount --
-----------

L["Mount"] = "Monte"
L["Summons your mount when another party member mounts."] = "Invoca tu montura cuando otro miembro del partido se monta."

L["ERROR: %s is missing that mount!"] = "ERROR: %s no tiene este montura."

L.HELP_MOUNT = [[]]

-----------
-- Party --
-----------

L["Party"] = "Grupo"
L["Responds to invite and promote requests from trusted players."] = "Responde a las peticiones para invitar y promover de los jugadores que están en tu lista de confianza."

L["I cannot invite you, because you are not on my trusted list."] = "No te puedo invitar, porque no están en mi lista de confianza."
L["I cannot invite you, because I am not the party leader."] = "No te puedo invitar, porque yo no soy el líder del grupo."
L["I cannot promote you, because you are not on my trusted list."] = "No te puedo promover, porque no están en mi lista de confianza."
L["I cannot promote you, because I am not the party leader."] = "No te puedo promover, porque yo no soy el líder del grupo."

L.HELP_PARTY = [[Escriba "|cffffffff/invitarme|r" para solicitar una invitación de grupo de tu objetivo.

Escriba "|cffffffff/invitarme Nombre|r" para solicitar una invitación de grupo de "Nombre".

Escriba "|cffffffff/ascenderme|r" mientras que en un grupo de solicitar un ascenso a líder del grupo.]]

L.SLASH_HYDRA_INVITEME3 = "/invitarme"
L.SLASH_HYDRA_PROMOTEME3 = "/ascenderme"

-----------
-- Quest --
-----------

L["Quest"] = "Misión"
L["Helps keep party members' quests in sync."] = "Ayuda a mantener las misiones de todos los miembros del partido en sincronía."
L["Turn in quests"] = "Entregar misiones"
L["Turn in complete quests to NPCs."] = "Entregar misiones completadas a PNJs."
L["Accept quests"] = "Aceptar misiones"
L["Accept quests shared by party members, quests from NPCs that other party members have already accepted, and escort-type quests started by another party member."] = "Aceptar misiones compartidas por los miembros del partido, misiones de PNJs que otros miembros del grupo ya han aceptado, y misiones de escolta iniciado por otro miembro del grupo."
L["Share quests"] = "Compartir misiones"
L["Share quests you accept from NPCs."] = "Compartir misiones aceptadas a partir del PNJ."
L["Abandon quests"] = "Abandonar misiones"
L["Abandon quests abandoned by trusted party members."] = "Abandonar misiones que otros miembros del grupo ya han abandonado."

L["%1$s accepted %2$s."] = "%1$s aceptó %2$s."
L["%1$s turned in %2$s."] = "%1$s entregó %2$s."
L["%1$s abandoned %2$s."] = "%1$s abandonó %2$s."
L["That quest cannot be shared."] = "No puedes compartir esa misión."

L.HELP_QUEST = [[]]

----------
-- Taxi --
----------

L["Taxi"] = "Transporte"
L["Selects the same taxi destination as other party members."] = "Seleccionar el mismo destino de transporte que otros miembros del grupo."
L["Clear the taxi selection after this many seconds."] = "Desactive la selección de ruta después de estos segundos."

L["ERROR: %s: Taxi timeout reached."] = "ERROR: %s: Tiempo de espera de la ruta de vuelo alcanzar."
L["ERROR: %s: Taxi node mismatch."] = "ERROR: %s: La ruta de vuelo no coinciden."
L["%1$s set the party taxi to %2$s."] = "%1$s establece la ruta de vuelo del grupo a %2$s."
L["Party taxi cleared."] = "Ruta de vuelo del grupo despejado."

L.HELP_TAXI = [[Pulse la tecla Shift mientras habla con un maestro de vuelo para ignorar la auto-selección.

Tipo "|cffffffff/quitartaxi|r" para quitar la selección de ruta de vuelo.]]

L.SLASH_HYDRA_CLEARTAXI2 = "/quitartaxi"