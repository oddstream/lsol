-- cc

local log = require 'log'

local CC = {}

function CC.EitherProne(cpair)
	return cpair[1].prone or cpair[2].prone
end

function CC.Empty(pile, card)
	if pile.label then
		if pile.label == 'X' then
			return 'Cannot move cards there'
		end
		local ordStr = _G.ORD2STRING[card.ord]
		if pile.label ~= ordStr then
			return string.format('Can only accept %s, not %s', pile.label, ordStr)
		end
	end
	return nil
end

function CC.None(cpair)
	return 'No'
end

function CC.Any(cpair)
	return nil
end

function CC.Up(cpair)
	if cpair[1].ord + 1 ~= cpair[2].ord then
		return 'Cards must be in ascending sequence'
	end
	return nil
end

function CC.Down(cpair)
	if cpair[1].ord ~= cpair[2].ord + 1 then
		return 'Cards must be in descending sequence'
	end
	return nil
end

function CC.UpOrDownWrap(cpair)
	if cpair[1].ord == 13 and cpair[2].ord == 1 then
		return nil
	elseif cpair[1].ord == 1 and cpair[2].ord == 13 then
		return nil
	elseif cpair[1].ord == cpair[2].ord + 1 then
		return nil	-- eg 4 on 3
	elseif cpair[1].ord + 1 == cpair[2].ord then
		return nil	-- eg 3 on 4
	else
		return 'Cards must be up or down (Aces on Kings allowed)'
	end
end

function CC.UpOrDownSuitWrap(cpair)
	assert(cpair)
	assert(cpair[1])
	assert(cpair[2])
	assert(cpair[1].suit)
	assert(cpair[2].suit)
	if cpair[1].suit ~= cpair[2].suit then
		return 'Must be the same suit'
	end
	return CC.UpOrDownWrap(cpair)
end

function CC.UpOrDown(cpair)
	if cpair[1].ord == cpair[2].ord + 1 then
		return nil	-- eg 4 on 3
	elseif cpair[1].ord + 1 == cpair[2].ord then
		return nil	-- eg 3 on 4
	else
		return 'Cards must be up or down'
	end
end

function CC.UpOrDownSuit(cpair)
	if cpair[1].suit ~= cpair[2].suit then
		return 'Cards must be the same suit'
	end
	return CC.UpOrDown(cpair)
end

function CC.UpSuit(cpair)
	if cpair[1].suit ~= cpair[2].suit then
		return 'Cards must be the same suit'
	end
	return CC.Up(cpair)
end

function CC.UpSuitWrap(cpair)
	if cpair[1].suit ~= cpair[2].suit then
		return 'Cards must all be the same suit'
	end
	if cpair[1].ord == 13 and cpair[2].ord == 1 then
		-- Ace on King
	elseif cpair[1].ord == cpair[2].ord - 1 then
		-- up, eg 3 on a 2
	else
		return 'Cards must go up in rank (Aces on Kings allowed)'
	end
	return nil
end

function CC.DownSuit(cpair)
	if cpair[1].suit ~= cpair[2].suit then
		return 'Cards must be the same suit'
	end
	return CC.Down(cpair)
end

function CC.DownSuitWrap(cpair)
	if cpair[1].suit ~= cpair[2].suit then
		return 'Cards must be the same suit'
	end
	if cpair[1].ord == 1 and cpair[2].ord == 13 then
		-- King on Ace
	elseif cpair[1].ord - 1 == cpair[2].ord then
		-- down, eg 2 on a 3
	else
		return 'Cards must go down in rank (Kings on Aces allowed)'
	end
	return nil
end

function CC.DownColor(cpair)
	if cpair[1].black ~= cpair[2].black then
		return 'Cards must be the same color'
	end
	return CC.Down(cpair)
end

function CC.DownColorWrap(cpair)
	if cpair[1].black ~= cpair[2].black then
		return 'Cards must be the same color'
	end
	if cpair[1].ord == 1 and cpair[2].ord == 13 then
		-- King on Ace
	elseif cpair[1].ord ~= cpair[2].ord + 1 then
		return 'Cards must go down in rank (Kings on Aces allowed)'
	end
	return nil
end

function CC.UpAltColor(cpair)
	if cpair[1].black == cpair[2].black then
		return 'Cards must be in alternating colors'
	end
	return CC.Up(cpair)
end

function CC.DownAltColor(cpair)
	if cpair[1].black == cpair[2].black then
		return 'Cards must be in alternating colors'
	end
	return CC.Down(cpair)
end

function CC.DownWrap(cpair)
	if cpair[1].ord == 1 and cpair[2].ord == 13 then
		-- King on Ace
	elseif cpair[1].ord ~= cpair[2].ord + 1 then
		return 'Cards must go down in rank (Kings on Aces allowed)'
	end
	return nil
end

function CC.DownAltColorWrap(cpair)
	if cpair[1].black == cpair[2].black then
		return 'Cards must be in alternating colors'
	end
	if cpair[1].ord == 1 and cpair[2].ord == 13 then
		-- King on Ace
	elseif cpair[1].ord ~= cpair[2].ord + 1 then
		return 'Cards must go down in rank (Kings on Aces allowed)'
	end
	return nil
end

function CC.Accordian(cpair)

	local function getPileIdx(pile)
		for i, p in ipairs(_G.BAIZE.piles) do
			if p == pile then
				return i
			end
		end
		return -1
	end

	if not ((cpair[1].ord == cpair[2].ord) or (cpair[1].suit == cpair[2].suit)) then
		return 'Cards must be the same rank or suit'
	end
	local p1x = getPileIdx(cpair[1].parent)
	local p2x = getPileIdx(cpair[2].parent)
	log.trace(p1x, p2x)
	if (p1x + 1 == p2x) or (p1x + 3 == p2x) then
		return nil
	end
	return 'A card can be moved on top of another card immediately to its left or three cards to its left'
end

function CC.Thirteen(cpair)
	local sum = cpair[1].ord + cpair[2].ord
	if sum ~= 13 then
		return string.format('The cards must add up to 13, not %d', sum)
	end
	return nil
end

return CC
