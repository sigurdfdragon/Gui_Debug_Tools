-- #textdomain wesnoth-Gui_Debug_Tools
local _ = wesnoth.textdomain "wesnoth-Gui_Debug_Tools"

local unit_ops = {}

local helper = wesnoth.require "lua/helper.lua"
local utils = wesnoth.dofile "~add-ons/Gui_Debug_Tools/lua/utils.lua"

-- to make code shorter
local wml_actions = wesnoth.wml_actions

function unit_ops.abilities ( unit, abilities )
	-- abilities change - adds or removes new abilities via objects, does not affect abilities that come with the unit type
	if abilities ~= "" then
		-- remove existing ability objects
		local u = unit.__cfg -- traits need to be removed by editing a __cfg table
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
		wesnoth.transform_unit ( unit, unit.type ) -- the above gets the [object], this gets the [abilities] imparted by the object
		if abilities ~= " " then -- a shortcut if user just wants to clear added objects
			-- chop user entered value
			local ability_sources = { }
			for value in utils.split( abilities ) do
				table.insert ( ability_sources, utils.chop( value ) )
			end
			-- add new abilities, copy from unit_types that have desired abilities
			for i = 1, #ability_sources do
				local new_ability = helper.get_child(wesnoth.unit_types[ability_sources[i]].__cfg, "abilities")
				if new_ability then
					local new_object = { gdt_id = i, delayed_variable_substitution = true, { "effect", { apply_to = "new_ability", { "abilities", new_ability } } } }
					wesnoth.add_modification ( unit, "object", new_object )
				end
			end
		end
	end
end

function unit_ops.amla ( unit, int )
	if int > 0 and unit.advances_to[1] == nil then
		for i = 1, int do
			-- since large values can slow things down, no animation here
			unit.experience = unit.max_experience ; unit:advance ( false, true )
		end
	end
end

function unit_ops.attack ( unit, attack )
	-- attacks - adds or removes new attacks via objects, does not affect attacks that come with the unit type
	if attack ~= "" then
		if attack == " " then -- user just wants to clear added object(s)
			-- remove existing attack objects
			local u = unit.__cfg -- traits need to be removed by editing a __cfg table
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
			wesnoth.transform_unit ( unit, unit.type ) -- the above gets the [object], this gets the [attack] imparted by the object
		else
			-- chop user entered value
			local attack_sources = { }
			for value in utils.split( attack ) do
				table.insert ( attack_sources, utils.chop( value ) )
			end
			-- add new attack, copy from unit_type & attack index that has the desired attack
			local new_attack = helper.get_nth_child(wesnoth.unit_types[attack_sources[1]].__cfg, "attack", attack_sources[2])
			if new_attack then
				new_attack.apply_to = "new_attack"
				local new_object = { gdt_id = "attack", delayed_variable_substitution = true, { "effect", new_attack } }
				wesnoth.add_modification ( unit, "object", new_object )
			end
		end
	end
end

function unit_ops.canrecruit ( unit, bool )
	wml_actions.modify_unit { { "filter", { id = unit.id } }, canrecruit = bool }
end

function unit_ops.copy_unit ( unit, int )
	-- do it this way instead of using wesnoth.copy_unit as
	-- it doesn't handle specified ids (ie, 'Konrad') in
	-- the way that we want it to
	if int ~= 0 then
		for i = 1, int do
			local copy = unit.__cfg
			copy.id, copy.underlying_id = nil, nil -- so custom ids are not duplicated & generic ids will match uid
			copy.name, copy.generate_name = nil, true --so copies have different names
			if copy.x == "recall" and copy.y == "recall" then
				wesnoth.put_recall_unit ( copy )
			else
				local x, y = wesnoth.find_vacant_tile ( copy.x, copy.y, copy )
				wesnoth.put_unit ( copy, x, y )
			end
		end
	end
end

function unit_ops.gender ( unit, gender )
		if gender ~= unit.__cfg.gender then -- if there are custom portraits, they are lost.
			wml_actions.modify_unit { { "filter", { id = unit.id } }, profile = "", small_profile = "", gender = gender }
			unit:transform( unit.type ) -- transform refills the profile keys
		end
end

function unit_ops.generate_name ( unit, bool )
	if bool then
		wml_actions.modify_unit { { "filter", { id = unit.id } }, name = "", generate_name = true }
	end
end

function unit_ops.get_traits_string ( unit )
	local unit_modifications = helper.get_child ( unit.__cfg, "modifications" ) or {}
	local trait_ids = { }
	for trait in helper.child_range ( unit_modifications, "trait" ) do
			if trait.id ~= nil then
				table.insert ( trait_ids, trait.id )
			end
	end
	return table.concat( trait_ids, "," )
end

function unit_ops.goto_xy ( unit, str )
	local loc = utils.split_to_table ( str )
	wml_actions.modify_unit { { "filter", { id = unit.id } }, goto_x = loc[1], goto_y = loc[2]}
end

function unit_ops.heal_unit ( unit, bool )
	if bool then
		wml_actions.heal_unit { { "filter", { id = unit.id } }, moves = "full", restore_attacks = true }
	end
end

function unit_ops.id ( unit, str )
	wml_actions.modify_unit { { "filter", { id = unit.id } }, id = str }
end

function unit_ops.level_type_advances_to_xp ( unit, level, unit_type, advances_to, experience )
	if unit.type ~= unit_type then
		-- disregard what is entered for level, advances_to, & experience
		wesnoth.transform_unit ( unit, unit_type )
		unit.experience = 0
	else
		unit.advances_to = utils.split_to_table ( advances_to, "," )
		if unit.level ~= level then
			-- disregarding experience here to avoid interfering with what player is intending
			if unit.level < level then -- leveling up
				local count = level - unit.level
				for i = 1, count do
					if unit.advances_to[1] ~= nil then
						unit.experience = unit.max_experience ; unit:advance ( true, true )
					end
				end
			elseif unit.level > level then -- leveling down
				local count = unit.level - level
				for i = 1, count do
					if wesnoth.unit_types[unit.type].advances_from[1] ~= nil then
						unit.advances_to = wesnoth.unit_types[unit.type].advances_from
						unit.experience = unit.max_experience ; unit:advance ( true, true )
					end
				end
			end
		else -- since unit type & level wasn't adjusted, make xp adjustment
			unit.experience = experience ; unit:advance ( true, true )
		end
	end
end

function unit_ops.location ( unit, str )
	if str == "" then
		-- do it this way as wml_action.put_to_recall doesn't cover petrified or unhealable
		wml_actions.heal_unit { { "filter", { id = unit.id } }, moves = "full", restore_attacks = true }
		wml_actions.modify_unit { { "filter", { id = unit.id } }, goto_x = 0, goto_y = 0 }
		unit:to_recall()
	else
		local loc = utils.split_to_table ( str )
		unit:to_map( loc[1], loc[2] )
	end
end

function unit_ops.modifications ( unit, str )
	-- modifications - copies any modification or removes objects & advancements
	if str ~= "" then
		if str == " " then -- remove all existing objects or advancements
			unit:remove_modifications( {}, "object" )
			unit:remove_modifications( {}, "advancement" )
		else
			-- chop user entered value - ex: Delfador,object,1
			local mod_source = { }
			for value in utils.split( str ) do
				table.insert ( mod_source, utils.chop( value ) )
			end
			if mod_source[1] == "remove" then
			-- remove modification specified by magic word, mod_type, & index - ex: remove,advancement,2
				local modifications = helper.get_child( unit.__cfg, "modifications" )
				local unit_mod = helper.get_nth_child( modifications, mod_source[2], mod_source[3] )
				if unit_mod then
					unit:remove_modifications( unit_mod, mod_source[2] )
				end
			else
				-- add new modification, copy from unit specified by id, mod type, & index
				local u = wesnoth.get_unit(mod_source[1] ) or wesnoth.get_recall_units( { id=mod_source[1] } )[1]
				local modifications = helper.get_child( u.__cfg, "modifications" )
				local new_mod = helper.get_nth_child( modifications, mod_source[2], mod_source[3] )
				if new_mod then
					unit:add_modification ( mod_source[2], new_mod )
				end
			end
		end
	end
end

function unit_ops.name ( unit, str )
	wml_actions.modify_unit { { "filter", { id = unit.id } }, name = str }
end

function unit_ops.overlays ( unit, str )
	wml_actions.modify_unit { { "filter", { id = unit.id } }, overlays = str }
end

function unit_ops.traits ( unit, trait_str )
	if trait_str ~= unit_ops.get_traits_string ( unit ) then
		-- returns a list of all mainline traits plus bonus traits
		-- start with making a table and adding the global traits
		-- quick, resilient, strong, intelligent
		local trait_array = {}
		local trait_t = wesnoth.get_traits()
		local i = 1
		for k,v in pairs(trait_t) do
			trait_array[i] = v
			i = i + 1
		end

		-- traverse through specified races and units to add more mainline traits
		-- healthy, dextrous, weak, slow, dim, mechanical, fearless, undead
		local race_array = { "dwarf", "elf", "goblin", "mechanical", "troll", "undead" }
		-- feral, elemental, aged, loyal
		local unit_array = { "Vampire Bat", "Mudcrawler", "Fog Clearer" }
		for i,v in ipairs(race_array) do
			for temp_trait in helper.child_range(wesnoth.races[v].__cfg, "trait") do
				local trait_is_present = false
				for j = 1, #trait_array do
					if temp_trait.id == trait_array[j].id then
						trait_is_present = true; break
					end
				end
				if trait_is_present == false then
					table.insert(trait_array, temp_trait)
				end
			end
		end
		for i,v  in ipairs(unit_array) do
			for temp_trait in helper.child_range(wesnoth.unit_types[v].__cfg, "trait") do
				local trait_is_present = false
				for j = 1, #trait_array do
					if temp_trait.id == trait_array[j].id then
						trait_is_present = true; break
					end
				end
				if trait_is_present == false then
					table.insert(trait_array, temp_trait)
				end
			end
		end

		-- add bonus traits expert, heroic, & powerful
		-- #textdomain wesnoth-Gui_Debug_Tools
		local _ = wesnoth.textdomain "wesnoth-Gui_Debug_Tools"
		-- expert trait - from The Great Quest
		local trait_expert = { id="expert", male_name=_"expert", female_name=_"female^expert",
			{ "effect", { apply_to="attack", increase_attacks=1 } },
			{ "effect", { apply_to="attack", increase_damage=-1 } } }
		-- heroic trait (Props to the World Conquest add-on for the idea.)
		-- This is The Great Quest version that has strong, resilient, quick & dextrous.
		local trait_heroic = { id="heroic", male_name=_"heroic", female_name=_"female^heroic",
			{ "effect", { apply_to="attack", increase_damage=1 } },
			{ "effect", { apply_to="hitpoints", increase_total=5 } },
			{ "effect", { apply_to="hitpoints", times="per level", increase_total=1 } },
			{ "effect", { apply_to="movement", increase=1 } } }
		-- powerful trait - from Random Campaign
		local trait_powerful = { id="powerful", male_name=_"powerful", female_name=_"female^powerful",
			{ "effect", { apply_to="attack", increase_damage="20%" } } }
		table.insert(trait_array, trait_expert)
		table.insert(trait_array, trait_heroic)
		table.insert(trait_array, trait_powerful)
		_ = nil

		-- add the unit's race, unit_type, and current traits to the array
		-- overwriting any with same id that are already in the array
		-- race traits
		for temp_trait in helper.child_range(wesnoth.races[unit.race].__cfg, "trait") do
			local trait_is_present = false
			for j = 1, #trait_array do
				if temp_trait.id == trait_array[j].id then
					trait_is_present = true
					trait_array[j] = temp_trait
					break
				end
			end
			if trait_is_present == false then
				table.insert(trait_array, temp_trait)
			end
		end
		-- unit_type traits
		for temp_trait in helper.child_range(wesnoth.unit_types[unit.type].__cfg, "trait") do
			local trait_is_present = false
			for j = 1, #trait_array do
				if temp_trait.id == trait_array[j].id then
					trait_is_present = true
					trait_array[j] = temp_trait
					break
				end
			end
			if trait_is_present == false then
				table.insert(trait_array, temp_trait)
			end
		end
		-- unit's current traits
		local u_mods = helper.get_child(unit.__cfg, "modifications") or {}
		for temp_trait in helper.child_range(u_mods, "trait") do
			local trait_is_present = false
			for j = 1, #trait_array do
				if temp_trait.id == trait_array[j].id then
					trait_is_present = true
					trait_array[j] = temp_trait
					break
				end
			end
			if trait_is_present == false then
				table.insert(trait_array, temp_trait)
			end
		end

		-- now that all the traits to pick from have been assembled
		-- take user entered values and use to set the unit's traits
		-- chop user entered value
		local temp_new_traits = { }
		for value in utils.split( trait_str ) do
			table.insert ( temp_new_traits, utils.chop( value ) )
		end
		-- remove undead status keys, in case undead trait is being removed
		-- it is easier to remove these keys from proxy than a __cfg
		-- TODO: may not be best handling, find better handling for this?
		unit.status.not_living = nil
		unit.status.undrainable = nil
		unit.status.unplaugeable = nil
		unit.status.unpoisonable = nil
		-- remove existing traits
		local u = unit.__cfg -- traits need to be removed by editing a __cfg table
		for tag = #u, 1, -1 do
			if u[tag][1] == "modifications" then
				for subtag = #u[tag][2], 1, -1 do
					if u[tag][2][subtag][1] == "trait" then
						local removed_trait = table.remove( u[tag][2], subtag )
						-- scan removed trait for apply_to=loyal
						for eff in helper.child_range(removed_trait[2], "effect") do
							if eff.apply_to == "loyal" then
								-- if a trait applied upkeep=loyal, remove it with that trait
								if u.upkeep == "loyal" then
									-- only change if upkeep is still loyal, player may
									-- have already changed it along with trait removal
									u.upkeep = "full"
								end
							end
						end
					end
				end
			end
		end
		-- add new traits
		for i = 1, #temp_new_traits do
			for j = 1, #trait_array do
				if temp_new_traits[i] == trait_array[j].id then
					if helper.get_child( u, "modifications" ) == nil then
						utils.add_empty_child( u, "modifications" )
					end
					local m = helper.get_child( u, "modifications" )
					table.insert ( m, { [1] = "trait", [2] = trait_array[j] } )
					break
				end
			end
		end
		wesnoth.put_unit ( u ) -- overwrites original that's still there, preserves underlying_id & proxy access
		wesnoth.transform_unit ( unit, unit.type ) -- refresh the unit with the new changes
	end
end

function unit_ops.unrenamable ( unit, bool )
	wml_actions.modify_unit { { "filter", { id = unit.id } }, unrenamable = bool }
end

function unit_ops.variables ( unit, variables )
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

function unit_ops.variation ( unit, variation )
	-- can this simply be a modify unit without all the rest of the code if this occurs
	-- before the unit_type transformation?
	if variation ~= unit.__cfg.variation then
		wml_actions.modify_unit { { "filter", { id = unit.id } }, variation = variation }
		wesnoth.transform_unit ( unit, unit.type ) -- so the variation change will take
	end
end

return unit_ops
