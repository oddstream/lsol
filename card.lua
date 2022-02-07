-- Card

local Card = {
	-- pack
    -- ord 1 .. 13
    -- suit C, D, H, S
	-- savableId
    -- textureId

    -- prone
    -- parent
}
Card.__index = Card

function Card:__tostring()
	return self.textureId
end

function Card.new(o)
	-- assert(type(o)=='table')
	-- assert(type(o.pack)=='number')
	-- assert(type(o.suit)=='string')
	-- assert(type(o.ord)=='number')
	o.savableId = string.format('%u01%02u%s', o.pack, o.ord, o.suit)	-- used when saving card in undoStack
	o.textureId = string.format('%02u%s', o.ord, o.suit)	-- used as index/key into Card Texture Library
	setmetatable(o, Card)
	return o
end

function Card:update(dt)
end

function Card:draw()
	local x = self.parent.x
	local y = self.parent.y
	if self.prone then
		love.graphics.draw(_G.BAIZE.cardBackTexture, x, y)
	else
		love.graphics.draw(_G.BAIZE.cardTextureLibrary[self.textureId], x, y)
	end
end

return Card
