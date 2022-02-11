-- cc

local CC = {}

local ord2String = {'A','2','3','4','5','6','7','8','9','10','J','Q','K'}

function CC.Empty(pile, card)
	if pile.label then
		if pile.label == 'X' then
			return 'Cannot move cards there'
		end
		local ordStr = ord2String[card.ord]
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

function CC.UpSuit(cpair)
	if cpair[1].suit ~= cpair[2].suit then
		return 'Cards must be the same suit'
	end
	return CC.Up(cpair)
end

function CC.DownSuit(cpair)
	if cpair[1].suit ~= cpair[2].suit then
		return 'Cards must be the same suit'
	end
	return CC.Down(cpair)
end

function CC.DownAltColor(cpair)
	if cpair[1].black == cpair[2].black then
		return 'Cards must be in alternating colors'
	end
	return CC.Down(cpair)
end

return CC