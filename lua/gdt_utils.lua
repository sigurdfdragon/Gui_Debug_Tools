-- #textdomain wesnoth-Gui_Debug_Tools
local _ = wesnoth.textdomain "wesnoth-Gui_Debug_Tools"

local utils = {}

local helper = wesnoth.require "lua/helper.lua"

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
	-- add powerful trait
	local trait_powerful = { id="powerful", male_name=_"powerful", female_name=_"female^powerful",
		{ "effect", { apply_to="attack", increase_damage="20%" } } }
	_ = nil
	table.insert(trait_array, trait_aged)
	table.insert(trait_array, trait_feral)
	table.insert(trait_array, trait_loyal)
	table.insert(trait_array, trait_heroic)
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

return utils
