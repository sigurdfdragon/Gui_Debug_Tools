-- #textdomain wesnoth-Gui_Debug_Tools
local _ = wesnoth.textdomain "wesnoth-Gui_Debug_Tools"
local wml_actions = wesnoth.wml_actions

wesnoth.require '~add-ons/Gui_Debug_Tools/lua/unit_debug.lua'
wesnoth.require '~add-ons/Gui_Debug_Tools/lua/side_debug.lua'

wml_actions.set_menu_item { id = "_1_gamestate_inspector" ,
	description = _ "Gamestate Inspector" ,
	image = "magical.png",
	{ "show_if" , {
		{ "lua", { code=[[return wesnoth.game_config.debug]] } }
	}},
	{ "command" , { 
		{ "inspect", { name="GUI Debug Tools" .. " " .. wesnoth.dofile '~add-ons/Gui_Debug_Tools/dist/version' } }
	}}
}

wml_actions.set_menu_item { id = "_2_lua_console" ,
	description = _ "Lua Console" ,
	image = "magical.png",
	{ "show_if" , {
		{ "lua", { code=[[return wesnoth.game_config.debug]] } }
	}},
	{ "command" , { 
		{ "lua", { code=[[wesnoth.show_lua_console()]] } }
	}}
}

wml_actions.set_menu_item { id = "_3_unit_debug" ,
	description = _ "Unit Debug" ,
	image = "magical.png",
	{ "show_if" , {
		{ "lua", { code=[[return wesnoth.game_config.debug]] } },
		{ "have_unit", { x = "$x1", y = "$y1" } }
	}},
	{ "command" , { 
		{ "gui_unit_debug" }
	}}
}

wml_actions.set_menu_item { id = "_4_side_debug" ,
	description = _ "Side Debug" ,
	image = "magical.png",
	{ "show_if" , {
		{ "lua", { code=[[return wesnoth.game_config.debug]] } },
		{ "have_unit", { x = "$x1", y = "$y1" } }
	}},
	{ "command" , { 
		{ "gui_side_debug" }
	}}
}
