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
	return ox * oy;
end

function Util.rectContains(X, Y, W, H, x, y, w, h)
	if x < X or y < Y then
		return false
	end
	if x + w > X + W then
		return false
	end
	if y + h > Y + H then
		return false
	end
	return true
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

function Util.getColorFromSetting(s)
	local setting = _G.SETTINGS[s]
	if not setting then
		log.error('No setting called', s)
		return 0.5, 0.5, 0.5
	end
	local col = _G.LSOL_COLORS[setting]
	if not col then
		log.error('No color for setting', s)
		return 0.5, 0.5, 0.5
	end
	return love.math.colorFromBytes(unpack(col))
end

function Util.setColorFromSetting(s)
	love.graphics.setColor(Util.getColorFromSetting(s))
end

function Util.getColorFromName(nam)
	local col = _G.LSOL_COLORS[nam]
	if not col then
		log.error('No color named', nam)
		return 0.5, 0.5, 0.5
	end
	return love.math.colorFromBytes(unpack(col))
end

function Util.setColorFromName(nam)
	return love.graphics.setColor(Util.getColorFromName(nam))
end

function Util.getGradientColors(settingName, default, amount)
	amount = amount or 0.1
	local color = _G.SETTINGS[settingName] or default
	local r, g, b, a = love.math.colorFromBytes(unpack(_G.LSOL_COLORS[color]))
	local amt = amount + 1.0
	local frontColor = {r * amt, g * amt, b * amt, a}
	-- backColor = {r - 0.1, g - 0.15, b - 0.2, a}
	amt = 1.0 - amount
	local backColor = {r * amt, g * amt, b * amt, a}
	return frontColor, backColor
end

function Util.getForegroundColor(backgroundColor)
	if not backgroundColor then
		log.error('Unknown color', backgroundColor)
		return 'UiForeground'
	end

	local color = _G.LSOL_COLORS[backgroundColor]
	if not color then
		log.error('No color', backgroundColor)
		return 'UiForeground'
	end
	local r, g, b = color[1], color[2], color[3]
	local foreColor
	if r + b + g > 400 then
		foreColor = 'UiBackground'
	else
		foreColor = 'UiForeground'
	end
	return foreColor
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
		if dst.category == 'Foundation' then
			Util.play('move2')
		else
			Util.play('move1')
		end
		dst:push(c)
		src:flipUpExposedCard()
	end
	return c
end

function Util.moveCardByOrd(src, dst, ord)
	local c = src:disinterOneCardByOrd(ord)
	if c then
		return Util.moveCard(src, dst)
	else
		log.error('Cannot find card', ord)
	end
	return nil
end

function Util.moveCardByOrdAndSuit(src, dst, ord, suit)
	local c = src:disinterOneCard(ord, suit)
	if c then
		return Util.moveCard(src, dst)
	else
		log.error('Cannot find card', ord, suit)
	end
	return nil
end

function Util.moveCards(src, idx, dst)
	local tmp = {}
	while #src.cards >= idx do
		table.insert(tmp, src:pop())
	end
	if dst.category == 'Foundation' or dst.category == 'Discard' then
		Util.play('move2')
	elseif #tmp > 1 then
		Util.play('move4')
	else
		Util.play('move1')
	end
	while #tmp > 0 do
		dst:push(table.remove(tmp))
	end
	src:flipUpExposedCard()
end

function Util.findHomesForTail(tail)

	local homes = {}	-- {dst=<pile>, weight=<number>}

	for _, card in ipairs(tail) do
		if card.prone then
			return homes
		end
	end

	local pileTypesToCheck = {_G.BAIZE.foundations, _G.BAIZE.tableaux, _G.BAIZE.cells}
	-- TODO adding discards here didn't move completed tail to discard
	local card = tail[1]
	local src = card.parent

	-- the following two checks should have already been made
	-- can the tail be moved in general?
	if src:moveTailError(tail) then
		log.error('Pile:tailMoveError')
		return homes
	end
	-- is the tail conformant enough to move?
	if _G.BAIZE.script:moveTailError(tail) then
		log.error('script:tailMoveError')
		return homes
	end

	for _, piles in ipairs(pileTypesToCheck) do
		for _, dst in ipairs(piles) do
			if dst ~= src then
				local err = dst:acceptTailError(tail)
				if not err then
					local home = {dst=dst, weight=#dst.cards}
					if #dst.cards == 0 then
		--[[
		if #dst.cards == 0 and #tail.tail == #src.cards then
			if src.label == dst.label then
				if src.category == dst.category then
					movable = false
				end
			end
		end
		if #tail.tail == #src.cards then
			if src.label == dst.label then
				if src.category == dst.category then
					home = nil
				end
			end
		end
		]]
						if not dst.label then
							-- filling an empty pile can be a poor move
							home.weight = 0
						end
					else
						if card.suit == dst:peek().suit then
							-- spider
							home.weight = home.weight + 26	-- magic number
						end
					end
					if dst.category == 'Foundation' then
						home.weight = home.weight + 52	-- magic number
					end
					table.insert(homes, home)
				end
			end
		end
	end

	return homes
end

function Util.unsortedPairs(tail, fn)
	if #tail < 2 then
		return 0
	end
	local unsorted = 0
	local cpairs = Util.makeCardPairs(tail)
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

function Util.play(name)
	if _G.SETTINGS.muteSounds then
		return
	end
	-- _G.LSOL_SOUNDS[name]:seek(0)
	-- love.audio.stop()
	if _G.LSOL_SOUNDS[name] then
		love.audio.play(_G.LSOL_SOUNDS[name])
	else
		log.error('no sound for', name)
	end
end

function Util.orientation()
	local _, _, safew, safeh = love.window.getSafeArea()
	if safew > safeh then
		return 'landscape'
	elseif safeh > safew then
		return 'portrait'
	else
		return 'square'
	end
end

return Util
