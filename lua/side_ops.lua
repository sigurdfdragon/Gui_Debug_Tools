-- #textdomain wesnoth-Gui_Debug_Tools
local _ = wesnoth.textdomain "wesnoth-Gui_Debug_Tools"

local side_ops = { }

local helper = wesnoth.require "lua/helper.lua"
local utils = wesnoth.dofile "~add-ons/Gui_Debug_Tools/lua/utils.lua"

-- to make code shorter
local wml_actions = wesnoth.wml_actions

function side_ops.convert_color ( color )
	-- if color is a number, convert it to the word form
	local color_names = { "red", "blue", "green", "purple", "black", "brown", "orange", "white", "teal" }
	local color_number = tonumber ( color )
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

function side_ops.heal ( side, bool )
	if bool then
		wml_actions.heal_unit { { "filter", { side = side.side } }, moves = "full", restore_attacks = true }
	end
end

function side_ops.kill ( side, bool )
	if bool then
		wml_actions.kill { side = side.side, animate = true, fire_event = true }
	end
end

function side_ops.recall_units ( side, str )
	if str ~= "" then
		local ids = utils.split_to_table ( str )
		for i = 1, #ids do
			local unit = wesnoth.get_recall_units ( { side = side.side, id = ids[i] } )[1]
			local x, y = wesnoth.current.event_context.x1, wesnoth.current.event_context.y1
			x, y = wesnoth.find_vacant_tile ( x, y, unit )
			unit:to_map ( x, y )
		end
	end
end

function side_ops.seed_recall ( side, int )
	if int == 0 then
		-- do nothing
	elseif int == -1 then
		wml_actions.kill ( { side = side.side, x = "recall", y = "recall" } )
	elseif int > 0 then
		-- assemble an array of unit types and their advancements from side.recruit and leader.extra_recruit
		local utypes = { }
		-- add the side's recruits
		for r, recruit in ipairs ( side.recruit ) do
			table.insert ( utypes, recruit )
		end
		-- add each leader's extra recruit
		local leaders = wesnoth.get_units ( { side = side.side, canrecruit = true } )
		local recall_leaders = wesnoth.get_recall_units ( { side = side.side, canrecruit = true } )
		for l, leader in ipairs ( recall_leaders ) do
			table.insert ( leaders, leader )
		end
		for l, leader in ipairs ( leaders ) do
			for r, recruit in ipairs ( leader.extra_recruit ) do
				table.insert ( utypes, recruit )
			end
		end
		-- add advancements from each unit type
		-- additions are added to the back of the array and processed when they are reached
		local i = 1
		while utypes[i] do
			for a, advances_to in ipairs ( wesnoth.unit_types[utypes[i]].advances_to ) do
				table.insert ( utypes, advances_to )
			end
			i = i + 1
		end
		-- purge array of duplicates
		local hash, result = { }, { }
		for _, value in ipairs ( utypes ) do
			 if not hash[value] then
					 result[#result+1] = value
					 hash[value] = true
			 end
		end
		utypes = result
		-- go through array int times, creating one of each unit
		for i = 1, int do
			for u, utype in ipairs ( utypes ) do
				local unit = wesnoth.create_unit ( { type = utype, random_gender = true } )
				unit:to_recall ( side.side )
			end
		end
	end
end

function side_ops.super_heal ( side, bool )
	if bool then
		local units = wesnoth.get_units { side = side.side }
		for i = 1, #units do
			units[i].hitpoints = math.max(units[i].max_hitpoints * 20, 1000)
			units[i].moves = math.max(units[i].max_moves * 20, 100)
			units[i].attacks_left = math.max(units[i].max_attacks * 20, 20)
		end
	end
end

function side_ops.teleport ( side, str )
	if str ~= "" then
		if str == " " then
			local units = wesnoth.get_units ( { side = side.side, canrecruit = false } )
			for i = 1, #units do
				wml_actions.heal_unit { { "filter", { id = units[i].id } }, moves = "full", restore_attacks = true }
				wml_actions.modify_unit { { "filter", { id = units[i].id } }, goto_x = 0, goto_y = 0 }
				units[i]:to_recall ( )
			end
		else
			local loc = utils.split_to_table ( str )
			local units = wesnoth.get_units { side = side.side }
			for i = 1, #units do
				local x, y = wesnoth.find_vacant_tile ( loc[1], loc[2], units[i] )
				units[i]:to_map ( x, y )
			end
		end
	end
end

return side_ops
