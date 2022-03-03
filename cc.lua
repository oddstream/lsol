-- cc

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

function CC.UpOrDownSuit(cpair)
	if cpair[1].suit ~= cpair[2].suit then
		return 'Cards must be the same suit'
	end
	if cpair[1].ord == cpair[2].ord + 1 then
		return nil	-- eg 4 on 3
	elseif cpair[1].ord + 1 == cpair[2].ord then
		return nil	-- eg 3 on 4
	else
		return 'Cards must be up or down'
	end
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

function CC.DownAltColor(cpair)
	if cpair[1].black == cpair[2].black then
		return 'Cards must be in alternating colors'
	end
	return CC.Down(cpair)
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

return CC
