--[[--------------------------------------------------------------------
	Hydra
	Multibox leveling helper.
	Written by Phanx <addons@phanx.net>
	Copyright © 2010–2011 Phanx. Some rights reserved. See LICENSE.txt for details.
	http://www.wowinterface.com/downloads/info17572-Hydra.html
	http://wow.curse.com/downloads/wow-addons/details/hydra.aspx
----------------------------------------------------------------------]]

local HYDRA, core = ...
if not core then core = _G.Hydra end

local L = core.L
local realmName, playerName = GetRealmName(), UnitName("player")

local panels = { }
core.optionPanels = panels

local CreateButton = LibStub( "PhanxConfig-Button" ).CreateButton
local CreateCheckbox = LibStub( "PhanxConfig-Checkbox" ).CreateCheckbox
local CreateDropdown = LibStub( "PhanxConfig-Dropdown" ).CreateDropdown
local CreateEditBox = LibStub( "PhanxConfig-EditBox" ).CreateEditBox
local CreateHeader = LibStub( "PhanxConfig-Header" ).CreateHeader
local CreateKeyBinding = LibStub("PhanxConfig-KeyBinding").CreateKeyBinding
local CreateOptionsPanel = LibStub( "PhanxConfig-OptionsPanel" ).CreateOptionsPanel
local CreateSlider = LibStub( "PhanxConfig-Slider" ).CreateSlider

------------------------------------------------------------------------

panels[ #panels + 1 ] = CreateOptionsPanel( HYDRA, nil, function( self )
	local title, notes = CreateHeader( self, self.name,
		L["Hydra is a multibox leveling helper that aims to minimize the need to actively control secondary characters."] )
	notes:SetHeight( notes:GetHeight() * 1.5 )

	local add = CreateEditBox( self, L["Add Name"], L["Add a name to your trusted list."], 12 )
	add:SetPoint( "TOPLEFT", notes, "BOTTOMLEFT", 0, -12 )
	add:SetPoint( "TOPRIGHT", notes, "BOTTOM", -8, -12 )
	add.OnValueChanged = function( self, v )
		if not _G.ADDBOX then _G.ADDBOX = self end
		text = v and string.gsub( string.trim( v ), "%a", string.upper, 1 )
		if string.len( v ) > 1 then
			core:Print( L["%s has been added to your trusted list."], v )
			core.trusted[ v ] = v
			HydraTrustList[ realmName ][ v ] = v
			core:TriggerEvent( "PARTY_MEMBERS_CHANGED" )
		end
		self:SetText( "" )
	end

	local party = CreateButton( self, L["Add Current Party"],
		L["Add all the characters in your current party group to your trusted list."] )
	party:SetPoint( "TOPLEFT", notes, "BOTTOM", 8, -5 - add.label:GetHeight() )
	party:SetPoint( "TOPRIGHT", notes, "BOTTOMRIGHT", 0, -5 - add.label:GetHeight() )
	party.OnClick = function( self )
		for i = 1, GetNumPartyMembers() do
			local v = UnitName( "party" .. i )
			core:Print( L["%s has been added to your trusted list."], v )
			core.trusted[ v ] = v
			HydraTrustList[ realmName ][ v ] = v
		end
		core:TriggerEvent("PARTY_MEMBERS_CHANGED")
	end

	local del = CreateDropdown( self, L["Remove Name"], nil, L["Remove a name from your trusted list."] )
	del:SetPoint( "TOPLEFT", add, "BOTTOMLEFT", 0, -16 )
	del:SetPoint( "TOPRIGHT", add, "BOTTOMRIGHT", 0, -16 )
	do
		local me = UnitName("player")
		local info, temp = { }, { }
		local OnClick = function( self )
			local v = self.value
			core:Print( L["%s has been removed from your trusted list."], v )
			core.trusted[ v ] = nil
			HydraTrustList[ realmName ][ v ] = nil
			core:TriggerEvent( "PARTY_MEMBERS_CHANGED" )
		end
		UIDropDownMenu_Initialize( del.dropdown, function()
			for name in pairs( core.trusted ) do
				temp[ #temp + 1 ] = name
			end
			table.sort( temp )
			for i = 1, #temp do
				local name = temp[ i ]
				info.text = name
				info.value = name
				info.func = OnClick
				info.notCheckable = 1
				info.disabled = name == me
				UIDropDownMenu_AddButton( info )
			end
			wipe( temp )
		end )
	end

	local help = self:CreateFontString( nil, "OVERLAY", "GameFontNormalSmall" )
	help:SetPoint( "BOTTOMLEFT", 16, 16 )
	help:SetPoint( "BOTTOMRIGHT", -16, 16 )
	help:SetHeight( 112 )
	help:SetJustifyH( "LEFT" )
	help:SetJustifyV( "BOTTOM" )
	help:SetText( L.HELP_TRUST )
end )

------------------------------------------------------------------------

panels[ #panels + 1 ] = CreateOptionsPanel( L["Automation"], HYDRA, function( self )
	local title, notes = CreateHeader( self, self.name, L["Automates simple repetetive tasks, such as clicking common dialogs."] )

	local function OnClick( self, checked )
		core.db["Automation"][ self.key ] = checked
		if self.key ~= "verbose" then
			core.modules["Automation"]:CheckState()
		end
	end

	local declineDuels = CreateCheckbox( self, L["Decline duels"], L["Decline duel requests."] )
	declineDuels:SetPoint( "TOPLEFT", notes, "BOTTOMLEFT", 0, -12 )
	declineDuels.OnClick = OnClick
	declineDuels.key = "declineDuels"

	local declineGuilds = CreateCheckbox( self, L["Decline guilds"], L["Decline guild invitations and petitions."] )
	declineGuilds:SetPoint( "TOPLEFT", declineDuels, "BOTTOMLEFT", 0, -8 )
	declineGuilds.OnClick = OnClick
	declineGuilds.key = "declineGuilds"

	local declineArenaTeams = CreateCheckbox( self, L["Decline arena teams"], L["Decline arena team invitations and petitions."] )
	declineArenaTeams:SetPoint( "TOPLEFT", declineGuilds, "BOTTOMLEFT", 0, -8 )
	declineArenaTeams.OnClick = OnClick
	declineArenaTeams.key = "declineArenaTeams"

	local acceptSummons = CreateCheckbox( self, L["Accept summons"], L["Accept summon requests."] )
	acceptSummons:SetPoint( "TOPLEFT", declineArenaTeams, "BOTTOMLEFT", 0, -8 )
	acceptSummons.OnClick = OnClick
	acceptSummons.key = "acceptSummons"

	local acceptResurrections = CreateCheckbox( self, L["Accept resurrections"], L["Accept resurrections from players not in combat."] )
	acceptResurrections:SetPoint( "TOPLEFT", acceptSummons, "BOTTOMLEFT", 0, -8 )
	acceptResurrections.OnClick = OnClick
	acceptResurrections.key = "acceptResurrections"

	local acceptResurrectionsInCombat = CreateCheckbox( self, L["Accept combat resurrections"], L["Accept resurrections from players in combat."] )
	acceptResurrectionsInCombat:SetPoint( "TOPLEFT", acceptResurrections, "BOTTOMLEFT", 0, -8 )
	acceptResurrectionsInCombat.OnClick = OnClick
	acceptResurrectionsInCombat.key = "acceptResurrectionsInCombat"

	local repairEquipment = CreateCheckbox( self, L["Repair equipment"], L["Repair all equipment when interacting with a repair vendor."] )
	repairEquipment:SetPoint( "TOPLEFT", acceptResurrectionsInCombat, "BOTTOMLEFT", 0, -8 )
	repairEquipment.OnClick = OnClick
	repairEquipment.key = "repairEquipment"

	local sellJunk = CreateCheckbox( self, L["Sell junk"], L["Sell all junk (gray) items when interacting with a vendor."] )
	sellJunk:SetPoint( "TOPLEFT", repairEquipment, "BOTTOMLEFT", 0, -8 )
	sellJunk.OnClick = OnClick
	sellJunk.key = "sellJunk"

	local verbose = CreateCheckbox( self, L["Verbose mode"], L["Enable notification messages from this module."] )
	verbose:SetPoint( "TOPLEFT", sellJunk, "BOTTOMLEFT", 0, -24 )
	verbose.OnClick = OnClick
	verbose.key = "verbose"

	local help = self:CreateFontString( nil, "OVERLAY", "GameFontNormalSmall" )
	help:SetPoint( "BOTTOMLEFT", 16, 16 )
	help:SetPoint( "BOTTOMRIGHT", -16, 16 )
	help:SetHeight( 112 )
	help:SetJustifyH( "LEFT" )
	help:SetJustifyV( "BOTTOM" )
	help:SetText( L.HELP_AUTO )

	self.refresh = function()
		declineDuels:SetChecked( core.db["Automation"].declineDuels )
		declineArenaTeams:SetChecked( core.db["Automation"].declineArenaTeams )
		declineGuilds:SetChecked( core.db["Automation"].declineGuilds )
		acceptSummons:SetChecked( core.db["Automation"].acceptSummons )
		acceptResurrections:SetChecked( core.db["Automation"].acceptResurrections )
		acceptResurrectionsInCombat:SetChecked( core.db["Automation"].acceptResurrectionsInCombat )
		repairEquipment:SetChecked( core.db["Automation"].repairEquipment )
		sellJunk:SetChecked( core.db["Automation"].sellJunk )
		verbose:SetChecked( core.db["Automation"].verbose )
	end
end )

------------------------------------------------------------------------

panels[ #panels + 1 ] = CreateOptionsPanel( L["Chat"], HYDRA, function( self )
	local title, notes = CreateHeader( self, self.name, L["Forwards whispers sent to inactive characters to party chat, and forwards replies to the original sender."] )

	local enable = CreateCheckbox( self, L["Enable"], L["Enable this module."] )
	enable:SetPoint( "TOPLEFT", notes, "BOTTOMLEFT", 0, -12 )
	enable.OnClick = function( self, checked )
		core.db["Chat"].enable = checked
		core.modules["Chat"]:CheckState()
	end

	local modes = {
		appfocus = L["Application Focus"],
		leader = L["Party Leader"],
	}

	local mode = CreateDropdown( self, L["Detection method"], nil,
		L["Select the method to use for detecting the primary character."] .. "\n\n" .. L["If you are multiboxing on multiple physical machines, or are running multiple copies of WoW in windowed mode, the \"Application Focus\" mode will probably not work for you, and you should make sure that your primary character is the party leader."] )
	mode:SetPoint( "TOPLEFT", enable, "BOTTOMLEFT", 0, -16 )
	mode:SetPoint( "TOPRIGHT", notes, "BOTTOM", -8, -12 - enable:GetHeight() -16 )
	do
		local info = { }
		local OnClick = function( self )
			core.db["Chat"].mode = self.value
			core.modules["Chat"]:CheckState()
		end
		UIDropDownMenu_Initialize( mode.dropdown, function()
			info.text = L["Application Focus"]
			info.value = "appfocus"
			info.func = OnClick
			UIDropDownMenu_AddButton( info )

			info.text = L["Party Leader"]
			info.value = "leader"
			info.func = OnClick
			UIDropDownMenu_AddButton( info )
		end )
	end

	local timeout = CreateSlider( self, L["Timeout"], 30, 600, 30, nil,
		L["If this many seconds have elapsed since the last forwarded message, don't forward messages typed in party chat to the last whisperer unless the target is explicitly specified."] )
	timeout:SetPoint( "TOPLEFT", mode, "BOTTOMLEFT", 0, -16 )
	timeout:SetPoint( "TOPRIGHT", mode, "BOTTOMRIGHT", 0, -16 )
	timeout.OnValueChanged = function( self, value )
		value = math.floor( ( value + 1 ) / 30 ) * 30
		core.db["Chat"].timeout = value
		return value
	end

	local help = self:CreateFontString( nil, "OVERLAY", "GameFontNormalSmall" )
	help:SetPoint( "BOTTOMLEFT", 16, 16 )
	help:SetPoint( "BOTTOMRIGHT", -16, 16 )
	help:SetHeight( 112 )
	help:SetJustifyH( "LEFT" )
	help:SetJustifyV( "BOTTOM" )
	help:SetText( L.HELP_CHAT )

	self.refresh = function()
		enable:SetChecked( core.db["Chat"].enable )
		mode:SetValue( modes[ core.db["Chat"].mode ] )
		timeout:SetValue( core.db["Chat"].timeout )
	end
end )

------------------------------------------------------------------------

panels[ #panels + 1 ] = CreateOptionsPanel( L["Follow"], HYDRA, function( self )
	local title, notes = CreateHeader( self, self.name, L["Responds to follow requests from trusted party members."] )

	local enable = CreateCheckbox( self, L["Enable"], L["Enable this module."] )
	enable:SetPoint( "TOPLEFT", notes, "BOTTOMLEFT", 0, -12 )
	enable.OnClick = function( self, checked )
		core.db["Follow"].enable = checked
	end

	local verbose = CreateCheckbox( self, L["Verbose mode"], L["Enable notification messages from this module."] )
	verbose:SetPoint( "TOPLEFT", enable, "BOTTOMLEFT", 0, -8 )
	verbose.OnClick = function( self, checked )
		core.db["Follow"].verbose = checked
	end

	local follow = CreateKeyBinding(self, BINDING_NAME_HYDRA_FOLLOW_TARGET, "HYDRA_FOLLOW_TARGET",
		L["Set a key binding to follow your current target."])
	follow:SetPoint("TOPLEFT", notes, "BOTTOM", -8, -8)
	follow:SetPoint("TOPRIGHT", notes, "BOTTOMRIGHT", 0, -8)

	local followme = CreateKeyBinding(self, BINDING_NAME_HYDRA_FOLLOW_ME, "HYDRA_FOLLOW_ME",
		L["Set a key binding to direct all characters in your party to follow you."])
	followme:SetPoint("TOPLEFT", follow, "BOTTOMLEFT", 0, -8)
	followme:SetPoint("TOPRIGHT", follow, "BOTTOMRIGHT", 0, -8)

	local release = CreateKeyBinding(self, BINDING_NAME_HYDRA_RELEASE_CORPSE, "HYDRA_RELEASE_CORPSE",
		L["Set a key binding to direct all dead characters in your party to release their spirit."])
	release:SetPoint("TOPLEFT", followme, "BOTTOMLEFT", 0, -8)
	release:SetPoint("TOPRIGHT", followme, "BOTTOMRIGHT", 0, -8)

	local acceptres = CreateKeyBinding(self, BINDING_NAME_HYDRA_ACCEPT_CORPSE, "HYDRA_ACCEPT_CORPSE",
		L["Set a key binding to direct all ghost characters in your party to accept resurrection to their corpse."])
	acceptres:SetPoint("TOPLEFT", release, "BOTTOMLEFT", 0, -8)
	acceptres:SetPoint("TOPRIGHT", release, "BOTTOMRIGHT", 0, -8)

	local help = self:CreateFontString( nil, "OVERLAY", "GameFontNormalSmall" )
	help:SetPoint( "BOTTOMLEFT", 16, 16 )
	help:SetPoint( "BOTTOMRIGHT", -16, 16 )
	help:SetHeight( 112 )
	help:SetJustifyH( "LEFT" )
	help:SetJustifyV( "BOTTOM" )
	help:SetText( L.HELP_FOLLOW )

	self.refresh = function()
		enable:SetChecked( core.db["Follow"].enable )
		verbose:SetChecked( core.db["Follow"].verbose )
		follow:RefreshValue()
		followme:RefreshValue()
		release:RefreshValue()
		acceptres:RefreshValue()
	end
end )

------------------------------------------------------------------------

panels[ #panels + 1 ] = CreateOptionsPanel( L["Mount"], HYDRA, function( self )
	local title, notes = CreateHeader( self, self.name, L["Summons your mount when another party member mounts."] )

	local enable = CreateCheckbox( self, L["Enable"], L["Enable this module."] )
	enable:SetPoint( "TOPLEFT", notes, "BOTTOMLEFT", 0, -12 )
	enable.OnClick = function( self, checked )
		core.db["Mount"].enable = checked
		core.modules["Mount"]:CheckState()
	end

	local help = self:CreateFontString( nil, "OVERLAY", "GameFontNormalSmall" )
	help:SetPoint( "BOTTOMLEFT", 16, 16 )
	help:SetPoint( "BOTTOMRIGHT", -16, 16 )
	help:SetHeight( 112 )
	help:SetJustifyH( "LEFT" )
	help:SetJustifyV( "BOTTOM" )
	help:SetText( L.HELP_MOUNT )

	self.refresh = function()
		enable:SetChecked( core.db["Mount"].enable )
	end
end )

------------------------------------------------------------------------

panels[ #panels + 1 ] = CreateOptionsPanel( L["Party"], HYDRA, function( self )
	local title, notes = CreateHeader( self, self.name, L["Responds to invite and promote requests from trusted players."] )

	local enable = CreateCheckbox( self, L["Enable"], L["Enable this module."] )
	enable:SetPoint( "TOPLEFT", notes, "BOTTOMLEFT", 0, -12 )
	enable.OnClick = function( self, checked )
		core.db["Party"].enable = checked
		core.modules["Party"]:CheckState()
	end

	local help = self:CreateFontString( nil, "OVERLAY", "GameFontNormalSmall" )
	help:SetPoint( "BOTTOMLEFT", 16, 16 )
	help:SetPoint( "BOTTOMRIGHT", -16, 16 )
	help:SetHeight( 112 )
	help:SetJustifyH( "LEFT" )
	help:SetJustifyV( "BOTTOM" )
	help:SetText( L.HELP_PARTY )

	self.refresh = function()
		enable:SetChecked( core.db["Party"].enable )
	end
end )

------------------------------------------------------------------------

panels[ #panels + 1 ] = CreateOptionsPanel( L["Quest"], HYDRA, function( self )
	local title, notes = CreateHeader( self, self.name, L["Helps keep party members' quests in sync."] )

	local function OnClick( self, checked )
		core.db["Quest"][ self.key ] = checked
	end

	local enable = CreateCheckbox( self, L["Enable"], L["Enable this module."] )
	enable:SetPoint( "TOPLEFT", notes, "BOTTOMLEFT", 0, -12 )
	enable.OnClick = OnClick
	enable.key = "enable"

	local turnin = CreateCheckbox( self, L["Turn in quests"], L["Turn in complete quests to NPCs."] )
	turnin:SetPoint( "TOPLEFT", enable, "BOTTOMLEFT", 0, -8 )
	turnin.OnClick = OnClick
	turnin.key = "turnin"

	local accept = CreateCheckbox( self, L["Accept quests"], L["Accept quests shared by party members, quests from NPCs that other party members have already accepted, and escort-type quests started by another party member."] )
	accept:SetPoint( "TOPLEFT", turnin, "BOTTOMLEFT", 0, -8 )
	accept.OnClick = OnClick
	accept.key = "accept"

	local share = CreateCheckbox( self, L["Share quests"], L["Share quests you accept from NPCs."] )
	share:SetPoint( "TOPLEFT", accept, "BOTTOMLEFT", 0, -8 )
	share.OnClick = OnClick
	share.key = "share"

	local abandon = CreateCheckbox( self, L["Abandon quests"], L["Abandon quests abandoned by trusted party members."] )
	abandon:SetPoint( "TOPLEFT", share, "BOTTOMLEFT", 0, -8 )
	abandon.OnClick = OnClick
	abandon.key = "abandon"

	local help = self:CreateFontString( nil, "OVERLAY", "GameFontNormalSmall" )
	help:SetPoint( "BOTTOMLEFT", 16, 16 )
	help:SetPoint( "BOTTOMRIGHT", -16, 16 )
	help:SetHeight( 112 )
	help:SetJustifyH( "LEFT" )
	help:SetJustifyV( "BOTTOM" )
	help:SetText( L.HELP_QUEST )

	self.refresh = function()
		enable:SetChecked( core.db["Quest"].enable )
		turnin:SetChecked( core.db["Quest"].turnin )
		accept:SetChecked( core.db["Quest"].accept )
		share:SetChecked( core.db["Quest"].share )
		abandon:SetChecked( core.db["Quest"].abandon )
	end
end )

------------------------------------------------------------------------

panels[ #panels + 1 ] = CreateOptionsPanel( L["Taxi"], HYDRA, function( self )
	local title, notes = CreateHeader( self, self.name, L["Selects the same taxi destination as other party members."] )

	local enable = CreateCheckbox( self, L["Enable"], L["Enable this module."] )
	enable:SetPoint( "TOPLEFT", notes, "BOTTOMLEFT", 0, -12 )
	enable.OnClick = function( self, checked )
		core.db["Party"].enable = checked
		core.modules["Party"]:CheckState()
	end

	local timeout = CreateSlider( self, L["Timeout"], 30, 600, 30, nil, L["Clear the taxi selection after this many seconds."] )
	timeout:SetPoint( "TOPLEFT", enable, "BOTTOMLEFT", 0, -16 )
	timeout:SetPoint( "TOPRIGHT", notes, "BOTTOM", -8, -28 - enable:GetHeight() )
	timeout.OnValueChanged = function( self, value )
		value = math.floor( ( value + 1 ) / 30 ) * 30
		core.db["Taxi"].timeout = value
		return value
	end

	local help = self:CreateFontString( nil, "OVERLAY", "GameFontNormalSmall" )
	help:SetPoint( "BOTTOMLEFT", 16, 16 )
	help:SetPoint( "BOTTOMRIGHT", -16, 16 )
	help:SetHeight( 112 )
	help:SetJustifyH( "LEFT" )
	help:SetJustifyV( "BOTTOM" )
	help:SetText( L.HELP_TAXI )

	self.refresh = function()
		enable:SetChecked( core.db["Taxi"].enable )
		timeout:SetValue( core.db["Taxi"].timeout )
	end
end )

------------------------------------------------------------------------

panels[ #panels + 1 ] = LibStub( "LibAboutPanel" ).new( HYDRA, HYDRA )

SLASH_HYDRA1 = "/hydra"
SlashCmdList.HYDRA = function()
	InterfaceOptionsFrame_OpenToCategory( panels[1] )
end

local LDB = LibStub("LibDataBroker-1.1", true)
if LDB then
	LDB:NewDataObject(HYDRA, {
		type = "launcher",
		icon = "Interface\\Icons\\Achievement_Boss_Bazil_Akumai",
		label = HYDRA,
		OnClick = SlashCmdList.HYDRA,
		OnTooltipShow = function( tooltip )
			tooltip:AddLine( HYDRA, 1, 1, 1 )
			tooltip:AddLine( L["Click for options."] )
			tooltip:Show()
		end,
	})
end