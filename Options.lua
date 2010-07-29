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
				type = "group", dialogInline = true, args = {
					help = {
						name = L["The automation module performs simple repetetive tasks, such as clicking the same choices over and over on common dialogs."],
						type = "description",
						order = 10,
					},
					duel = {
						name = L["Decline duels"],
						type = "toggle",
						order = 20,
					},
					arena = {
						name = L["Decline arena teams"],
						type = "toggle",
						order = 20,
					},
					guild = {
						name = L["Decline guilds"],
						type = "toggle",
						order = 20,
					},
					summon = {
						name = L["Accept summons"],
						type = "toggle",
						order = 20,
					},
					resurrection = {
						name = L["Accept resurrections"],
						type = "toggle",
						order = 20,
					},
					corpse = {
						name = L["Accept corpse on arrival"],
						type = "toggle",
						order = 20,
					},
					release = {
						name = L["Release spirit on death"],
						type = "toggle",
						order = 20,
					},
					repair = {
						name = L["Repair equipment"],
						type = "toggle",
						order = 20,
					},
					sell = {
						name = L["Sell junk"],
						type = "toggle",
						order = 20,
					},
				},
			},
			Chat = {
				name = L["Chat"],
				type = "group", dialogInline = true, args = {
					help = {
						name = L["The chat module forwards whispers sent to inactive characters to party chat, and forwards replies to the original sender."],
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
						name = L["The follow module responds to follow requests from trusted party members."],
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
			Mount = {
				name = L["Mount"],
				type = "group", dialogInline = true, args = {
					help = {
						name = L["The mount module summons your mount when another party member mounts."],
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
			Party = {
				name = L["Party"],
				type = "group", dialogInline = true, args = {
					help = {
						name = L["The party module responds to invite and promote commands from trusted players."],
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
						name = L["The quest module helps keep party members' quests in syncs."],
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
						name = L["The taxi module automatically selects the same destination as other party members."],
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
