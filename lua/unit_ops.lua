-- #textdomain wesnoth-Gui_Debug_Tools
local _ = wesnoth.textdomain "wesnoth-Gui_Debug_Tools"

local unit_ops = { }

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
			local sources = stringx.split ( str )
			for i = 1, #sources do
				local ability = wml.get_child ( wesnoth.unit_types[sources[i]].__cfg, "abilities" )
				if ability then
					local object = { item_id = "gdt_ability", delayed_variable_substitution = true, { "effect", { apply_to = "new_ability", { "abilities", ability } } } }
					unit:add_modification ( "object", object )
				end
			end
		end
	end
end

function unit_ops.advancement_count ( unit )
	local umods = wml.get_child ( unit.__cfg, "modifications" )
	return wml.child_count ( umods, "advancement" )
end

function unit_ops.advancements ( unit, int )
	local count = unit_ops.advancement_count ( unit )
	if ( int ~= count ) and ( int == 0 ) then -- always allow clearing
		unit:remove_modifications ( { }, "advancement" )
		-- if we are clearing amlas from a unit at max level, give a heal for consistency, as that happens when increasing or decreasing as well.
		if unit.advances_to[1] == nil then
			wml_actions.heal_unit { { "filter", { id = unit.id } }}
		end
	elseif ( int ~= count ) and ( not unit.advances_to[1] ) then
		if int > count then -- since increasing, apply the difference
			for i = 1, int - count do
				unit.experience = unit.max_experience ; unit:advance ( false, true )
			end
		elseif int < count then -- clear all current & reapply specified amount to decrease
		-- make copy table of all adavancements on unit,
		-- decrease to desired number by removing last in, first out from copy
		-- purge all advancements from unit, then reapply the copy's remaining advancements.
			local config = unit.__cfg
			local modifications = wml.get_child ( config, "modifications" )
			local advancement = wml.child_array ( modifications, "advancement" )
			for i = 1, count - int do
				table.remove ( advancement )
			end
			unit:remove_modifications ( { }, "advancement" )
			for i = 1, #advancement do
				unit:add_modification ( "advancement", advancement[i] )
			end
		end
	end
end

function unit_ops.alignment_check ( unit )
	-- determine if the unit has a GDT alignment object.
	-- If not, report 'default' - unit has alignment of unit type, or a non-gdt change.
	-- If so, report what alignment the object is setting.
	-- might not be sufficent handling if a non-gdt alignment object is added after a gdt object.
	local umods = wml.get_child ( unit.__cfg, "modifications" )
	local gdt_alignment_present = wml.find_child ( umods, "object", { item_id = "gdt_alignment" } )
	local str = ""
	if gdt_alignment_present ~= nil then
		str = unit.alignment
	else
		str = "default"
	end
	return str
end

function unit_ops.alignment ( unit, str )
-- create, replace or remove alignment object as specified by user choice.
		if str == "default" then
			-- alignment is set by unit type or non-gdt object
			-- remove any existing gdt alignment objects
			unit:remove_modifications ( { item_id = "gdt_alignment" }, "object" )
		elseif unit.alignment == str and unit_ops.alignment_check ( unit ) == str then
			-- do nothing, unit alignment is the same as what's currently being applied by a gdt_alignment object
		else
			-- a change was made, and not to default, so remove any existing gdt alignement objects & then apply one.
			unit:remove_modifications ( { item_id = "gdt_alignment" }, "object" )
			local object = { item_id = "gdt_alignment", { "effect", { apply_to = "alignment", set = str } } }
			unit:add_modification ( "object", object )
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
			local t = stringx.split ( str )
			local utype, index = t[1], t[2]
			local attack = wml.get_nth_child ( wesnoth.unit_types[utype].__cfg, "attack", index )
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
			copy = wesnoth.units.create ( copy )
			if unit.valid == "recall" then
				copy:to_recall ( )
			else
				local x, y = wesnoth.find_vacant_tile ( unit.x, unit.y, copy )
				copy:to_map ( x, y )
			end
		end
	end
end

function unit_ops.experience ( unit, experience )
	-- other functions done before this may have changed max_experience,
	-- so this takes that into account. ie, changing unit type or applying intelligent trait.
	-- lower slider value if it would cause leveling, otherwise keep it. Set to 0 if it somehow would be negative.
	unit.experience = math.max ( 0, math.min ( experience, unit.max_experience - 1 ) )
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

function unit_ops.get_level_max ( unit )
	-- assemble list of the unit and all possible advance_to, recursively
	local types = { }
	table.insert ( types, unit.type ) -- add itself
	local advances_to = unit.advances_to -- current advances_to, may be different than wesnoth.unit_types[unit.type].advances_to
	for a = 1, #advances_to do
		table.insert ( types, advances_to[a] )
	end
	local i = 1
	while types[i] do
		local advances_to = wesnoth.unit_types[types[i]].advances_to
		for a = 1, #advances_to do
			-- check that current type is not already on the list to avoid recursion
			local present = false
			for t = 1, #types do
				if advances_to[a] == types[t] then
					present = true
				end
			end
			if not present then
				table.insert ( types, advances_to[a] )
			end
		end
		i = i + 1
	end
	-- go through the types list and mark what is the highest level
	local max_level = unit.level
	for i = 1, #types do
		max_level = math.max ( max_level, wesnoth.unit_types[types[i]].level )
	end
	return max_level
end

function unit_ops.get_level_min ( unit )
 -- assemble list of the unit and all possible advances_from, recursively
	local types = { }
	-- add itself
	table.insert ( types, unit.type )
	local i = 1
	while types[i] do
    local advances_from = wesnoth.unit_types[types[i]].advances_from
		for a = 1, #advances_from do
			-- check that current type is not already on the list to avoid recursion
			local present = false
			for t = 1, #types do
				if advances_from[a] == types[t] then
					present = true
				end
			end
			if not present then
				table.insert ( types, advances_from[a] )
			end
		end
		i = i + 1
	end
	-- go through the types list and mark what is the lowest level
	local min_level = unit.level
	for i = 1, #types do
		min_level = math.min ( min_level, wesnoth.unit_types[types[i]].level )
	end
	return min_level
end

function unit_ops.get_traits_string ( unit )
	local unit_modifications = wml.get_child ( unit.__cfg, "modifications" ) or {}
	local trait_ids = { }
	for trait in wml.child_range ( unit_modifications, "trait" ) do
			if trait.id ~= nil then
				table.insert ( trait_ids, trait.id )
			end
	end
	return stringx.join( trait_ids )
end

function unit_ops.goto_xy ( unit, str )
	local loc = stringx.split ( str )
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

function unit_ops.level_type_advances_to ( unit, level, unit_type, advances_to )
	if unit.type ~= unit_type then
		-- disregard what is entered for level & advances_to
		unit:transform ( unit_type )
	else
		unit.advances_to = stringx.split ( advances_to )
		if unit.level ~= level then
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
		end
	end
end

function unit_ops.location ( unit, str )
	if str == "" then
		-- do it this way as wml_action.put_to_recall doesn't cover petrified or unhealable
		wml_actions.heal_unit { { "filter", { id = unit.id } }, moves = "full", restore_attacks = true }
		wml_actions.modify_unit { { "filter", { id = unit.id } }, goto_x = 0, goto_y = 0 }
		unit:to_recall ( )
	else
		local loc = stringx.split ( str )
		unit:to_map ( loc[1], loc[2] )
	end
end

function unit_ops.name ( unit, str )
	wml_actions.modify_unit { { "filter", { id = unit.id } }, name = str }
end

function unit_ops.objects ( unit, str ) -- copies or removes one or all objects
	if str ~= "" then
		local t = stringx.split ( str )
		if t[1] == "remove" then
			local index = t[2]
			if index == nil then -- remove all objects
				unit:remove_modifications ( { }, "object" )
			else -- remove object specified by magic word & index - ex: remove,2
				local umods = wml.get_child( unit.__cfg, "modifications" )
				local object = wml.get_nth_child( umods, "object", index )
				if object then
					unit:remove_modifications( object, "object" )
				end
			end
		else
			local id, index = t[1], t[2]
			local source = wesnoth.units.get( id ) or wesnoth.units.find_on_recall( { id = id } )[1]
			local umods = wml.get_child( source.__cfg, "modifications" )
			if index == nil then -- copy all objects
				local count =  wml.child_count ( umods, "object" )
				for i = 1, count do
					local object = wml.get_nth_child( umods, "object", i )
					if object then
						unit:add_modification ( "object", object )
					end
				end
			else -- copy object specified by unit id & index - ex: Delfador,1
				local object = wml.get_nth_child( umods, "object", index )
				if object then
					unit:add_modification ( "object", object )
				end
			end
		end
	end
end

function unit_ops.overlays ( unit, str )
	wml_actions.modify_unit { { "filter", { id = unit.id } }, overlays = str }
end

function unit_ops.super_heal ( unit, bool )
	if bool then
		wml_actions.heal_unit { { "filter", { id = unit.id } } }
		unit.hitpoints = math.max(unit.max_hitpoints * 20, 1000)
		unit.moves = math.max(unit.max_moves * 20, 100)
		unit.attacks_left = math.max(unit.max_attacks * 20, 20)
	end
end

function unit_ops.traits ( unit, str )
	if str ~= unit_ops.get_traits_string ( unit ) then
		-- make a table with all traits the unit can receive
		-- add global traits: quick, resilient, strong, intelligent
		local traits = { }
		local global_traits = wesnoth.game_config.global_traits
		for key, value in pairs ( global_traits ) do
			table.insert ( traits, value )
		end
		-- add more mainline traits from select races: healthy, dextrous, weak, slow, dim, mechanical, fearless, undead
		local select_races = { "dwarf", "elf", "goblin", "mechanical", "troll", "undead" }
		for index, value in ipairs ( select_races ) do
			for trait in wml.child_range ( wesnoth.races[value].__cfg, "trait" ) do
				local present
				for i = 1, #traits do
					if trait.id == traits[i].id then
						present = true ; break
					end
				end
				if not present then
					table.insert ( traits, trait )
				end
			end
		end
		-- add more mainline traits from select units: feral, elemental, aged, loyal
		local select_units = { "Vampire Bat", "Mudcrawler", "GDT Dummy" }
		for index, value in ipairs ( select_units ) do
			for trait in wml.child_range ( wesnoth.unit_types[value].__cfg, "trait" ) do
				local present
				for i = 1, #traits do
					if trait.id == traits[i].id then
						present = true ; break
					end
				end
				if not present then
					table.insert ( traits, trait )
				end
			end
		end
		-- bonus - expert, heroic, & powerful
		-- #textdomain wesnoth-Gui_Debug_Tools
		local _ = wesnoth.textdomain "wesnoth-Gui_Debug_Tools"
		-- expert - from The Great Quest
		local trait_expert = { id="expert", male_name=_"expert", female_name=_"female^expert",
			{ "effect", { apply_to="attack", increase_attacks=1 } },
			{ "effect", { apply_to="attack", increase_damage=-1 } } }
		-- heroic (Props to the World Conquest add-on for the idea.)
		-- This is The Great Quest version that has strong, resilient, quick & dextrous.
		local trait_heroic = { id="heroic", male_name=_"heroic", female_name=_"female^heroic",
			{ "effect", { apply_to="attack", increase_damage=1 } },
			{ "effect", { apply_to="hitpoints", increase_total=5 } },
			{ "effect", { apply_to="hitpoints", times="per level", increase_total=1 } },
			{ "effect", { apply_to="movement", increase=1 } } }
		-- powerful - from Random Campaign
		local trait_powerful = { id="powerful", male_name=_"powerful", female_name=_"female^powerful",
			{ "effect", { apply_to="attack", increase_damage="20%" } } }
		-- ethereal
		local trait_ethereal = { id="ethereal", male_name=_"ethereal", female_name=_"female^ethereal", description=_"1 mp & 50% defense on all terrain",
			{ "effect", { apply_to="movement_costs", replace=true, { "movement_costs",
				{ deep_water=1, shallow_water=1, reef=1, swamp_water=1, flat=1, rails=1, sand=1, forest=1, hills=1,
					mountains=1, village=1, castle=1, cave=1, frozen=1, unwalkable=1, fungus=1, impassable=1 } } } },
			{ "effect", { apply_to="defense", replace=true, { "defense",
				{ deep_water=50, shallow_water=50, reef=50, swamp_water=50, flat=50, rails=50, sand=50, forest=50, hills=50,
					mountains=50, village=50, castle=50, cave=50, frozen=50, unwalkable=50, fungus=50, impassable=50 } } } } }
		table.insert ( traits, trait_expert )
		table.insert ( traits, trait_heroic )
		table.insert ( traits, trait_powerful )
		table.insert ( traits, trait_ethereal )
		_ = nil
		-- add all traits from all known races
		for key, value in pairs ( wesnoth.races ) do
			for trait in wml.child_range ( value.__cfg, "trait" ) do
				local present
				for i = 1, #traits do
					if trait.id == traits[i].id then
						present = true ; break
					end
				end
				if not present then
					table.insert ( traits, trait )
				end
			end
		end
		-- add all traits currently held by existing units ( to get things like the void_armor trait )
		local units = wesnoth.units.find_on_map ( { } )
		local recall = wesnoth.units.find_on_recall ( { } )
		for index, value in ipairs ( recall ) do
			table.insert ( units, value )
		end
		for index, value in ipairs ( units ) do
			local umods = wml.get_child ( value.__cfg, "modifications" ) or { }
			for trait in wml.child_range ( umods, "trait" ) do
				local present
				for i = 1, #traits do
					if trait.id == traits[i].id then
						present = true ; break
					end
				end
				if not present then
					table.insert ( traits, trait )
				end
			end
		end
		-- add the unit's race, unit_type, and current traits to the array
		-- overwriting any with same id that are already in the array
		-- unit's race traits
		for trait in wml.child_range ( wesnoth.races[unit.race].__cfg, "trait" ) do
			local present
			for i = 1, #traits do
				if trait.id == traits[i].id then
					present = true ; traits[i] = trait; break
				end
			end
			if not present then
				table.insert ( traits, trait )
			end
		end
		-- unit's unit_type traits
		for trait in wml.child_range ( wesnoth.unit_types[unit.type].__cfg, "trait" ) do
			local present
			for i = 1, #traits do
				if trait.id == traits[i].id then
					present = true ; traits[i] = trait; break
				end
			end
			if not present then
				table.insert ( traits, trait )
			end
		end
		-- unit's current traits
		local umods = wml.get_child ( unit.__cfg, "modifications" ) or { }
		for trait in wml.child_range ( umods, "trait" ) do
			local present
			for i = 1, #traits do
				if trait.id == traits[i].id then
					present = true ; traits[i] = trait ; break
				end
			end
			if not present then
				table.insert ( traits, trait )
			end
		end

		-- now that all the traits to pick from have been assembled
		-- take user entered values and use to set the unit's traits
		local new_traits = stringx.split ( str )
		-- since musthaves are automatically reapplied, temporary turn unit
		-- into one without traits so accidental dupes are avoided and order respected
		local utype, hitpoints, moves = unit.type, unit.hitpoints, unit.moves
		unit:transform ( "GDT Dummy" )
		-- remove existing traits
		unit:remove_modifications( { }, "trait" )
		-- remove undead status keys, in case undead trait is being removed
		unit.status.not_living = nil
		unit.status.undrainable = nil
		unit.status.unplaugeable = nil
		unit.status.unpoisonable = nil
		-- add the user specified traits
		for n = 1, #new_traits do
			for i = 1, #traits do
				if new_traits[n] == traits[i].id then
					unit:add_modification ( "trait", traits[i] ) ; break
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
		local t = stringx.split ( str, "=" )
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
