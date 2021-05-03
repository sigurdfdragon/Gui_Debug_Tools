-- #textdomain wesnoth-Gui_Debug_Tools
local _ = wesnoth.textdomain "wesnoth-Gui_Debug_Tools"

local utils = {}

-- to make code shorter
local wml_actions = wesnoth.wml_actions

-- support functions for handling strings
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

function utils.split_to_table ( str, char )
	local char = char or ","
	local t = {}
	for value in utils.split( str, char ) do
		table.insert( t, utils.chop( value ) )
	end
	return t
end

return utils
