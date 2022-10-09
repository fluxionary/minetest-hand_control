hand_control.formspec = {}

local fsl = fs_layout

local pairs_by_key = table.pairs_by_key

function hand_control.formspec.build_creative(name)
	local player = minetest.get_player_by_name(name)
	if not player then
		return ""
	end

	local inv = player:get_inventory()
	local hand = inv:get_stack("hand", 1)

	local hand_toolcaps = hand:get_tool_capabilities()
	local i = 1
	--local num_caps = table_size(hand_toolcaps.groupcaps)

	local elements = {
		fsl.field(3, 1, "full_punch_interval", "full_punch_interval", ("%.03f"):format(hand_toolcaps.full_punch_interval)),
		fsl.field(3, 1, "max_drop_level", "max_drop_level", hand_toolcaps.max_drop_level),
		--fsl.background(8, num_caps + .5, "[combine:16x16^[noalpha^[colorize:#00f"),
		fsl.line_break(),
		fsl.label("tool capabilities"),
		fsl.line_break(),
	}

	local toolcap_elements = {}
	for group, caps in pairs_by_key(hand_toolcaps.groupcaps) do
		table.insert_all(toolcap_elements, {
			fsl.field(3.5, 1, ("cg_%i_name"):format(i), "group", group),
			fsl.field(1.5, 1, ("cg_%i_maxlevel"):format(i), "max level", caps.maxlevel),
			fsl.field(1, 1, ("cg_%i_time_1"):format(i), "time (1)", caps.times[1] and ("%.03f"):format(caps.times[1])),
			fsl.field(1, 1, ("cg_%i_time_2"):format(i), "time (2)", caps.times[2] and ("%.03f"):format(caps.times[2])),
			fsl.field(1, 1, ("cg_%i_time_3"):format(i), "time (3)", caps.times[3] and ("%.03f"):format(caps.times[3])),
			fsl.line_break(),
		})
		i = i + 1
	end

	table.insert(elements, fsl.scroll_container(toolcap_elements))

	--local num_dgs = table_size(hand_toolcaps.damage_groups)
	--table.insert(fs_parts, ("background[0,%s;8,%s;%s]"):format(i + .8, num_dgs + 0.5, F("[combine:16x16^[noalpha^[colorize:#f00")))

	table.insert_all(elements, {
		fsl.label("damage groups"),
		fsl.line_break(),
	})

	i = 1
	for group, damage in pairs_by_key(hand_toolcaps.damage_groups) do
		table.insert_all(elements, {
			fsl.field(3.5, 1, ("damage_group_%i"):format(i), "group", group),
			fsl.field(2, 1, ("damage_%i"):format(i), "damage", damage),
			fsl.line_break(),
		})
		i = i + 1
	end

	table.insert(elements,
		fsl.button(2, 1, "reset_to_default", "reset to default")
	)

	elements.formspec_version = 1

	return fs_layout.compose(elements, 0.5, 0.5)
end

function hand_control.formspec.show_creative(name)
	minetest.show_formspec(name, "hand_control:creative", hand_control.formspec.build_creative(name))
end

function hand_control.formspec.build_survival(name)
	local player = minetest.get_player_by_name(name)
	if not player then
		return ""
	end

	local inv = player:get_inventory()
	local hand = inv:get_stack("hand", 1)

	local hand_toolcaps = hand:get_tool_capabilities()
	local hand_groupcaps = hand_toolcaps.groupcaps

	local elements = {
		fsl.size(4, 3)
	}

	local i = 0
	for group in pairs_by_key(hand_monoid.settings.groupcaps) do
		if hand_groupcaps[group] then
			table.insert(elements, fsl.checkbox(group, group, true))
		else
			table.insert(elements, fsl.checkbox(group, group, false))
		end
		table.insert(elements, fsl.line_break(0.5))
		i = i + 1
	end

	elements.formspec_version = 1

	return fs_layout.compose(elements, 0.5, 0.5)
end

function hand_control.formspec.show_survival(name)
	minetest.show_formspec(name, "hand_control:survival", hand_control.formspec.build_survival(name))
end

function hand_control.formspec.handle_survival(player, fields)
	if not player then
		return ""
	end

	for group, caps in pairs(hand_monoid.settings.groupcaps) do
		local change_id = ("hand_control:survival_cap_%s"):format(group)

		if fields[group] == "true" then
			hand_monoid.monoid:add_change(player, {groupcaps = {[group] = caps}}, change_id)

		elseif fields[group] == "false" then
			hand_monoid.monoid:add_change(player, {groupcaps = {[group] = {}}}, change_id)
		end
	end
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "hand_control:survival" then
		hand_control.formspec.handle_survival(player, fields)
	end
end)
