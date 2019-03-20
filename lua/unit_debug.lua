-- #textdomain wesnoth-Gui_Debug_Tools
local _ = wesnoth.textdomain "wesnoth-Gui_Debug_Tools"

local helper = wesnoth.require "lua/helper.lua"
local utils = wesnoth.dofile "~add-ons/Gui_Debug_Tools/lua/utils.lua"
local unit_ops = wesnoth.dofile "~add-ons/Gui_Debug_Tools/lua/unit_utils.lua"

-- to make code shorter
local wml_actions = wesnoth.wml_actions

-- metatable for GUI tags
local T = wml.tag

-- This code is meant for use inside a [set_menu_item], because it gets the unit at x1,y1
local function unit_debug ( )
	local dbg_unit = wesnoth.get_unit ( wesnoth.current.event_context.x1, wesnoth.current.event_context.y1 )
	if dbg_unit and dbg_unit.valid then -- to avoid indexing a nil value
		local oversize_factor = 10 -- make it possible to increase over unit.max_attacks; no idea what would be a sensible value
		--creating dialog here
		-- right side entries
		local read_only_panel = T.grid {
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
								T.text_box {
									id = "textbox_unit_name",
									history = "other_names",
									tooltip = _ "The player visible name of the unit."
								}
							}
						},
						T.row {
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.label {
									label = _ "ID"
								}
							},
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.text_box {
									id = "textbox_unit_id",
									history = "other_ids",
									tooltip = _ "The internal WML designation for the unit. Each unit ID needs to be unique."
								}
							}
						},
						T.row {
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.label {
									label = _ "Underlying ID"
								}
							},
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.label {
									id = "underlying_id_label",
									tooltip = _ "The internal C++ designation for the unit."
								}
							}
						},
						T.row {
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.label {
									label = _ "Level"
								}
							},
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.slider {
									minimum_value = 0,
									maximum_value = math.max(10, dbg_unit.level + 5),
									step_size = 1,
									id = "unit_level_slider",
									tooltip = _ "The unit will be advanced or declined to the specified level."
								}
							}
						},
						T.row {
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.label {
									label = _ "Type"
								}
							},
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.text_box {
									id = "textbox_unit_type",
									history = "other_types",
									tooltip = _ "What kind of unit this is."
								}
							}
						},
						T.row {
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.label {
									label = _ "Variation"
								}
							},
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.text_box {
									id = "textbox_unit_variation",
									history = "other_variations",
									tooltip = _ "The variation of the unit type that this unit is."
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
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.text_box { --unit.x
									id = "textbox_unit_location",
									history = "other_locations",
									tooltip = _ "The coordinates on the map where the unit is located. Empty string places the unit on the recall list."
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
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.text_box { --unit.x
									id = "textbox_unit_goto",
									history = "other_gotos",
									tooltip = _ "The unit will move toward the coordinates specified. 0,0 and -999,-999 indicate no destination."
								}
							}
						},
						T.row {
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.label {
									label = _ "Upkeep"
								}
							},
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.text_box {
									id = "textbox_unit_upkeep",
									history = "other_upkeeps",
									tooltip = _ "The unit will have the upkeep specified."
								}
							}
						},
						T.row {
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.label {
									label = _ "Can Recruit"
								}
							},
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.toggle_button {
									id = "canrecruit_checkbutton",
									tooltip = _ "Makes the unit a leader and able to recruit."
								}
							}
						},
						T.row {
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.label {
									label = _ "Unrenamable"
								}
							},
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.toggle_button {
									id = "unrenamable_checkbutton",
									tooltip = _ "Prevents changing the unit's name in the right click menu."
								}
							}
						},
						T.row {
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.label {
									label = _ "Generate Name"
								}
							},
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.toggle_button {
									id = "generate_name_checkbutton",
									tooltip = _ "If the unit type has random names available, a new name will be generated."
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
									id = "heal_unit_checkbutton",
									tooltip = _ "The unit will be healed with moves restored, regardless of other settings in this dialog."
								}
							}
						},
						T.row {
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.label {
									label = _ "Copy"
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
									id = "unit_copy_slider",
									tooltip = _ "Copies of the unit will be created. Will be identical except for id and name."
								}
							}
						}
					}

		local status_checkbuttons = T.grid {
						T.row {
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.toggle_button {
									label = _ "Poisoned",
									id = "poisoned_checkbutton",
									tooltip = _ "The unit loses HP each turn."
								}
							},
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.toggle_button {
									label = _ "Slowed",
									id = "slowed_checkbutton",
									tooltip = _ "The unit has 50% of its normal movement and does half damage."
								}
							},
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.toggle_button {
									label = _ "Petrified",
									id = "petrified_checkbutton",
									tooltip = _ "The unit cannot move, attack, or be attacked."
								}
							},
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.toggle_button {
									label = _ "Invulnerable",
									id = "invulnerable_checkbutton",
									tooltip = _ "Attacks can't hit the unit."
								}
							}
						},
						T.row {
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.toggle_button {
									label = _ "Uncovered",
									id = "uncovered_checkbutton",
									tooltip = _ "The unit has performed an action (e.g. attacking) that causes it to no longer be hidden until the next turn."
								}
							},
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.toggle_button {
									label = _ "Guardian",
									id = "guardian_checkbutton",
									tooltip = _ "The unit will not move, except to attack something in immediate range."
								}
							},
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.toggle_button {
									label = _ "Unhealable",
									id = "unhealable_checkbutton",
									tooltip = _ "The unit cannot be healed."
								}
							},
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.toggle_button {
									label = _ "Stunned",
									id = "stunned_checkbutton",
									tooltip = _ "The unit has lost its zone of control until next turn. This status is only available in some campaigns and add-ons."
								}
							}
						},
						T.row {
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.toggle_button {
									label = _ "Not Living",
									id = "not_living_checkbutton",
									tooltip = _ "If checked, the unit will gain undrainable, unplagueable, and unpoisonable. If those three are checked, the unit will gain not_living"
								}
							},
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.toggle_button {
									label = _ "Undrainable",
									id = "undrainable_checkbutton",
									tooltip = _ "The unit will not give life to another unit if the drain special is used against it."
								}
							},
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.toggle_button {
									label = _ "Unplagueable",
									id = "unplagueable_checkbutton",
									tooltip = _ "The unit is immune to the plague special."
								}
							},
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.toggle_button {
									label = _ "Unpoisonable",
									id = "unpoisonable_checkbutton",
									tooltip = _ "The unit cannot be poisoned."
								}
							}
						}
					}


		local facing_radiobutton = T.horizontal_listbox {
						id = "facing_listbox",
						T.list_definition {
							T.row {
								T.column {
									T.toggle_button {
										id = "facing_radiobutton",
										tooltip = _ "Which way the unit is looking."
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
									label = _ "nw"
								}
							},
							T.row {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.column {
									label = _ "ne"
								}
							},
							T.row {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.column {
									label = _ "n"
								}
							},
							T.row {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.column {
									label = _ "sw"
								}
							},
							T.row {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.column {
									label = _ "se"
								}
							},
							T.row {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.column {
									label = _ "s"
								}
							}
						}
					}


		local misc_checkbuttons = T.grid {
						T.row {
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.toggle_button {
									label = _ "Resting",
									id = "resting_checkbutton", --unit.resting
									tooltip = _ "If the unit is resting, it will receive rest healing at the start of its next turn."
								}
							},
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.toggle_button {
									label = _ "Hidden",
									id = "hidden_checkbutton", --unit.hidden
									tooltip = _ "If the unit has been hidden using [hide_unit]. This is not the same as a [hides] ability."
								}
							}
						}
					}


		local gender_radiobutton = T.horizontal_listbox {
						id = "gender_listbox",
						T.list_definition {
							T.row {
								T.column {
									T.toggle_button {
										id = "gender_radiobutton",
										tooltip = _ "The gender of the unit. Note that changing gender will cause any custom profile portraits to be lost."
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
									label = _ "Male"
								}
							},
							T.row {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.column {
									label = _ "Female"
								}
							}
						}
					}

		-- buttonbox
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

		-- right side entries
		local modify_panel = T.grid { -- side slider
					T.row {
						T.column {
							horizontal_alignment = "right",
							border = "all",
							border_size = 5,
							T.label {
								label = _ "Side"
							}
						},
						T.column {
							horizontal_grow = true,
							border = "all",
							border_size = 5,
							T.slider {
								minimum_value = 1,
								maximum_value = #wesnoth.sides,
								step_size = 1,
								id = "unit_side_slider", --unit.side
								tooltip = _ "The side the unit belongs to."
							}
						}
					},
					-- hitpoints slider
					T.row {
						T.column {
							horizontal_alignment = "right",
							border = "all",
							border_size = 5,
							T.label {
								label = _ "Hitpoints"
							}
						},
						T.column {
							horizontal_grow = true,
							border = "all",
							border_size = 5,
							T.slider {
								minimum_value = math.min(1, dbg_unit.hitpoints),
								maximum_value = math.max(dbg_unit.max_hitpoints * oversize_factor, dbg_unit.hitpoints),
								--minimum_value_label = _ "Kill",
								--maximum_value_label = _ "Full health",
								step_size = 1,
								id = "unit_hitpoints_slider", --unit.hitpoints
								tooltip = _ "The amount of hitpoints the unit has."
							}
						}
					},
					-- experience slider
					T.row {
						T.column {
							horizontal_alignment = "right",
							border = "all",
							border_size = 5,
							T.label {
								label = _ "Experience"
							}
						},
						T.column {
							horizontal_grow = true,
							border = "all",
							border_size = 5,
							T.slider {
								minimum_value = math.min(0, dbg_unit.experience),
								maximum_value = math.max(dbg_unit.max_experience * oversize_factor, dbg_unit.experience),
								--maximum_value_label = _ "Level up",
								step_size = 1,
								id = "unit_experience_slider", --unit.experience
								tooltip = _ "The amount of experience the unit has. If the value is over the unit's max experience, the unit will level."
							}
						}
					},
					-- moves slider
					T.row {
						T.column {
							horizontal_alignment = "right",
							border = "all",
							border_size = 5,
							T.label {
								label = _ "Moves"
							}
						},
						T.column {
							horizontal_grow = true,
							border = "all",
							border_size = 5,
							T.slider {
								minimum_value = 0,
								-- to avoid crashing if max_moves == 0
								maximum_value = math.max(100, dbg_unit.max_moves * oversize_factor, dbg_unit.moves),
								step_size = 1,
								id = "unit_moves_slider", --unit.moves
								tooltip = _ "The amount of move points the unit has."
							}
						}
					},
					-- attacks slider
					T.row {
						T.column {
							horizontal_alignment = "right",
							border = "all",
							border_size = 5,
							T.label {
								label = _ "Attacks Left"
							}
						},
						T.column {
							horizontal_grow = true,
							border = "all",
							border_size = 5,
							T.slider {
								minimum_value = 0,
								-- to avoid crashing if unit has max_attacks == 0
								maximum_value = math.max(1, dbg_unit.max_attacks * oversize_factor, dbg_unit.attacks_left),
								step_size = 1,
								id = "unit_attacks_slider", --unit.attacks_left
								tooltip = _ "The number of attacks the unit can make on the current turn."
							}
						}
					},
					-- amla slider
					T.row {
						T.column {
							horizontal_alignment = "right",
							border = "all",
							border_size = 5,
							T.label {
								label = _ "Amla"
							}
						},
						T.column {
							horizontal_grow = true,
							border = "all",
							border_size = 5,
							T.slider {
								minimum_value = 0,
								maximum_value = 100,
								step_size = 1,
								id = "unit_amla_slider",
								tooltip = _ "If the unit is at the maximum level, this number of amlas will be applied."
							}
						}
					},
					-- extra recruit
					T.row {
						T.column {
							horizontal_alignment = "right",
							border = "all",
							border_size = 5,
							T.label {
								label = _ "Extra Recruit"
							}
						},
						T.column {
							horizontal_grow = true,
							border = "all",
							border_size = 5,
							T.text_box {
								id = "textbox_extra_recruit", --unit.extra_recruit
								history = "other_recruits",
								tooltip = _ "Unit types the unit can recruit in addition to the ones its side can recruit, if the unit is a leader."
							}
						}
					},
					-- advances to
					T.row {
						T.column {
							horizontal_alignment = "right",
							border = "all",
							border_size = 5,
							T.label {
								label = _ "Advances To"
							}
						},
						T.column {
							horizontal_grow = true,
							border = "all",
							border_size = 5,
							T.text_box {
								id = "textbox_advances_to", --unit.advances_to
								history = "other_advancements",
								tooltip = _ "The unit types that the unit can advance to upon leveling."
							}
						}
					},
					-- role
					T.row {
						T.column {
							horizontal_alignment = "right",
							border = "all",
							border_size = 5,
							T.label {
								label = _ "Role"
							}
						},
						T.column {
							horizontal_grow = true,
							border = "all",
							border_size = 5,
							T.text_box {
								id = "textbox_role", --unit.role
								history = "other_roles",
								tooltip = _ "An additional field that can be used to identify a unit."
							}
						}
					},
					-- attack
					T.row {
						T.column {
							horizontal_alignment = "right",
							border = "all",
							border_size = 5,
							T.label {
								label = _ "Attack"
							}
						},
						T.column {
							horizontal_grow = true,
							border = "all",
							border_size = 5,
							T.text_box {
								id = "textbox_attack",
								history = "other_attack",
								tooltip = _ "The unit will receive the attack indicated. Use form 'Unit Type,Attack Index'. Single space clears added attacks."
							}
						}
					},
					-- abilities
					T.row {
						T.column {
							horizontal_alignment = "right",
							border = "all",
							border_size = 5,
							T.label {
								label = _ "Abilities"
							}
						},
						T.column {
							horizontal_grow = true,
							border = "all",
							border_size = 5,
							T.text_box {
								id = "textbox_abilities",
								history = "other_abilities",
								tooltip = _ "The unit will receive the abilities of the unit types entered. Single space clears added abilities."
							}
						}
					},
					-- modifications
					T.row {
						T.column {
							horizontal_alignment = "right",
							border = "all",
							border_size = 5,
							T.label {
								label = _ "Modifications"
							}
						},
						T.column {
							horizontal_grow = true,
							border = "all",
							border_size = 5,
							T.text_box {
								id = "textbox_modifications",
								history = "other_modifications",
								tooltip = _ "Copy: 'Unit Id,Mod Type,Index' - Remove: 'remove,Mod Type,Index' - Single space clears all objects and advancements."
							}
						}
					},
					-- traits
					T.row {
						T.column {
							horizontal_alignment = "right",
							border = "all",
							border_size = 5,
							T.label {
								label = _ "Traits"
							}
						},
						T.column {
							horizontal_grow = true,
							border = "all",
							border_size = 5,
							T.text_box {
								id = "textbox_traits",
								history = "other_traits",
								tooltip = _ "The unit will be altered by the traits listed. Valid traits are all in mainline, and any the unit could receive or currently has."
							}
						}
					},
					-- overlays
					T.row {
						T.column {
							horizontal_alignment = "right",
							border = "all",
							border_size = 5,
							T.label {
								label = _ "Overlays"
							}
						},
						T.column {
							horizontal_grow = true,
							border = "all",
							border_size = 5,
							T.text_box {
								id = "textbox_overlays",
								history = "other_overlays",
								tooltip = _ "The unit's image will be altered by overlays listed here."
							}
						}
					},
					-- variables
					T.row {
						T.column {
							horizontal_alignment = "right",
							border = "all",
							border_size = 5,
							T.label {
								label = _ "Variables"
							}
						},
						T.column {
							horizontal_grow = true,
							border = "all",
							border_size = 5,
							T.text_box {
								id = "textbox_variables",
								history = "other_variables",
								tooltip = _ "Unit variables and sub-containers can be set/changed using the form 'var=value'"
							}
						}
					},
					-- gender
					T.row {
						T.column {
							horizontal_alignment = "right",
							border = "all",
							border_size = 5,
							T.label {
								label = _ "Gender"
							}
						},
						T.column {
							horizontal_alignment = "left",
							border = "all",
							border_size = 5,
							gender_radiobutton
						}
					},
					-- statuses
					T.row {
						T.column {
							horizontal_alignment = "right",
							border = "all",
							border_size = 5,
							T.label {
								label = _ "Status"
							}
						},
						T.column {
							horizontal_alignment = "left",
							status_checkbuttons
						}
					},
					-- facing
					T.row {
						T.column {
							horizontal_alignment = "right",
							border = "all",
							border_size = 5,
							T.label {
								label = _ "Facing"
							}
						},
						T.column {
							horizontal_alignment = "left",
							border = "all",
							border_size = 5,
							facing_radiobutton
						}
					},
					-- misc
					T.row {
						T.column {
							horizontal_alignment = "right",
							border = "all",
							border_size = 5,
							T.label {
								label = _ "Misc"
							}
						},
						T.column {
							horizontal_alignment = "left",
							misc_checkbuttons
						}
					}
				}

		local debug_dialog = {
			T.helptip { id="tooltip_large" }, -- mandatory field
			T.tooltip { id="tooltip_large" }, -- mandatory field
			maximum_height = 840,
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
							label = _ "Unit Debug",
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
				-- non-modifiable proxies, melinath's layout
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
													id = "unit_image", -- unit sprite
													tooltip = _ "The image of the unit."
												}
											}
										},
										T.row {
											vertical_alignment = "bottom",
											T.column {
												vertical_alignment = "center",
												horizontal_alignment = "center",
												border = "all",
												border_size = 5,
												T.button {
													id = "unit_profile_button",
													label = _ "Profile",
													tooltip = _ "Displays the help entry for the unit."
												}
											}
										},
										T.row {
											T.column {
												read_only_panel
											}
										}
									}
								},
								-- modification part
								T.column {
									modify_panel
								}
							}
						}
					}
				},
				-- button box
				T.row {
					T.column {
						buttonbox
					}
				}
			}
		}

		local temp_table = { } -- to store values before checking if user allowed modifying

		--note that the help won't show up if you haven't discovered that unit yet.
		local unit_profile = function()
			wesnoth.wml_actions.open_help ( {topic = [[unit_]] .. dbg_unit.type} ) -- Literal string needed here or .po will have an error.
		end
		
		local function preshow()
			-- here set all widget starting values
			-- set read_only labels
			wesnoth.set_dialog_value ( string.format("%s~RC(magenta>%s)~SCALE_INTO_SHARP(144,144)", dbg_unit.__cfg.image or "", wesnoth.sides[dbg_unit.side].color ), "unit_image" )
			wesnoth.set_dialog_callback ( unit_profile, "unit_profile_button" )
			wesnoth.set_dialog_value ( dbg_unit.__cfg.underlying_id, "underlying_id_label" )
			-- set sliders
			wesnoth.set_dialog_value ( dbg_unit.level, "unit_level_slider" )
			wesnoth.set_dialog_value ( 0, "unit_copy_slider" )
			wesnoth.set_dialog_value ( dbg_unit.side, "unit_side_slider" )
			wesnoth.set_dialog_value ( dbg_unit.hitpoints, "unit_hitpoints_slider" )
			wesnoth.set_dialog_value ( dbg_unit.experience, "unit_experience_slider" )
			wesnoth.set_dialog_value ( dbg_unit.moves, "unit_moves_slider" )
			wesnoth.set_dialog_value ( dbg_unit.attacks_left, "unit_attacks_slider" )
			wesnoth.set_dialog_value ( 0, "unit_amla_slider" )
			-- set textboxes
			wesnoth.set_dialog_value ( dbg_unit.x .. "," .. dbg_unit.y, "textbox_unit_location" )
			wesnoth.set_dialog_value ( dbg_unit.__cfg.goto_x .. "," .. dbg_unit.__cfg.goto_y, "textbox_unit_goto" )
			wesnoth.set_dialog_value ( dbg_unit.upkeep, "textbox_unit_upkeep" )
			wesnoth.set_dialog_value ( dbg_unit.id, "textbox_unit_id" )
			wesnoth.set_dialog_value ( dbg_unit.type, "textbox_unit_type" )
			wesnoth.set_dialog_value ( dbg_unit.__cfg.variation, "textbox_unit_variation" )
			wesnoth.set_dialog_value ( dbg_unit.name, "textbox_unit_name" )
			wesnoth.set_dialog_value ( table.concat( dbg_unit.extra_recruit, "," ), "textbox_extra_recruit" )
			wesnoth.set_dialog_value ( table.concat( dbg_unit.advances_to, "," ), "textbox_advances_to" )
			wesnoth.set_dialog_value ( dbg_unit.role, "textbox_role" )
			wesnoth.set_dialog_value ( "", "textbox_attack" )
			wesnoth.set_dialog_value ( "", "textbox_abilities" )
			wesnoth.set_dialog_value ( "", "textbox_modifications" )
			wesnoth.set_dialog_value ( unit_ops.get_traits_string ( dbg_unit ), "textbox_traits" )
			wesnoth.set_dialog_value ( dbg_unit.__cfg.overlays, "textbox_overlays" )
			wesnoth.set_dialog_value ( "", "textbox_variables" )
			-- set checkbuttons
			wesnoth.set_dialog_value ( dbg_unit.canrecruit, "canrecruit_checkbutton" )
			wesnoth.set_dialog_value ( dbg_unit.__cfg.unrenamable, "unrenamable_checkbutton" )
			wesnoth.set_dialog_value ( false, "generate_name_checkbutton" )
			wesnoth.set_dialog_value ( false, "heal_unit_checkbutton" )
			wesnoth.set_dialog_value ( dbg_unit.status.poisoned, "poisoned_checkbutton" )
			wesnoth.set_dialog_value ( dbg_unit.status.slowed, "slowed_checkbutton" )
			wesnoth.set_dialog_value ( dbg_unit.status.petrified, "petrified_checkbutton" )
			wesnoth.set_dialog_value ( dbg_unit.status.invulnerable, "invulnerable_checkbutton" )
			wesnoth.set_dialog_value ( dbg_unit.status.uncovered, "uncovered_checkbutton" )
			wesnoth.set_dialog_value ( dbg_unit.status.guardian, "guardian_checkbutton" )
			wesnoth.set_dialog_value ( dbg_unit.status.unhealable, "unhealable_checkbutton" )
			wesnoth.set_dialog_value ( dbg_unit.status.stunned, "stunned_checkbutton" )
			wesnoth.set_dialog_value ( dbg_unit.status.not_living, "not_living_checkbutton" )
			wesnoth.set_dialog_value ( dbg_unit.status.undrainable, "undrainable_checkbutton" )
			wesnoth.set_dialog_value ( dbg_unit.status.unplagueable, "unplagueable_checkbutton" )
			wesnoth.set_dialog_value ( dbg_unit.status.unpoisonable, "unpoisonable_checkbutton" )
			-- set radiobutton for facing
			local temp_facing
			if dbg_unit.facing == "nw" then temp_facing = 1
			elseif dbg_unit.facing == "ne" then temp_facing = 2
			elseif dbg_unit.facing == "n" then temp_facing = 3
			elseif dbg_unit.facing == "sw" then temp_facing = 4
			elseif dbg_unit.facing == "se" then temp_facing = 5
			elseif dbg_unit.facing == "s" then temp_facing = 6
			end
			wesnoth.set_dialog_value ( temp_facing, "facing_listbox" )
			-- other checkbuttons
			wesnoth.set_dialog_value ( dbg_unit.resting, "resting_checkbutton" )
			wesnoth.set_dialog_value ( dbg_unit.hidden, "hidden_checkbutton" )
			-- set radiobutton for gender
			local temp_gender
			if dbg_unit.__cfg.gender == "male" then temp_gender = 1
			elseif dbg_unit.__cfg.gender == "female" then temp_gender = 2
			end
			wesnoth.set_dialog_value ( temp_gender, "gender_listbox" )
		end

		local function sync()
			local temp_table = { } -- to store values before checking if user allowed modifying

			local function postshow()
				-- here get all the widget values in variables; store them in temp variables
				-- sliders
				temp_table.level = wesnoth.get_dialog_value "unit_level_slider"
				temp_table.copy = wesnoth.get_dialog_value "unit_copy_slider"
				temp_table.side = wesnoth.get_dialog_value ( "unit_side_slider" )
				temp_table.hitpoints = wesnoth.get_dialog_value ( "unit_hitpoints_slider" )
				temp_table.experience = wesnoth.get_dialog_value ( "unit_experience_slider" )
				temp_table.moves = wesnoth.get_dialog_value ( "unit_moves_slider" )
				temp_table.attacks_left = wesnoth.get_dialog_value ( "unit_attacks_slider" )
				temp_table.amla = wesnoth.get_dialog_value ( "unit_amla_slider" )
				-- text boxes
				temp_table.location = wesnoth.get_dialog_value "textbox_unit_location"
				temp_table.goto_xy = wesnoth.get_dialog_value "textbox_unit_goto"
				temp_table.upkeep = wesnoth.get_dialog_value "textbox_unit_upkeep"
				temp_table.id = wesnoth.get_dialog_value "textbox_unit_id"
				temp_table.type = wesnoth.get_dialog_value "textbox_unit_type"
				temp_table.variation = wesnoth.get_dialog_value "textbox_unit_variation"
				temp_table.name = wesnoth.get_dialog_value "textbox_unit_name"
				temp_table.advances_to = wesnoth.get_dialog_value "textbox_advances_to"
				temp_table.extra_recruit = wesnoth.get_dialog_value "textbox_extra_recruit"
				temp_table.role = wesnoth.get_dialog_value "textbox_role"
				temp_table.attack = wesnoth.get_dialog_value "textbox_attack"
				temp_table.abilities = wesnoth.get_dialog_value "textbox_abilities"
				temp_table.modifications = wesnoth.get_dialog_value "textbox_modifications"
				temp_table.traits = wesnoth.get_dialog_value "textbox_traits"
				temp_table.overlays = wesnoth.get_dialog_value "textbox_overlays"
				temp_table.variables = wesnoth.get_dialog_value "textbox_variables"
				-- checkbuttons
				temp_table.unrenamable = wesnoth.get_dialog_value "unrenamable_checkbutton"
				temp_table.canrecruit = wesnoth.get_dialog_value "canrecruit_checkbutton"
				temp_table.generate_name = wesnoth.get_dialog_value "generate_name_checkbutton"
				temp_table.heal = wesnoth.get_dialog_value "heal_unit_checkbutton"
				temp_table.poisoned = wesnoth.get_dialog_value "poisoned_checkbutton"
				temp_table.slowed = wesnoth.get_dialog_value "slowed_checkbutton"
				temp_table.petrified = wesnoth.get_dialog_value "petrified_checkbutton"
				temp_table.invulnerable = wesnoth.get_dialog_value "invulnerable_checkbutton"
				temp_table.uncovered = wesnoth.get_dialog_value "uncovered_checkbutton"
				temp_table.guardian = wesnoth.get_dialog_value "guardian_checkbutton"
				temp_table.unhealable = wesnoth.get_dialog_value "unhealable_checkbutton"
				temp_table.stunned = wesnoth.get_dialog_value "stunned_checkbutton"
				temp_table.not_living = wesnoth.get_dialog_value "not_living_checkbutton"
				temp_table.undrainable = wesnoth.get_dialog_value "undrainable_checkbutton"
				temp_table.unplagueable = wesnoth.get_dialog_value "unplagueable_checkbutton"
				temp_table.unpoisonable = wesnoth.get_dialog_value "unpoisonable_checkbutton"
				-- put facing here
				local facings = { "nw", "ne", "n", "sw", "se", "s" }
				-- wesnoth.get_dialog_value ( "facing_listbox" ) returns a number, that was 2 for the second radiobutton and 5 for the fifth, hence the table above
				temp_table.facing = facings[ wesnoth.get_dialog_value ( "facing_listbox" ) ] -- it is set correctly, but for some reason it is not shown
				-- misc; checkbuttons
				temp_table.resting = wesnoth.get_dialog_value "resting_checkbutton"
				temp_table.hidden = wesnoth.get_dialog_value "hidden_checkbutton"
				-- gender radiobuttons
				local gender = { "male", "female" }
				temp_table.gender = gender[ wesnoth.get_dialog_value ( "gender_listbox" ) ]
			end

			local return_value = wesnoth.show_dialog( debug_dialog, preshow, postshow )

			return { return_value = return_value, { "temp_table", temp_table } }
		end

		local return_table = wesnoth.synchronize_choice(sync)
		local return_value = return_table.return_value
		local temp_table = helper.get_child ( return_table, "temp_table" )

		if return_value == 1 or return_value == -1 then -- if used pressed OK or Enter, modify unit
			dbg_unit.side = temp_table.side -- first, for proper look on map with other actions
			-- statuses, need to be before transforms, so poison can be removed from undead if a transform is used
			dbg_unit.status.poisoned = temp_table.poisoned
			dbg_unit.status.slowed = temp_table.slowed
			dbg_unit.status.petrified = temp_table.petrified
			dbg_unit.status.invulnerable = temp_table.invulnerable
			dbg_unit.status.uncovered = temp_table.uncovered
			dbg_unit.status.guardian = temp_table.guardian
			dbg_unit.status.unhealable = temp_table.unhealable
			dbg_unit.status.stunned = temp_table.stunned
			dbg_unit.status.not_living = temp_table.not_living -- must be before undrainable, unplagueable, and unpoisonable to work correctly
			dbg_unit.status.undrainable = temp_table.undrainable
			dbg_unit.status.unplagueable = temp_table.unplagueable
			dbg_unit.status.unpoisonable = temp_table.unpoisonable
			dbg_unit.upkeep = temp_table.upkeep -- upkeep must be before traits, so adding a loyal trait can override this value
			-- these values need to before transforms so level/type changes work better
			dbg_unit.attacks_left = temp_table.attacks_left
			dbg_unit.hitpoints = temp_table.hitpoints
			dbg_unit.moves = temp_table.moves
			-- transform_unit based actions, all at least require the field to change to trigger a transform
			-- level_type_advances_to_xp must be after all other transforms, to handle the values as expected
			unit_ops.attack ( dbg_unit, temp_table.attack )
			unit_ops.abilities ( dbg_unit, temp_table.abilities )
			unit_ops.gender ( dbg_unit, temp_table.gender )
			unit_ops.traits ( dbg_unit, temp_table.traits )
			unit_ops.modifications ( dbg_unit, temp_table.modifications ) -- must be after traits, as it could be adding a trait
			unit_ops.variation ( dbg_unit, temp_table.variation )
			unit_ops.level_type_advances_to_xp ( dbg_unit, temp_table.level, temp_table.type, temp_table.advances_to, temp_table.experience)
			-- misc, these don't need to be anywhere in particular
			unit_ops.amla (dbg_unit, temp_table.amla)
			dbg_unit.facing = temp_table.facing
			dbg_unit.extra_recruit = utils.split_to_table ( temp_table.extra_recruit )
			dbg_unit.role = temp_table.role
			dbg_unit.hidden = temp_table.hidden
			dbg_unit.resting = temp_table.resting
			unit_ops.canrecruit ( dbg_unit, temp_table.canrecruit )
			unit_ops.goto_xy ( dbg_unit, temp_table.goto_xy ) -- needs to be before location
			unit_ops.id ( dbg_unit, temp_table.id )
			unit_ops.overlays ( dbg_unit, temp_table.overlays )
			unit_ops.name ( dbg_unit, temp_table.name ) -- needs to be before generate_name
			unit_ops.generate_name ( dbg_unit, temp_table.generate_name )
			unit_ops.unrenamable ( dbg_unit, temp_table.unrenamable )
			unit_ops.variables ( dbg_unit, temp_table.variables )
			-- these need to be last, as they involve healing or copying the unit
			unit_ops.location ( dbg_unit, temp_table.location ) -- healed if put to recall
			unit_ops.heal ( dbg_unit, temp_table.heal )
			unit_ops.copy ( dbg_unit, temp_table.copy )
			wml_actions.redraw ( { } ) -- to be sure of showing changes
			wml_actions.print ( { text = _ "unit debug was used during turn of " .. wesnoth.sides[wesnoth.current.side].__cfg.current_player,
				size = 24, duration = 200, color = "255,255,255" } )
		elseif return_value == 2 or return_value == -2 then -- if user pressed Cancel or Esc, nothing happens
		else wesnoth.message( tostring( _ "Unit Debug" ), tostring( _ "Error, return value :" ) .. return_value ) end -- any unhandled case is handled here
	-- if user clicks on empty hex, do nothing
	end
end

unit_debug ( )
