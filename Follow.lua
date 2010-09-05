--[[--------------------------------------------------------------------
	HYDRA FOLLOW
	* Alerts when someone who is following you falls off
	* /followme or /fme commands all party members to follow you
	* /corpse r[elease] causes all dead party members to release their spirit
	* /corpse a[ccept] causes all ghost party members to accept their corpse
----------------------------------------------------------------------]]

local _, core = ...
if not core then core = _G.Hydra end

local SOLO, PARTY, TRUSTED, LEADER = 0, 1, 2, 3
local playerName = UnitName("player")

local followers, following = { }

local module = core:RegisterModule("Follow", CreateFrame("Frame"))
module:SetScript("OnEvent", function(f, e, ...) return f[e] and f[e](f, ...) end)

module.defaults = { enable = true }

------------------------------------------------------------------------

function module:CheckState()
	if core.status == SOLO then
		self:Debug("Disable module: Follow")
		self:UnregisterAllEvents()
		followers, following = wipe(followers), nil
	else
		self:Debug("Enable module: Follow")
		self:RegisterEvent("AUTOFOLLOW_BEGIN")
		self:RegisterEvent("AUTOFOLLOW_END")
		self:RegisterEvent("CHAT_MSG_ADDON")
	end
end

------------------------------------------------------------------------

function module:CHAT_MSG_ADDON(prefix, message, channel, sender)
	if sender == playerName then return end

	if prefix == "HydraFollow" then
		if message == playerName then -- sender is following me
			if self.db.verbose then
				self:Print(sender, "is now following you.")
			end
			followers[sender] = GetTime()
		elseif message == "END" and followers[sender] then -- sender stopped following me
			if GetTime() - followers[sender] > 2 then
				if self.db.verbose then
					self:Print(sender, "is no longer following you.")
				end
				if not CheckInteractDistance(sender, 2) and not UnitOnTaxi("player") then
					self:Alert(sender .. " is no longer following you!")
				end
			end
			followers[sender] = nil
		elseif message == "ME" and core:IsTrusted(sender) and self.db.enable then -- sender wants me to follow them
			if CheckInteractDistance(sender, 4) then
				self:Debug(sender, "has sent a follow request.")
				FollowUnit(sender)
			else
				if self.db.verbose then
					self:Print(sender, "is too far away to follow!")
				end
			end
		end
		return
	elseif prefix == "HydraCorpse" then
		if message == "release" and UnitIsDead("player") and not UnitIsGhost("player") and core:IsTrusted(sender) then
			local ss = HasSoulstone()
			if ss then
				if ss == "Use Soulstone" then
					SendChatMessage("I have a soulstone.", "PARTY") -- #TODO: use comms
				elseif ss == "Reincarnate" then
					SendChatMessage("I can reincarnate.", "PARTY") -- #TODO: use comms
				else -- probably "Twisting Nether"
					SendChatMessage("I can self-resurrect.", "PARTY") -- #TODO: use comms
				end
			else
				RepopMe()
			end
		elseif message == "accept" and core:IsTrusted(sender) then
			if UnitIsGhost("player") then
				RetrieveCorpse()
			elseif HasSoulstone() then
				UseSoulstone()
			end
			if CannotBeResurrected() then
				SendChatMessage("I cannot resurrect!", "PARTY") -- #TODO: use comms
			end
		end
	end
end

function module:AUTOFOLLOW_BEGIN(name)
	self:Debug("Now following", name)
	SendAddonMessage("HydraFollow", name, "WHISPER", name)
	following = name
end

function module:AUTOFOLLOW_END()
	if not following then return end -- we don't know who we were following!
	self:Debug("No longer following", following)
	SendAddonMessage("HydraFollow", "END", "WHISPER", following)
	following = nil
end

------------------------------------------------------------------------

SLASH_FOLLOWME1 = "/fme"
SLASH_FOLLOWME2 = "/followme"

function SlashCmdList.FOLLOWME()
	if core.state == SOLO then return end
	module:Debug("Sending follow command")
	SendAddonMessage("HydraFollow", "ME", "PARTY")
end

------------------------------------------------------------------------

SLASH_HYDRACORPSE1 = "/corpse"

function SlashCmdList.HYDRACORPSE(command)
	if core.state == SOLO then return end
	command = command and command:trim() or ""
	if command:match("^r") then
		SendAddonMessage("HydraCorpse", "release", "PARTY")
	elseif command:match("^a") then
		SendAddonMessage("HydraCorpse", "accept", "PARTY")
	end
end

------------------------------------------------------------------------