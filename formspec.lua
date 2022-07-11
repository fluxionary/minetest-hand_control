hand_control.formspec = {}

local F = minetest.formspec_escape
local pairs_by_key = hand_control.util.pairs_by_key
local table_size = hand_control.util.table_size

local fsl = fs_layout

function hand_control.formspec.build_creative(name)
	local player = minetest.get_player_by_name(name)
	if not player then
		return ""
	end

	local inv = player:get_inventory()
	local hand = inv:get_stack("hand", 1)

	local hand_toolcaps = hand:get_tool_capabilities()
	local i = 1
	local num_caps = table_size(hand_toolcaps.groupcaps)

	local fs_parts = {
		fsl.field(3, 1, "full_punch_interval", "full_punch_interval", ("%.03f"):format(hand_toolcaps.full_punch_interval)),
		fsl.field(3, 1, "max_drop_level", "max_drop_level", hand_toolcaps.max_drop_level),
		--fsl.background(8, num_caps + .5, "[combine:16x16^[noalpha^[colorize:#00f"),
		fsl.line_break(),
		fsl.label("tool capabilities"),
		fsl.line_break(),
	}

	for group, caps in pairs_by_key(hand_toolcaps.groupcaps) do
		table.insert(fs_parts, ("field[0.25,%s;3.5,1;cg_%i_name;group;%s]"):format(i + 0.7, i, group))
		table.insert(fs_parts, ("field[3.75,%s;1.5,1;cg_%i_maxlevel;max level;%i]"):format(i + 0.7, i, caps.maxlevel))
		table.insert(fs_parts, ("field[5.25,%s;1,1;cg_%i_time_1;time (1);%s]"):format(i + 0.7, i, caps.times[1] and ("%.03f"):format(caps.times[1]) or ""))
		table.insert(fs_parts, ("field[6.25,%s;1,1;cg_%i_time_2;time (2);%s]"):format(i + 0.7, i, caps.times[2] and ("%.03f"):format(caps.times[2]) or ""))
		table.insert(fs_parts, ("field[7.25,%s;1,1;cg_%i_time_3;time (3);%s]"):format(i + 0.7, i, caps.times[3] and ("%.03f"):format(caps.times[3]) or ""))

		--table.insert(fs_parts, ("field[0.25,%s;7,1;cap_group_%s;%s;%s]"):format(i + 0.7, group, group, F(serialize(caps))))
		i = i + 1
	end

	local num_dgs = table_size(hand_toolcaps.damage_groups)
	table.insert(fs_parts, ("background[0,%s;8,%s;%s]"):format(i + .8, num_dgs + 0.5, F("[combine:16x16^[noalpha^[colorize:#f00")))
	table.insert(fs_parts, ("label[0,%s;damage groups]"):format(0.8 - 0.65 + i + 0.5))

	for group, damage in pairs_by_key(hand_toolcaps.damage_groups) do
		table.insert(fs_parts, ("field[0.25,%i.5;7,1;damage_group_%s;%s;%s]"):format(i + 1, group, group, damage))
		i = i + 1
	end

	return table.concat(fs_parts, "")
end

function hand_control.formspec.show_creative(name)
	minetest.show_formspec(name, "hand_control:creative", hand_control.formspec.build_creative(name))
end

function hand_control.formspec.build_survival(name)
	local player = minetest.get_player_by_name(name)
	if not player then
		return ""
	end

	local available_groupcaps = hand_control.default_groupcaps

	local inv = player:get_inventory()
	local hand = inv:get_stack("hand", 1)

	local hand_toolcaps = hand:get_tool_capabilities()
	local hand_groupcaps = hand_toolcaps.groupcaps

	local fs_parts = {"size[3,4]"}

	local i = 0
	for group in pairs(available_groupcaps) do
		if hand_groupcaps[group] then
			table.insert(fs_parts, ("checkbox[0,%s;%s;%s;true]"):format(i / 2, group, group))
		else
			table.insert(fs_parts, ("checkbox[0,%s;%s;%s;false]"):format(i / 2, group, group))
		end
		i = i + 1
	end

	return table.concat(fs_parts, "")
end

function hand_control.formspec.show_survival(name)
	minetest.show_formspec(name, "hand_control:survival", hand_control.formspec.build_survival(name))
end

function hand_control.formspec.handle_survival(player, fields)
	if not player then
		return ""
	end

	for group, _ in pairs(hand_control.default_groupcaps) do
		local change_id = ("hand_control:survival_cap_%s"):format(group)

		if fields[group] == "true" then
			hand_monoid.monoid:del_change(player, change_id)

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
