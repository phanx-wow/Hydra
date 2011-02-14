--[[--------------------------------------------------------------------
	Hydra
	Multibox leveling helper.
	Written by Phanx <addons@phanx.net>
	Maintained by Akkorian <akkorian@hotmail.com>
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
local CreatePanel = LibStub( "PhanxConfig-Panel" ).CreatePanel
local CreateSlider = LibStub( "PhanxConfig-Slider" ).CreateSlider

------------------------------------------------------------------------

local CreateHeader = function( parent, titleText, notesText )
	local title = parent:CreateFontString( nil, "ARTWORK", "GameFontNormalLarge" )
	title:SetPoint( "TOPLEFT", 16, -16 )
	title:SetPoint( "TOPRIGHT", -16, -16 )
	title:SetJustifyH( "LEFT" )
	title:SetText( titleText or parent.name )

	local notes = parent:CreateFontString( nil, "ARTWORK", "GameFontHighlightSmall" )
	notes:SetPoint( "TOPLEFT", title, "BOTTOMLEFT", 0, -8 )
	notes:SetPoint( "TOPRIGHT", title, 0, -8 )
	notes:SetHeight( 32 )
	notes:SetJustifyH( "LEFT" )
	notes:SetJustifyV( "TOP" )
	notes:SetNonSpaceWrap( true )
	notes:SetText( notesText )

	return title, notes
end

------------------------------------------------------------------------

local OptionsPanel_OnShow = function( self )
	if type( self.runOnce ) == "function" then
		self.runOnce( self )
	end
	if type( self.refresh ) == "function" then
		self.refresh()
	end
	self.runOnce = nil
	self:SetScript( "OnShow", nil )
end

local CreateOptionsPanel = function( name, parent, construct, refresh )
	if type( name ) ~= "string" then return end
	if type( parent ) ~= "string" then parent = nil end
	if type( construct ) ~= "function" then construct = nil end
	if type( refresh ) ~= "function" then refresh = nil end

	local f = CreateFrame( "Frame", nil, InterfaceOptionsFramePanelContainer )
	f:Hide()

	f.name = name
	f.parent = parent
	f.refresh = refresh

	f.runOnce = construct
	f:SetScript( "OnShow", OptionsPanel_OnShow )

	InterfaceOptions_AddCategory( f, parent )

	return f
end

------------------------------------------------------------------------

panels[1] = CreateOptionsPanel( HYDRA, nil, function( self )
	local title, notes = CreateHeader( self, HYDRA, L["Hydra is a multibox leveling helper that aims to minimize the need to actively control secondary characters."] )
	notes:SetHeight( notes:GetHeight() * 1.5 )

	local add = CreateEditBox( self, L["Add Name"], L["Add a character name to your trusted list for this realm."], 12 )
	add:SetPoint( "TOPLEFT", notes, "BOTTOMLEFT", 0, -12 )
	add:SetPoint( "TOPRIGHT", notes, "BOTTOM", -8, -12 )
	add.OnValueChanged = function( self, v )
		text = v and string.gsub( string.trim( v ), "%a", string.upper, 1 )
		if string.len( v ) > 1 then
			core:Print( L["%s has been added to your trusted list."], v )
			core.trusted[ v ] = v
			HydraTrustList[ realmName ][ v ] = v
			core:TriggerEvent( "PARTY_MEMBERS_CHANGED" )
		end
		self:SetText( nil )
	end

	local party = CreateButton( self, L["Add Current Party"], L["Add all characters in your current party to your trusted list."] )
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

	local del = CreateDropdown( self, L["Remove Name"], nil, L["Remove a character name from your trusted list for this realm."] )
	del:SetPoint( "TOPLEFT", add, "BOTTOMLEFT", 0, -16 )
	del:SetPoint( "TOPRIGHT", add, "BOTTOMRIGHT", 0, -16 )
	do
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
				UIDropDownMenu_AddButton( info )
			end
			wipe( temp )
		end )
	end

	self.refresh = function()
	end
end )

------------------------------------------------------------------------

panels[2] = CreateOptionsPanel( L["Automation"], HYDRA, function( self )
	local title, notes = CreateHeader( self, L["Automation"], L["Automates simple repetetive tasks, such as clicking common dialogs."] )

	local function OnClick( self, checked )
		core.db["Automation"][ self.key ] = v
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

	local verbose = CreateCheckbox( self, L["Verbose mode"], L["Add messages to the chat frame when automatically performing actions."] )
	verbose:SetPoint( "TOPLEFT", sellJunk, "BOTTOMLEFT", 0, -8 - verbose:GetHeight() )
	verbose.OnClick = OnClick
	verbose.key = "verbose"

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

--[=[
Chat = {
	name = L["Chat"],
	type = "group", dialogInline = true, args = {
		help = {
			name = L["Forwards whispers sent to inactive characters to party chat, and forwards replies to the original sender."],
			type = "description",
			order = 10,
		},
		enable = {
			name = L["Enable"],
			type = "toggle",
			order = 20,
			get = function()
				return core.db["Chat"].enable
			end,
			set = function(_, v)
				core.db["Chat"].enable = v
				core.modules["Chat"]:CheckState()
			end,
		},
		mode = {
			name = L["Mode"],
			order = 30,
			type = "select", values = {
				appfocus = L["Application Focus"],
				leader = L["Party Leader"],
			},
			get = function()
				return core.db["Chat"].mode
			end,
			set = function(_, v)
				core.db["Chat"].mode = v
				core.modules["Chat"]:CheckState()
			end,
		},
		timeout = {
			name = L["Timeout"],
			type = "range", min = 30, max = 600, step = 30,
			order = 40,
			get = function()
				return core.db["Chat"].timeout
			end,
			set = function(_, v)
				core.db["Chat"].timeout = v
			end,
		},
	},
},
Follow = {
	name = L["Follow"],
	type = "group", dialogInline = true, args = {
		help = {
			name = L["Responds to follow requests from trusted party members."],
			type = "description",
			order = 10,
		},
		enable = {
			name = L["Enable"],
			type = "toggle",
			order = 20,
			get = function()
				return core.db["Follow"].enable
			end,
			set = function(_, v)
				core.db["Follow"].enable = v
			end,
		},
		verbose = {
			name = L["Verbose"],
			type = "toggle",
			order = 30,
			get = function()
				return core.db["Follow"].verbose
			end,
			set = function(_, v)
				core.db["Follow"].verbose = v
			end,
		},
	},
},
Mount = {
	name = L["Mount"],
	type = "group", dialogInline = true, args = {
		help = {
			name = L["Summons your mount when another party member mounts."],
			type = "description",
			order = 10,
		},
		enable = {
			name = L["Enable"],
			type = "toggle",
			order = 20,
			get = function()
				return core.db["Mount"].enable
			end,
			set = function(_, v)
				core.db["Mount"].enable = v
				core.modules["Mount"]:CheckState()
			end,
		},
	},
},
Party = {
	name = L["Party"],
	type = "group", dialogInline = true, args = {
		help = {
			name = L["Responds to invite and promote requests from trusted players."],
			type = "description",
			order = 10,
		},
		enable = {
			name = L["Enable"],
			type = "toggle",
			order = 20,
			get = function()
				return core.db["Party"].enable
			end,
			set = function(_, v)
				core.db["Party"].enable = v
				core.modules["Party"]:CheckState()
			end,
		},
	},
},
Quest = {
	name = L["Quest"],
	type = "group", dialogInline = true,
	get = function(t)
		return core.db["Quest"][t[#t]]
	end,
	set = function(t, v)
		core.db["Quest"][t[#t]] = v
	end,
	args = {
		help = {
			name = L["Helps keep party members' quests in sync."],
			type = "description",
			order = 10,
		},
		turnin = {
			name = L["Turn in quests"],
			desc = L["Turn in complete quests."],
			type = "toggle",
			order = 20,
		},
		accept = {
			name = L["Accept quests"],
			desc = L["Accept quests shared by party members, quests from NPCs that other party members have already accepted, and escort-type quests started by another party member."],
			type = "toggle",
			order = 30,
		},
		share = {
			name = L["Share quests"],
			desc = L["Share quests you accept from NPCs."],
			type = "toggle",
			order = 40,
		},
		abandon = {
			name = L["Abandon quests"],
			desc = L["Abandon quests abandoned by a trusted party member."],
			type = "toggle",
			order = 50,
		},
	},
},
Taxi = {
	name = L["Taxi"],
	type = "group", dialogInline = true, args = {
		help = {
			name = L["Selects the same taxi destination as other party members."],
			type = "description",
			order = 10,
		},
		enable = {
			name = L["Enable"],
			type = "toggle",
			order = 20,
			get = function()
				return core.db["Taxi"].enable
			end,
			set = function(_, v)
				core.db["Chat"].enable = v
				core.modules["Taxi"]:CheckState()
			end,
		},
		timeout = {
			name = L["Timeout"],
			desc = L["Clear the taxi selection after this many seconds."],
			type = "range", min = 30, max = 600, step = 30,
			order = 30,
			get = function()
				return core.db["Taxi"].timeout
			end,
			set = function(_, v)
				core.db["Taxi"].timeout = v
			end,
		},
	},
}
]=]

------------------------------------------------------------------------

local about = LibStub( "LibAboutPanel" ).new( HYDRA, HYDRA )

SLASH_HYDRA1 = "/hydra"
SlashCmdList.HYDRA = function()
	InterfaceOptionsFrame_OpenToCategory( about )
	InterfaceOptionsFrame_OpenToCategory( panels[1] )
end

local LDB = LibStub("LibDataBroker-1.1", true)
if LDB then
	LDB:NewDataObject(HYDRA, {
		type = "launcher",
		icon = "Interface\\Icons\\Achievement_Boss_Bazil_Akumai",
		label = HYDRA,
		OnClick = SlashCmdList.HYDRA,
	})
end