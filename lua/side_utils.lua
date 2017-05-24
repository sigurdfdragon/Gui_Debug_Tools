-- #textdomain wesnoth-Gui_Debug_Tools
local _ = wesnoth.textdomain "wesnoth-Gui_Debug_Tools"

local gdt_side = {}

local helper = wesnoth.require "lua/helper.lua"
local utils = wesnoth.require "~add-ons/Gui_Debug_Tools/lua/utils.lua"

-- to make code shorter
local wml_actions = wesnoth.wml_actions

function gdt_side.clear_recall ( side, bool )
	if bool then
		wml_actions.kill( { side = side.side, x = "recall", y = "recall" } )
	end
end

function gdt_side.convert_color( color )
	-- if color is a number, convert it to the word form
	local color_names = { "red", "blue", "green", "purple", "black", "brown", "orange", "white", "teal" }
	local color_number = tonumber( color )
	if color_number then
		return color_names[color_number]
	else
		return color
	end
end

function gdt_side.goto_xy ( side, str )
	if str ~= "" then
		local goto_xy = { }
		for value in utils.split ( str ) do
			table.insert ( goto_xy, utils.chop( value ) )
		end
		wml_actions.modify_unit { { "filter", { side = side.side } }, goto_x = goto_xy[1], goto_y = goto_xy[2]}
	end
end

function gdt_side.heal_units ( side, bool )
	if bool then
		wml_actions.heal_unit { { "filter", { side = side.side } }, moves = "full", restore_attacks = true }
	end
end

function gdt_side.kill_units ( side, bool )
	if bool then
		wml_actions.kill { side = side.side, animate = true, fire_event = true }
	end
end

function gdt_side.location ( side, str )
	if str ~= "" then
		local location = { }
		for value in utils.split ( str ) do
			table.insert ( location, utils.chop( value ) )
		end
		local units = wesnoth.get_units { side = side.side }
		for i = 1, #units do
			local x,y = wesnoth.find_vacant_tile ( location[1], location[2], units[i] )
			wesnoth.put_unit ( x, y, units[i])
		end
	end
end

function gdt_side.seed_recall ( side, bool )
	if bool then
		if side.recruit[1] ~= nil then
			local u = 1
			temp_recruit = {}
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
			wesnoth.put_recall_unit ( { type = temp_recruit[i], side = side.side } )
		end
	end
end

function gdt_side.super_heal_units ( side, bool )
	if bool then
		local units = wesnoth.get_units { side = side.side }
		for i = 1, #units do
			units[i].hitpoints = math.max(units[i].max_hitpoints * 20, 1000)
			units[i].moves = math.max(units[i].max_moves * 20, 100)
			units[i].attacks_left = math.max(units[i].max_attacks * 20, 20)
		end
	end
end

return gdt_side
