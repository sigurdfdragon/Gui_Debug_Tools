-- #textdomain wesnoth-Gui_Debug_Tools
local _ = wesnoth.textdomain "wesnoth-Gui_Debug_Tools"

local side_ops = {}

local helper = wesnoth.require "lua/helper.lua"
local utils = wesnoth.dofile "~add-ons/Gui_Debug_Tools/lua/utils.lua"

-- to make code shorter
local wml_actions = wesnoth.wml_actions

function side_ops.clear_recall ( side, bool )
	if bool then
		wml_actions.kill( { side = side.side, x = "recall", y = "recall" } )
	end
end

function side_ops.convert_color( color )
	-- if color is a number, convert it to the word form
	local color_names = { "red", "blue", "green", "purple", "black", "brown", "orange", "white", "teal" }
	local color_number = tonumber( color )
	if color_number then
		return color_names[color_number]
	else
		return color
	end
end

function side_ops.goto_xy ( side, str )
	if str ~= "" then
		local loc = utils.split_to_table ( str )
		wml_actions.modify_unit { { "filter", { side = side.side } }, goto_x = loc[1], goto_y = loc[2]}
	end
end

function side_ops.heal_units ( side, bool )
	if bool then
		wml_actions.heal_unit { { "filter", { side = side.side } }, moves = "full", restore_attacks = true }
	end
end

function side_ops.kill_units ( side, bool )
	if bool then
		wml_actions.kill { side = side.side, animate = true, fire_event = true }
	end
end

function side_ops.location ( side, str )
	if str ~= "" then
		local loc = utils.split_to_table ( str )
		local units = wesnoth.get_units { side = side.side }
		for i = 1, #units do
			local x, y = wesnoth.find_vacant_tile ( loc[1], loc[2], units[i] )
			units[i]:to_map ( x, y )
		end
	end
end

function side_ops.recall_unit ( side, str )
	if str ~= "" then
		local unit = wesnoth.get_recall_units( { side = side.side, id = str } )[1]
		local x, y = wesnoth.current.event_context.x1, wesnoth.current.event_context.y1
		x, y = wesnoth.find_vacant_tile( x, y, unit )
		unit:to_map( x, y )
	end
end

function side_ops.seed_recall ( side, int )
	if int ~= 0 then
		for seed = 1, int do
			local temp_recruit = {}
			if side.recruit[1] ~= nil then
				local u = 1
				for i = 1, #side.recruit do
					table.insert ( temp_recruit, side.recruit[i] )
				end
				while temp_recruit[u] do
					if wesnoth.unit_types[temp_recruit[u]].__cfg.advances_to and wesnoth.unit_types[temp_recruit[u]].__cfg.advances_to ~= "null" then
						local advances = {}
						for value in utils.split( wesnoth.unit_types[temp_recruit[u]].__cfg.advances_to ) do
							table.insert ( advances, utils.chop( value ) )
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
				wesnoth.put_recall_unit ( { type = temp_recruit[i], side = side.side, random_gender = true } )
			end
		end
	end
end

function side_ops.super_heal_units ( side, bool )
	if bool then
		local units = wesnoth.get_units { side = side.side }
		for i = 1, #units do
			units[i].hitpoints = math.max(units[i].max_hitpoints * 20, 1000)
			units[i].moves = math.max(units[i].max_moves * 20, 100)
			units[i].attacks_left = math.max(units[i].max_attacks * 20, 20)
		end
	end
end

return side_ops
