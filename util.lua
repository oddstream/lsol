-- util

local Util = {}

function Util.smoothstep(A, B, v)
    -- see http://sol.gfxile.net/interpolation/
    v = (v) * (v) * (3.0 - 2.0 * (v));
    return (B * v) + (A * (1.0 - v));
end

function Util.smootherstep(A, B, v)
    -- see http://sol.gfxile.net/interpolation/
    v = (v) * (v) * (v) * ((v)*((v) * 6.0 - 15.0) + 10.0);
    return (B * v) + (A * (1.0 - v));
end

function Util.lerp(start, finish, factor)
	-- return start*(1-factor) + finish*factor
	-- Precise method, which guarantees v = v1 when t = 1.
	-- https://en.wikipedia.org/wiki/Linear_interpolation
	return (1 - factor) * start + factor * finish;
end

--[[
	The opposite of lerp. Instead of a range and a factor, we give a range and a value to find out the factor.
]]
function Util.normalize(start, finish, value)
	return (value - start) / (finish - start)
end

--[[
	converts a value from the scale [fromMin, fromMax] to a value from the scale[toMin, toMax].
	It’s just the normalize and lerp functions working together.
]]
function Util.mapValue(value, fromMin, fromMax, toMin, toMax)
	return Util.lerp(toMin, toMax, Util.normalize(fromMin, fromMax, value))
end

function Util.clamp(value, min, max)
	return math.min(math.max(value, min), max)
end

--[[
	due to the lack of bit operators in Lua 5.1, it's tricky to use CRC32 to compare
	two baizes for any changes. So, we just use two tables that record the length of
	each pile
]]
function Util.baizeChanged(old, new)
	assert(type(old)=='table')
	assert(type(new)=='table')
	if #old ~= #new then
		return true	-- shouldn't ever happen
	end
	for i = 1, #old do
		if old[i] ~= new[i] then return true end
	end
	return false
end

function Util.MoveCard(src, dst)
	local c = src:pop()
	if c then
		dst:push(c)
	end
end

return Util
