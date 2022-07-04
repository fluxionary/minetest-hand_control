minetest.register_chatcommand("hand_control", {
	description = "open the hand control GUI",
	func = function(name)
		if minetest.check_player_privs(name, hand_control.settings.creative_priv) then
			hand_control.formspec.show_creative(name)
		else
			hand_control.formspec.show_survival(name)
		end
	end,
})
