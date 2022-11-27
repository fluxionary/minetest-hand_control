local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local S = minetest.get_translator(modname)

assert(
	type(futil.version) == "number" and futil.version >= os.time({ year = 2022, month = 10, day = 24 }),
	"please update futil"
)

hand_control = {
	version = os.time({ year = 2022, month = 10, day = 26 }),
	fork = "fluxionary",

	modname = modname,
	modpath = modpath,

	S = S,

	has = {
		default = minetest.get_modpath("default"),
	},

	log = function(level, messagefmt, ...)
		return minetest.log(level, ("[%s] %s"):format(modname, messagefmt:format(...)))
	end,

	dofile = function(...)
		return dofile(table.concat({ modpath, ... }, DIR_DELIM) .. ".lua")
	end,
}

hand_control.dofile("settings")
hand_control.dofile("formspec")
hand_control.dofile("chatcommands")

minetest.register_on_joinplayer(function(player, last_login) end)
