-- util

local CC = require 'cc'
local log = require 'log'

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

-- overlapArea returns the intersection area of two rectangles
function Util.overlapArea(x, y, w, h, X, Y, W, H)
	local ox = math.max(0, math.min(x + w, X + W) - math.max(x, X));
	local oy = math.max(0, math.min(y + h, Y + H) - math.max(y, Y));
	-- local x = math.max(0, math.min(a.x2, b.x2) - math.max(a.x1, b.x1));
	-- local y = math.max(0, math.min(a.y2, b.y2) - math.max(a.y1, b.y1));
	return ox * oy;
end

function Util.inRect(x, y, rx, ry, rw, rh)
	return x >= rx and y >= ry and x < (rx + rw) and y < (ry + rh)
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

function Util.colorBytes(s)
	local setting = _G.BAIZE.settings[s]
	if not setting then
		log.error('No setting for', s)
		return 0.5, 0.5, 0.5
	end
	if not _G.PATIENCE_COLORS[setting] then
		log.error('No color for', s)
		return 0.5, 0.5, 0.5
	end
	return love.math.colorFromBytes(unpack(_G.PATIENCE_COLORS[setting]))
end

function Util.makeCardPairs(tail)
	if #tail < 2 then
		return {}
	end
	local cpairs = {}
	local c1 = tail[1]
	for i = 2, #tail do
		local c2 = tail[i]
		table.insert(cpairs, {c1, c2})
		c1 = c2
	end
	return cpairs
end

function Util.moveCard(src, dst)
	local c = src:pop()
	if c then
		dst:push(c)
		src:flipUpExposedCard()
	end
	return c
end

function Util.moveCards(src, idx, dst)
	local tmp = {}
	while #src.cards >= idx do
		table.insert(tmp, src:pop())
	end
	while #tmp > 0 do
		dst:push(table.remove(tmp))
	end
	src:flipUpExposedCard()
end

function Util.unsortedPairs(pile, fn)
	if #pile.cards < 2 then
		return 0
	end
	local unsorted = 0
	local cpairs = Util.makeCardPairs(pile.cards)
	for _, cpair in ipairs(cpairs) do
		if CC.EitherProne(cpair) then
			unsorted = unsorted + 1
		else
			local err = fn(cpair)
			if err then
				unsorted = unsorted + 1
			end
		end
	end
	return unsorted
end

local soundRandomizer = {
	fan = {'fan1', 'fan2'},
	place = {'place1','place2','place3','place4'},
	shove = {'shove1','shove2','shove3','shove4'},
}

function Util.play(name)
	if _G.BAIZE.settings.muteSound then
		return
	end
	local trueName
	local lst = soundRandomizer[name]
	if lst then
		local n = math.random(#lst)
		trueName = lst[n]
	else
		trueName = name
	end
	love.audio.play(_G.PATIENCE_SOUNDS[trueName])
end

return Util
