-- #textdomain wesnoth-Gui_Debug_Tools
local _ = wesnoth.textdomain "wesnoth-Gui_Debug_Tools"

local helper = wesnoth.require "lua/helper.lua"
local gdt_utils = wesnoth.require "~add-ons/Gui_Debug_Tools/lua/gdt_utils.lua"

-- to make code shorter
local wml_actions = wesnoth.wml_actions

-- metatable for GUI tags
local T = helper.set_wml_tag_metatable {}

-- [gui_side_debug]
-- This tag is meant for use inside a [set_menu_item], because it gets the unit at x1,y1
function wml_actions.gui_side_debug ( cfg )
	local side_unit = wesnoth.get_units ( { x = wesnoth.current.event_context.x1, y = wesnoth.current.event_context.y1 } )[1]
	if side_unit and side_unit.valid then
		local side_number = side_unit.side -- clearly, at x1,y1 there could be only one unit

		local dialog_side = wesnoth.sides[side_number]

		-- experimenting with macrowidgets... sort of
		--buttonbox
		local buttonbox = T.grid {
					T.row {
						T.column {
							T.button {
								label = _ "OK",
								return_value = 1
							}
						},
						T.column {
							T.spacer {
								width = 10
							}
						},
						T.column {
							T.button {
								label = _ "Cancel",
								return_value = 2
							}
						}
					}
				}

		-- left side entries
		local read_only_panel = T.grid {
						T.row {
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.label {
									label = _ "Side"
								}
							},
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.label {
									id = "side_label"
								}
							}
						},
						T.row {
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.label {
									label = _ "Current player"
								}
							},
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.label {
									id = "current_player_label"
								}
							}
						},
						T.row {
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.label {
									label = _ "Name"
								}
							},
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.label {
									id = "name_label"
								}
							}
						},
						T.row {
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.label {
									label = _ "Total income"
								}
							},
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.label {
									id = "total_income_label"
								}
							}
						},
						T.row {
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.label {
									label = _ "Scroll to leader"
								}
							},
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.toggle_button {
									id = "scroll_to_leader_checkbutton",
									tooltip = _ "Makes the view scroll to the side's leader at start of side turn."
								}
							}
						},
						T.row {
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.label {
									label = _ "S.e.t.c.",
								}
							},
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.toggle_button {
									id = "suppress_end_turn_confirmation_checkbutton",
									tooltip = _ "Prevents the side from being asked to confirm ending the turn, even if no action has been taken."
								}
							}
						},
						T.row {
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.label {
									label = _ "Fog"
								}
							},
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.toggle_button {
									id = "fog_checkbutton",
									tooltip = _ "Activates fog for the side."
								}
							}
						},
						T.row {
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.label {
									label = _ "Shroud"
								}
							},
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.toggle_button {
									id = "shroud_checkbutton",
									tooltip = _ "Activates shroud for the side."
								}
							}
						},
						T.row {
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.label {
									label = _ "Hidden"
								}
							},
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.toggle_button {
									id = "hidden_checkbutton",
									tooltip = _ "Prevents the side's details from being shown in the status table."
								}
							}
						},
						T.row {
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.label {
									label = _ "Clear recall"
								}
							},
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.toggle_button {
									id = "clear_recall_checkbutton",
									tooltip = _ "All units will be removed from the side's recall list."
								}
							}
						},
						T.row {
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.label {
									label = _ "Seed recall"
								}
							},
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.toggle_button {
									id = "seed_recall_checkbutton",
									tooltip = _ "One random unit of every type on the recruit list and any advancements derived from those units will be added to the recall list."
								}
							}
						},
						T.row {
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.label {
									label = _ "Heal units"
								}
							},
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.toggle_button {
									id = "heal_units_checkbutton",
									tooltip = _ "All the side's units on the map will be healed."
								}
							}
						},
						T.row {
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.label {
									label = _ "Kill units"
								}
							},
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.toggle_button {
									id = "kill_units_checkbutton",
									tooltip = _ "All the side's units will be killed."
								}
							}
						}
					}

		-- controller radio button
		-- values here: ai, human, idle, null, network, network_ai
		local radiobutton = T.horizontal_listbox {
					id = "controller_listbox",
					T.list_definition {
						T.row {
							T.column {
								T.toggle_button {
									id = "controller_radiobutton",
									tooltip = _ "How moves for this side are inputted."
								}
							}
						}
					},
					T.list_data {
						T.row {
							horizontal_alignment = "left",
							border = "all",
							border_size = 5,
							T.column {
								label = _ "ai"
							}
						},
						T.row {
							horizontal_alignment = "left",
							border = "all",
							border_size = 5,
							T.column {
								label = _ "human"
							}
						},
						T.row {
							horizontal_alignment = "left",
							border = "all",
							border_size = 5,
							T.column {
								label = _ "idle"
							}
						},
						T.row {
							horizontal_alignment = "left",
							border = "all",
							border_size = 5,
							T.column {
								label = _ "network"
							}
						},
						T.row {
							horizontal_alignment = "left",
							border = "all",
							border_size = 5,
							T.column {
								label = _ "network_ai"
							}
						},
						T.row {
							horizontal_alignment = "left",
							border = "all",
							border_size = 5,
							T.column {
								label = _ "null"
							}
						}
					}
				}

		-- right side entries
		local modify_panel = T.grid {
					T.row {
						T.column {
							horizontal_alignment = "right",
							border = "all",
							border_size = 5,
							T.label {
								label = _ "Gold"
							}
						},
						T.column {
							vertical_grow = true,
							horizontal_grow = true,
							horizontal_alignment = "left",
							border = "all",
							border_size = 5,
							T.text_box {
								id = "gold_textbox",
								tooltip = _ "The amount of gold the side has."
							}
						}
					},
					T.row {
						T.column {
							horizontal_alignment = "right",
							border = "all",
							border_size = 5,
							T.label {
								label = _ "Village gold"
							}
						},
						T.column {
							vertical_grow = true,
							horizontal_grow = true,
							horizontal_alignment = "left",
							border = "all",
							border_size = 5,
							T.slider {
								minimum_value = math.min( 0, dialog_side.village_gold ),
								maximum_value = math.max( 10, dialog_side.village_gold ),
								step_size = 1,
								id = "side_village_gold_slider",
								tooltip = _ "Each village controlled by the side will yield this amount of income."
							}
						}
					},
					T.row {
						T.column {
							horizontal_alignment = "right",
							border = "all",
							border_size = 5,
							T.label {
								label = _ "Village support"
							}
						},
						T.column {
							vertical_grow = true,
							horizontal_grow = true,
							horizontal_alignment = "left",
							border = "all",
							border_size = 5,
							T.slider {
								minimum_value = math.min( 0, dialog_side.village_support ),
								maximum_value = math.max( 10, dialog_side.village_support ),
								step_size = 1,
								id = "side_village_support_slider",
								tooltip = _ "Each village controlled by the side will support this number of unit levels."
							}
						}
					},
					T.row {
						T.column {
							horizontal_alignment = "right",
							border = "all",
							border_size = 5,
							T.label {
								label = _ "Base income"
							}
						},
						T.column {
							vertical_grow = true,
							horizontal_grow = true,
							horizontal_alignment = "left",
							border = "all",
							border_size = 5,
							T.slider {
								minimum_value = math.min( -2, dialog_side.base_income ),
								maximum_value = math.max( 18, dialog_side.base_income ),
								step_size = 1,
								id = "side_base_income_slider",
								tooltip = _ "The amount of income the side receives per turn."
							}
						}
					},
					T.row {
						T.column {
							horizontal_alignment = "left",
							border = "all",
							border_size = 5,
							T.label {
								label = _ "Defeat condition"
							}
						},
						T.column {
							vertical_grow = true,
							horizontal_grow = true,
							horizontal_alignment = "left",
							border = "all",
							border_size = 5,
							T.text_box {
								id = "defeat_condition_textbox",
								history = "other_defeat_conditions",
								tooltip = _ "Specifies when the side is considered defeated."
							}
						}
					},
					T.row {
						T.column {
							horizontal_alignment = "right",
							border = "all",
							border_size = 5,
							T.label {
								label = _ "Color"
							}
						},
						T.column {
							vertical_grow = true,
							horizontal_grow = true,
							horizontal_alignment = "left",
							border = "all",
							border_size = 5,
							T.text_box {
								id = "color_textbox",
								history = "other_colors",
								tooltip = _ "The color that is applied to the side's flag and units."
							}
						}
					},
					T.row {
						T.column {
							horizontal_alignment = "right",
							border = "all",
							border_size = 5,
							T.label {
								label = _ "Flag"
							}
						},
						T.column {
							vertical_grow = true,
							horizontal_grow = true,
							horizontal_alignment = "left",
							border = "all",
							border_size = 5,
							T.text_box {
								id = "flag_textbox",
								history = "other_flags",
								tooltip = _ "The flag that flies over villages that the side controls."
							}
						}
					},
					T.row {
						T.column {
							horizontal_alignment = "right",
							border = "all",
							border_size = 5,
							T.label {
								label = _ "Flag icon"
							}
						},
						T.column {
							vertical_grow = true,
							horizontal_grow = true,
							horizontal_alignment = "left",
							border = "all",
							border_size = 5,
							T.text_box {
								id = "flag_icon_textbox",
								history = "other_flag_icons",
								tooltip = _ "The flag icon that is displayed next to the turn counter for the side."
							}
						}
					},
					T.row {
						T.column {
							horizontal_alignment = "right",
							border = "all",
							border_size = 5,
							T.label {
								label = _ "User team name"
							}
						},
						T.column {
							vertical_grow = true,
							horizontal_grow = true,
							horizontal_alignment = "left",
							border = "all",
							border_size = 5,
							T.text_box {
								id = "user_team_name_textbox",
								history = "other_user_team_names",
								tooltip = _ "The player visible team name for the side in the status table."
							}
						}
					},
					T.row {
						T.column {
							horizontal_alignment = "right",
							border = "all",
							border_size = 5,
							T.label {
								label = _ "Team name"
							}
						},
						T.column {
							vertical_grow = true,
							horizontal_grow = true,
							horizontal_alignment = "left",
							border = "all",
							border_size = 5,
							T.text_box {
								id = "team_name_textbox",
								history = "other_team_names",
								tooltip = _ "The player team name for the side used internally by the game."
							}
						}
					},
					T.row {
						T.column {
							horizontal_alignment = "right",
							border = "all",
							border_size = 5,
							T.label {
								label = _ "Recruit"
							}
						},
						T.column {
							vertical_grow = true,
							horizontal_grow = true,
							horizontal_alignment = "left",
							border = "all",
							border_size = 5,
							T.text_box {
								id = "recruit_textbox",
								history = "other_recruits",
								tooltip = _ "The unit types that any leader of the side can recruit."
							}
						}
					},
					T.row {
						T.column {
							horizontal_alignment = "right",
							border = "all",
							border_size = 5,
							T.label {
								label = _ "Controller"
							}
						},
						T.column {
							horizontal_alignment = "left",
							border = "all",
							border_size = 5,
							radiobutton
						}
					}
				}

		local side_dialog = {
			T.helptip { id="tooltip_large" }, -- mandatory field
			T.tooltip { id="tooltip_large" }, -- mandatory field
			maximum_height = 700,
			maximum_width = 900,
			T.grid { -- Title
				T.row {
					T.column {
						horizontal_alignment = "left",
						grow_factor = 1,
						border = "all",
						border_size = 5,
						T.label {
							definition = "title",
							label = _ "Side Debug"
						}
					}
				},
				-- Subtitile
				T.row {
					T.column {
						horizontal_alignment = "left",
						border = "all",
						border_size = 5,
						T.label {
							label = _ "Set the desired parameters, then press OK to confirm or Cancel to exit"
						}
					}
				},
				T.row {
					T.column {
						T.grid {
							T.row {
								T.column {
									vertical_alignment = "top",
									read_only_panel
								},
								T.column {
									modify_panel
								}
							}
						}
					}
				},
				T.row {
					T.column {
						buttonbox
					}
				}
			}
		}

		local function preshow()
			-- set widget values
			-- labels
			wesnoth.set_dialog_value ( dialog_side.side, "side_label" )
			wesnoth.set_dialog_value ( dialog_side.__cfg.current_player, "current_player_label" )
			wesnoth.set_dialog_value ( tostring(dialog_side.name), "name_label" ) -- name is nil in 1.13, so tostring is needed
			wesnoth.set_dialog_value ( dialog_side.total_income, "total_income_label" )
			-- sliders
			wesnoth.set_dialog_value ( dialog_side.village_gold, "side_village_gold_slider" )
			wesnoth.set_dialog_value ( dialog_side.village_support, "side_village_support_slider" )
			wesnoth.set_dialog_value ( dialog_side.base_income, "side_base_income_slider" )
			-- text boxes
			wesnoth.set_dialog_value ( dialog_side.gold, "gold_textbox" )
			wesnoth.set_dialog_value ( dialog_side.defeat_condition, "defeat_condition_textbox" )
			local color_names = { "red", "blue", "green", "purple", "black", "brown", "orange", "white", "teal" }
			local color_number = tonumber( dialog_side.color )
			if color_number then
				wesnoth.set_dialog_value ( color_names[color_number], "color_textbox" )
			else
				wesnoth.set_dialog_value ( dialog_side.color, "color_textbox" )
			end
			wesnoth.set_dialog_value ( dialog_side.flag, "flag_textbox" )
			wesnoth.set_dialog_value ( dialog_side.flag_icon, "flag_icon_textbox" )
			wesnoth.set_dialog_value ( dialog_side.user_team_name, "user_team_name_textbox" )
			wesnoth.set_dialog_value ( dialog_side.team_name, "team_name_textbox" )
			wesnoth.set_dialog_value ( table.concat( dialog_side.recruit, "," ), "recruit_textbox" )
			-- checkbutton
			wesnoth.set_dialog_value ( dialog_side.__cfg.suppress_end_turn_confirmation, "suppress_end_turn_confirmation_checkbutton" )
			wesnoth.set_dialog_value ( dialog_side.scroll_to_leader, "scroll_to_leader_checkbutton" )
			wesnoth.set_dialog_value ( dialog_side.fog, "fog_checkbutton" )
			wesnoth.set_dialog_value ( dialog_side.shroud, "shroud_checkbutton" )
			wesnoth.set_dialog_value ( dialog_side.hidden, "hidden_checkbutton" )
			wesnoth.set_dialog_value ( false, "clear_recall_checkbutton" )
			wesnoth.set_dialog_value ( false, "seed_recall_checkbutton" )
			wesnoth.set_dialog_value ( false, "heal_units_checkbutton" )
			wesnoth.set_dialog_value ( false, "kill_units_checkbutton" )

			-- radiobutton
			local temp_controller

			if dialog_side.controller == "ai" then
				temp_controller = 1
			elseif dialog_side.controller == "human" then
				temp_controller = 2
			elseif dialog_side.controller == "idle" then
				temp_controller = 3
			elseif dialog_side.controller == "network" then
				temp_controller = 4
			elseif dialog_side.controller == "network_ai" then
				temp_controller = 5
			elseif dialog_side.controller == "null" then
				temp_controller = 6
			end
			wesnoth.set_dialog_value ( temp_controller, "controller_listbox" )
		end

		local function sync()
			local temp_table = { } -- to store values before checking if user allowed modifying

			local function postshow()
				-- get widget values
				-- sliders
				temp_table.village_gold = wesnoth.get_dialog_value ( "side_village_gold_slider" )
				temp_table.village_support = wesnoth.get_dialog_value ( "side_village_support_slider" )
				temp_table.base_income = wesnoth.get_dialog_value ( "side_base_income_slider" )
				-- text boxes
				temp_table.gold = wesnoth.get_dialog_value ( "gold_textbox" )
				temp_table.defeat_condition = wesnoth.get_dialog_value ( "defeat_condition_textbox" )
				temp_table.color = wesnoth.get_dialog_value ( "color_textbox" )
				temp_table.flag = wesnoth.get_dialog_value ( "flag_textbox" )
				temp_table.flag_icon = wesnoth.get_dialog_value ( "flag_icon_textbox" )
				temp_table.user_team_name = wesnoth.get_dialog_value ( "user_team_name_textbox" )
				temp_table.team_name = wesnoth.get_dialog_value ( "team_name_textbox" )
				temp_table.recruit = wesnoth.get_dialog_value "recruit_textbox"
				-- checkbutton
				temp_table.suppress_end_turn_confirmation = wesnoth.get_dialog_value ( "suppress_end_turn_confirmation_checkbutton" )
				temp_table.scroll_to_leader = wesnoth.get_dialog_value ( "scroll_to_leader_checkbutton" )
				temp_table.fog = wesnoth.get_dialog_value ( "fog_checkbutton" )
				temp_table.shroud = wesnoth.get_dialog_value ( "shroud_checkbutton" )
				temp_table.hidden = wesnoth.get_dialog_value ( "hidden_checkbutton" )
				temp_table.clear_recall = wesnoth.get_dialog_value ( "clear_recall_checkbutton" )
				temp_table.seed_recall = wesnoth.get_dialog_value ( "seed_recall_checkbutton" )
				temp_table.heal_units = wesnoth.get_dialog_value ( "heal_units_checkbutton" )
				temp_table.kill_units = wesnoth.get_dialog_value ( "kill_units_checkbutton" )
				-- radiobutton
				local controllers = { "ai", "human", "idle", "network", "network_ai", "null" }
				temp_table.controller = controllers[ wesnoth.get_dialog_value ( "controller_listbox" ) ]
			end

			local return_value = wesnoth.show_dialog( side_dialog, preshow, postshow )

			return { return_value = return_value, { "temp_table", temp_table } }
		end
		local return_table = wesnoth.synchronize_choice(sync)
		local return_value = return_table.return_value
		local temp_table = helper.get_child(return_table, "temp_table")

		if return_value == 1 or return_value == -1 then -- if used pressed OK or Enter, modify side
			dialog_side.scroll_to_leader = temp_table.scroll_to_leader
			dialog_side.suppress_end_turn_confirmation = temp_table.suppress_end_turn_confirmation
			dialog_side.fog = temp_table.fog
			dialog_side.shroud = temp_table.shroud
			dialog_side.hidden = temp_table.hidden
			dialog_side.gold = temp_table.gold
			dialog_side.village_gold = temp_table.village_gold
			dialog_side.village_support = temp_table.village_support
			dialog_side.base_income = temp_table.base_income
			dialog_side.defeat_condition = temp_table.defeat_condition
			wesnoth.set_side_id(dialog_side.side, temp_table.flag, temp_table.color)
			dialog_side.flag_icon = temp_table.flag_icon
			dialog_side.user_team_name = temp_table.user_team_name
			dialog_side.team_name = temp_table.team_name
			-- we do this empty table/gmatch/insert cycle, because get_dialog_value returns a string from a text_box, and the value required is a "table with unnamed indices holding strings"
			-- moved here because synchronize_choice needs a WML object, and a table with unnamed indices isn't
			local temp_recruit = {}
			for value in gdt_utils.split( temp_table.recruit ) do
				table.insert( temp_recruit, gdt_utils.chop( value ) )
			end
			dialog_side.recruit = temp_recruit
			dialog_side.controller = temp_table.controller
			--clear recall list
			if temp_table.clear_recall then
				wml_actions.kill( { side = dialog_side.side, x = "recall", y = "recall" } )
			end
			--seed recall list
			if temp_table.seed_recall then
				if temp_recruit[1] ~= nil then
					local u = 1
					while temp_recruit[u] do
						if wesnoth.unit_types[temp_recruit[u]].__cfg.advances_to and wesnoth.unit_types[temp_recruit[u]].__cfg.advances_to ~= "null" then
							local advances = {}
							for value in gdt_utils.split( wesnoth.unit_types[temp_recruit[u]].__cfg.advances_to ) do
								table.insert ( advances, gdt_utils.chop( value ) )
							end
							local a = 1
							while advances[a] do
								local is_present = false
								for i = 1, #temp_recruit do
									if advances[a] == temp_recruit[i] then
										is_present = true; break
									end
								end
								if is_present == false then
									table.insert ( temp_recruit, advances[a] )
								end
								a = a + 1
							end
						end
						u = u + 1
					end
				end
				for i = 1, #temp_recruit do
					wesnoth.put_recall_unit ( { type = temp_recruit[i], side = dialog_side.side } )
				end
			end
			-- heal units
			if temp_table.heal_units then
				wml_actions.heal_unit { { "filter", { side = dialog_side.side } } }
			end
			-- kill units
			if temp_table.kill_units then
				wml_actions.kill { side = dialog_side.side, animate = true, fire_event = true }
			end
			wml_actions.redraw ( { side = dialog_side.side } ) -- redraw to be sure of showing changes. needed for turning on fog or shroud
			wml_actions.print ( { text = _ "side debug was used during turn of " .. wesnoth.sides[wesnoth.current.side].__cfg.current_player,
				size = 24, duration = 200, color = "255,255,255" } )
		elseif return_value == 2 or return_value == -2 then -- if user pressed Cancel or Esc, nothing happens
		else wesnoth.message( tostring( _ "Side Debug" ), tostring( _ "Error, return value :" ) .. return_value ) end -- any unhandled case is handled here
		-- if user clicks on empty hex, do nothing
	end
end
