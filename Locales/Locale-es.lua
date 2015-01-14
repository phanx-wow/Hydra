--[[--------------------------------------------------------------------
	Hydra
	Multibox leveling helper.
	Copyright (c) 2010-2015 Phanx <addons@phanx.net>. All rights reserved.
	http://www.wowinterface.com/downloads/info17572-Hydra.html
	http://www.curse.com/addons/wow/hydra
	https://github.com/Phanx/Hydra
------------------------------------------------------------------------
	Spanish localization
	Last updated 2014-02-22 by Phanx
	Previous contributors: Valdesca
----------------------------------------------------------------------]]

if not strmatch(GetLocale(), "^es") then return end
local HYDRA, core = ...
local L = core.L

-----------------
-- Core/Common --
-----------------

L.AddedTrusted = "%s ha sido añadido a la lista de confianza."
L.AddGroup = "Añadir el grupo"
L.AddGroup_Info = "Añadir a la lista de confianza los nombres de todos los personajes en tu grupo actual."
L.AddName = "Añadir un nombre"
L.AddName_Info = "Añadir a la lista de confianza un nombre de personaje."
L.ClickForOptions = "Clic para opciones."
L.CoreHelpText = [[Hydra functiona sobre la base de "confianza". Añada una lista de personajes de tu confianza, si son tus personajes multibox, o tus amigos, y las funciones se activan o desactivan dependiendo de si estás en una grupo con sólo personajes de confianza.

Por ejemplo, los susurros sólo se reenvían al chat de grupo si todos en el grupo son de confianza.]]
L.Enable = ENABLE
L.Enable_Info = "Activar este módulo."
L.Hydra_Info = "Hydra está un ayudante para el multibox y la subir en grupo, que trata de minimizar la necesidad para controlar los personajes secundarios."
L.RemoveAll = "Quitar todos"
L.RemoveAll_Info = "Vaciar la lista de confianza por la eliminación de todos los nombres de personajes."
L.RemovedTrusted = "%s ha sido quitado de la lista de confianza."
L.RemoveEmpty = "La lista de confianza está vacía."
L.RemoveName = "Quitar un numbre"
L.RemoveName_Info = "Quitar de la lista de confianza un nombre de personaje."
L.Timeout = "Tiempo de espera"
L.Verbose = "Verboso"
L.Verbose_Info = "Activar mensajes de notificación de este módulo."

------------
-- Assist --
------------

L.Assist = "Asistir"
--L.Assist_Info = "Synchronizes an assist target across trusted group members."
--L.AssistFailed = "%s could not assist you due to an unknown error."
--L.AssistFailedCombat = "%s will assist you after combat."
--L.AssistFailedTrust = "%s cannot assist you because you are not on their trusted list."
--L.AssistGetMacro = "Get Macro"
--L.AssistGetMacro_Info = "If you prefer to activate the Assist function from your action bars, you can use this button to get a macro you can drop onto any action button."
--L.AssistHelpText = "This module is really only useful in combination with key cloning software. You should set your selected |cffffffffAssist|r key to be sent to your secondary clients."
L.AssistMacro = "Asistir"
--L.AssistMacro_Info = "Set a key binding to assist your current assist target."
L.AssistRespond = "Asistir"
--L.AssistRespond_Info = "Respond to assist requests from trusted group members."
--L.AssistSet = "%s will now assist you."
--L.AssistUnset = "%s is now assisting %s instead of you."
--L.NobodyAssisting = "Nobody is currently assisting you."
--L.RequestAssist = "Request Assist"
--L.RequestAssist_Info = "Set a key binding to request that all group members set you as their assist target."
L.SlashAssistMe = "/asistirme"

----------------
-- Automation --
----------------

L.AcceptCombatRes = "Aceptar resurecciones en combate"
L.AcceptCombatRes_Info = "Aceptar resurecciones en combate por los miembres del grupo."
L.AcceptedRes = "Aceptó una resurrección de %s."
L.AcceptedSummon = "Aceptó invocar de %1$s a %2$s."
L.AcceptedSummonCombat = "Aceptará invocar cuando se termina el combate ..."
L.AcceptRes = "Aceptar resurecciones"
L.AcceptRes_Info = "Aceptar los resurecciones ofrecidos fuera de combate por los miembres del grupo."
L.AcceptSummons = "Aceptar invocaciones"
L.AcceptSummons_Info = "Aceptar los invocaciones ofrecidos por los jugadores de confianza."
L.Automation = "Automatización"
L.Automation_Info = "Automatiza algunas tareas sencillas, como hacer clic en los cuadros de diálogo comunes."
--L.AutomationHelpText = ""
L.DeclineArenas = "Rechazar equipos de arena"
L.DeclineArenas_Info = "Rechazar invitaciones y peticiones de equipos de arena de todo jugadores."
L.DeclinedArena = "Rechazó una invitación a equipo de arena de %s."
L.DeclinedArenaPetition = "Rechazó una petición de equipo de arena de %s."
L.DeclinedDuel = "Rechazó una invitación a duelo de %s."
L.DeclinedGuild = "Rechazó una invitación a hermandad de %s."
L.DeclinedGuildPetition = "Rechazó una petición de hermandad de %s."
L.DeclineDuels = "Rechazar duelos"
L.DeclineDuels_Info = "Rechazar invitaciones a duelos de todos jugadores."
L.DeclineGuilds = "Rechazar hermandades"
L.DeclineGuilds_Info = "Rechazar invitaciones y peticiones a hermandades de todos jugadores."
L.NoRepairMoney = "¡No tienes suficiente dinero para reparar!"
L.NoRepairMoneyGuild = "¡La hermandad no tiene suficiente dinero para reparar!"
L.Repair = "Reparar equipos"
L.Repair_Info = "Reparar todos equipos cuando hablas con un mercador de reparación."
L.RepairGuild = "Usar dinero de hermandad"
L.RepairGuild = "Pagar la reparación con el dinero de la hermandad cuando sea posible."
L.Repaired = "Reparó todos los equpios por %s."
L.RepairedGuild = "Reparó todos los equipos por %s del dinero de la hermandad."
L.SellJunk = "Vender chatarra"
L.SellJunk_Info = "Vender todas las chatarra (objetos gris) en el inventario cuando hablas con un vendedor."
L.SoldJunk = "Vendió %1$d |4artículo:artículos; de chatarra por %2$s."
L.SummonExpired = "La invocación expiró!"

----------
-- Chat --
----------

L.AppFocus = "Programa en foco"
L.Chat = "Chat"
L.Chat_Info = "Reenvía al chat del grupo los susurros que se enviaron a los personajes inactivos, y reenvía las respuestas al remitente original."
L.ChatHelpText = [[Escribe en el chat de grupo para responder a la última susurro que se reenvió al chat de grupo por un otro personaje.

Escribe "|cffffffff@Nombre Mensaje aquí|r" para responder a la última susurro que se reenvió por el personaje "Nombre".

Escribe "|cffffffff@Nombre Mensaje aquí|r" en un susurro al otro personaje para enviar por ese personaje el mensaje como un susurro a "Nombre".]]
L.DetectionMethod = "Método de detección"
L.DetectionMethod_Info = [[Seleccione el método para utilizar para detectar el personaje principal.

Si estás jugando en varios equipos, o estás ejecutando en la misma computadora múltiples copias de WoW en el modo de ventana, el método de detección "Programa en foco" probablemente no funcione. En este caso, debe utilizar el método "Líder del grupo" y asegúrate de que tu personaje principal es el líder del grupo.]]
L.GroupLeader = "Líder del grupo"
L.GroupTimeout_Info = "Después de estos segundos desde el último susurro, los mensajes escritos en el chat de grupo no se reenvían, a menos especificar explícitamente el objetivo."
L.GroupTimeoutError = "Se ha alcanzado el tiempo de espera para el chat de grupo."
L.WhisperFrom = "%1$s recibió un susurro de %2$s."
L.WhisperFromBnet = "%1$s recibió un susurro de Battle.net de %2$s:\n%3$s"
L.WhisperFromConvo = "%1$s recibió un mensaje en conversación de %2$s:\n%3$s"
L.WhisperFromGM = "¡%s recibió un susurro de un MJ!"
L.WhisperTimeoutError = "Se ha alcanzado el tiempo de espera para los susurros."

------------
-- Follow --
------------

L.AcceptCorpse = "Recuperar cadáver"
L.AcceptCorpse_Info = "Asignar una tecla para mandar los miembros muertos del grupo a recuperar los cadáveres."
L.CanReincarnate = "%s puede usar Reencarnación."
L.CanSelfRes = "%s puede resucitarse."
L.CantRes = "¡%s no puede ser resucitado!"
L.CantResDelay = "%1$s no puede ser resucitado por otros %2$d segundos!"
L.CanUseSoulstone = "%s puede usar una Piedra de alma."
L.CmdAccept = "[ar]e?[cs]?[eu]?[pc]?[ei]?[rt]?a?r?"
L.CmdRelease = "libe?r?a?r?"
L.Follow = "Seguir"
L.Follow_Info = "Responde a los comandos de seguiente por los miembros de confianza del grupo."
L.FollowHelpText = [[Escriba "|cffffffff/seguirme|r" para mandar los miembres cercanos del grupo a seguirte.

Escriba "|cffffffff/cadaver libera|r" para mandar los miembros muertos del grupo a liberar los espíritus.

Escriba "|cffffffff/cadaver recupera|r" para mandar mandar los miembros muertos del grupo a recuperar los cadáveres.]]
L.FollowingYouStart = "%s te está siguiendo."
L.FollowingYouStop = "%s dejó de seguirte."
L.FollowMe = "¡Sígueme!"
L.FollowMe_Info = "Asignar una tecla para mandar los miembres cercanos del grupo a seguirte."
L.FollowTarget = "Seguir objetivo"
L.FollowTarget_Info = "Asignar una tecla para seguir el objetivo actual."
L.FollowTooFar = "%s está demasiado lejos para seguir!"
L.RefollowAfterCombat = "Resuigir después de combate"
L.RefollowAfterCombat_Info = "Automáticamente tratará seguir el objetivo seguido previamente cuando termina el combate."
L.ReleaseCorpse = "Liberar el espíritu"
L.ReleaseCorpse_Info = "Asignar una tecla para mandar los miembros muertos del grupo a liberar los espíritus."
L.Reincarnate = "Reencarnarse" -- Must match Blizzard self-res dialog!
L.SlashCorpse = "/cadaver"
L.SlashFollowMe = "/sigueme"
L.TargetedFollowMe = "Enviar /sigueme al objetivo"
L.TargetedFollowMe_Info = "Si el objetivo actual es un miembro de confianza del grupo, el comando se enviará sólo a ese personaje, en lugar del grupo entero."
L.UseSoulstone = "Usa Piedra de alma" -- Must match Blizzard self-res dialog!

-----------
-- Group --
-----------

L.CantInviteNotLeader = "No te puedo invitar, porque no estoy el líder del grupo."
L.CantInviteNotTrusted = "No te puedo invitar, porque no estás en mi lista de confianza."
L.CantPromoteNotLeader = "No te puedo promover, porque no estoy el líder del grupo."
L.CantPromoteNotTrusted = "No te puedo promover, porque no estás en mi lista de confianza."
L.CmdNoPromote = "[Nn][Oo][Pp][Rr][Oo][Mm][Oo][Vv][Ee][Rr]?" -- nopromover
L.Group = "Grupo"
L.Group_Info = "Responde a los comandos de invitar o promover de los jugadores de confianza."
L.GroupHelpText = [[Escribe "|cffffffff/invitarme|r" para solictar una invitación de grupo de tu objetivo.

Escribe "|cffffffff/invitarme Nombre|r" para solictar una invitación de grupo del personaje "Nombre".

Escribe "|cffffffff/promoverme|r" mientras estás en el grupo para solicitar una promoción al líder del grupo.]]
L.SlashInviteMe = "/invitarme"
L.SlashPromoteMe = "/promoverme"

-----------
-- Mount --
-----------

L.Dismount = "Desmontar juntos"
L.Dismount_Info = "Desmontar cuando desmonta un miembro de confianza del grupo."
L.Mount = "Montura"
L.Mount_Info = "Montar y desmontar como un grupo."
--L.MountHelpText = ""
L.MountMissing = "¡%s no tiene una montura equivalente!"
L.MountRandom = "Monturas aleatorias"
L.MountRandom_Info = "Al montar automáticamente, utilizar una montura aleatoria del mismo tipo del miembro de confianza del grupo.\nSi está desactivada, vas a utilizar la misma monutra si lo tienen, o el equivalente primero a encontrar."
L.MountTogether = "Montar juntos"
L.MountTogether_Info = "Montar cuando desmonta un miembro de confianza del grupo."

-----------
-- Quest --
-----------

L.AbandonQuests = "Abandonar las misiones"
L.AbandonQuests_Info = "Abandonar las misiones que se abandonaron por otros miembros de confianza del grupo."
L.AcceptQuests = "Aceptar las misiones"
L.AcceptQuests_Info = "Aceptar todos las misiones."
L.OnlySharedQuests = "Sólo las misiones compartidos"
L.OnlySharedQuests_Info = "Aceptar sólo las misiones que se compartieron por otros miembros del grupo, las misiones de escoltar que se iniciaron por otros miembros del grupo, y las misiones de PNJs que ya han compartido por los miembres de confianza del grupo."
L.Quest = "Misión"
L.Quest_Info = "Ayuda a mantener en sincronía las misiones de las miembros del grupo."
L.QuestAbandoned = "%1$s abandonó %2$s."
L.QuestAccepted = "%1$s aceptó %2$s."
L.QuestHelpText = "Si desea una lista en la pantalla de los estados de las misiones de los miembros del grupo, te recomiendo el addon Quecho, por Tekkub."
L.QuestNotShareable = "Esta misión no se puede compartir."
L.QuestTurnedIn = "%1$s entregó %2$s."
L.ShareQuests = "Compartir las misiones"
L.ShareQuests_Info = "Compartir las misiones que lo aceptaron de PNJs."
L.TurnInQuests = "Entregar las misiones"
L.TurnInQuests_Info = "Entregar a PNJs las misiones completadas."

----------
-- Taxi --
----------

L.SlashClearTaxi = "/borrartaxi"
L.Taxi = "Taxi"
L.Taxi_Info = "Seleccionar el mismo destino de taxi que los otros miembros del grupo."
L.TaxiCleared = "El destino compartido de taxi ha sido borrada."
L.TaxiHelpText = [[Pulse la tecla Mayús cuando hablas con un maestro de vuelo para ignorar el destino seleccionado compartido.

Escribe "|cffffffff/borrartaxi|r" para borrar el destino compardito antes de que el tiempo de espera se alcance.]]
L.TaxiMismatchError = "%s: El destino no coincide."
L.TaxiSet = "%1$s estableció el destino compartido a %2$s."
L.TaxiTimeout_Info = "Borrar la selección del destino compartido después de estos segundos."
L.TaxiTimeoutError = "%s: Se ha alcanzado el tiempo de espera para el taxi."

-----------
-- Debug --
-----------

L.Debug = "Depurar"
L.Debug_Info = "Activar los mensajes de depuración para los partes seleccionados de Hydra."
L.DebugCore = "Núcleo"