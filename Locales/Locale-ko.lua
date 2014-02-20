--[[--------------------------------------------------------------------
	Hydra
	Multibox leveling helper.
	Copyright (c) 2010-2014 Phanx <addons@phanx.net>. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info17572-Hydra.html
	http://www.curse.com/addons/wow/hydra
------------------------------------------------------------------------
	Korean localization
	Last updated 2010-12-06 by Bruteforce
	***
----------------------------------------------------------------------]]

if GetLocale() ~= "koKR" then return end
local _, core = {}
local L = core.L

-----------------
-- Core/Common --
-----------------

L.AddedTrusted = "%s 님을 신뢰하는 목록에 추가했습니다."
L.AddGroup = "현재 파티 추가"
L.AddGroup_Info = "현재 파티 그룹의 모든 캐릭터들을 신뢰하는 목록에 추가합니다."
L.AddName = "이름 추가"
L.AddName_Info = "신뢰하는 목록에 이름을 추가합니다."
--L.ClickForOptions = "Click for options."
--[=[ L.CoreHelpText = [[Hydra operates on the basis of "trust". You tell it which characters you trust, whether they're your multibox characters or just your questing buddies, and features are enabled or disabled depending on whether you're in a party with trusted characters or not.

For example, whispers are only forwarded to party chat if everyone in the party is on your trusted list.]] ]=]
L.Enable = ENABLE
--L.Enable_Info = "Enable this module."
L.Hydra_Info = "Hydra는 두번째 캐릭터를 직접 조종하는 것을 최소화하는 것에 초점을 맞춘 멀티박스 레벨링 도우미입니다."
--L.RemoveAll = "Remove All"
--L.RemoveAll_Info = "Clear your existing trusted list, removing all characters from all servers."
L.RemovedTrusted = "%s 님을 신뢰하는 목록에서 제거했습니다."
L.RemoveName = "이름 제거"
L.RemoveName_Info = "신뢰하는 목록에서 이름을 제거합니다."
L.Timeout = "시간 초과"
L.Verbose = "수다 모드"
--L.Verbose_Info = "Enable notification messages from this module."

----------------
-- Automation --
----------------

L.AcceptCombatRes = "전투중 부할 수락"
--L.AcceptCombatRes_Info = "Accept resurrections in combat from all group members."
L.AcceptedRes = "%s 님의 부활을 수락했습니다"
L.AcceptedSummon = "%1$s 님이 %2$s|1로;으로; 소환하는 것을 수락합니다."
L.AcceptedSummonCombat = "전투가 종료가 되면 소환을 수락합니다..."
L.AcceptRes = "부활 수락"
--L.AcceptRes_Info = "Accept resurrections out of combat from all group members."
L.AcceptSummons = "소환 수락"
--L.AcceptSummons_Info = "Accept summons from trusted players."
L.Automation = "자동 조작"
L.Automation_Info = "일반적인 대화 상자를 클릭하는 것과 같은 단순 반복적인 작업들을 자동화합니다."
--L.AutomationHelpText = ""
L.DeclineArenas = "투기장 팀 초대 거절"
--L.DeclineArenas_Info = "Decline arena team invitations and petitions from all players."
L.DeclinedArena = "%s 님의 투기장 팀 초대를 거절했습니다."
L.DeclinedArenaPetition = "%s 님의 투기장 창단 서명 요청을 거절했습니다."
L.DeclinedDuel = "%s 님의 결투 신청을 거절했습니다."
L.DeclinedGuild = "%s 님의 길드 초대를 거절했습니다."
L.DeclinedGuildPetition = "%s 님의 길드 창단 서명 요청을 거절했습니다."
L.DeclineDuels = "결투 거절"
--L.DeclineDuels_Info = "Decline duel requests from all players."
L.DeclineGuilds = "길드 초대 거절"
--L.DeclineGuilds_Info = "Decline guild invitations and petitions from all players."
L.NoRepairMoney = "수리하기 위한 금액이 부족합니다!"
L.NoRepairMoneyGuild = "수리하기 위한 길드 은행의 금액이 부족합니다!"
L.Repair = "장비 수리"
--L.Repair_Info = "Repair all equipment when interacting with a repair vendor."
--L.RepairGuild = "Use guild funds"
--L.RepairGuild_Info = "Pay for repairs out of the guild bank when possible."
L.Repaired = "모든 아이템을 %s로 수리했습니다."
L.RepairedGuild = "모든 아이템을 길드 은행의 금액으로 수리했습니다."
L.SellJunk = "잡동사니 팔기"
--L.SellJunk_Info = "Sell junk (gray) items when interacting with a vendor."
L.SoldJunk = "잡동사니 아이템 %1$d개를 상인에게 판매하여 %2$s를 획득했습니다."
L.SummonExpired = "소환이 만료되었습니다!"

----------
-- Chat --
----------

L.AppFocus = "애플리케이션 포커스"
L.Chat = "대화"
L.Chat_Info = "비활동 캐릭터에게 보내진 귓속말을 파티 대화로 전달하며, 귓속말을 보낸 이에게 답장을 전달합니다."
--[=[ L.ChatHelpText = [[Type a message in group chat to reply to the last forwarded whisper from any character.

Type "|cffffffff@name Your message here|r" in group chat to reply to the last forwarded whisper from the character "name".

Type "|cffffffff@name Your message here|r" in a whisper to a character to direct that character to send the message as a whisper to "name".]] ]=]
L.DetectionMethod = "모드"
--[=[ L.DetectionMethod_Info = [[Select the method to use for detecting the primary character.

If you are multiboxing on multiple physical machines, or are running multiple copies of WoW in windowed mode, the "Application Focus" mode will probably not work for you, and you should make sure that your primary character is the group leader.]] ]=]
L.GroupLeader = "파티장"
--L.GroupTimeout_Info = "If this many seconds have elapsed since the last forwarded message, don't forward messages typed in group chat to the last whisperer unless the target is explicitly specified."
L.GroupTimeoutError = "Group chat forwarding timeout reached."
L.WhisperFrom = "%1$s 님이 %2$s 님으로 부터 귓속말을 받았습니다."
L.WhisperFromBnet = "%1$s 님이 %2$s 님으로 부터 Battle.net 귓속말을 받았습니다:\n%3$s"
--L.WhisperFromConvo = "%1$s received a Battle.net message from %2$s:\n%3$s"
L.WhisperFromGM = "%s 님이 GM에게 귓속말을 받았습니다!"
--L.WhisperTimeoutError = "Whisper timeout reached."

------------
-- Follow --
------------

--L.AcceptCorpse = "Resurrect to corpse"
--L.AcceptCorpse_Info = "Set a key binding to direct dead group members to accept resurrection to their corpse."
--L.CanReincarnate = "%s can use Reincarnation."
--L.CanSelfRes = "%s can self-ressurect."
--L.CantRes = "%s cannot be resurrected!"
--L.CantResDelay = "%1$s cannot be resurrected for %2$d more seconds!"
--L.CanUseSoulstone = "%s can use a Soulstone."
L.CmdAccept = "수락"
L.CmdRelease = "무덤"
L.Follow = "따라가기"
L.Follow_Info = "신뢰하는 파티원의 따라다니기 요청에 대하여 응답합니다."
--[=[ L.FollowHelpText = [[Type "|cffffffff/followme|r" to direct nearby group members to follow you.

Type "|cffffffff/corpse release|r" to direct dead party members to release their spirits.

Type "|cffffffff/corpse accept|r" to direct dead group members to accept resurrection to their corpse.]] ]=]
L.FollowingYouStart = "%s 님이 당신을 따라다닙니다."
L.FollowingYouStop = "%s 님은 더 이상 당신을 따라다니지 않습니다."
--L.FollowMe = "Request follow"
--L.FollowMe_Info = "Set a key binding to direct nearby group members to follow you."
--L.FollowTarget = "Follow target"
--L.FollowTarget_Info = "Set a key binding to follow your current target."
L.FollowTooFar = "%s 님은 따라다니기엔 너무 멀리 있습니다!"
--L.ReleaseCorpse = "Release spirit"
--L.ReleaseCorpse_Info = "Set a key binding to direct dead group members to release their spirit."
--L.RefollowAfterCombat = "Refollow after combat"
--L.RefollowAfterCombat_Info = "Automatically try to follow your last followed target when leaving combat."
--L.Reincarnate = "Reincarnate" -- Must match Blizzard self-res dialog!
L.SlashCorpse = "/시체"
L.SlashFollowMe = "/따라와"
--L.TargetedFollowMe = "Targetable /followme"
--L.TargetedFollowMe_Info = "If your current target is a trusted group member, your /followme command will be sent only to that target."
--L.UseSoulstone = "Use Soulstone" -- Must match Blizzard self-res dialog!

-----------
-- Mount --
-----------

--L.Dismount = "Dismount with group"
--L.Dismount_Info = "Dismount when another trusted group member dismounts."
L.Mount = "탈것"
--L.Mount_Info = "Group mounting and dismounting."
L.MountHelpText = ""
L.MountMissing = "%s 님은 탈 것이 없습니다!"
--L.MountRandom = "Use random mount"
--L.MountRandom_Info = "Use a random mount of the same type as your trusted group member.\nIf this is disabled, you will use the same mount if you have it, or the first equivalent mount otherwise."
L.MountTogether = "탈것"
L.MountTogether_Info = "다른 파티원이 탈것을 소환할 때, 당신의 탈것을 소환합니다."

-----------
-- Party --
-----------

L.CantInviteNotLeader = "저는 모듈 리더가 아니므로 당신을 초대할 수 없습니다."
L.CantInviteNotTrusted = "나의 신뢰하는 목록에 존재하지 않으므로 당신을 초대할 수 없습니다."
L.CantPromoteNotLeader = "저는 파티장이 아니므로 당신을 승급할 수 없습니다."
L.CantPromoteNotTrusted = "나의 신뢰하는 목록에 존재하지 않으므로 때문에 당신을 승급할 수 없습니다."
--L.CmdNoPromote = "[Nn][Oo][Pp][Rr][Oo][Mm][Oo][Tt][Ee]"
L.Group = "파티"
L.Group_Info = "신뢰하는 파티원의 초대와 승급 요청에 대하여 응답합니다."
--[=[ L.GroupHelpText = [[Type "|cffffffff/inviteme|r" to request a group invitation from your current target.

Type "|cffffffff/inviteme Name|r" to request a group invitation from "Name".

Type "|cffffffff/promoteme|r" while in a group to request to be promoted to group leader.]] ]=]
L.SlashInviteMe = "/나초대"
L.SlashPromoteMe = "/승급"

-----------
-- Quest --
-----------

L.AbandonQuests = "퀘스트 포기"
L.AbandonQuests_Info = "신뢰하는 파티원이 포기한 퀘스트를 포기합니다."
L.AcceptQuests = "퀘스트 수락"
--L.AcceptQuests = "Automatically accept all quests."
--L.OnlySharedQuests = "Only shared quests"
L.OnlySharedQuests_Info = "다른 파티원이 이미 NPC에게 수락했던 퀘스트와, 다른 파티원에 의해 호위 형태의 퀘스트가 시작되면, 파티원에 의하여 공유된 퀘스트를 수락합니다."
L.Quest = "퀘스트"
L.Quest_Info = "파티원의 퀘스트와 항상 동기화하도록 도와줍니다."
L.QuestAbandoned = "%1$s 님이 %2$s|1을;를; 포기했습니다."
L.QuestAccepted = "%1$s 님이 %2$s|1을;를; 수락했습니다."
--L.QuestHelpText = "If you want an on-screen list of your other characters' quests, I recommend the addon Quecho, by Tekkub."
L.QuestNotShareable = "해당 퀘스트는 공유할 수 없습니다."
L.QuestTurnedIn = "%1$s 님이 %2$s|1을;를; 반환했습니다."
L.ShareQuests = "퀘스트 공유"
L.ShareQuests_Info = "NPC에게 수락한 퀘스트를 공유합니다."
L.TurnInQuests = "퀘스트 제출"
L.TurnInQuests_Info = "완료한 퀘스트를 제출합니다."

----------
-- Taxi --
----------

L.SlashClearTaxi = "/택시지우기"
L.Taxi = "택시"
L.Taxi_Info = "택시(그리핀, 와이번)의 목적지를 다른 파티원과 동일한 곳으로 선택합니다."
L.TaxiCleared = "파티 택시가 지워졌습니다."
--[=[ L.TaxiHelpText = [[Hold the Shift key while speaking to a flight master to temporarily disable auto-selection.

Type "|cffffffff/cleartaxi|r" to clear the party taxi selection before the normal timeout.]] ]=]
L.TaxiMismatchError = "%s: 님의 택시 노드가 일치하지 않습니다."
L.TaxiSet = "%1$s 님이 지정한 파티 택시의 노드 %2$s."
L.TaxiTimeout_Info = "이 시간(초)이 경과된 후에 택시 선택을 지웁니다."
L.TaxiTimeoutError = "%s: 님의 택시가 시간 초과되었습니다."