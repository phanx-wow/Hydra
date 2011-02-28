--[[--------------------------------------------------------------------
	Hydra
	Multibox leveling helper.
	Written by Phanx <addons@phanx.net>
	Maintained by Akkorian <akkorian@hotmail.com>
	Copyright © 2010–2011 Phanx. Some rights reserved. See LICENSE.txt for details.
	http://www.wowinterface.com/downloads/info17572-Hydra.html
	http://wow.curse.com/downloads/wow-addons/details/hydra.aspx
------------------------------------------------------------------------
	Hydra Follow
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

module.defaults = { enable = true, verbose = true }

local L = core.L
if GetLocale():match( "^en" ) then
	L["release"] = "re?l?e?a?s?e?"
	L["accept"] = "ac?c?e?p?t?"
end

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
				self:Print( L["%s is now following you."], sender )
			end
			followers[sender] = GetTime()
		elseif message == "END" and followers[sender] then -- sender stopped following me
			if GetTime() - followers[sender] > 2 then
				if self.db.verbose then
					self:Print( L["%s is no longer following you."], sender )
				end
				if not CheckInteractDistance(sender, 2) and not UnitOnTaxi("player") then
					self:Alert( string.format(  L["%s is no longer following you!"], sender ) )
				end
			end
			followers[sender] = nil
		elseif message == "ME" and core:IsTrusted(sender) and self.db.enable then -- sender wants me to follow them
			if CheckInteractDistance(sender, 4) then
				self:Debug(sender, "has sent a follow request.")
				FollowUnit(sender)
			else
				if self.db.verbose then
					self:Print( L["%s is too far away to follow!"], sender )
				end
			end
		end
		return
	elseif prefix == "HydraCorpse" then
		if message == "release" and UnitIsDead("player") and not UnitIsGhost("player") and core:IsTrusted(sender) then
			local ss = HasSoulstone()
			if ss then
				if ss == L["Use Soulstone"] then
					SendChatMessage( L["I have a soulstone."], "PARTY") -- #TODO: use comms
				elseif ss == L["Reincarnate"] then
					SendChatMessage( L["I can reincarnate."], "PARTY") -- #TODO: use comms
				else -- probably "Twisting Nether"
					SendChatMessage( L["I can resurrect myself."], "PARTY") -- #TODO: use comms
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
				SendChatMessage( L["I cannot resurrect!"], "PARTY") -- #TODO: use comms
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
SLASH_FOLLOWME3 = L.SLASH_FOLLOWME3 ~= "/fme" and L.SLASH_FOLLOWME3 ~= "/followme" and L.SLASH_FOLLOWME3

function SlashCmdList.FOLLOWME()
	if core.state == SOLO then return end
	module:Debug("Sending follow command")
	SendAddonMessage("HydraFollow", "ME", "PARTY")
end

------------------------------------------------------------------------

SLASH_HYDRACORPSE1 = "/corpse"
SLASH_HYDRACORPSE2 = L.SLASH_HYDRACORPSE2 ~= "/corpse" and L.SLASH_HYDRACORPSE2

function SlashCmdList.HYDRACORPSE(command)
	if core.state == SOLO then return end
	command = command and command:trim():lower() or ""
	if command:match( L["release"] ) then
		SendAddonMessage("HydraCorpse", "release", "PARTY")
	elseif command:match( L["accept"] ) then
		SendAddonMessage("HydraCorpse", "accept", "PARTY")
	end
end

------------------------------------------------------------------------

BINDING_NAME_HYDRA_FOLLOW_TARGET = L.BINDING_NAME_HYDRA_FOLLOW_TARGET or "Follow target"
BINDING_NAME_HYDRA_FOLLOW_ME = L.BINDING_NAME_HYDRA_FOLLOW_ME or "Request follow"
BINDING_NAME_HYDRA_RELEASE_CORPSE = L.BINDING_NAME_HYDRA_RELEASE_CORPSE or "Release spirit"
BINDING_NAME_HYDRA_ACCEPT_CORPSE = L.BINDING_NAME_HYDRA_ACCEPT_CORPSE or "Resurrect"