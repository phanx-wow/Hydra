--[[--------------------------------------------------------------------
	Hydra
	Multibox leveling helper.
	Written by Phanx <addons@phanx.net>
	Maintained by Akkorian <akkorian@hotmail.com>
	Copyright © 2010–2011 Phanx. Some rights reserved. See LICENSE.txt for details.
	http://www.wowinterface.com/downloads/info17572-Hydra.html
	http://wow.curse.com/downloads/wow-addons/details/hydra.aspx
------------------------------------------------------------------------
	Localization: esMX | Español (AL) | Spanish (Latin America)
	Last updated 2011-01-19 by Akkorian
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
L["Add a name to your trusted list."] = "Añadir un nombre a la lista de confianza."
L["Remove Name"] = "Eliminar nombre"
L["Remove a name from your trusted list."] = "Eliminar un nombre de la lista de confianza."
L["Add Current Party"] = "Añadir grupo"
L["Adds all the characters in your current party group to your trusted list."] = "Añadir todos los personajes en tu grupo actual a la lista de confianza."

L["Added %s to the trusted list."] = "Agregó %s a la lista de confianza."
L["Removed %s from the trusted list."] = "Eliminado %s de la lista de confianza."

L.HELP_TRUST = [[]]

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
L["Decline arena teams"] = "Rechazar equipos de arena"
L["Decline guilds"] = "Rechazar invitaciones de hermandad"
L["Accept summons"] = "Aceptar invocaciones"
L["Accept resurrections"] = "Aceptar resurecciones"
L["Accept combat resurrections"] = "Aceptar resurecciones en combate"
L["Repair equipment"] = "Reparar equipos"
L["Sell junk"] = "Vender chatarra"

L["Declined arena petition from %s"] = "Rechazó la petición de equipo de arena de %s."
L["Declined guild petition from %s"] = "Rechazó la petición de hermandad de %s."
L["Declined arena team invite from %s"] = "Rechazó la invitación a equipo de arena de %s"
L["Declined duel request from %s"] = "Rechazó una invitación duelo de X."
L["Declined guild invite from %s"] = "Rechazó una invitación a hermandad de %s"
L["Sold %s junk |4item:items; for %s"] = "Vendió %s |4artículo:artículos; chatarra por %s."
L["Repaired all items with guild bank funds for %s"] = "Reparado todos los objetos con el dinero del banco de hermandad por %s."
L["Insufficient guild bank funds to repair!"] = "Insuficiente dinero en el banco de hermandad para reparar!"
L["Repaired all items for %s"] = "Reparado todos los objetos por %s."
L["Insufficient funds to repair!"] = "Insuficiente dinero para reparar!"
L["Accepted resurrection from %s"] = "Aceptada la resurrección de %s."
L["Accepting summon when combat ends..."] = "Aceptando invocar cuando el combate termina ..."
L["Accepting summon from %s to %s"] = "Aceptando invocar por %s a %s."
L["Summon expired!"] = "Invocar caducado!"

L.HELP_AUTO = [[]]

----------
-- Chat --
----------

L["Chat"] = "Chat"
L["Forwards whispers sent to inactive characters to party chat, and forwards replies to the original sender."] = "Reenvía susurros enviado a los personajes inactivos por el chat del grupo, y reenvía las respuestas al remitente original."
L["Enable"] = "Activar"
L["Mode"] = "Modo"
L["Application Focus"] = "Aplicación enfoque"
L["Party Leader"] = "Líder del grupo"

L["%s has received a whisper from a GM!"] = "%s ha recibido un susurro de un GM!"
L["%s received a Battle.net whisper from %s"] = "%s ha recibido un susurro de Battle.net por %s."
L["%s received a whisper from %s"] = "%s ha recibido un susurro por %s."

L.HELP_CHAT = [[]]

------------
-- Follow --
------------

L["Follow"] = "Seguir"
L["Responds to follow requests from trusted party members."] = "Responde a las peticiones para seguimientar de los miembros del partido que están en tu lista de confianza."
L["Follow target"] = "Seguir el objetivo"
L["Follow me"] = "Sígueme"
L["Release spirit"] = "Liberar espíritu"
L["Resurrect to corpse"] = "Recuperar cadáver"

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

L.HELP_FOLLOW = [[Escriba "|cffffffff/sigueme|r" para solicitar que todos en tu grupo seguirte.

Escriba "|cffffffff/cadáver lib|r" para solicitar que todos en tu grupo liberar sus espíritus.

Escriba "|cffffffff/cadáver res|r" para solicitar que todos en tu grupo resucitar sobre sus cadáveres.]]

SLASH_FOLLOWME3 = "/sigueme"
SLASH_HYDRACORPSE2 = "/cadáver"
L["release"] = "li?b?e?r?a?r?" -- liberar
L["accept"] = "re?[cs]?u?[pc]?[ei]?[rt]?a?r?" -- recuperar o resucitar

BINDING_NAME_HYDRA_FOLLOW_TARGET = "Seguir el objetivo"
BINDING_NAME_HYDRA_FOLLOW_ME = "Enviar: Sígueme"
BINDING_NAME_HYDRA_RELEASE_CORPSE = "Enviar: Liberar espíritu"
BINDING_NAME_HYDRA_ACCEPT_CORPSE = "Enviar: Recuperar cadáver"

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

SLASH_INVITEME3 = "/invitarme"
SLASH_PROMOTEME3 = "/ascenderme"

-----------
-- Quest --
-----------

L["Quest"] = "Misión"
L["Helps keep party members' quests in sync."] = "Ayuda a mantener las misiones de todos los miembros del partido en sincronía."
L["Turn in quests"] = "Entregar misiones"
L["Turn in complete quests."] = "Entregar misiones completadas."
L["Accept quests"] = "Aceptar misiones"
L["Accept quests shared by party members, quests from NPCs that other party members have already accepted, and escort-type quests started by another party member."] = "Aceptar misiones compartidas por los miembros del partido, misiones de PNJs que otros miembros del grupo ya han aceptado, y misiones de escolta iniciado por otro miembro del grupo."
L["Share quests"] = "Compartir misiones"
L["Share quests you accept from NPCs."] = "Compartir misiones aceptadas a partir del PNJ."
L["Abandon quests"] = "Abandonar misiones"
L["Abandon quests abandoned by a trusted party member."] = "Abandonar misiones que otros miembros del grupo ya han abandonado."

L["%s accepted %s"] = "%s aceptó %s."
L["%s turned in %s"] = "%s entrega %s."
L["%s abandoned %s"] = "%s ha abandonó a %s."
L["That quest cannot be shared."] = "Esa misión no te puedes compartir."

L.HELP_QUEST = [[]]

----------
-- Taxi --
----------

L["Taxi"] = "Transporte"
L["Selects the same taxi destination as other party members."] = "Seleccionar el mismo destino de transporte que otros miembros del grupo."
L["Clear the taxi selection after this many seconds."] = "Desactive la selección de ruta después de estos segundos."

L["ERROR: %s taxi timeout reached."] = "ERROR: Tiempo de espera de la ruta de vuelo alcanzar."
L["ERROR: %s taxi node mismatch."] = "ERROR: La ruta de vuelo no coinciden."
L["%s set the party taxi to: %s"] = "%s establece la ruta de vuelo del grupo a %s."
L["Party taxi cleared."] = "Ruta de vuelo del grupo despejado."

L.HELP_TAXI = [[]]

SLASH_CLEARTAXI2 = "/quitartaxi"