-- #textdomain wesnoth-Gui_Debug_Tools
local _ = wesnoth.textdomain "wesnoth-Gui_Debug_Tools"

local unit_ops = {}

local helper = wesnoth.require "lua/helper.lua"
local utils = wesnoth.dofile "~add-ons/Gui_Debug_Tools/lua/utils.lua"

-- to make code shorter
local wml_actions = wesnoth.wml_actions

function unit_ops.abilities ( unit, str )
	-- adds or removes new abilities via objects, does not affect abilities that come with the unit type
	if str ~= "" then
		if str == " " then
			-- remove existing ability objects
			unit:remove_modifications ( { item_id = "gdt_ability" }, "object" )
		else
			-- copy abilities from specified unit_types
			local sources = utils.split_to_table ( str )
			for i = 1, #sources do
				local ability = helper.get_child ( wesnoth.unit_types[sources[i]].__cfg, "abilities" )
				if ability then
					local object = { item_id = "gdt_ability", delayed_variable_substitution = true, { "effect", { apply_to = "new_ability", { "abilities", ability } } } }
					unit:add_modification ( "object", object )
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

function unit_ops.attack ( unit, str )
	-- adds or removes new attacks via objects, does not affect attacks that come with the unit type
	if str ~= "" then
		if str == " " then
			-- remove existing attack objects
			unit:remove_modifications ( { item_id = "gdt_attack" }, "object" )
		else
			-- copy attack from specified unit_type & attack index
			local t = utils.split_to_table ( str )
			local utype, index = t[1], t[2]
			local attack = helper.get_nth_child ( wesnoth.unit_types[utype].__cfg, "attack", index )
			if attack then
				attack.apply_to = "new_attack"
				local object = { item_id = "gdt_attack", delayed_variable_substitution = true, { "effect", attack } }
				unit:add_modification ( "object", object )
			end
		end
	end
end

function unit_ops.canrecruit ( unit, bool )
	wml_actions.modify_unit { { "filter", { id = unit.id } }, canrecruit = bool }
end

function unit_ops.copy ( unit, int )
	-- do it this way instead of using wesnoth.copy_unit as it doesn't
	-- handle specified ids (ie, 'Konrad') the way we want it to.
	if int ~= 0 then
		for i = 1, int do
			local copy = unit.__cfg
			copy.id, copy.underlying_id = nil, nil -- so custom ids are not duplicated & generic ids will match uid
			copy.name, copy.generate_name = nil, true --so copies have different names
			copy = wesnoth.create_unit( copy )
			if unit.valid == "recall" then
				copy:to_recall ( )
			else
				local x, y = wesnoth.find_vacant_tile ( unit.x, unit.y, copy )
				copy:to_map ( x, y )
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

function unit_ops.heal ( unit, bool )
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
		unit:transform ( unit_type )
		unit.experience = 0
	else
		unit.advances_to = utils.split_to_table ( advances_to )
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
		if str == " " then -- remove all existing objects and advancements
			unit:remove_modifications( {}, "object" )
			unit:remove_modifications( {}, "advancement" )
		else
			local t = utils.split_to_table ( str )
			if t[1] == "remove" then
				-- remove modification specified by magic word, mod_type, & index - ex: remove,advancement,2
				local mtype, index = t[2], t[3]
				local umods = helper.get_child( unit.__cfg, "modifications" )
				local modification = helper.get_nth_child( umods, mtype, index )
				if modification then
					unit:remove_modifications( modification, mtype )
				end
			else
				-- copy modification specified by unit id, mod type, & index - ex: Delfador,object,1
				local id, mtype, index = t[1], t[2], t[3]
				local u = wesnoth.get_unit( id ) or wesnoth.get_recall_units( { id = id } )[1]
				local umods = helper.get_child( u.__cfg, "modifications" )
				local modification = helper.get_nth_child( umods, mtype, index )
				if modification then
					unit:add_modification ( mtype, modification )
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

function unit_ops.traits ( unit, str )
	if str ~= unit_ops.get_traits_string ( unit ) then
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
		local new_traits = utils.split_to_table ( str )
		-- since musthaves are automatically reapplied, temporary turn unit
		-- into one without traits so accidental dupes are avoided and order respected
		local utype, hitpoints, moves = unit.type, unit.hitpoints, unit.moves
		unit:transform ( "Fog Clearer" ) -- if removed, replace with low move unit
		-- remove existing traits
		unit:remove_modifications( {}, "trait" )
		-- remove undead status keys, in case undead trait is being removed
		unit.status.not_living = nil
		unit.status.undrainable = nil
		unit.status.unplaugeable = nil
		unit.status.unpoisonable = nil
		-- add the user specified traits
		for i = 1, #new_traits do
			for j = 1, #trait_array do
				if new_traits[i] == trait_array[j].id then
					unit:add_modification ( "trait", trait_array[j] )
					break
				end
			end
		end
		-- restore unit to correct type
		unit:transform ( utype )
		unit.hitpoints, unit.moves = hitpoints, moves
	end
end

function unit_ops.unrenamable ( unit, bool )
	wml_actions.modify_unit { { "filter", { id = unit.id } }, unrenamable = bool }
end

function unit_ops.variables ( unit, str )
	if str ~= "" then
		local t = utils.split_to_table ( str, "=" )
		key, value = t[1], t[2]
		unit.variables[key] = value
	end
end

function unit_ops.variation ( unit, str )
	if str ~= unit.__cfg.variation then
		wml_actions.modify_unit { { "filter", { id = unit.id } }, variation = str }
		unit:transform ( unit.type ) -- so the variation change will take
	end
end

return unit_ops