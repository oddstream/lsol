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

function Card:baizeRect()
	return {x1=self.x, y1=self.y, x2=self.x + _G.BAIZE.cardWidth, y2=self.y + _G.BAIZE.cardHeight}
end

function Card:screenRect()
	local rect = self:baizeRect()
	return {
		x1 = rect.x1 + _G.BAIZE.dragOffset.x,
		y1 = rect.y1 + _G.BAIZE.dragOffset.y,
		x2 = rect.x2 + _G.BAIZE.dragOffset.x,
		y2 = rect.y2 + _G.BAIZE.dragOffset.y,
	}
end

function Card:transitionTo(x,y)
	self.x = x
	self.y = y
end

function Card:update(dt)
end

function Card:draw()
	-- very important!: reset color before drawing to canvas to have colors properly displayed
    -- see discussion here: https://love2d.org/forums/viewtopic.php?f=4&p=211418#p211418
	love.graphics.setColor(1,1,1,1)

	if self.prone then
		love.graphics.draw(_G.BAIZE.cardBackTexture, self.x, self.y)
	else
		love.graphics.draw(_G.BAIZE.cardTextureLibrary[self.textureId], self.x, self.y)
	end
end

return Card
