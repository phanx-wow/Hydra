--[[--------------------------------------------------------------------
	Hydra
	Multibox leveling helper.
	Written by Phanx <addons@phanx.net>
	Copyright © 2010–2011 Phanx. Some rights reserved. See LICENSE.txt for details.
	http://www.wowinterface.com/downloads/info17572-Hydra.html
	http://wow.curse.com/downloads/wow-addons/details/hydra.aspx
------------------------------------------------------------------------
	Korean Localization (한국어)
	Last updated 2010-12-06 by Bruteforce
----------------------------------------------------------------------]]

if GetLocale() ~= "koKR" then return end
local L, _, core = { }, ...
core.L = L

----------
-- Core --
----------

L["Hydra is a multibox leveling helper that aims to minimize the need to actively control secondary characters."] = "Hydra는 두번째 캐릭터를 직접 조종하는 것을 최소화하는 것에 초점을 맞춘 멀티박스 레벨링 도우미입니다."
L["Trust List"] = "신뢰 목록"
L["Add Name"] = "이름 추가"
L["Add a name to your trusted list."] = "신뢰하는 목록에 이름을 추가합니다."
L["Remove Name"] = "이름 제거"
L["Remove a name from your trusted list."] = "신뢰하는 목록에서 이름을 제거합니다."
L["Add Current Party"] = "현재 파티 추가"
L["Adds all the characters in your current party group to your trusted list."] = "현재 파티 그룹의 모든 캐릭터들을 신뢰하는 목록에 추가합니다."

L["Added %s to the trusted list."] = "%s 님을 신뢰하는 목록에 추가했습니다."
L["Removed %s from the trusted list."] = "%s 님을 신뢰하는 목록에서 제거했습니다."

-- L.HELP_TRUST = [[]]

------------
-- Common --
------------

L["Enable"] = "활성화"
-- L["Enable this module."] = ""

L["Verbose mode"] = "수다 모드"
-- L["Enable notification messages from this module."] = ""

L["Timeout"] = "시간 초과"

----------------
-- Automation --
----------------

L["Automation"] = "자동 조작"
L["Automates simple repetetive tasks, such as clicking common dialogs."] = "일반적인 대화 상자를 클릭하는 것과 같은 단순 반복적인 작업들을 자동화합니다."
L["Decline duels"] = "결투 거절"
L["Decline duel requests."] = "결투 거절" -- needs check
L["Decline arena teams"] = "투기장 팀 초대 거절"
L["Decline arena team invitations and petitions."] = "투기장 팀 초대 거절" -- needs check
L["Decline guilds"] = "길드 초대 거절"
L["Decline guild invitations and petitions."] = "길드 초대 거절" -- needs check
L["Accept summons"] = "소환 수락"
L["Accept summon requests."] = "소환 수락" -- needs check
L["Accept resurrections"] = "부활 수락"
L["Accept resurrections from players not in combat."] = "부활 수락" -- needs check
L["Accept combat resurrections"] = "전투중 부할 수락"
L["Accept resurrections from players in combat."] = "전투중 부할 수락" -- needs check
L["Repair equipment"] = "장비 수리"
L["Repair all equipment when interacting with a repair vendor."] = "장비 수리" -- needs check
L["Sell junk"] = "잡동사니 팔기"
L["Sell all junk (gray) items when interacting with a vendor."] = "잡동사니 팔기" -- needs check

L["Declined an arena team invitation from %s."] = "%s 님의 투기장 팀 초대를 거절했습니다."
L["Declined an arena team petition from %s."] = "%s 님의 투기장 창단 서명 요청을 거절했습니다."
L["Declined a guild invitation from %s."] = "%s 님의 길드 초대를 거절했습니다."
L["Declined a guild petition from %s."] = "%s 님의 길드 창단 서명 요청을 거절했습니다."
L["Declined a duel request from %s."] = "%s 님의 결투 신청을 거절했습니다."
L["Sold %1$d junk |4item:items; for %2$s."] = "잡동사니 아이템 %1$d개를 상인에게 판매하여 %2$s를 획득했습니다."
L["Repaired all items with guild bank funds for %s."] = "모든 아이템을 길드 은행의 금액으로 수리했습니다."
L["Insufficient guild bank funds to repair!"] = "수리하기 위한 길드 은행의 금액이 부족합니다!"
L["Repaired all items for %s."] = "모든 아이템을 %s로 수리했습니다."
L["Insufficient funds to repair!"] = "수리하기 위한 금액이 부족합니다!"
L["Accepted a resurrection from %s."] = "%s 님의 부활을 수락했습니다."
L["Accepting a summon from %1$s to %2$s."] = "%1$s 님이 %2$s|1로;으로; 소환하는 것을 수락합니다."
L["Accepting a summon when combat ends..."] = "전투가 종료가 되면 소환을 수락합니다..."
L["Summon expired!"] = "소환이 만료되었습니다!"

-- L.HELP_AUTO = [[]]

----------
-- Chat --
----------

L["Chat"] = "대화"
L["Forwards whispers sent to inactive characters to party chat, and forwards replies to the original sender."] = "비활동 캐릭터에게 보내진 귓속말을 파티 대화로 전달하며, 귓속말을 보낸 이에게 답장을 전달합니다."
L["Detection method"] = "모드"
-- L["Select the method to use for detecting the primary character."] = ""
-- L["If you are multiboxing on multiple physical machines, or are running multiple copies of WoW in windowed mode, the \"Application Focus\" mode will probably not work for you, and you should make sure that your primary character is the party leader."] = ""
L["Application Focus"] = "애플리케이션 포커스"
L["Party Leader"] = "파티장"
-- L["If this many seconds have elapsed since the last forwarded message, don't forward messages typed in party chat to the last whisperer unless the target is explicitly specified."] = ""

L["|TInterface\\ChatFrame\\UI-ChatIcon-Blizz.blp:0:2:0:-3|t %s has received a whisper from a GM!"] = "|TInterface\\ChatFrame\\UI-ChatIcon-Blizz.blp:0:2:0:-3|t %s 님이 GM에게 귓속말을 받았습니다!"
L["%1$s has received a Battle.net whisper from %2$s."] = "%1$s 님이 %2$s 님으로 부터 Battle.net 귓속말을 받았습니다."
L["%1$s has received a whisper from %2$s."] = "%1$s 님이 %2$s 님으로 부터 귓속말을 받았습니다."
-- L["!ERROR: Party forwarding timeout reached."] = ""
-- L["!ERROR: Whisper timeout reached."] = ""

-- L.HELP_CHAT = [[]]

------------
-- Follow --
------------

L["Follow"] = "따라가기"
L["Responds to follow requests from trusted party members."] = "신뢰하는 파티원의 따라다니기 요청에 대하여 응답합니다."
-- L["Set a key binding to follow your current target."] = ""
-- L["Set a key binding direct all characters in your party to follow you."] = ""
-- L["Set a key binding to direct all dead characters in your party to release their spirit."] = ""
-- L["Set a key binding to direct all ghost characters in your party to accept resurrection to their corpse."] = ""

L["%s is now following you."] = "%s 님이 당신을 따라다닙니다."
L["%s is no longer following you."] = "%s 님은 더 이상 당신을 따라다니지 않습니다."
L["%s is no longer following you!"] = "%s 님은 더 이상 당신을 따라다니지 않습니다!"
L["%s is too far away to follow!"] = "%s 님은 따라다니기엔 너무 멀리 있습니다!"
L["Use Soulstone"] = ""
L["Reincarnate"] = ""
L["I have a soulstone."] = "영혼석을 가지고 있습니다."
L["I can reincarnate."] = "윤회를 할 수 있습니다."
L["I can resurrect myself."] = "스스로 부활할 수 있습니다."
L["I cannot resurrect!"] = "부활을 할 수 없습니다!"

-- L.HELP_FOLLOW = [[]]

L.SLASH_HYDRA_FOLLOWME3 = "/따라와"

L.SLASH_HYDRA_CORPSE2 = "/시체"
L["release"] = "무덤"
L["accept"] = "수락"

-- L.BINDING_NAME_HYDRA_FOLLOW_TARGET = ""
-- L.BINDING_NAME_HYDRA_FOLLOW_ME = ""
-- L.BINDING_NAME_HYDRA_RELEASE_CORPSE = ""
-- L.BINDING_NAME_HYDRA_ACCEPT_CORPSE = ""

-----------
-- Mount --
-----------

L["Mount"] = "탈것"
L["Summons your mount when another party member mounts."] = "다른 파티원이 탈것을 소환할 때, 당신의 탈것을 소환합니다."

L["ERROR: %s is missing that mount!"] = "오류: %s 님은 탈 것이 없습니다!"

-- L.HELP_MOUNT = [[]]

-----------
-- Party --
-----------

L["Party"] = "파티"
L["Responds to invite and promote requests from trusted players."] = "신뢰하는 파티원의 초대와 승급 요청에 대하여 응답합니다."

L["I cannot invite you, because you are not on my trusted list."] = "나의 신뢰하는 목록에 존재하지 않으므로 당신을 초대할 수 없습니다."
L["I cannot invite you, because I am not the party leader."] = "저는 모듈 리더가 아니므로 당신을 초대할 수 없습니다."
L["I cannot promote you, because you are not on my trusted list."] = "나의 신뢰하는 목록에 존재하지 않으므로 때문에 당신을 승급할 수 없습니다."
L["I cannot promote you, because I am not the party leader."] = "저는 파티장이 아니므로 당신을 승급할 수 없습니다."

-- L.HELP_PARTY = [[]]

L.SLASH_HYDRA_INVITEME3 = "/나초대"
L.SLASH_HYDRA_PROMOTEME3 = "/승급"

-----------
-- Quest --
-----------

L["Quest"] = "퀘스트"
L["Helps keep party members' quests in sync."] = "파티원의 퀘스트와 항상 동기화하도록 도와줍니다."
L["Turn in quests"] = "퀘스트 제출"
L["Turn in complete quests."] = "완료한 퀘스트를 제출합니다."
L["Accept quests"] = "퀘스트 수락"
L["Accept quests shared by party members, quests from NPCs that other party members have already accepted, and escort-type quests started by another party member."] = "다른 파티원이 이미 NPC에게 수락했던 퀘스트와, 다른 파티원에 의해 호위 형태의 퀘스트가 시작되면, 파티원에 의하여 공유된 퀘스트를 수락합니다."
L["Share quests"] = "퀘스트 공유"
L["Share quests you accept from NPCs."] = "NPC에게 수락한 퀘스트를 공유합니다."
L["Abandon quests"] = "퀘스트 포기"
L["Abandon quests abandoned by a trusted party member."] = "신뢰하는 파티원이 포기한 퀘스트를 포기합니다."

L["%1$s accepted %2$s."] = "%1$s 님이 %2$s|1을;를; 수락했습니다."
L["%1$s turned in %2$s."] = "%1$s 님이 %2$s|1을;를; 반환했습니다."
L["%1$s abandoned %2$s."] = "%1$s 님이 %2$s|1을;를; 포기했습니다."
L["That quest cannot be shared."] = "해당 퀘스트는 공유할 수 없습니다."

-- L.HELP_QUEST = [[]]

----------
-- Taxi --
----------

L["Taxi"] = "택시"
L["Selects the same taxi destination as other party members."] = "택시(그리핀, 와이번)의 목적지를 다른 파티원과 동일한 곳으로 선택합니다."
L["Clear the taxi selection after this many seconds."] = "이 시간(초)이 경과된 후에 택시 선택을 지웁니다."

L["ERROR: %s: Taxi timeout reached."] = "오류: %s: 님의 택시가 시간 초과되었습니다."
L["ERROR: %s: Taxi node mismatch."] = "오류: %s: 님의 택시 노드가 일치하지 않습니다."
L["%1$s set the party taxi to %2$s."] = "%1$s 님이 지정한 파티 택시의 노드 %2$s"
L["Party taxi cleared."] = "파티 택시가 지워졌습니다."

-- L.HELP_TAXI = [[]]

L.SLASH_HYDRA_CLEARTAXI2 = "/택시지우기"