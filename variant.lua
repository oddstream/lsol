-- variant, base class for all variants, implements fallback behaviour

local log = require 'log'

local Util = require 'util'

---@class Variant
---@field Wikipedia string
local Variant = {}
Variant.__index = Variant

function Variant.new(o)
	o = o or {}
	o.wikipedia='https://en.wikipedia.org/wiki/Patience_(game)'
	return setmetatable(o, Variant)
end

function Variant:buildPiles()
	log.error('base function should not be called')
end

function Variant:startGame()
	log.error('base function should not be called')
end

function Variant:afterMove()
	-- do nothing if variant does not implement this
end

function Variant:moveTailError(tail)
	log.error('base function should not be called')
	return nil
end

---@return string|nil
function Variant:tailAppendError(dst, tail)
	log.error('base function should not be called')
	return nil
end

---@return integer
function Variant:unsortedPairs(pile)
	log.error('base function should not be called')
	return 0
end

---@return number
function Variant:percentComplete()
	-- default percentComplete behaviour
	-- variants (eg Accordian) can override this
	local pairs = 0
	local unsorted = 0
	for _, p in ipairs(_G.BAIZE.piles) do
		if #p.cards > 1 then
			pairs = pairs + (#p.cards - 1)
			unsorted = unsorted + p:unsortedPairs()
		end
	end
	return 100 - Util.mapValue(unsorted, 0, pairs, 0, 100)
end

---@return boolean
function Variant:complete()
	-- trigger the default behaviour
	-- variants (eg Accordian) can override this
	return _G.BAIZE:complete()
end

-- there is no default for pileTapped
-- it's up to each variant to implement this
-- pileTapped on a Stock pile will usually recycle Waste cards to Stock
-- in Spider it just displays a message

function Variant:tailTapped(tail)
	tail[1].parent:tailTapped(tail)
end

---default behaviour for cardSelected;
---return false means 'script did nothing'
---return true means 'script handled this COMPLETELY'
---@param card Card
---@return boolean
function Variant:cardSelected(card)
	return false
end

---return command line name for fc-solver, see https://fc-solve.shlomifish.org/docs/distro/USAGE.html
function Variant:fcSolver()
	return ''
end

return Variant
