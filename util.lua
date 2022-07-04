local util = {}

function util.serialize(x)
	if (type(x) == "number" or type(x) == "boolean" or type(x) == "nil") then
		return tostring(x)
	elseif type(x) == "string" then
		return ("%q"):format(x)
	elseif type(x) == "table" then
		local parts = {}
		for k, v in pairs(x) do
			table.insert(parts, ("[%s] = %s"):format(util.serialize(k), util.serialize(v)))
		end
		return ("{%s}"):format(table.concat(parts, ", "))
	else
		error(("can't serialize type %s"):format(type(x)))
	end
end

function util.pairs_by_key(t, sort_function)
	local s = {}
	for k, v in pairs(t) do
		table.insert(s, {k, v})
	end

	if sort_function then
		table.sort(s, function(a, b)
			return sort_function(a[1], b[1])
		end)
	else
		table.sort(s, function(a, b)
			return a[1] < b[1]
		end)
	end

	local i = 0
	return function()
		i = i + 1
		local v = s[i]
		if v then
			return unpack(v)
		else
			return nil
		end
	end
end

function util.table_size(t)
	local size = 0
	for _ in pairs(t) do
		size = size + 1
	end
	return size
end

hand_control.util = util
