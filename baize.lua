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
	-- cardTextureLibrary (built when cards change size)
	-- cardBackTexture (built when cards change size)
	-- cardShadowTexture (built when cards change size)

	-- dragOffset

	-- undoStack
	-- recycles
	-- bookmark
}
Baize.__index = Baize

function Baize.new()
	-- local o = {variantName = 'Simple Simon'}
	-- local o = {variantName = 'Klondike'}
	local o = {variantName = _G.PATIENCE_SETTINGS.lastVariant}
	setmetatable(o, Baize)
	o.dragOffset = {x=0, y=0}
	o.dragStart = {x=0, y=0}
	o.undoStack = {}
	o.recycles = 32767
	o.bookmark = 0
	o.ui = UI.new()
	return o
end

function Baize:getSavable()
	local piles = {}
	for _, pile in ipairs(self.piles) do
		table.insert(piles, pile:getSavable())
	end
	return {recycles=self.recycles, bookmark=self.bookmark, piles=piles}
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

			love.graphics.setColor(_G.PATIENCE_SETTINGS:colorBytes('cardFaceColor'))
			love.graphics.rectangle('fill', 0, 0, self.cardWidth, self.cardHeight, self.cardRadius, self.cardRadius)

			love.graphics.setColor(love.math.colorFromBytes(unpack(_G.PATIENCE_COLORS['Silver'])))
			love.graphics.setLineWidth(2)
			love.graphics.rectangle('line', 0, 0, self.cardWidth, self.cardHeight, self.cardRadius, self.cardRadius)

			if _G.PATIENCE_SETTINGS.fourColorCards then
				if suit == '♣' then
					love.graphics.setColor(_G.PATIENCE_SETTINGS:colorBytes('clubColor'))
				elseif suit == '♦' then
					love.graphics.setColor(_G.PATIENCE_SETTINGS:colorBytes('diamondColor'))
				elseif suit == '♥' then
					love.graphics.setColor(_G.PATIENCE_SETTINGS:colorBytes('heartColor'))
				elseif suit == '♠' then
					love.graphics.setColor(_G.PATIENCE_SETTINGS:colorBytes('spadeColor'))
				end
			else
				if suit == '♦' or suit == '♥' then
					love.graphics.setColor(_G.PATIENCE_SETTINGS:colorBytes('heartColor'))
				else
					love.graphics.setColor(_G.PATIENCE_SETTINGS:colorBytes('spadeColor'))
				end
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
	love.graphics.setColor(_G.PATIENCE_SETTINGS:colorBytes('cardBackColor'))
	love.graphics.rectangle('fill', 0, 0, self.cardWidth, self.cardHeight, self.cardRadius, self.cardRadius)

	love.graphics.setColor(_G.PATIENCE_SETTINGS:colorBytes('cardBorderColor'))
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
	Debug = {file = 'debug.lua', params={}},
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

function Baize:resetState()
	self.undoStack = {}
	self.bookmark = 0
	self.recycles = 32767
end

--[[
function Baize:allCards()

	local co = coroutine.create(function()
		for _,pile in ipairs(self.piles) do
			for _,c in ipairs(pile.cards) do
				coroutine.yield(c)
			end
		end
	end)

	return function() -- iterator for generic for loop
		local result, c = coroutine.resume(co)
		return result == true and c or nil
	end

end
]]

function Baize:percentComplete()
	local pairs = 0
	local unsorted = 0
	for _, p in ipairs(self.piles) do
		if #p.cards > 1 then
			pairs = pairs + #p.cards
		end
		unsorted = unsorted + p:unsortedPairs()
	end
	return 100 - Util.mapValue(unsorted, 0, pairs, 0, 100)
end

function Baize:updateFromSaved(saved)
	if #saved.piles ~= #self.piles then
		log.error('saved piles do not match')
		return
	end
--[[
	local function different(a, b)
		if #a.cards ~= #b.cards then
			return true
		end
		if a.label ~= b.label then
			return true
		end
		return false
	end
]]
	for i = 1, #self.piles do
		local pile = self.piles[i]
		local savedPile = saved.piles[i]
		-- if different(pile, savedPile) then
			pile:updateFromSaved(savedPile)
		-- end
	end

	self.bookmark = saved.bookmark
	self:setRecycles(saved.recycles)	-- updates stock rune
end

function Baize:undoPush()
	local saved = self:getSavable()
	table.insert(self.undoStack, saved)

	if self.stock:hidden() then
		self.ui:setStock('')
	else
		if self.waste then
			self.ui:setStock(string.format('STOCK:%d  WASTE:%d', #self.stock.cards, #self.waste.cards))
		else
			self.ui:setStock(string.format('STOCK:%d', #self.stock.cards))
		end
	end

	local percent = self:percentComplete()
	self.ui:setComplete(string.format('%d%%', percent))
end

function Baize:undoPeek()
	if #self.undoStack == 0 then
		return nil
	end
	return self.undoStack[#self.undoStack]
end

function Baize:undoPop()
	return table.remove(self.undoStack)
end

function Baize:undo()
	if #self.undoStack < 2 then
		self.ui:toast('Nothing to undo')
		return
	end
	local _ = self:undoPop()	-- remove current state
	local saved = self:undoPop()
	assert(saved)
	self:updateFromSaved(saved)
	self:undoPush()	-- replace current state
end

function Baize:newDeal()
	for _, p in ipairs(self.piles) do
		p.cards = {}
	end
	for _, c in ipairs(self.deck) do
		self.stock:push(c)
	end
	self.stock:shuffle()
	self:resetState()
	self.script.startGame()
	self:undoPush()
end

function Baize:restartDeal()
	local saved
	while #self.undoStack > 0 do
		saved = self:undoPop()
	end
	self:updateFromSaved(saved)
	self:undoPush()
end

function Baize:setBookmark()
	-- TODO if Complete
	self.bookmark = #self.undoStack
	local saved = self:undoPeek()
	saved.bookmark = self.bookmark
	saved.recycles = self.recycles
	self.ui:toast('Position bookmarked')
end

function Baize:gotoBookmark()
	if self.bookmark == 0 then
		self.ui:toast('No bookmark')
		return
	end
	local saved
	while #self.undoStack + 1 > self.bookmark do
		saved = self:undoPop()
	end
	self:updateFromSaved(saved)
	self:undoPush()
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
	local slotHeight = slotWidth * _G.PATIENCE_SETTINGS['cardRatio']
	local pilePaddingY = slotHeight / 10
	self.cardHeight = slotHeight - pilePaddingY
	local leftMargin = self.cardWidth / 2 + pilePaddingX
	local topMargin = 48 + pilePaddingY

	if self.cardWidth ~= oldCardWidth or self.oldCardHeight ~= oldCardHeight then
		self.labelFont = love.graphics.newFont('assets/Acme-Regular.ttf', self.cardWidth)
		self.runeFont = love.graphics.newFont('assets/DejaVuSans.ttf', self.cardWidth)
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
	self:undoPush()
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
	-- largest intersection can be source pile,
	-- when user is putting a dragged tail back
	local largestArea = 0
	local pile
	local cardRect = card:baizeRect()
	for _, p in ipairs(self.piles) do
		local pileRect = p:fannedBaizeRect()
		local area = Util.overlapArea(cardRect, pileRect)
		if area > largestArea then
			largestArea = area
			pile = p
		end
	end
	return pile
end

function Baize:startDrag()
	self.dragStart.x = self.dragOffset.x
	self.dragStart.y = self.dragOffset.y
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
		-- offer tailTapped to the script first
		-- the script can then call Pile.tailTapped if it likes
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
		assert(#tail>0)
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
					self.ui:toast(err)
					for _, c in ipairs(tail) do c:cancelDrag() end
				else
					err = dst:canAcceptTail(tail)
					if err then
						self.ui:toast(err)
						for _, c in ipairs(tail) do c:cancelDrag() end
					else
						err = self.script.tailMoveError(tail)
						if err then
							self.ui:toast(err)
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
			self.ui:toast('No more recycles')
		elseif self.recycles == 1 then
			self.ui:toast('One more recycle')
		elseif self.recycles < 10 then
			self.ui:toast(string.format('%d recycles remaining', self.recycles))
		end
	else
		self.ui:toast('No more recycles')
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

	-- love.graphics.setFont(self.ordFont)
	-- love.graphics.setColor(love.math.colorFromBytes(255, 255, 240))	-- Ivory
	-- love.graphics.print(string.format('#undoStack %d', #_G.BAIZE.undoStack, 10, 10))
end

return Baize
