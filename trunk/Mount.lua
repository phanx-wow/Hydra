--[[--------------------------------------------------------------------
	HYDRA MOUNT
	* Mounts other characters in the party when you mount
----------------------------------------------------------------------]]

local _, core = ...
if not core then core = _G.Hydra end

local SOLO, PARTY, TRUSTED, LEADER = 0, 1, 2, 3
local playerName = UnitName("player")

local responding

local module = core:RegisterModule("Mount", CreateFrame("Frame"))
module:SetScript("OnEvent", function(f, e, ...) return f[e] and f[e](f, ...) end)

module.defaults = { enable = true }

------------------------------------------------------------------------

function module:CheckState()
	if core.state > SOLO and self.db.enable then
		self:Debug("Enable module: Mount")
		self:RegisterEvent("CHAT_MSG_ADDON")
		self:RegisterEvent("UNIT_SPELLCAST_SENT")
	else
		self:Debug("Disable module: Mount")
		self:UnregisterAllEvents()
	end
end

------------------------------------------------------------------------

function module:CHAT_MSG_ADDON(prefix, message, channel, sender)
	if prefix ~= "HydraMount" or channel ~= "PARTY" or sender == playerName or not core:IsTrusted(sender) then return end
	self:Debug("CHAT_MSG_ADDON", prefix, message, channel, sender)

	if message == "ERROR" then
		print("ERROR:", sender, "is missing that mount!")
		return
	end

	local remoteID, remoteName = message:match("^(%d+) (.+)$")
	if not remoteID or not remoteName then return end
	remoteID = tonumber(remoteID)
	self:Debug(sender, "mounted on", remoteName, remoteID, self.mounts[remoteID])

	if IsMounted() then return self:Debug("Already mounted.") end
	if not UnitIsVisible(sender) then return self:Debug("Not mounting because", sender, "is out of range.") end

	responding = true

	-- 1. look for same mount
	for i = 1, GetNumCompanions("MOUNT") do
		local _, name, id = GetCompanionInfo("MOUNT", i)
		if id == remoteID then
			self:Debug("Found same mount", name)
			CallCompanion("MOUNT", i)
			responding = nil
			return
		end
	end

	-- 2. look for equivalent mount
	local category = self.mounts[remoteID]
	for i = 1, GetNumCompanions("MOUNT") do
		local _, name, id = GetCompanionInfo("MOUNT", i)
		self:Debug("Checking mount", name, self.mounts[id])
		if self.mounts[id] == category then
			self:Debug("Found equivalent mount", name, category)
			CallCompanion("MOUNT", i)
			responding = nil
			return
		end
	end

	SendAddonMessage("HydraMount", "ERROR", "PARTY")
	responding = nil
end

------------------------------------------------------------------------

function module:UNIT_SPELLCAST_SENT(unit, spell)
	if responding or unit ~= "player" or core.state == SOLO or UnitAffectingCombat("player") then return end
	for i = 1, GetNumCompanions("MOUNT") do
		local _, name, id = GetCompanionInfo("MOUNT", i)
		if name == spell or (GetSpellInfo(id)) == spell then -- stupid paladin mount summon spell doesn't match companion name
			self:Debug("Summoning mount", name, id)
			SendAddonMessage("HydraMount", id .. " " .. name, "PARTY")
		end
	end
end

hooksecurefunc("CallCompanion", function(type, i)
	if responding or core.state == SOLO then return end
	if type == "MOUNT" then
		local _, name, id = GetCompanionInfo(type, i)
		module:Debug("CallCompanion", type, i, name, id)
		SendAddonMessage("HydraMount", id .. " " .. name, "PARTY")
	end
end)

------------------------------------------------------------------------

module.mounts = { -- data from Adirelle's Squire ( http://www.wowace.com/addons/squire/ )
	[458]="G60",
	[470]="G60",
	[472]="G60",
	[580]="G60",
	[5784]="G60",
	[6648]="G60",
	[6653]="G60",
	[6654]="G60",
	[6777]="G60",
	[6898]="G60",
	[6899]="G60",
	[8394]="G60",
	[8395]="G60",
	[10789]="G60",
	[10793]="G60",
	[10796]="G60",
	[10799]="G60",
	[10873]="G60",
	[10969]="G60",
	[13819]="G60",
	[15779]="G100",
	[16055]="G100",
	[16056]="G100",
	[16080]="G100",
	[16081]="G100",
	[16082]="G100",
	[16083]="G100",
	[16084]="G100",
	[17229]="G100",
	[17450]="G100",
	[17453]="G60",
	[17454]="G60",
	[17459]="G100",
	[17460]="G100",
	[17461]="G100",
	[17462]="G60",
	[17463]="G60",
	[17464]="G60",
	[17465]="G100",
	[17481]="G100",
	[18989]="G60",
	[18990]="G60",
	[18991]="G100",
	[18992]="G100",
	[22717]="G100",
	[22718]="G100",
	[22719]="G100",
	[22720]="G100",
	[22721]="G100",
	[22722]="G100",
	[22723]="G100",
	[22724]="G100",
	[23161]="G100",
	[23214]="G100",
	[23219]="G100",
	[23221]="G100",
	[23222]="G100",
	[23223]="G100",
	[23225]="G100",
	[23227]="G100",
	[23228]="G100",
	[23229]="G100",
	[23238]="G100",
	[23239]="G100",
	[23240]="G100",
	[23241]="G100",
	[23242]="G100",
	[23243]="G100",
	[23246]="G100",
	[23247]="G100",
	[23248]="G100",
	[23249]="G100",
	[23250]="G100",
	[23251]="G100",
	[23252]="G100",
	[23338]="G100",
	[23509]="G100",
	[23510]="G100",
	[24242]="G100",
	[24252]="G100",
	[25953]="AQ60",
	[26054]="AQ60",
	[26055]="AQ60",
	[26056]="AQ60",
	[26656]="G100",
	[30174]="G60",
	[32235]="F150",
	[32239]="F150",
	[32240]="F150",
	[32242]="F280",
	[32243]="F150",
	[32244]="F150",
	[32245]="F150",
	[32246]="F280",
	[32289]="F280",
	[32290]="F280",
	[32292]="F280",
	[32295]="F280",
	[32296]="F280",
	[32297]="F280",
	[32345]="F280",
	[33660]="G100",
	[34406]="G60",
	[34767]="G100",
	[34769]="G60",
	[34790]="G100",
	[34795]="G60",
	[34896]="G100",
	[34897]="G100",
	[34898]="G100",
	[34899]="G100",
	[35018]="G60",
	[35020]="G60",
	[35022]="G60",
	[35025]="G100",
	[35027]="G100",
	[35028]="G100",
	[35710]="G60",
	[35711]="G60",
	[35712]="G100",
	[35713]="G100",
	[35714]="G100",
	[36702]="G100",
	[37015]="F310",
	[39315]="G100",
	[39316]="G100",
	[39317]="G100",
	[39318]="G100",
	[39319]="G100",
	[39798]="F280",
	[39800]="F280",
	[39801]="F280",
	[39802]="F280",
	[39803]="F280",
	[40192]="F310",
	[41252]="G100",
	[41513]="F280",
	[41514]="F280",
	[41515]="F280",
	[41516]="F280",
	[41517]="F280",
	[41518]="F280",
	[42776]="G60",
	[42777]="G100",
	[43688]="G100",
	[43899]="G60",
	[43900]="G100",
	[43927]="F280",
	[44151]="F280",
	[44153]="F150",
	[44744]="F310",
	[46197]="F150",
	[46199]="F280",
	[46628]="G100",
	[48025]="DYN",
	[48027]="G100",
	[48778]="G100",
	[49193]="F310",
	[49322]="G100",
	[49379]="G100",
	[50869]="G60",
	[51412]="G100",
	[54729]="FDYN",
	[54753]="G100",
	[55531]="G100",
	[58615]="F310",
	[58983]="GDYN",
	[59567]="F280",
	[59568]="F280",
	[59569]="F280",
	[59570]="F280",
	[59571]="F280",
	[59650]="F280",
	[59785]="G100",
	[59788]="G100",
	[59791]="G100",
	[59793]="G100",
	[59797]="G100",
	[59799]="G100",
	[59961]="F280",
	[59976]="F310",
	[59996]="F280",
	[60002]="F280",
	[60021]="F310",
	[60024]="F310",
	[60025]="F280",
	[60114]="G100",
	[60116]="G100",
	[60118]="G100",
	[60119]="G100",
	[60424]="G100",
	[61229]="F280",
	[61230]="F280",
	[61294]="F280",
	[61309]="F280",
	[61425]="G100",
	[61447]="G100",
	[61451]="F150",
	[61465]="G100",
	[61467]="G100",
	[61469]="G100",
	[61470]="G100",
	[61996]="F280",
	[61997]="F280",
	[63232]="G100",
	[63635]="G100",
	[63636]="G100",
	[63637]="G100",
	[63638]="G100",
	[63639]="G100",
	[63640]="G100",
	[63641]="G100",
	[63642]="G100",
	[63643]="G100",
	[63796]="FMAX",
	[63844]="F280",
	[63956]="F310",
	[63963]="F310",
	[64656]="G100",
	[64657]="G60",
	[64658]="G60",
	[64659]="G100",
	[64731]="G60",
	[64927]="F310",
	[64977]="G60",
	[65439]="F310",
	[65637]="G100",
	[65638]="G100",
	[65639]="G100",
	[65640]="G100",
	[65641]="G100",
	[65642]="G100",
	[65643]="G100",
	[65644]="G100",
	[65645]="G100",
	[65646]="G100",
	[65917]="G100",
	[66087]="F280",
	[66088]="F280",
	[66090]="G100",
	[66091]="G100",
	[66846]="G100",
	[66847]="G60",
	[66906]="G100",
	[66907]="G60",
	[67336]="F310",
	[67466]="G100",
	[68056]="G100",
	[68057]="G100",
	[68187]="G100",
	[68188]="G100",
	[69395]="F280",
	[71342]="DYN",
	[71810]="F310",
	[72286]="DYN",
	[72807]="F310",
	[72808]="F310",
	[73313]="G100",
	[74856]="FDYN",
	[74918]="G100",
	[75596]="F280",
	[75614]="DYN",
	[75973]="FDYN",
}
