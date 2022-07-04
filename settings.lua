local hand_caps = minetest.registered_items[""].tool_capabilities

local function parse_lua(code)
	local f = loadstring(("return %s"):format(code))
	if f then
		return f()
	end
end

local s = minetest.settings

hand_control.settings = {
	full_punch_interval = tonumber(s:get("hand_control.full_punch_interval")) or hand_caps.full_punch_interval,
	max_drop_level = tonumber(s:get("hand_control.max_drop_level")) or hand_caps.max_drop_level,
	groupcaps = parse_lua(s:get("hand_control.groupcaps")) or hand_caps.groupcaps,
	damage_groups = parse_lua(s:get("hand_control.damage_groups")) or hand_caps.damage_groups,

	creative_priv = s:get("hand_control.creative_priv") or "creative",
}
