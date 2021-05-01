-- #textdomain wesnoth-Gui_Debug_Tools
local _ = wesnoth.textdomain "wesnoth-Gui_Debug_Tools"
local wml_actions = wesnoth.wml_actions

wml_actions.set_menu_item { id = "_1_gamestate_inspector" ,
	description = _ "Gamestate Inspector" ,
	image = "magical.png",
	{ "show_if" , {
		{ "lua", { code=[[return wesnoth.game_config.debug]] } }
	}},
	{ "command" , {
		{ "lua", { code=[[gui.show_inspector({})]] } }
	}}
}

wml_actions.set_menu_item { id = "_2_lua_console" ,
	description = _ "Lua Console" ,
	image = "magical.png",
	{ "show_if" , {
		{ "lua", { code=[[return wesnoth.game_config.debug]] } }
	}},
	{ "command" , { 
		{ "lua", { code=[[gui.show_lua_console()]] } }
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
		{ "lua", { code=[[wesnoth.dofile( '~add-ons/Gui_Debug_Tools/lua/unit_debug.lua' )]] } }
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
		{ "lua", { code=[[wesnoth.dofile( '~add-ons/Gui_Debug_Tools/lua/side_debug.lua' )]] } }
	}}
}
