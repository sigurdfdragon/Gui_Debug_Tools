-- #textdomain wesnoth-Gui_Debug_Tools
local _ = wesnoth.textdomain "wesnoth-Gui_Debug_Tools"

local utils = {}

local helper = wesnoth.require "lua/helper.lua"

-- to make code shorter
local wml_actions = wesnoth.wml_actions

--! Function removes the first child with a given name.
--! melinath
function utils.remove_child(cfg, name)
	for index = 1, #cfg do
		local value = cfg[index]
		if value[1] == name then
			table.remove(cfg, index)
			return
		end
	end
end

-- two support functions for handling strings
function utils.split( str, char )
	local char = char or ","
	local pattern = "[^" .. char .. "]+"
	return string.gmatch( str, pattern )
end

function utils.chop( str )
	local temp = string.gsub( str, "^%s+", "" )
	temp = string.gsub( temp, "%s+$", "" )
	return temp
end

function utils.convert_color( color )
	-- if color is a number, convert it to the word form
	local color_names = { "red", "blue", "green", "purple", "black", "brown", "orange", "white", "teal" }
	local color_number = tonumber( color )
	if color_number then
		return color_names[color_number]
	else
		return color
	end
end

function utils.recruit ( recruit_str )
	-- we do this empty table/gmatch/insert cycle, because get_dialog_value returns a string from a text_box, and the value required is a "table with unnamed indices holding strings"
	-- moved here because synchronize_choice needs a WML object, and a table with unnamed indices isn't
	local recruit = {}
	for value in utils.split( recruit_str ) do
		table.insert( recruit, utils.chop( value ) )
	end
	return recruit
end

function utils.seed_recall ( side, bool )
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

function utils.clear_recall ( side, bool )
	if bool then
		wml_actions.kill( { side = side.side, x = "recall", y = "recall" } )
	end
end

function utils.heal_units ( side, bool )
	if bool then
		wml_actions.heal_unit { { "filter", { side = side.side } } }
	end
end

function utils.kill_units ( side, bool )
	if bool then
		wml_actions.kill { side = side.side, animate = true, fire_event = true }
	end
end

function utils.trait_list()
	-- returns a list of all traits known to the engine
	-- start with making a table and adding the global traits
	local trait_array = {}
	local trait_t = wesnoth.get_traits()
	local i = 1
	for k,v in pairs(trait_t) do
		trait_array[i] = v
		i = i + 1
	end

	-- add aged, feral, & loyal as none of the races in mainline cover them
	-- #textdomain wesnoth-help
	local _ = wesnoth.textdomain "wesnoth-help"
	local trait_aged = { id="aged", male_name=_"aged", female_name=_"female^aged",
		{ "effect", { apply_to="hitpoints", increase_total=-8 } }, 
		{ "effect", { apply_to="movement", increase=-1 } }, 
		{ "effect", { apply_to="attack", range="melee", increase_damage=-1 } } }
	-- must have is unnecessary for feral here
	local trait_feral = { id="feral", male_name=_"feral", female_name=_"female^feral", 
		description=_"Receive only 50% defense in land-based villages", 
		{ "effect", { apply_to="defense", replace="true", { "defense", { village=-50 } } } } }
	local trait_loyal = { id="loyal", male_name=_"loyal", female_name=_"female^loyal",
		description=_"Zero upkeep", { "effect", { apply_to="loyal" } } }
	-- #textdomain wesnoth-Gui_Debug_Tools
	local _ = wesnoth.textdomain "wesnoth-Gui_Debug_Tools"
	-- add heroic trait (Props to the World Conquest add-on for the idea.)
	-- This is The Great Quest version that has strong, resilient, quick & dextrous.
	local trait_heroic = { id="heroic", male_name=_"heroic", female_name=_"female^heroic",
		{ "effect", { apply_to="attack", increase_damage=1 } },
		{ "effect", { apply_to="hitpoints", increase_total=5 } },
		{ "effect", { apply_to="hitpoints", times="per level", increase_total=1 } },
		{ "effect", { apply_to="movement", increase=1 } } }
		-- add expert trait - from The Great Quest
	local trait_expert = { id="expert", male_name=_"expert", female_name=_"female^expert",
		{ "effect", { apply_to="attack", increase_attacks=1 } },
		{ "effect", { apply_to="attack", increase_damage=-1 } } }
	-- add powerful trait
	local trait_powerful = { id="powerful", male_name=_"powerful", female_name=_"female^powerful",
		{ "effect", { apply_to="attack", increase_damage="20%" } } }
	_ = nil
	table.insert(trait_array, trait_aged)
	table.insert(trait_array, trait_feral)
	table.insert(trait_array, trait_loyal)
	table.insert(trait_array, trait_heroic)
	table.insert(trait_array, trait_expert)
	table.insert(trait_array, trait_powerful)
	-- traverse through all the races and add traits by id that are not already present
	for k,v in pairs(wesnoth.races) do
		for temp_trait in helper.child_range(wesnoth.races[k].__cfg, "trait") do
			local trait_is_present = false
			for i = 1, #trait_array do
				if temp_trait.id == trait_array[i].id then
					trait_is_present = true; break
				end
			end
			if trait_is_present == false then
				table.insert(trait_array, temp_trait)
			end
		end
	end
	return trait_array
end

function utils.unit_variables ( unit, variables )
	if variables ~= "" then
		local vstr = {}
		for value in utils.split( variables, "=" ) do
			table.insert ( vstr, utils.chop( value ) )
		end
		if vstr[2] == nil then
			vstr[2] = ""
		end
		unit.variables[vstr[1]] = vstr[2]
	end
end

function utils.gender ( unit, gender )
		if gender ~= unit.__cfg.gender then -- if there are custom portraits, they are lost.
			wml_actions.modify_unit { { "filter", { id = unit.id } }, profile = "", small_profile = "", gender = gender }
			wesnoth.transform_unit ( unit, unit.type ) -- transform refills the profile keys
			unit.hitpoints = unit.max_hitpoints -- to fix hp lowering bug that can occur when gender change is done on a run after a trait change
		end
end

function utils.generate_name ( unit, bool )
	if bool then
		wml_actions.modify_unit { { "filter", { id = unit.id } }, name = "", generate_name = true }
	end
end

return utils
