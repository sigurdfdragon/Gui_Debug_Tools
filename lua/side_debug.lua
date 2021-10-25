-- #textdomain wesnoth-Gui_Debug_Tools
local _ = wesnoth.textdomain "wesnoth-Gui_Debug_Tools"

local side_ops = wesnoth.dofile "~add-ons/Gui_Debug_Tools/lua/side_ops.lua"

-- to make code shorter
local wml_actions = wesnoth.wml_actions

-- metatable for GUI tags
local T = wml.tag

-- This code is meant for use inside a [set_menu_item], because it gets the unit at x1,y1
local function side_debug ( )
	local side_unit = wesnoth.units.get ( wesnoth.current.event_context.x1, wesnoth.current.event_context.y1 )
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
									id = "side",
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
									label = _ "Starting Location"
								}
							},
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.label {
									id = "starting_location",
									tooltip = _ "The coordinates for the starting location of the side. 0,0 indicates no starting location."
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
									id = "current_player",
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
									label = _ "Is Local"
								}
							},
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.label {
									id = "is_local",
									tooltip = _ "Indicates if the current instance of Wesnoth owns the side."
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
									id = "total_income",
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
									id = "scroll_to_leader",
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
									id = "suppress_end_turn_confirmation",
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
									id = "fog",
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
									id = "shroud",
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
									id = "hidden",
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
									label = _ "Seed Recall"
								}
							},
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.slider {
									minimum_value = -1,
									maximum_value = 10,
									minimum_value_label = _ "Clear",
									step_size = 1,
									id = "seed_recall",
									tooltip = _ "The recall list will be stocked with sets of recruits and their advancements, or the recall list can be cleared."
								}
							}
						},
						T.row {
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.label {
									label = _ "Heal"
								}
							},
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.toggle_button {
									id = "heal",
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
									label = _ "Super Heal"
								}
							},
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.toggle_button {
									id = "super_heal",
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
									label = _ "Teleport"
								}
							},
							T.column {
								horizontal_grow = true,
								border = "all",
								border_size = 5,
								T.text_box {
									id = "teleport",
									history = "other_teleports",
									tooltip = _ "All on map units of the side will be placed at the coordinates specified. Single space places all non-leaders on the recall list."
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
									id = "goto_xy",
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
									label = _ "Kill"
								}
							},
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.toggle_button {
									id = "kill",
									tooltip = _ "All the side's units will be killed."
								}
							}
						}
					}

		-- controller radio button
		-- values here: human, ai, null
		local radiobutton = T.horizontal_listbox {
					id = "controller",
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
								label = _ "human" .. "     " -- added strings are a hack so the buttons aren't too close together 5 spaces each
							}
						},
						T.row {
							horizontal_alignment = "left",
							border = "all",
							border_size = 5,
							T.column {
								label = _ "ai" .. "     "
							}
						},
						T.row {
							horizontal_alignment = "left",
							border = "all",
							border_size = 5,
							T.column {
								label = _ "null" .. "     "
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
								id = "gold",
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
								id = "village_gold",
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
								id = "village_support",
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
								id = "base_income",
								tooltip = _ "The amount of income the side receives per turn."
							}
						}
					},
					T.row {
						T.column {
							horizontal_alignment = "right",
							border = "all",
							border_size = 5,
							T.label {
								label = _ "Recall Cost"
							}
						},
						T.column {
							-- vertical_grow = true,
							horizontal_grow = true,
							border = "all",
							border_size = 5,
							T.slider {
								minimum_value = 0,
								maximum_value = 100,
								step_size = 1,
								id = "recall_cost",
								tooltip = _ "The amount of gold needed to recall units of this side."
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
								id = "defeat_condition",
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
								id = "color",
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
								id = "flag",
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
								id = "flag_icon",
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
								id = "user_team_name",
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
								id = "team_name",
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
								id = "recruit",
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
								label = _ "Recall Units"
							}
						},
						T.column {
							horizontal_grow = true,
							border = "all",
							border_size = 5,
							T.text_box {
								id = "recall_units",
								history = "other_recall_units",
								tooltip = _ "The units with the specified IDs will be recalled."
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

		local dialog = {
			T.helptip { id="tooltip_large" }, -- mandatory field
			T.tooltip { id="tooltip_large" }, -- mandatory field
			maximum_height = 700,
			maximum_width = 1000,
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
							tooltip = _ "Allows changes to various aspects of a side."
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
													id = "image", -- flag sprite
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

		local function preshow ( dialog )
			-- set widget values
			-- labels
			dialog.image.label = string.format("%s~RC(flag_green>%s)~SCALE_INTO_SHARP(48,48)", dbg_side.flag_icon or "", wesnoth.sides[dbg_side.side].color )
			dialog.side.label = dbg_side.side
			dialog.starting_location.label = stringx.join( dbg_side.starting_location or { 0, 0 } )
			dialog.current_player.label = dbg_side.__cfg.current_player
			dialog.is_local.label = dbg_side.is_local
			dialog.total_income.label = dbg_side.total_income
			-- sliders
			dialog.seed_recall.value = 0
			dialog.village_gold.value = dbg_side.village_gold
			dialog.village_support.value = dbg_side.village_support
			dialog.base_income.value = dbg_side.base_income
			dialog.recall_cost.value = dbg_side.recall_cost
			-- text boxes
			dialog.teleport.text = ""
			dialog.goto_xy.text = ""
			dialog.gold.text = dbg_side.gold
			dialog.defeat_condition.text = dbg_side.defeat_condition
			dialog.color.text = side_ops.convert_color( dbg_side.color )
			dialog.flag.text = dbg_side.flag
			dialog.flag_icon.text = dbg_side.flag_icon
			dialog.user_team_name.text = tostring(dbg_side.user_team_name)
			dialog.team_name.text = dbg_side.team_name
			dialog.recruit.text = stringx.join( dbg_side.recruit )
			dialog.recall_units.text = ""
			-- checkbutton
			dialog.suppress_end_turn_confirmation.selected = dbg_side.__cfg.suppress_end_turn_confirmation
			dialog.scroll_to_leader.selected = dbg_side.scroll_to_leader
			dialog.fog.selected = dbg_side.fog
			dialog.shroud.selected = dbg_side.shroud
			dialog.hidden.selected = dbg_side.hidden
			dialog.heal.selected = false
			dialog.super_heal.selected = false
			dialog.kill.selected = false

			-- radiobutton
			local temp_controller

			if dbg_side.controller == "human" then
				temp_controller = 1
			elseif dbg_side.controller == "ai" then
				temp_controller = 2
			elseif dbg_side.controller == "null" then
				temp_controller = 3
			end
			dialog.controller.selected_index = temp_controller
		end

		local function sync()
			local temp_table = { } -- to store values before checking if user allowed modifying

			local function postshow ( dialog )
				-- get widget values
				-- sliders
				temp_table.seed_recall = dialog.seed_recall.value
				temp_table.village_gold = dialog.village_gold.value
				temp_table.village_support = dialog.village_support.value
				temp_table.base_income = dialog.base_income.value
				temp_table.recall_cost = dialog.recall_cost.value
				-- text boxes
				temp_table.teleport = dialog.teleport.text
				temp_table.goto_xy = dialog.goto_xy.text
				temp_table.gold = dialog.gold.text
				temp_table.defeat_condition = dialog.defeat_condition.text
				temp_table.color = dialog.color.text
				temp_table.flag = dialog.flag.text
				temp_table.flag_icon = dialog.flag_icon.text
				temp_table.user_team_name = dialog.user_team_name.text
				temp_table.team_name = dialog.team_name.text
				temp_table.recruit = dialog.recruit.text
				temp_table.recall_units = dialog.recall_units.text
				-- checkbutton
				temp_table.suppress_end_turn_confirmation = dialog.suppress_end_turn_confirmation.selected
				temp_table.scroll_to_leader = dialog.scroll_to_leader.selected
				temp_table.fog = dialog.fog.selected
				temp_table.shroud = dialog.shroud.selected
				temp_table.hidden = dialog.hidden.selected
				temp_table.heal = dialog.heal.selected
				temp_table.super_heal = dialog.super_heal.selected
				temp_table.kill = dialog.kill.selected
				-- radiobutton
				local controllers = { "human", "ai", "null" }
				temp_table.controller = controllers[ dialog.controller.selected_index ]
			end

			local return_value = gui.show_dialog( dialog, preshow, postshow )

			return { return_value = return_value, { "temp_table", temp_table } }
		end
		local return_table = wesnoth.sync.evaluate_single(sync)
		local return_value = return_table.return_value
		local temp_table = wml.get_child(return_table, "temp_table")

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
			dbg_side.recall_cost = temp_table.recall_cost
			dbg_side.defeat_condition = temp_table.defeat_condition
			wesnoth.sides.set_id(dbg_side.side, temp_table.flag, temp_table.color)
			dbg_side.flag_icon = temp_table.flag_icon
			dbg_side.user_team_name = temp_table.user_team_name
			dbg_side.team_name = temp_table.team_name
			dbg_side.recruit = stringx.split ( temp_table.recruit )
			dbg_side.controller = temp_table.controller
			side_ops.recall_units ( dbg_side, temp_table.recall_units )
			side_ops.seed_recall ( dbg_side, temp_table.seed_recall )
			side_ops.heal ( dbg_side, temp_table.heal )
			side_ops.super_heal ( dbg_side, temp_table.super_heal )
			side_ops.teleport ( dbg_side, temp_table.teleport )
			side_ops.goto_xy ( dbg_side, temp_table.goto_xy )
			side_ops.kill ( dbg_side, temp_table.kill )
			wml_actions.redraw ( { side = dbg_side.side } ) -- redraw to be sure of showing changes. needed for turning on fog or shroud
			wml_actions.print ( { text = _ "side debug was used during turn of " .. wesnoth.sides[wesnoth.current.side].__cfg.current_player,
				size = 24, duration = 200, color = "255,255,255" } )
		elseif return_value == 2 or return_value == -2 then -- if user pressed Cancel or Esc, nothing happens
		else wesnoth.interface.add_chat_message ( tostring( _ "Side Debug" ), tostring( _ "Error, return value :" ) .. return_value ) end -- any unhandled case is handled here
		-- if user clicks on empty hex, do nothing
	end
end

side_debug()
