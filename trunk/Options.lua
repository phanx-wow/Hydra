--[[--------------------------------------------------------------------
	HYDRA OPTIONS
----------------------------------------------------------------------]]

local AceConfigRegistry = LibStub("AceConfigRegistry-3.0", true)
local AceConfigDialog = LibStub("AceConfigDialog-3.0", true)
if not AceConfigRegistry or not AceConfigDialog then return end

local _, core = ...
local module = core:RegisterModule("Options")

------------------------------------------------------------------------

function module:CheckState()
	self:Debug("Loading options...")

	local L = setmetatable({ }, { __index = function(t, k)
		if not k then return end
		local v = tostring(k)
		t[k] = v
		return v
	end })

	local options = {
		type = "group", inline = true, args = {
			Automation = {
				name = L["Automation"],
				type = "group", dialogInline = true,
				get = function(t)
					return self.db["Automation"][t.key]
				end,
				set = function(t, v)
					self.db["Automation"][t.key] = v
					if t[#t] ~= "verbose" then
						self.modules["Automation"]:CheckState()
					end
				end,
				args = {
					help = {
						name = L["Automates simple repetetive tasks, such as clicking common dialogs."],
						type = "description",
						order = 10,
					},
					duel = {
						name = L["Decline duels"],
						type = "toggle",
						order = 20,
						key = "declineDuels",
					},
					arena = {
						name = L["Decline arena teams"],
						type = "toggle",
						order = 30,
						key = "declineArenaTeams",
					},
					guild = {
						name = L["Decline guilds"],
						type = "toggle",
						order = 40,
						key = "declineGuilds",
					},
					summon = {
						name = L["Accept summons"],
						type = "toggle",
						order = 50,
						key = "acceptSummons",
					},
					res = {
						name = L["Accept resurrections"],
						type = "toggle",
						order = 60,
						key = "acceptResurrections",
					},
					combatres = {
						name = L["Accept resurrections in combat"],
						type = "toggle",
						order = 65,
						key = "acceptResurrectionsInCombat",
					},
					corpse = {
						name = L["Accept corpse"],
						desc = L["Accept resurrection to your corpse if another party member is alive and nearby."],
						type = "toggle",
						order = 70,
						key = "acceptCorpseResurrections",
					},
					release = {
						name = L["Release spirit"],
						desc = L["Release your spirit when you die."],
						type = "toggle",
						order = 80,
						key = "releaseSpirit",
					},
					repair = {
						name = L["Repair equipment"],
						type = "toggle",
						order = 90,
						key = "repairEquipment",
					},
					sell = {
						name = L["Sell junk"],
						type = "toggle",
						order = 100,
						key = "sellJunk",
					},
					verbose = {
						name = L["Verbose mode"],
						desc = L["Print messages to the chat frame when performing any action."],
						type = "toggle",
						order = 200,
						key = "verbose",
					},
				},
			},
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
					},
					timeout = {
						name = L["Timeout"],
						type = "range", min = 30, max = 600, step = 30,
						order = 20,
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
						get = function() return self.db["Follow"].enable end,
						get = function(_, v) self.db["Follow"].enable = v end,
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
						get = function() return self.db["Mount"].enable end,
						get = function(_, v) self.db["Mount"].enable = v end,
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
					},
				},
			},
			Quest = {
				name = L["Quest"],
				type = "group", dialogInline = true, args = {
					help = {
						name = L["Helps keep party members' quests in sync."],
						type = "description",
						order = 10,
					},
					share = {
						name = L["Share quests"],
						desc = L["Share quests you accept from NPCs, accept quests shared by party members, and accept quests from NPCs that another party member already accepted."],
						type = "toggle",
						order = 20,
					},
					start = {
						name = L["Start escort quests"],
						desc = L["Start escort quests started by another party member."],
						type = "toggle",
						order = 20,
					},
					turnin = {
						name = L["Turn in complete quests"],
						desc = L["Turn in complete quests"],
						type = "toggle",
						order = 20,
					},
					abandon = {
						name = L["Abandon quests"],
						desc = L["Abandon quests abandoned by a trusted party member."],
						type = "toggle",
						order = 20,
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
					},
					timeout = {
						name = L["Timeout"],
						desc = L["Clear the taxi selection after this many seconds."],
						type = "range", min = 30, max = 600, step = 30,
						order = 20,
					},
				},
			},
		}
	}

	AceConfigRegistry:RegisterOptionsTable("Hydra", options)
	AceConfigDialog:AddToBlizOptions("Hydra")

	core.modules["Options"] = nil
	module.CheckState, module, AceConfigRegistry, AceConfigDialog = nil, nil, nil, nil
end
