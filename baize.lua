-- baize

local Baize = {
	-- variantName

	-- script
	-- piles

	-- cells
	-- discards
	-- foundations
	-- reserves
	-- stock
	-- tableaux
	-- waste

	-- cardWidth
	-- cardHeight
	-- numberOfCards (taken just after Stock.new creates cards)
	-- cardTextureLibrary (built when cards change size)
	-- cardBackTexture (built when cards change size)
	-- cardShadowTexture (built when cards change size)

	-- undoStack
	-- bookmark
}
Baize.__index = Baize

function Baize.new()
	local o = {variantName = 'Freecell'}
	setmetatable(o, Baize)
	return o
end

function Baize:createCardTextures(ordFilter, suitFilter)
	assert(self.cardWidth and self.cardWidth ~= 0)
	assert(self.cardHeight and self.cardHeight ~= 0)

	local canvas

	self.cardTextureLibrary = {}
	for _, ord in ipairs(ordFilter) do
		for _, suit in ipairs(suitFilter) do
			canvas = love.graphics.newCanvas(self.cardWidth, self.cardHeight)
			love.graphics.setCanvas(canvas)	-- direct drawing operations to the canvas

			love.graphics.setColor(1, 1, 240*4/1020)	-- Ivory
			love.graphics.rectangle('fill', 0, 0, self.cardWidth, self.cardHeight, 10, 10)

			love.graphics.setCanvas()	-- reset render target to the screen
			self.cardTextureLibrary[string.format('%02u%s', ord, suit)] = canvas
		end
	end

	canvas = love.graphics.newCanvas(self.cardWidth, self.cardHeight)
	love.graphics.setCanvas(canvas)	-- direct drawing operations to the canvas
	love.graphics.setColor(100*4/1020,149*4/1020,237*4/1020)	-- Cornflowerblue
	love.graphics.rectangle('fill', 0, 0, self.cardWidth, self.cardHeight, 10, 10)
	love.graphics.setCanvas()	-- reset render target to the screen
	self.cardBackTexture = canvas

	canvas = love.graphics.newCanvas(self.cardWidth, self.cardHeight)
	love.graphics.setCanvas(canvas)	-- direct drawing operations to the canvas
	love.graphics.setColor(128*4/1020,128*4/1020,128*4/1020)	-- Gray
	love.graphics.rectangle('fill', 0, 0, self.cardWidth, self.cardHeight, 10, 10)
	love.graphics.setCanvas()	-- reset render target to the screen
	self.cardShadowTexture = canvas
end

local Variants = {
	Freecell = {file = 'freecell.lua', params={}},
	Klondike = {file = 'klondike.lua', params={}},
	['Simple Simon'] = {file = 'simplesimon.lua', params = {}},
}

function Baize:loadScript()
	for v, _ in pairs(Variants) do
		print(v)
	end
	local vinfo = Variants[self.variantName]
	if not vinfo then
		print('ERROR Unknown variant', self.variantName)
		return nil
	end
	local fname = 'variants/' .. vinfo.file
	print('looking for file', fname)

	local info = love.filesystem.getInfo('variants', 'directory')
	if not info then
		print('ERROR no variants directory')
		return nil
	end

	info = love.filesystem.getInfo(fname, 'file')
	if not info then
		print('ERROR no file called', fname)
		return nil
	end

	local ok, chunk, result
	ok, chunk = pcall(love.filesystem.load, fname) -- load the chunk safely
	if not ok then
		print('ERROR ' .. tostring(chunk))
		return nil
	else
		ok, result = pcall(chunk) -- execute the chunk safely
	end

	if not ok then -- will be false if there is an error
		print('ERROR ' .. tostring(result))
		return nil
	end

	return result.new(vinfo.params)
end

function Baize:resetPiles()
	self.piles = {}
	-- are these weak tables?
	self.cells = {}
	self.discards = {}
	self.foundations = {}
	self.reserves = {}
	self.stock = nil
	self.tableaux = {}
	self.waste = nil
end

function Baize:layoutPiles()
	local oldCardWidth, oldCardHeight = self.cardWidth, self.cardheight

	local maxSlotX = 0
	for _, pile in ipairs(self.piles) do
		if not (pile.slot.x < 0 or pile.slot.y < 0) then
			if pile.slot.x > maxSlotX then
				maxSlotX = pile.slot.x
			end
		end
	end

	local windowWidth, _, _ = love.window.getMode()
	local slotWidth = windowWidth / (maxSlotX + 1) -- +1 gives a half card width gap either side
	local pilePaddingX = slotWidth / 10
	self.cardWidth = slotWidth - pilePaddingX
	local slotHeight = slotWidth * 1.357
	local pilePaddingY = slotHeight / 10
	self.cardHeight = slotHeight - pilePaddingY
	local leftMargin = self.cardWidth / 2 + pilePaddingX
	local topMargin = 48 + pilePaddingY

	if self.cardWidth ~= oldCardWidth or self.oldCardHeight ~= oldCardHeight then
		self:createCardTextures(self.stock.ordFilter, self.stock.suitFilter)
	end

	for _, pile in ipairs(self.piles) do
		-- slots are 1-based, graphics coords are 0-based
		pile.x = leftMargin + ((pile.slot.x - 1) * (self.cardWidth + pilePaddingX))
		pile.y = topMargin + ((pile.slot.y - 1) * (self.cardHeight + pilePaddingY))
	end
end

function Baize:stateSnapshot()
	local t = {}
	for _, pile in ipairs(self.piles) do
		table.insert(t, #pile)
	end
	return t
end

return Baize
