-- #textdomain wesnoth-Gui_Debug_Tools
local _ = wesnoth.textdomain "wesnoth-Gui_Debug_Tools"

local helper = wesnoth.require "lua/helper.lua"
local utils = wesnoth.dofile "~add-ons/Gui_Debug_Tools/lua/utils.lua"
local side_ops = wesnoth.dofile "~add-ons/Gui_Debug_Tools/lua/side_ops.lua"

-- to make code shorter
local wml_actions = wesnoth.wml_actions

-- metatable for GUI tags
local T = wml.tag

-- This code is meant for use inside a [set_menu_item], because it gets the unit at x1,y1
local function side_debug ( )
	local side_unit = wesnoth.get_unit ( wesnoth.current.event_context.x1, wesnoth.current.event_context.y1 )
	if side_unit and side_unit.valid then -- to avoid indexing a nil value
		local dbg_side = wesnoth.sides[side_unit.side]
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
									id = "side_label",
									tooltip = _ "The number of the side."
								}
							}
						},
						T.row {
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.label {
									label = _ "Current Player"
								}
							},
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.label {
									id = "current_player_label",
									tooltip = _ "The name of the entity controlling the side."
								}
							}
						},
						T.row {
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.label {
									label = _ "Total Income"
								}
							},
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.label {
									id = "total_income_label",
									tooltip = _ "The total of base + village income that the side receives each turn."
								}
							}
						},
						T.row {
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.label {
									label = _ "Scroll to Leader"
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
									label = _ "S.E.T.C.",
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
									label = _ "Clear Recall"
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
									label = _ "Seed Recall"
								}
							},
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.slider {
									minimum_value = 0,
									maximum_value = 10,
									step_size = 1,
									id = "seed_recall_slider",
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
									label = _ "Heal Units"
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
									label = _ "Super Heal Units"
								}
							},
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.toggle_button {
									id = "super_heal_units_checkbutton",
									tooltip = _ "All the side's units on the map will be super healed."
								}
							}
						},
						T.row {
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.label {
									label = _ "Location"
								}
							},
							T.column {
								horizontal_grow = true,
								border = "all",
								border_size = 5,
								T.text_box {
									id = "location_textbox",
									history = "other_locations",
									tooltip = _ "All on map units of the side will be moved to the coordinates specified."
								}
							}
						},
						T.row {
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.label {
									label = _ "Goto"
								}
							},
							T.column {
								horizontal_grow = true,
								border = "all",
								border_size = 5,
								T.text_box {
									id = "goto_textbox",
									history = "other_gotos",
									tooltip = _ "All units of the side will move toward the coordinates specified. 0,0 and -999,-999 indicate no destination."
								}
							}
						},
						T.row {
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.label {
									label = _ "Kill Units"
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
									tooltip = _ "The type of entity that enters moves for the side."
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
							horizontal_grow = true,
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
								label = _ "Village Gold"
							}
						},
						T.column {
							horizontal_grow = true,
							border = "all",
							border_size = 5,
							T.slider {
								minimum_value = math.min( 0, dbg_side.village_gold ),
								maximum_value = math.max( 10, dbg_side.village_gold ),
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
								label = _ "Village Support"
							}
						},
						T.column {
							horizontal_grow = true,
							border = "all",
							border_size = 5,
							T.slider {
								minimum_value = math.min( 0, dbg_side.village_support ),
								maximum_value = math.max( 10, dbg_side.village_support ),
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
								label = _ "Base Income"
							}
						},
						T.column {
							-- vertical_grow = true,
							horizontal_grow = true,
							border = "all",
							border_size = 5,
							T.slider {
								minimum_value = math.min( -2, dbg_side.base_income ),
								maximum_value = math.max( 98, dbg_side.base_income ),
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
								label = _ "Defeat Condition"
							}
						},
						T.column {
							horizontal_grow = true,
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
							horizontal_grow = true,
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
							horizontal_grow = true,
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
								label = _ "Flag Icon"
							}
						},
						T.column {
							horizontal_grow = true,
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
								label = _ "User Team Name"
							}
						},
						T.column {
							horizontal_grow = true,
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
								label = _ "Team Name"
							}
						},
						T.column {
							horizontal_grow = true,
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
							horizontal_grow = true,
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
								label = _ "Recall Unit"
							}
						},
						T.column {
							horizontal_grow = true,
							border = "all",
							border_size = 5,
							T.text_box {
								id = "recall_unit_textbox",
								history = "other_recall_units",
								tooltip = _ "The unit with the specified ID will be recalled."
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
							label = _ "Side Debug",
							tooltip = _ "GUI Debug Tools" .. " " .. wesnoth.dofile '~add-ons/Gui_Debug_Tools/dist/version'
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
									T.grid {
										T.row {
											T.column {
												vertical_alignment = "center",
												horizontal_alignment = "center",
												border = "all",
												border_size = 5,
												T.image {
													id = "flag_image", -- flag sprite
													tooltip = _ "The flag of the side."
												}
											}
										},
										T.row {
											T.column {
												vertical_alignment = "top",
												read_only_panel
											}
										}
									}
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
			wesnoth.set_dialog_value ( string.format("%s~RC(flag_green>%s)~SCALE_INTO_SHARP(48,48)", dbg_side.flag_icon or "", wesnoth.sides[dbg_side.side].color ), "flag_image" )
			wesnoth.set_dialog_value ( dbg_side.side, "side_label" )
			wesnoth.set_dialog_value ( dbg_side.__cfg.current_player, "current_player_label" )
			wesnoth.set_dialog_value ( dbg_side.total_income, "total_income_label" )
			-- sliders
			wesnoth.set_dialog_value ( 0, "seed_recall_slider" )
			wesnoth.set_dialog_value ( dbg_side.village_gold, "side_village_gold_slider" )
			wesnoth.set_dialog_value ( dbg_side.village_support, "side_village_support_slider" )
			wesnoth.set_dialog_value ( dbg_side.base_income, "side_base_income_slider" )
			-- text boxes
			wesnoth.set_dialog_value ( "", "location_textbox" )
			wesnoth.set_dialog_value ( "", "goto_textbox" )
			wesnoth.set_dialog_value ( dbg_side.gold, "gold_textbox" )
			wesnoth.set_dialog_value ( dbg_side.defeat_condition, "defeat_condition_textbox" )
			wesnoth.set_dialog_value ( side_ops.convert_color( dbg_side.color ), "color_textbox" )
			wesnoth.set_dialog_value ( dbg_side.flag, "flag_textbox" )
			wesnoth.set_dialog_value ( dbg_side.flag_icon, "flag_icon_textbox" )
			wesnoth.set_dialog_value ( dbg_side.user_team_name, "user_team_name_textbox" )
			wesnoth.set_dialog_value ( dbg_side.team_name, "team_name_textbox" )
			wesnoth.set_dialog_value ( table.concat( dbg_side.recruit, "," ), "recruit_textbox" )
			wesnoth.set_dialog_value ( "", "recall_unit_textbox" )
			-- checkbutton
			wesnoth.set_dialog_value ( dbg_side.__cfg.suppress_end_turn_confirmation, "suppress_end_turn_confirmation_checkbutton" )
			wesnoth.set_dialog_value ( dbg_side.scroll_to_leader, "scroll_to_leader_checkbutton" )
			wesnoth.set_dialog_value ( dbg_side.fog, "fog_checkbutton" )
			wesnoth.set_dialog_value ( dbg_side.shroud, "shroud_checkbutton" )
			wesnoth.set_dialog_value ( dbg_side.hidden, "hidden_checkbutton" )
			wesnoth.set_dialog_value ( false, "clear_recall_checkbutton" )
			wesnoth.set_dialog_value ( false, "heal_units_checkbutton" )
			wesnoth.set_dialog_value ( false, "super_heal_units_checkbutton" )
			wesnoth.set_dialog_value ( false, "kill_units_checkbutton" )

			-- radiobutton
			local temp_controller

			if dbg_side.controller == "ai" then
				temp_controller = 1
			elseif dbg_side.controller == "human" then
				temp_controller = 2
			elseif dbg_side.controller == "idle" then
				temp_controller = 3
			elseif dbg_side.controller == "network" then
				temp_controller = 4
			elseif dbg_side.controller == "network_ai" then
				temp_controller = 5
			elseif dbg_side.controller == "null" then
				temp_controller = 6
			end
			wesnoth.set_dialog_value ( temp_controller, "controller_listbox" )
		end

		local function sync()
			local temp_table = { } -- to store values before checking if user allowed modifying

			local function postshow()
				-- get widget values
				-- sliders
				temp_table.seed_recall = wesnoth.get_dialog_value ( "seed_recall_slider" )
				temp_table.village_gold = wesnoth.get_dialog_value ( "side_village_gold_slider" )
				temp_table.village_support = wesnoth.get_dialog_value ( "side_village_support_slider" )
				temp_table.base_income = wesnoth.get_dialog_value ( "side_base_income_slider" )
				-- text boxes
				temp_table.location = wesnoth.get_dialog_value "location_textbox"
				temp_table.goto_xy = wesnoth.get_dialog_value "goto_textbox"
				temp_table.gold = wesnoth.get_dialog_value ( "gold_textbox" )
				temp_table.defeat_condition = wesnoth.get_dialog_value ( "defeat_condition_textbox" )
				temp_table.color = wesnoth.get_dialog_value ( "color_textbox" )
				temp_table.flag = wesnoth.get_dialog_value ( "flag_textbox" )
				temp_table.flag_icon = wesnoth.get_dialog_value ( "flag_icon_textbox" )
				temp_table.user_team_name = wesnoth.get_dialog_value ( "user_team_name_textbox" )
				temp_table.team_name = wesnoth.get_dialog_value ( "team_name_textbox" )
				temp_table.recruit = wesnoth.get_dialog_value "recruit_textbox"
				temp_table.recall_unit = wesnoth.get_dialog_value "recall_unit_textbox"
				-- checkbutton
				temp_table.suppress_end_turn_confirmation = wesnoth.get_dialog_value ( "suppress_end_turn_confirmation_checkbutton" )
				temp_table.scroll_to_leader = wesnoth.get_dialog_value ( "scroll_to_leader_checkbutton" )
				temp_table.fog = wesnoth.get_dialog_value ( "fog_checkbutton" )
				temp_table.shroud = wesnoth.get_dialog_value ( "shroud_checkbutton" )
				temp_table.hidden = wesnoth.get_dialog_value ( "hidden_checkbutton" )
				temp_table.clear_recall = wesnoth.get_dialog_value ( "clear_recall_checkbutton" )
				temp_table.heal_units = wesnoth.get_dialog_value ( "heal_units_checkbutton" )
				temp_table.super_heal_units = wesnoth.get_dialog_value ( "super_heal_units_checkbutton" )
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
			dbg_side.scroll_to_leader = temp_table.scroll_to_leader
			dbg_side.suppress_end_turn_confirmation = temp_table.suppress_end_turn_confirmation
			dbg_side.fog = temp_table.fog
			dbg_side.shroud = temp_table.shroud
			dbg_side.hidden = temp_table.hidden
			dbg_side.gold = temp_table.gold
			dbg_side.village_gold = temp_table.village_gold
			dbg_side.village_support = temp_table.village_support
			dbg_side.base_income = temp_table.base_income
			dbg_side.defeat_condition = temp_table.defeat_condition
			wesnoth.set_side_id(dbg_side.side, temp_table.flag, temp_table.color)
			dbg_side.flag_icon = temp_table.flag_icon
			dbg_side.user_team_name = temp_table.user_team_name
			dbg_side.team_name = temp_table.team_name
			dbg_side.recruit = utils.split_to_table ( temp_table.recruit )
			dbg_side.controller = temp_table.controller
			side_ops.recall_unit ( dbg_side, temp_table.recall_unit )
			side_ops.clear_recall ( dbg_side, temp_table.clear_recall )
			side_ops.seed_recall ( dbg_side, temp_table.seed_recall )
			side_ops.heal_units ( dbg_side, temp_table.heal_units )
			side_ops.super_heal_units ( dbg_side, temp_table.super_heal_units )
			side_ops.location ( dbg_side, temp_table.location )
			side_ops.goto_xy ( dbg_side, temp_table.goto_xy )
			side_ops.kill_units ( dbg_side, temp_table.kill_units )
			wml_actions.redraw ( { side = dbg_side.side } ) -- redraw to be sure of showing changes. needed for turning on fog or shroud
			wml_actions.print ( { text = _ "side debug was used during turn of " .. wesnoth.sides[wesnoth.current.side].__cfg.current_player,
				size = 24, duration = 200, color = "255,255,255" } )
		elseif return_value == 2 or return_value == -2 then -- if user pressed Cancel or Esc, nothing happens
		else wesnoth.message( tostring( _ "Side Debug" ), tostring( _ "Error, return value :" ) .. return_value ) end -- any unhandled case is handled here
		-- if user clicks on empty hex, do nothing
	end
end

side_debug()
