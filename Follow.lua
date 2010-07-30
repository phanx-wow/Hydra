--[[--------------------------------------------------------------------
	HYDRA FOLLOW
	* Alerts when someone who is following you falls off
	* /followme or /fme commands all party members to follow you
----------------------------------------------------------------------]]

local _, core = ...
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
	if prefix ~= "HydraFollow" or sender == playerName then return end

	if message == playerName then -- sender is following me
		self:Print(sender, "is now following you.")
		followers[sender] = GetTime()

	elseif message == "END" and followers[sender] then -- sender stopped following me
		if GetTime() - followers[sender] > 2 then
			self:Print(sender, "is no longer following you.")
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
			self:Print(sender, "is too far away to follow!")
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