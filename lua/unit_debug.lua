-- #textdomain wesnoth-Gui_Debug_Tools
local _ = wesnoth.textdomain "wesnoth-Gui_Debug_Tools"

local helper = wesnoth.require "lua/helper.lua"
local gdt_utils = wesnoth.require "~add-ons/Gui_Debug_Tools/lua/gdt_utils.lua"

-- to make code shorter
local wml_actions = wesnoth.wml_actions

-- metatable for GUI tags
local T = helper.set_wml_tag_metatable {}

-- [gui_unit_debug]
-- This tag is meant for use inside a [set_menu_item], because it gets the unit at x1,y1
function wml_actions.gui_unit_debug ( cfg )
	-- acquire unit with get_units, if unit.valid show dialog
	local dialog_unit = wesnoth.get_units ( { x = wesnoth.current.event_context.x1, y = wesnoth.current.event_context.y1 } )[1] -- clearly, at x1,y1 there could be only one unit
	local oversize_factor = 10 -- make it possible to increase over unit.max_attacks; no idea what would be a sensible value
	if dialog_unit and dialog_unit.valid then -- to avoid indexing a nil value
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
									tooltip = _ "The internal designation for the unit. Each unit's ID should be unique."
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
									tooltip = _ "The coordinates on the map where the unit is located."
								}
							}
						},
						T.row {
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.label {
									label = _ "Can recruit"
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
									label = _ "Generate name"
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
									label = _ "Copy unit"
								}
							},
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.toggle_button {
									id = "copy_unit_checkbutton",
									tooltip = _ "A copy of the unit will be created at the nearest passable hex."
								}
							}
						},
						T.row {
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.label {
									label = _ "Put to recall"
								}
							},
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.toggle_button {
									id = "put_to_recall_checkbutton",
									tooltip = _ "Places the unit on the recall list."
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
									id = "poisoned_checkbutton"
								}
							},
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.toggle_button {
									label = _ "Slowed",
									id = "slowed_checkbutton"
								}
							},
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.toggle_button {
									label = _ "Petrified",
									id = "petrified_checkbutton"
								}
							},
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.spacer {
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
									id = "uncovered_checkbutton"
								}
							},
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.toggle_button {
									label = _ "Guardian",
									id = "guardian_checkbutton"
								}
							},
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.toggle_button {
									label = _ "Unhealable",
									id = "unhealable_checkbutton"
								}
							},
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.toggle_button {
									label = _ "Stunned",
									id = "stunned_checkbutton"
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
									id = "resting_checkbutton" --unit.resting
								}
							},
							T.column {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.toggle_button {
									label = _ "Hidden",
									id = "hidden_checkbutton" --unit.hidden
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
									label = _ "male"
								}
							},
							T.row {
								horizontal_alignment = "left",
								border = "all",
								border_size = 5,
								T.column {
									label = _ "female"
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

		-- left side entries
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
							vertical_grow = true,
							horizontal_grow = true,
							border = "all",
							border_size = 5,
							T.slider {
								minimum_value = 1,
								maximum_value = math.max( 2, #wesnoth.sides ), -- to avoid crash if there is only one side
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
							vertical_grow = true,
							horizontal_grow = true,
							border = "all",
							border_size = 5,
							T.slider {
								minimum_value = math.min(0, dialog_unit.hitpoints),
								maximum_value = math.max(dialog_unit.max_hitpoints * oversize_factor, dialog_unit.hitpoints),
								minimum_value_label = _ "Kill",
								--maximum_value_label = _ "Full health",
								step_size = 1,
								id = "unit_hitpoints_slider", --unit.hitpoints
								tooltip = _ "The amount of hitpoints the unit has. Setting this to 0 will kill the unit."
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
							vertical_grow = true,
							horizontal_grow = true,
							border = "all",
							border_size = 5,
							T.slider {
								minimum_value = math.min(0, dialog_unit.experience),
								maximum_value = math.max(dialog_unit.max_experience * oversize_factor, dialog_unit.experience),
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
							vertical_grow = true,
							horizontal_grow = true,
							border = "all",
							border_size = 5,
							T.slider {
								minimum_value = 0,
								-- to avoid crashing if max_moves == 0
								maximum_value = math.max(1, dialog_unit.max_moves * oversize_factor, dialog_unit.moves),
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
								label = _ "Attacks left"
							}
						},
						T.column {
							vertical_grow = true,
							horizontal_grow = true,
							border = "all",
							border_size = 5,
							T.slider {
								minimum_value = 0,
								-- to avoid crashing if unit has max_attacks == 0
								maximum_value = math.max(1, dialog_unit.max_attacks * oversize_factor, dialog_unit.attacks_left),
								step_size = 1,
								id = "unit_attacks_slider", --unit.attacks_left
								tooltip = _ "The number of attacks the unit can make on the current turn."
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
								label = _ "Extra recruit"
							}
						},
						T.column {
							vertical_grow = true,
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
								label = _ "Advances to"
							}
						},
						T.column {
							vertical_grow = true,
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
							vertical_grow = true,
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
							vertical_grow = true,
							horizontal_grow = true,
							border = "all",
							border_size = 5,
							T.text_box {
								id = "textbox_attack",
								history = "other_attack",
								tooltip = _ "The unit will receive the attack indicated. Specify a unit type and attack index to copy. Single space clears added attacks."
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
							vertical_grow = true,
							horizontal_grow = true,
							border = "all",
							border_size = 5,
							T.text_box {
								id = "textbox_abilities",
								history = "other_abilities",
								tooltip = _ "The unit will have the abilities of the unit types entered. Does not affect the unit's base abilities. Single space clears added abilities."
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
							vertical_grow = true,
							horizontal_grow = true,
							border = "all",
							border_size = 5,
							T.text_box {
								id = "textbox_traits",
								history = "other_traits",
								tooltip = _ "The unit's base stats will be altered by the traits listed."
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
							label = _ "Unit Debug Menu"
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
													id = "unit_image" -- unit sprite
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
													label = _ "Profile"
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
			wesnoth.wml_actions.open_help ( {topic = [[unit_]] .. dialog_unit.type} ) -- Literal string needed here or .po will have an error.
		end
		
		local function preshow()
			-- here set all widget starting values
			-- set read_only labels
			wesnoth.set_dialog_value ( string.format("%s~RC(magenta>%s)", dialog_unit.__cfg.image or "", wesnoth.sides[dialog_unit.side].color ), "unit_image" )
			wesnoth.set_dialog_callback ( unit_profile, "unit_profile_button" )
			-- set sliders
			wesnoth.set_dialog_value ( dialog_unit.side, "unit_side_slider" )
			wesnoth.set_dialog_value ( dialog_unit.hitpoints, "unit_hitpoints_slider" )
			wesnoth.set_dialog_value ( dialog_unit.experience, "unit_experience_slider" )
			wesnoth.set_dialog_value ( dialog_unit.moves, "unit_moves_slider" )
			wesnoth.set_dialog_value ( dialog_unit.attacks_left, "unit_attacks_slider" )
			-- set textboxes
			wesnoth.set_dialog_value ( dialog_unit.x .. "," .. dialog_unit.y, "textbox_unit_location" )
			wesnoth.set_dialog_value ( dialog_unit.id, "textbox_unit_id" )
			wesnoth.set_dialog_value ( dialog_unit.type, "textbox_unit_type" )
			wesnoth.set_dialog_value ( dialog_unit.__cfg.variation, "textbox_unit_variation" )
			wesnoth.set_dialog_value ( dialog_unit.name, "textbox_unit_name" )
			wesnoth.set_dialog_value ( table.concat( dialog_unit.extra_recruit, "," ), "textbox_extra_recruit" )
			wesnoth.set_dialog_value ( table.concat( dialog_unit.advances_to, "," ), "textbox_advances_to" )
			wesnoth.set_dialog_value ( dialog_unit.role, "textbox_role" )
			wesnoth.set_dialog_value ( "", "textbox_attack" )
			wesnoth.set_dialog_value ( "", "textbox_abilities" )
			-- set traits textbox
			local unit_modifications = helper.get_child ( dialog_unit.__cfg, "modifications" )
			local unit_traits_ids = { }
			for traits in helper.child_range ( unit_modifications, "trait" ) do
					if traits.id ~= nil then
						table.insert ( unit_traits_ids, traits.id )
					end
			end
			wesnoth.set_dialog_value ( table.concat( unit_traits_ids, "," ), "textbox_traits" )
			-- set checkbuttons
			wesnoth.set_dialog_value ( dialog_unit.canrecruit, "canrecruit_checkbutton" )
			wesnoth.set_dialog_value ( dialog_unit.__cfg.unrenamable, "unrenamable_checkbutton" )
			wesnoth.set_dialog_value ( false, "generate_name_checkbutton" )
			wesnoth.set_dialog_value ( false, "copy_unit_checkbutton" )
			wesnoth.set_dialog_value ( false, "put_to_recall_checkbutton" )
			wesnoth.set_dialog_value ( dialog_unit.status.poisoned, "poisoned_checkbutton" )
			wesnoth.set_dialog_value ( dialog_unit.status.slowed, "slowed_checkbutton" )
			wesnoth.set_dialog_value ( dialog_unit.status.petrified, "petrified_checkbutton" )
			wesnoth.set_dialog_value ( dialog_unit.status.uncovered, "uncovered_checkbutton" )
			wesnoth.set_dialog_value ( dialog_unit.status.guardian, "guardian_checkbutton" )
			wesnoth.set_dialog_value ( dialog_unit.status.unhealable, "unhealable_checkbutton" )
			wesnoth.set_dialog_value ( dialog_unit.status.stunned, "stunned_checkbutton" )
			-- set radiobutton for facing
			local temp_facing
			if dialog_unit.facing == "nw" then temp_facing = 1
			elseif dialog_unit.facing == "ne" then temp_facing = 2
			elseif dialog_unit.facing == "n" then temp_facing = 3
			elseif dialog_unit.facing == "sw" then temp_facing = 4
			elseif dialog_unit.facing == "se" then temp_facing = 5
			elseif dialog_unit.facing == "s" then temp_facing = 6
			end
			wesnoth.set_dialog_value ( temp_facing, "facing_listbox" )
			-- other checkbuttons
			wesnoth.set_dialog_value ( dialog_unit.resting, "resting_checkbutton" )
			wesnoth.set_dialog_value ( dialog_unit.hidden, "hidden_checkbutton" )
			-- set radiobutton for gender
			local temp_gender
			if dialog_unit.__cfg.gender == "male" then temp_gender = 1
			elseif dialog_unit.__cfg.gender == "female" then temp_gender = 2
			end
			wesnoth.set_dialog_value ( temp_gender, "gender_listbox" )
		end

		local function sync()
			local temp_table = { } -- to store values before checking if user allowed modifying

			local function postshow()
				-- here get all the widget values in variables; store them in temp variables
				-- sliders
				temp_table.side = wesnoth.get_dialog_value ( "unit_side_slider" )
				temp_table.hitpoints = wesnoth.get_dialog_value ( "unit_hitpoints_slider" )
				temp_table.experience = wesnoth.get_dialog_value ( "unit_experience_slider" )
				temp_table.moves = wesnoth.get_dialog_value ( "unit_moves_slider" )
				temp_table.attacks_left = wesnoth.get_dialog_value ( "unit_attacks_slider" )
				-- text boxes
				temp_table.location = wesnoth.get_dialog_value "textbox_unit_location"
				temp_table.id = wesnoth.get_dialog_value "textbox_unit_id"
				temp_table.type = wesnoth.get_dialog_value "textbox_unit_type"
				temp_table.variation = wesnoth.get_dialog_value "textbox_unit_variation"
				temp_table.name = wesnoth.get_dialog_value "textbox_unit_name"
				temp_table.advances_to = wesnoth.get_dialog_value "textbox_advances_to"
				temp_table.extra_recruit = wesnoth.get_dialog_value "textbox_extra_recruit"
				temp_table.role = wesnoth.get_dialog_value "textbox_role"
				temp_table.attack = wesnoth.get_dialog_value "textbox_attack"
				temp_table.abilities = wesnoth.get_dialog_value "textbox_abilities"
				temp_table.traits = wesnoth.get_dialog_value "textbox_traits"
				-- initial traits
				local unit_modifications = helper.get_child ( dialog_unit.__cfg, "modifications" )
				local unit_traits_ids = { }
				for traits in helper.child_range ( unit_modifications, "trait" ) do
						if traits.id ~= nil then
							table.insert ( unit_traits_ids, traits.id )
						end
				end
				temp_table.traits_initial = table.concat ( unit_traits_ids, "," )
				-- checkbuttons
				temp_table.unrenamable = wesnoth.get_dialog_value "unrenamable_checkbutton"
				temp_table.canrecruit = wesnoth.get_dialog_value "canrecruit_checkbutton"
				temp_table.generate_name = wesnoth.get_dialog_value "generate_name_checkbutton"
				temp_table.copy_unit = wesnoth.get_dialog_value "copy_unit_checkbutton"
				temp_table.put_to_recall = wesnoth.get_dialog_value "put_to_recall_checkbutton"
				temp_table.poisoned = wesnoth.get_dialog_value "poisoned_checkbutton"
				temp_table.slowed = wesnoth.get_dialog_value "slowed_checkbutton"
				temp_table.petrified = wesnoth.get_dialog_value "petrified_checkbutton"
				temp_table.uncovered = wesnoth.get_dialog_value "uncovered_checkbutton"
				temp_table.guardian = wesnoth.get_dialog_value "guardian_checkbutton"
				temp_table.unhealable = wesnoth.get_dialog_value "unhealable_checkbutton"
				temp_table.stunned = wesnoth.get_dialog_value "stunned_checkbutton"
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
			-- sliders
			if wesnoth.sides[temp_table.side] then
				dialog_unit.side = temp_table.side
			end
			dialog_unit.moves = temp_table.moves
			dialog_unit.attacks_left = temp_table.attacks_left
			-- text boxes
			wml_actions.modify_unit { { "filter", { id = dialog_unit.id } }, id = temp_table.id }
			local location = { }
			for value in gdt_utils.split ( temp_table.location ) do
				table.insert ( location, gdt_utils.chop( value ) )
			end
			wesnoth.put_unit ( location[1], location[2], dialog_unit )
			-- we do this empty table/gmatch/insert cycle, because get_dialog_value returns a string from a text_box, and the value required is a "table with unnamed indices holding strings"
			-- moved here because synchronize_choice needs a WML object, and a table with unnamed indices isn't
			local temp_advances_to = { }
			for value in gdt_utils.split( temp_table.advances_to ) do
				table.insert( temp_advances_to, gdt_utils.chop( value ) )
			end
			dialog_unit.advances_to = temp_advances_to
			local temp_extra_recruit = { }
			for value in gdt_utils.split( temp_table.extra_recruit ) do
				table.insert ( temp_extra_recruit, gdt_utils.chop( value ) )
			end
			dialog_unit.extra_recruit = temp_extra_recruit
			dialog_unit.role = temp_table.role
			-- checkbuttons
			dialog_unit.status.poisoned = temp_table.poisoned
			dialog_unit.status.slowed = temp_table.slowed
			dialog_unit.status.petrified = temp_table.petrified
			dialog_unit.status.uncovered = temp_table.uncovered
			dialog_unit.status.guardian = temp_table.guardian
			dialog_unit.status.unhealable = temp_table.unhealable
			dialog_unit.status.stunned = temp_table.stunned
			dialog_unit.facing = temp_table.facing
			-- misc; checkbuttons
			dialog_unit.resting = temp_table.resting
			dialog_unit.hidden = temp_table.hidden
			dialog_unit.hitpoints = temp_table.hitpoints
			-- for some reason, without this delay the death animation isn't played
			wesnoth.delay(1)
			if dialog_unit.hitpoints <= 0 then -- check if killing the unit before doing any complex stuff
				wml_actions.kill ( { id = dialog_unit.id, animate = true, fire_event = true } )
			else
				-- type / variation change
				if temp_table.type ~= dialog_unit.type or temp_table.variation ~= dialog_unit.__cfg.variation then
					wml_actions.modify_unit { { "filter", { id = dialog_unit.id } }, variation = temp_table.variation }
					wesnoth.transform_unit ( dialog_unit, temp_table.type )
					dialog_unit.hitpoints = dialog_unit.max_hitpoints -- full heal, as that's the most common desired behavior
					dialog_unit.moves = dialog_unit.max_moves
				end
				-- attacks - adds or removes new attacks via objects, does not affect attacks that come with the unit type
				if temp_table.attack ~= "" then
					if temp_table.attack == " " then -- user just wants to clear added object(s)
						-- remove existing attack objects
						local u = dialog_unit.__cfg -- traits need to be removed by editing a __cfg table
						for tag = #u, 1, -1 do
							if u[tag][1] == "modifications" then
								for subtag = #u[tag][2], 1, -1 do
									if u[tag][2][subtag][1] == "object" and u[tag][2][subtag][2].gdt_id == "attack" then
										table.remove( u[tag][2], subtag )
									end
								end
							end
						end
						wesnoth.put_unit ( u ) -- overwrites original that's still there, preserves underlying_id & proxy access
						wesnoth.transform_unit ( dialog_unit, dialog_unit.type ) -- the above gets the [object], this gets the [attack] imparted by the object
					else
						-- chop user entered value
						local attack_sources = { }
						for value in gdt_utils.split( temp_table.attack ) do
							table.insert ( attack_sources, gdt_utils.chop( value ) )
						end
						-- add new attack, copy from unit_type & attack index that has the desired attack
						local new_attack = helper.get_nth_child(wesnoth.unit_types[attack_sources[1]].__cfg, "attack", attack_sources[2])
						if new_attack then
							new_attack.apply_to = "new_attack"
							local new_object = { gdt_id = "attack", delayed_variable_substitution = true, { "effect", new_attack } }
							wesnoth.add_modification ( dialog_unit, "object", new_object )
						end
					end
				end
				-- abilities change - adds or removes new abilities via objects, does not affect abilities that come with the unit type
				if temp_table.abilities ~= "" then
					-- remove existing ability objects
					local u = dialog_unit.__cfg -- traits need to be removed by editing a __cfg table
					for tag = #u, 1, -1 do
						if u[tag][1] == "modifications" then
							for subtag = #u[tag][2], 1, -1 do
								if u[tag][2][subtag][1] == "object" and u[tag][2][subtag][2].gdt_id ~= nil then
									table.remove( u[tag][2], subtag )
								end
							end
						end
					end
					wesnoth.put_unit ( u ) -- overwrites original that's still there, preserves underlying_id & proxy access
					wesnoth.transform_unit ( dialog_unit, dialog_unit.type ) -- the above gets the [object], this gets the [abilities] imparted by the object
					if temp_table.abilities ~= " " then -- a shortcut if user just wants to clear added objects
						-- chop user entered value
						local ability_sources = { }
						for value in gdt_utils.split( temp_table.abilities ) do
							table.insert ( ability_sources, gdt_utils.chop( value ) )
						end
						-- add new abilities, copy from unit_types that have desired abilities
						for i = 1, #ability_sources do
							local new_ability = helper.get_child(wesnoth.unit_types[ability_sources[i]].__cfg, "abilities")
							if new_ability then
								local new_object = { gdt_id = i, delayed_variable_substitution = true, { "effect", { apply_to = "new_ability", { "abilities", new_ability } } } }
								wesnoth.add_modification ( dialog_unit, "object", new_object )
							end
						end
					end
				end
				-- trait change - must be after transform to handle undead->human changes according to most likely user expectations.
				if temp_table.traits ~= temp_table.traits_initial then
					local trait_table = gdt_utils.trait_list()
					-- chop user entered value
					local temp_new_traits = { }
					for value in gdt_utils.split( temp_table.traits ) do
						table.insert ( temp_new_traits, gdt_utils.chop( value ) )
					end
					-- remove existing traits
					local u = dialog_unit.__cfg -- traits need to be removed by editing a __cfg table
					for tag = #u, 1, -1 do
						if u[tag][1] == "modifications" then
							for subtag = #u[tag][2], 1, -1 do
								if u[tag][2][subtag][1] == "trait" then
									table.remove( u[tag][2], subtag )
								end
							end
						end
					end
					if u.upkeep == "loyal" then -- in case loyal was present, overlay handled below
						u.upkeep = "full" 
					end
					wesnoth.put_unit ( u ) -- overwrites original that's still there, preserves underlying_id & proxy access
					-- add new traits
					for i = 1, #temp_new_traits do
						for j = 1, #trait_table do 
							if temp_new_traits[i] == trait_table[j].id then
								wesnoth.add_modification ( dialog_unit, "trait", trait_table[j] )
								break
							end
						end
					end
					wesnoth.transform_unit ( dialog_unit, dialog_unit.type ) -- refresh the unit with the new changes
					dialog_unit.hitpoints = dialog_unit.max_hitpoints -- full heal, as that's the most common desired behavior
					dialog_unit.moves = dialog_unit.max_moves -- restore moves, as adding quick or heroic are likely to be common choices
					if dialog_unit.__cfg.upkeep == "loyal" then
						wml_actions.unit_overlay ( { id = dialog_unit.id, image = "misc/loyal-icon.png" } )
					else
						wml_actions.remove_unit_overlay ( { id = dialog_unit.id, image = "misc/loyal-icon.png" } )
					end
				end -- /trait change
				-- advance the unit if enough xp
				dialog_unit.experience = temp_table.experience -- changing xp needs to be with xp check, as any modify_unit between can cause level-up
				wml_actions.modify_unit { { "filter", { id = dialog_unit.id } } } -- simple way to trigger level up if enough xp
				-- gender change
				if temp_table.gender ~= dialog_unit.__cfg.gender then -- if there are custom portraits, they are lost.
					wml_actions.modify_unit { { "filter", { id = dialog_unit.id } }, profile = "", small_profile = "", gender = temp_table.gender }
					wesnoth.transform_unit ( dialog_unit, dialog_unit.type ) -- transform refills the profile keys
					dialog_unit.hitpoints = dialog_unit.max_hitpoints -- to fix hp lowering bug that can occur when gender change is done on a run after a trait change
				end
				wml_actions.modify_unit { { "filter", { id = dialog_unit.id } }, name = temp_table.name }
				if temp_table.generate_name then
					wml_actions.modify_unit { { "filter", { id = dialog_unit.id } }, name = "", generate_name = true }
				end
				wml_actions.modify_unit { { "filter", { id = dialog_unit.id } }, unrenamable = temp_table.unrenamable }
				wml_actions.modify_unit { { "filter", { id = dialog_unit.id } }, canrecruit = temp_table.canrecruit }
				-- copy unit
				if temp_table.copy_unit then
					local new_unit = wesnoth.copy_unit ( dialog_unit )
					local x, y = wesnoth.find_vacant_tile ( dialog_unit.x, dialog_unit.y, new_unit )
					wesnoth.put_unit ( x, y, new_unit )
					wml_actions.modify_unit { { "filter", { id = new_unit.id } }, name = "", generate_name = true }
				end
				-- put to recall
				if temp_table.put_to_recall then
					wesnoth.put_recall_unit ( dialog_unit )
				end
			end
			wml_actions.redraw ( { } ) -- to be sure of showing changes
			wml_actions.print ( { text = _ "unit debug was used during turn of " .. wesnoth.sides[wesnoth.current.side].__cfg.current_player,
				size = 24, duration = 200, red = 255, green = 255, blue = 255 } )
		elseif return_value == 2 or return_value == -2 then -- if user pressed Cancel or Esc, nothing happens
		else wesnoth.message( tostring( _ "Unit Debug" ), tostring( _ "Error, return value :" ) .. return_value ) end -- any unhandled case is handled here
	-- if user clicks on empty hex, do nothing
	end
end
