-- baize

local log = require 'log'

local Card = require 'card'
local Stroke = require 'stroke'
local Util = require 'util'

local UI = require 'ui'

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

	-- dragOffset

	-- undoStack
	-- bookmark
}
Baize.__index = Baize

function Baize.new()
	local o = {variantName = 'Freecell'}
	setmetatable(o, Baize)
	o.dragOffset = {x=0, y=0}
	o.recycles = 32767
	o.ui = UI.new()
	return o
end

local ord2String = {'A','2','3','4','5','6','7','8','9','10','J','Q','K'}

function Baize:createCardTextures(ordFilter, suitFilter)
	assert(self.cardWidth and self.cardWidth ~= 0)
	assert(self.cardHeight and self.cardHeight ~= 0)

	self.ordFontSize = self.cardWidth / 3
	self.ordFont = love.graphics.newFont('assets/Acme-Regular.ttf', self.ordFontSize)
	self.suitFontSize = self.cardWidth / 3
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
			love.graphics.setLineWidth(2)
			love.graphics.rectangle('line', 0, 0, self.cardWidth, self.cardHeight, self.cardRadius, self.cardRadius)

			if suit == '♦' or suit == '♥' then
				love.graphics.setColor(love.math.colorFromBytes(220, 20, 60)) -- crimson
			else
				love.graphics.setColor(0, 0, 0)
			end
			love.graphics.setFont(self.ordFont)
			love.graphics.print(ord2String[ord], self.cardWidth / 10, 2)

			love.graphics.setFont(self.suitFont)
			love.graphics.print(suit, self.cardWidth - self.cardWidth / 10 - self.suitFontSize, 4)

			love.graphics.setCanvas()	-- reset render target to the screen
			self.cardTextureLibrary[string.format('%02u%s', ord, suit)] = canvas
		end
	end

	canvas = love.graphics.newCanvas(self.cardWidth, self.cardHeight)
	love.graphics.setCanvas(canvas)	-- direct drawing operations to the canvas
	love.graphics.setColor(love.math.colorFromBytes(100, 149, 237))	-- Cornflowerblue
	love.graphics.rectangle('fill', 0, 0, self.cardWidth, self.cardHeight, self.cardRadius, self.cardRadius)

	love.graphics.setColor(love.math.colorFromBytes(192, 192, 192))	-- Silver
	love.graphics.setLineWidth(2)
	love.graphics.rectangle('line', 0, 0, self.cardWidth, self.cardHeight, self.cardRadius, self.cardRadius)

	love.graphics.setCanvas()	-- reset render target to the screen
	self.cardBackTexture = canvas

	canvas = love.graphics.newCanvas(self.cardWidth, self.cardHeight)
	love.graphics.setCanvas(canvas)	-- direct drawing operations to the canvas
	love.graphics.setColor(love.math.colorFromBytes(0, 0, 0, 128))
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
		log.error('Unknown variant', self.variantName)
		return nil
	end
	local fname = 'variants/' .. vinfo.file
	log.trace('looking for file', fname)

	local info = love.filesystem.getInfo('variants', 'directory')
	if not info then
		log.error('no variants directory')
		return nil
	end

	info = love.filesystem.getInfo(fname, 'file')
	if not info then
		log.error('no file called', fname)
		return nil
	end

	local ok, chunk, result
	ok, chunk = pcall(love.filesystem.load, fname) -- load the chunk safely
	if not ok then
		log.error(tostring(chunk))
		return nil
	else
		ok, result = pcall(chunk) -- execute the chunk safely
	end

	if not ok then -- will be false if there is an error
		log.error(tostring(result))
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
		self.labelFont = love.graphics.newFont('assets/Acme-Regular.ttf', self.cardWidth / 2)
		self.runeFont = love.graphics.newFont('assets/DejaVuSans.ttf', self.cardWidth / 2)
		self:createCardTextures(self.stock.ordFilter, self.stock.suitFilter)
	end

	for _, pile in ipairs(self.piles) do
		pile:setBaizePos(
			-- slots are 1-based, graphics coords are 0-based
			leftMargin + ((pile.slot.x - 1) * (self.cardWidth + pilePaddingX)),
			topMargin + ((pile.slot.y - 1) * (self.cardHeight + pilePaddingY))
		)
		pile:refan(Card.setBaizePos)
	end

	self.ui:layout()
end

function Baize:stateSnapshot()
	local t = {}
	for _, pile in ipairs(self.piles) do
		table.insert(t, #pile.cards)
	end
	return t
end

function Baize:afterUserMove()
	-- log.trace('Baize:afterUserMove')
	self.script.afterMove()
	-- TODO undo push
	-- TODO check if complete, FAB &c
end

function Baize:findCardAt(x, y)
	for j = #self.piles, 1, -1 do
		local pile = self.piles[j]
		for i = #pile.cards, 1, -1 do
			local card = pile.cards[i]
			local rect = card:screenRect()
			if x > rect.x1 and y > rect.y1 and x < rect.x2 and y < rect.y2 then
				return card, pile
			end
		end
	end
	return nil, nil
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

function Baize:largestIntersection(card)
	local largestArea = 0
	local pile
	local cardRect = card:baizeRect()
	for _, p in ipairs(self.piles) do
		if p ~= card.parent then
			local pileRect = p:fannedBaizeRect()
			local area = Util.overlapArea(cardRect, pileRect)
			if area > largestArea then
				largestArea = area
				pile = p
			end
		end
	end
	return pile
end

function Baize:startDrag()
	self.dragStart = self.dragOffset
end

function Baize:dragBy(dx, dy)
	self.dragOffset.x = self.dragStart.x + dx
	if self.dragOffset.x > 0 then
		self.dragOffset.x = 0	-- DragOffset should only ever be 0 or -ve
	end
	self.dragOffset.y = self.dragStart.y + dy
	if self.dragOffset.y > 0 then
		self.dragOffset.y = 0	-- DragOffset should only ever be 0 or -ve
	end
end

function Baize:stopDrag()
end

function Baize:strokeStart(s)
	-- log.info(s.event, s.x, s.y)
	assert(self.stroke==nil)
	self.stroke = s.stroke

	local card, pile = self:findCardAt(s.x, s.y)
	if card then
		local tail = pile:makeTail(card)
		for _, c in ipairs(tail) do
			c:startDrag()
		end
		-- hide the cursor
		self.stroke:setDraggedObject(tail, 'tail')
		-- print(tostring(card), 'tail len', #tail)
	else
		pile = self:findPileAt(s.x, s.y)
		if pile then
			self.stroke:setDraggedObject(pile, 'pile')
		else
			self:startDrag()
			self.stroke:setDraggedObject(self, 'baize')
		end
	end
end

function Baize:strokeMove(s)
	if s.type == 'tail' then
		for _, c in ipairs(s.object) do
			c:dragBy(s.dx, s.dy)
		end
	elseif s.type == 'baize' then
		self:dragBy(s.dx, s.dy)
	end
end

function Baize:strokeTap(s)
	-- log.info(s.event, s.x, s.y)
	if s.type == 'tail' then
		-- print('TRACE tap on', tostring(s.object[1]), 'parent', s.object[1].parent.category)
		local oldSnap = self:stateSnapshot()
		self.script.tailTapped(s.object)
		local newSnap = self:stateSnapshot()
		if Util.baizeChanged(oldSnap, newSnap) then
			self:afterUserMove()
		end
	elseif s.type == 'pile' then
		-- print('TRACE tap on', s.object.category)
		local oldSnap = self:stateSnapshot()
		self.script.pileTapped(s.object)
		local newSnap = self:stateSnapshot()
		if Util.baizeChanged(oldSnap, newSnap) then
			self:afterUserMove()
		end
	elseif s.type == 'baize' then
		-- TODO close any open UI drawer
	end
end

function Baize:strokeCancel(s)
	-- log.info(s.event, s.x, s.y)
	if s.type == 'tail' then
		for _, c in ipairs(s.object) do
			c:cancelDrag()
		end
	end
end

function Baize:strokeStop(s)
	-- log.info(s.event, s.x, s.y)
	if s.type == 'tail' then
		local tail = s.object
		local src = tail[1].parent
		local dst = self:largestIntersection(tail[1])
		if not dst then
			for _, c in ipairs(s.object) do c:cancelDrag() end
		else
			-- log.trace('intersection found', dst.category)
			if src == dst then
				for _, c in ipairs(tail) do c:cancelDrag() end
			else
				local err = src:canMoveTail(tail)
				if err then
					log.warn(err)	-- TODO toast
					for _, c in ipairs(tail) do c:cancelDrag() end
				else
					err = dst:canAcceptTail(tail)
					if err then
						log.warn(err)	-- TODO toast
						for _, c in ipairs(tail) do c:cancelDrag() end
					else
						err = self.script.tailMoveError(tail)
						if err then
							log.warn(err)	-- TODO toast
							for _, c in ipairs(tail) do c:cancelDrag() end
						else
							for _, c in ipairs(tail) do c:stopDrag() end

							local oldSnap = self:stateSnapshot()
							if #tail == 1 then
								Util.moveCard(src, dst)
							else
								Util.moveCards(src, src:indexOf(tail[1]), dst)
							end
							local newSnap = self:stateSnapshot()
							if Util.baizeChanged(oldSnap, newSnap) then
								self:afterUserMove()
							end
						end
					end
				end
			end
		end
	elseif s.type == 'pile' then
		-- do nothing, we don't drag piles
	elseif s.type == 'baize' then
		self:stopDrag()
	end
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

function Baize:setRecycles(n)
	self.recycles = n
	if n == 0 then
		self.stock.rune = '☓'	-- https://www.compart.com/en/unicode/U+2613
	else
		self.stock.rune = '♲'	-- https://www.compart.com/en/unicode/U+2672
	end
end

function Baize:recycleWasteToStock()
	if self.recycles > 0 then
		while #self.waste.cards > 0 do
			Util.moveCard(self.waste, self.stock)
		end
		self:setRecycles(self.recycles - 1)
		if self.recycles == 0 then
			log.info('No more recycles')
		elseif self.recycles == 1 then
			log.info('One more recycle')
		elseif self.recycles < 10 then
			log.info(string.format('%d recycles remaining', b.recycles))
		end
	else
		log.info('No more recycles')
	end
end

function Baize:update(dt)
	if self.stroke == nil then
		Stroke.start(notifyStroke)
	else
		self.stroke:update()
		if self.stroke:isCancelled() or self.stroke:isReleased() then
			self.stroke = nil
		end
	end
	for _, pile in ipairs(self.piles) do
		pile:update(dt)
	end
	self.ui:update(dt)
end

function Baize:draw()
	for _, pile in ipairs(self.piles) do
		pile:draw()
	end
	for _, pile in ipairs(self.piles) do
		pile:drawStaticCards()
	end
	for _, pile in ipairs(self.piles) do
		pile:drawTransitioningCards()
	end
	for _, pile in ipairs(self.piles) do
		pile:drawFlippingCards()
	end
	for _, pile in ipairs(self.piles) do
		pile:drawDraggingCards()
	end
	self.ui:draw()
end

return Baize
