-- baize

local Stroke = require 'stroke'

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
	o.dragOffset = {x=0, y=0}
	return o
end

local ord2String = {'A','2','3','4','5','6','7','8','9','10','J','Q','K'}

function Baize:createCardTextures(ordFilter, suitFilter)
	assert(self.cardWidth and self.cardWidth ~= 0)
	assert(self.cardHeight and self.cardHeight ~= 0)

	self.ordFontSize = self.cardWidth * 0.35
	self.ordFont = love.graphics.newFont('assets/Acme-Regular.ttf', self.ordFontSize)
	self.suitFontSize = self.cardWidth * 0.35
	self.suitFont = love.graphics.newFont('assets/DejaVuSans.ttf', self.suitFontSize)

	local canvas

	self.cardTextureLibrary = {}
	for _, ord in ipairs(ordFilter) do
		for _, suit in ipairs(suitFilter) do
			canvas = love.graphics.newCanvas(self.cardWidth, self.cardHeight)
			love.graphics.setCanvas(canvas)	-- direct drawing operations to the canvas

			love.graphics.setColor(love.math.colorFromBytes(255, 255, 240))	-- Ivory
			love.graphics.rectangle('fill', 0, 0, self.cardWidth, self.cardHeight, self.cardRadius, self.cardRadius)

			love.graphics.setColor(love.math.colorFromBytes(192, 192, 192))	-- Silver
			love.graphics.rectangle('line', 0, 0, self.cardWidth, self.cardHeight, self.cardRadius, self.cardRadius)

			if suit == '♦' or suit == '♥' then
				love.graphics.setColor(love.math.colorFromBytes(220, 20, 60)) -- crimson
			else
				love.graphics.setColor(0, 0, 0)
			end
			love.graphics.setFont(self.ordFont)
			love.graphics.print(ord2String[ord], 8, 8)

			love.graphics.setFont(self.suitFont)
			love.graphics.print(suit, self.cardWidth - 8 - self.suitFontSize, 8)

			love.graphics.setCanvas()	-- reset render target to the screen
			self.cardTextureLibrary[string.format('%02u%s', ord, suit)] = canvas
		end
	end

	canvas = love.graphics.newCanvas(self.cardWidth, self.cardHeight)
	love.graphics.setCanvas(canvas)	-- direct drawing operations to the canvas
	love.graphics.setColor(love.math.colorFromBytes(100, 149, 237))	-- Cornflowerblue
	love.graphics.rectangle('fill', 0, 0, self.cardWidth, self.cardHeight, self.cardRadius, self.cardRadius)
	love.graphics.setCanvas()	-- reset render target to the screen
	self.cardBackTexture = canvas

	canvas = love.graphics.newCanvas(self.cardWidth, self.cardHeight)
	love.graphics.setCanvas(canvas)	-- direct drawing operations to the canvas
	love.graphics.setColor(love.math.colorFromBytes(128, 128, 128))	-- Gray
	love.graphics.rectangle('fill', 0, 0, self.cardWidth, self.cardHeight, self.cardRadius, self.cardRadius)
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

function Baize:layout()
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
	self.cardRadius = self.cardWidth / 15
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

function Baize:findCardAt(x, y)
	for j = #self.piles, 1, -1 do
		local pile = self.piles[j]
		for i = #pile.cards, 1, -1 do
			local card = pile.cards[i]
			local rect = card:screenRect()
			if x > rect.x1 and y > rect.y1 and x < rect.x2 and y < rect.y2 then
				return card
			end
		end
	end
	return nil
end

function Baize:findPileAt(x, y)
	for _, pile in ipairs(self.piles) do
		local rect = pile:screenRect()
		if x > rect.x1 and y > rect.y1 and x < rect.x2 and y < rect.y2 then
			return pile
		end
	end
	return nil
end

function Baize:strokeStart(s)
	print(s.event, s.x, s.y)
	assert(self.stroke==nil)
	self.stroke = s.stroke

	local c = self:findCardAt(s.x, s.y)
	if c then
		print(tostring(c))
	else
		local p = self:findPileAt(s.x, s.y)
		if p then
			print(p.category)
		end
	end
end

function Baize:strokeMove(s)
end

function Baize:strokeTap(s)
	print(s.event, s.x, s.y)
end

function Baize:strokeCancel(s)
	print(s.event, s.x, s.y)
end

function Baize:strokeStop(s)
	print(s.event, s.x, s.y)
end

local function notifyStroke(s)
	local b = _G.BAIZE
	if s.event == 'start' then
		Baize.strokeStart(b, s)
	elseif s.event == 'move' then
		Baize.strokeMove(b, s)
	elseif s.event == 'tap' then
		Baize.strokeTap(b, s)
	elseif s.event == 'cancel' then
		Baize.strokeCancel(b, s)
	elseif s.event == 'stop' then
		Baize.strokeStop(b, s)
	end
end

function Baize:update(dt)
	if self.stroke == nil then
		Stroke.start(notifyStroke)
	else
		assert(self.stroke)
		assert(self.stroke.update)
		self.stroke:update()
		if self.stroke:isCancelled() or self.stroke:isReleased() then
			self.stroke = nil
		end
	end

	for _, pile in ipairs(self.piles) do
		pile:update(dt)
	end
end

function Baize:draw()
	love.graphics.setBackgroundColor(0, 0.3, 0)
	for _, pile in ipairs(self.piles) do
		pile:draw()
	end
end

return Baize
