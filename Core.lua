--[[--------------------------------------------------------------------
	Hydra
	Multibox leveling helper.
	Written by Phanx <addons@phanx.net>
	Copyright © 2010–2012 Phanx. Some rights reserved. See LICENSE.txt for details.
	http://www.wowinterface.com/downloads/info17572-Hydra.html
	http://www.curse.com/addons/wow/hydra
----------------------------------------------------------------------]]

local HYDRA, core = ...

local L = setmetatable( core.L or { }, { __index = function( t, k )
	if k == nil then return "" end
	local v = tostring( k )
	rawset( t, k, v )
	return v
end } )
core.L = L

core.modules = { }

BINDING_HEADER_HYDRA = HYDRA

------------------------------------------------------------------------

local throttle, realmName, playerName = 0, GetRealmName(), UnitName( "player" )
local SOLO, INSECURE, SECURE, LEADER = 0, 1, 2, 3

------------------------------------------------------------------------

function core:Debug( str, ... )
	if not str or ( not self.debug and not core.debugall ) then return end
	str = tostring( str )
	if str:match( "%%[dsx%d%.]" ) then
		print( "|cffff9999Hydra:|r", str:format( ... ) )
	else
		print( "|cffff9999Hydra:|r", str, ... )
	end
end

function core:Print( str, ... )
	if str:match( "%%[dsx%d%.]" ) then
		str = str:format( ... )
	end
	print( "|cffffcc00Hydra:|r", str )
end

function core:Alert( message, flash, r, g, b )
	UIErrorsFrame:AddMessage( message, r or 1, g or 1, b or 0, 1, UIERRORS_HOLD_TIME )
end

function core:IsTrusted( name, realm )
	if ( realm and realm ~= "" and realm ~= realmName ) or name:match( "%-" ) then return end
	local trusted = core.trusted[ name ]
	self:Debug("IsTrusted", name, tostring(trusted))
	return trusted
end

local noop = function() end
function core:RegisterModule( name, module )
	assert( not self.modules[ name ], "Module %s is already registered!", name )
	if not module then module = { } end

	module.name = name
	module.CheckState = noop
	module.Alert, module.Debug, module.Print = self.Alert, self.Debug, self.Print

	self.modules[name] = module

	return module
end

function core:GetModule( name )
	local module = self.modules[name]
	assert( module, "Module %s is not registered!", name )
	return module
end

------------------------------------------------------------------------

local function copyTable( a, b )
	if not a then return { } end
	if not b then b = { } end
	for k, v in pairs( a ) do
		if type( v ) == "table" then
			b[ k ] = copyTable( v, b[ k ] )
		elseif type( v ) ~= type( b[ k ] ) then
			b[ k ] = v
		end
	end
	return b
end

local f = CreateFrame( "Frame" )
f:SetScript( "OnEvent", function( f, e, ... ) return f[ e ] and f[ e ]( f, ... ) end )
f:RegisterEvent( "PLAYER_LOGIN" )

function f:PLAYER_LOGIN()
	core:Debug( "Loading..." )
	f:UnregisterEvent( "PLAYER_LOGIN" )

	HydraTrustList = copyTable( { [ realmName ] = { [ playerName ] = playerName } }, HydraTrustList )
	core.trusted = copyTable( HydraTrustList[ realmName ] )

	HydraSettings = copyTable( { }, HydraSettings )
	core.db = HydraSettings

	for name, module in pairs( core.modules ) do
		if module.defaults then
			core:Debug( "Initializing settings for module", name )
			core.db[ name ] = copyTable( module.defaults, core.db[ name ] )
			module.db = core.db[ name ]
			for k, v in pairs( module.db ) do core:Debug( k, "=", v ) end
		end
	end

	f:RegisterEvent( "PARTY_LEADER_CHANGED" )
	f:RegisterEvent( "PARTY_MEMBERS_CHANGED" )
	f:RegisterEvent( "UNIT_NAME_UPDATE" )

	f:PARTY_LEADER_CHANGED()
end

------------------------------------------------------------------------

function f:PARTY_LEADER_CHANGED( unit )
	if unit and not unit:match( "^party%d$" ) then return end

	local newstate = SOLO
	if GetNumPartyMembers() > 0 then
		for i = 1, GetNumPartyMembers() do
			if not core:IsTrusted( UnitName( "party" .. i ) ) then
				newstate = INSECURE
				break
			end
		end
		if newstate == SOLO then
			newstate = IsPartyLeader() and LEADER or SECURE
		end
	end

	core:Debug( "Party changed:", core.state, "->", newstate )

	if newstate ~= core.state then
		core.state = newstate

		if newstate >= SECURE then
			if IsPartyLeader() and GetLootMethod() ~= "freeforall" then
				core:Debug( "Setting loot method to Free For All." )
				SetLootMethod( "freeforall" )
			end
		elseif newstate > SOLO then
			if IsPartyLeader() and GetLootMethod() == "freeforall" then
				core:Debug( "Setting loot method to Group." )
				SetLootMethod( "group" )
			end
		end

		for name, module in pairs( core.modules ) do
			core:Debug( "Checking state for module:", name )
			module:CheckState()
		end
	end
end

f.PARTY_MEMBERS_CHANGED = f.PARTY_LEADER_CHANGED
f.UNIT_NAME_UPDATE = f.PARTY_LEADER_CHANGED

------------------------------------------------------------------------

function core:TriggerEvent( event, ... )
	if f:IsEventRegistered( event ) then
		f:GetScript( "OnEvent" )( f, event, ... )
	end
end

------------------------------------------------------------------------

function core:SetupOptions(panel)
	local title, notes = LibStub("PhanxConfig-Header").CreateHeader(panel, panel.name,
		L["Hydra is a multibox leveling helper that aims to minimize the need to actively control secondary characters."])
	notes:SetHeight(notes:GetHeight() * 1.5)

	local add = LibStub("PhanxConfig-EditBox").CreateEditBox(panel, L["Add Name"], L["Add a name to your trusted list."], 12)
	add:SetPoint("TOPLEFT", notes, "BOTTOMLEFT", 0, -12)
	add:SetPoint("TOPRIGHT", notes, "BOTTOM", -8, -12)
	add.OnValueChanged = function(panel, v)
		text = v and string.gsub(string.trim(v), "%a", string.upper, 1)
		if string.len(v) > 1 then
			self:Print(L["%s has been added to your trusted list."], v)
			self.trusted[ v ] = v
			HydraTrustList[ realmName ][ v ] = v
			self:TriggerEvent("PARTY_MEMBERS_CHANGED")
		end
		panel:SetText("")
	end

	local party = LibStub("PhanxConfig-Button").CreateButton(panel, L["Add Current Party"], L["Add all the characters in your current party group to your trusted list."])
	party:SetPoint("TOPLEFT", notes, "BOTTOM", 8, -5 - add.label:GetHeight())
	party:SetPoint("TOPRIGHT", notes, "BOTTOMRIGHT", 0, -5 - add.label:GetHeight())
	party.OnClick = function(panel)
		for i = 1, GetNumPartyMembers() do
			local v = UnitName("party" .. i)
			self:Print(L["%s has been added to your trusted list."], v)
			self.trusted[ v ] = v
			HydraTrustList[ realmName ][ v ] = v
		end
		self:TriggerEvent("PARTY_MEMBERS_CHANGED")
	end

	local del = LibStub("PhanxConfig-Dropdown").CreateDropdown(panel, L["Remove Name"], nil, L["Remove a name from your trusted list."])
	del:SetPoint("TOPLEFT", add, "BOTTOMLEFT", 0, -16)
	del:SetPoint("TOPRIGHT", add, "BOTTOMRIGHT", 0, -16)
	do
		local me = UnitName("player")
		local info, temp = { }, { }
		local OnClick = function(panel)
			local v = panel.value
			self:Print(L["%s has been removed from your trusted list."], v)
			self.trusted[ v ] = nil
			HydraTrustList[ realmName ][ v ] = nil
			self:TriggerEvent("PARTY_MEMBERS_CHANGED")
		end
		UIDropDownMenu_Initialize(del.dropdown, function()
			for name in pairs(self.trusted) do
				temp[ #temp + 1 ] = name
			end
			table.sort(temp)
			for i = 1, #temp do
				local name = temp[ i ]
				info.text = name
				info.value = name
				info.func = OnClick
				info.notCheckable = 1
				info.disabled = name == me
				UIDropDownMenu_AddButton(info)
			end
			wipe(temp)
		end)
	end

	local help = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	help:SetPoint("BOTTOMLEFT", 16, 16)
	help:SetPoint("BOTTOMRIGHT", -16, 16)
	help:SetHeight(112)
	help:SetJustifyH("LEFT")
	help:SetJustifyV("BOTTOM")
	help:SetText(L.HELP_TRUST)
end