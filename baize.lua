-- baize

local bitser = require 'bitser'
local log = require 'log'

local Card = require 'card'
local Stroke = require 'stroke'
local Util = require 'util'

local UI = require 'ui'

local Baize = {
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
	local o = {}
	setmetatable(o, Baize)
	o.dragOffset = {x=0, y=0}
	o.dragStart = {x=0, y=0}
	o.undoStack = {}
	o.recycles = 32767
	o.bookmark = 0
	o.ui = UI.new()
	return o
end

function Baize:loadSettings()
	local fname = 'settings.bitser'
	local settings
	local info = love.filesystem.getInfo(fname)
	if type(info) == 'table' and type(info.type) == 'string' and info.type == 'file' then
		settings = bitser.loadLoveFile(fname)
		log.info('loaded', fname)
	else
		log.info('not loading', fname)
	end
	self.settings = settings or _G.LSOL_DEFAULT_SETTINGS
end

function Baize:saveSettings()
	local fname = 'settings.bitser'
	self.settings.lastVersion = _G.LSOL_VERSION
	bitser.dumpLoveFile(fname, self.settings)
	log.info('saved', fname)
end

function Baize:getSavable()
	local piles = {}
	for _, pile in ipairs(self.piles) do
		table.insert(piles, pile:getSavable())
	end
	return {recycles=self.recycles, bookmark=self.bookmark, piles=piles}
end

-- card graphics creation

local pipInfo = {
	--[[ 1 ]] {},
	--[[ 2 ]] {
		{x=0.5, y=0.166},
		{x=0.5, y=0.833},
	},
	--[[ 3 ]] {
		{x=0.5, y=0.166},
		{x=0.5, y=0.5},
		{x=0.5, y=0.833},
	},
	--[[ 4 ]] {
		{x=0.375, y=0.166},	{x=0.625, y=0.166},
		{x=0.375, y=0.833},	{x=0.625, y=0.833},
	},
	--[[ 5 ]] {
		{x=0.375, y=0.166},	{x=0.625, y=0.166},
		{x=0.5, y=0.5},
		{x=0.375, y=0.833},	{x=0.625, y=0.833},
	},
	--[[ 6 ]] {
		{x=0.375, y=0.166},	{x=0.625, y=0.166},
		{x=0.375, y=0.5},	{x=0.625, y=0.5},
		{x=0.375, y=0.833},	{x=0.625, y=0.833},
	},
	--[[ 7 ]] {
		{x=0.375, y=0.166},	{x=0.625, y=0.166},
		{x=0.5, y=0.333},
		{x=0.375, y=0.5},	{x=0.625, y=0.5},
		{x=0.375, y=0.833},	{x=0.625, y=0.833},
	},
	--[[ 8 ]] {
		{x=0.375, y=0.166},	{x=0.625, y=0.166},
		{x=0.5, y=0.333},
		{x=0.375, y=0.5},	{x=0.625, y=0.5},
		{x=0.5, y=0.666},
		{x=0.375, y=0.833},	{x=0.625, y=0.833},
	},
	--[[ 9 ]] {
		{x=0.375, y=0.166}, {x=0.625, y=0.166},
		{x=0.375, y=0.4}, {x=0.625, y=0.4},
		{x=0.5, y=0.5},
		{x=0.375, y=0.6}, {x=0.625, y=0.6},
		{x=0.375, y=0.833}, {x=0.625, y=0.833},
	},
	--[[ 10 ]] {
		{x=0.375, y=0.166}, {x=0.625, y=0.166},
		{x=0.5, y=0.3},
		{x=0.375, y=0.4}, {x=0.625, y=0.4},
		{x=0.375, y=0.6}, {x=0.625, y=0.6},
		{x=0.5, y=0.7},
		{x=0.375, y=0.833}, {x=0.625, y=0.833},

	},
	--[[ 11 ]] {},
	--[[ 12 ]] {},
	--[[ 13 ]] {},
}

function Baize:getSuitColor(suit)
	local suitColor
	if self.settings.fourColorCards then
		if suit == '♣' then
			suitColor = 'clubColor'
		elseif suit == '♦' then
			suitColor = 'diamondColor'
		elseif suit == '♥' then
			suitColor = 'heartColor'
		elseif suit == '♠' then
			suitColor = 'spadeColor'
		end
	else
		if suit == '♦' or suit == '♥' then
			suitColor = 'heartColor'
		else
			suitColor = 'spadeColor'
		end
	end
	return suitColor
end

function Baize:createSimpleFace(ord, suit)
	local canvas = love.graphics.newCanvas(self.cardWidth, self.cardHeight)
	love.graphics.setCanvas(canvas)	-- direct drawing operations to the canvas
	love.graphics.setLineWidth(1)

	love.graphics.setColor(Util.colorBytes('cardFaceColor'))
	love.graphics.rectangle('fill', 0, 0, self.cardWidth, self.cardHeight, self.cardRadiusX, self.cardRadiusY)

	love.graphics.setColor(0.5, 0.5, 0.5, 0.1)
	love.graphics.rectangle('line', 1, 1, self.cardWidth-2, self.cardHeight-2, self.cardRadiusX, self.cardRadiusY)

	love.graphics.setColor(Util.colorBytes(self:getSuitColor(suit)))

	love.graphics.setFont(self.ordFont)
	love.graphics.print(_G.ORD2STRING[ord], self.cardWidth / 10, 2)

	love.graphics.setFont(self.suitFont)
	love.graphics.print(suit, self.cardWidth - self.cardWidth / 10 - self.suitFontSize, 4)

	love.graphics.setCanvas()	-- reset render target to the screen
	return canvas
end

function Baize:createRegularFace(ord, suit)

	local function printAt(str, rx, ry, font, angle)
		angle = angle or 0.0
		local ox = font:getWidth(str) / 2
		local oy = font:getHeight(str) / 2
		love.graphics.print(str,
			self.cardWidth * rx,
			self.cardHeight * ry,
			angle,
			1.0, 1.0,
			ox, oy)
	end

	local canvas = love.graphics.newCanvas(self.cardWidth, self.cardHeight)
	love.graphics.setCanvas(canvas)	-- direct drawing operations to the canvas
	love.graphics.setLineWidth(1)

	love.graphics.setColor(Util.colorBytes('cardFaceColor'))
	love.graphics.rectangle('fill', 0, 0, self.cardWidth, self.cardHeight, self.cardRadiusX, self.cardRadiusY)

	love.graphics.setColor(0.5, 0.5, 0.5, 0.1)
	love.graphics.rectangle('line', 1, 1, self.cardWidth-2, self.cardHeight-2, self.cardRadiusX, self.cardRadiusY)

	local suitColor = self:getSuitColor(suit)

	-- every card gets an ord top left and bottom right (inverted)
	love.graphics.setColor(Util.colorBytes(suitColor))
	love.graphics.setFont(self.ordFont)
	printAt(_G.ORD2STRING[ord], 0.15, 0.15, self.ordFont)
	printAt(_G.ORD2STRING[ord], 0.85, 0.85, self.ordFont, math.pi)

	if ord > 1 and ord < 11 then
		love.graphics.setColor(Util.colorBytes(suitColor))
		love.graphics.setFont(self.suitFont)
		local pips = pipInfo[ord]
		for _, pip in ipairs(pips) do
			local angle = 0
			if pip.y > 0.5 then
				angle = math.pi
			end
			printAt(suit, pip.x, pip.y, self.suitFont, angle)
		end
	else
		-- Ace, Jack, Queen, King get suit runes at top right and bottom left
		-- so the suit can be seen when fanned
		-- they also get purdy rectangles in the middle

		love.graphics.setColor(0,0,0,0.05)
		love.graphics.rectangle('fill', self.cardWidth * 0.25, self.cardHeight * 0.25, self.cardWidth * 0.5, self.cardHeight * 0.5)

		love.graphics.setColor(Util.colorBytes(suitColor))
		love.graphics.setFont(self.suitFontLarge)
		printAt(suit, 0.5, 0.5, self.suitFontLarge)

		love.graphics.setFont(self.suitFont)
		printAt(suit, 0.85, 0.15, self.suitFont)
		printAt(suit, 0.15, 0.85, self.suitFont, math.pi)
	end

	love.graphics.setCanvas()	-- reset render target to the screen
	return canvas
end

function Baize:createCardTextures()
	-- PFTMB create textures for all possible cards, even if current variant has ordFilter and suitFilter
	-- LÖVE drawing on the canvas with 0,0 origin at top left
	-- Ebiten n/a
	-- gg/fogleman drawing on the canvas with 0,0 origin at top left
	-- Solar2D
	assert(self.cardWidth and self.cardWidth ~= 0)
	assert(self.cardHeight and self.cardHeight ~= 0)

	if self.settings.simpleCards then
		self.ordFontSize = self.cardWidth / 3
	else
		self.ordFontSize = self.cardWidth / 4
	end
	self.ordFont = love.graphics.newFont('assets/fonts/Acme-Regular.ttf', self.ordFontSize)

	if self.settings.simpleCards then
		self.suitFontSize = self.cardWidth / 3
	else
		self.suitFontSize = self.cardWidth / 4
	end
	self.suitFont = love.graphics.newFont('assets/fonts/DejaVuSans.ttf', self.suitFontSize)
	self.suitFontLarge = love.graphics.newFont('assets/fonts/DejaVuSans.ttf', self.suitFontSize * 2)

	local canvas

	-- card faces
	self.cardTextureLibrary = {}
	for _, ord in ipairs{1,2,3,4,5,6,7,8,9,10,11,12,13} do
		for _, suit in ipairs{'♣','♦','♥','♠'} do
			if self.settings.simpleCards then
				self.cardTextureLibrary[string.format('%02u%s', ord, suit)] = self:createSimpleFace(ord, suit)
			else
				self.cardTextureLibrary[string.format('%02u%s', ord, suit)] = self:createRegularFace(ord, suit)
			end
		end
	end

	-- card back
	canvas = love.graphics.newCanvas(self.cardWidth, self.cardHeight)
	love.graphics.setCanvas(canvas)	-- direct drawing operations to the canvas
	love.graphics.setLineWidth(1)

	love.graphics.setColor(Util.colorBytes('cardBackColor'))
	love.graphics.rectangle('fill', 0, 0, self.cardWidth, self.cardHeight, self.cardRadiusX, self.cardRadiusY)

	love.graphics.setColor(1, 1, 1, 0.1)
	love.graphics.rectangle('line', 1, 1, self.cardWidth-2, self.cardHeight-2, self.cardRadiusX, self.cardRadiusY)

	if not self.settings.simpleCards then
		local pipWidth = self.suitFont:getWidth('♠')
		local pipHeight = self.suitFont:getHeight('♠')
		love.graphics.setFont(self.suitFont)
		love.graphics.setColor(0,0,0, 0.2)
		love.graphics.print('♦', self.cardWidth / 2, self.cardHeight / 2 - pipHeight)	-- top right
		love.graphics.print('♥', self.cardWidth / 2 - pipWidth, self.cardHeight / 2)	-- bottom left
		love.graphics.setColor(0,0,0, 0.1)
		love.graphics.print('♣', self.cardWidth / 2 - pipWidth, self.cardHeight / 2 - pipHeight)	-- top left
		love.graphics.print('♠', self.cardWidth / 2, self.cardHeight / 2)	-- bottom right
		local ox = self.cardWidth / 8
		local oy = self.cardHeight / 8
		love.graphics.setLineWidth(4)
		love.graphics.rectangle('line', ox, oy, self.cardWidth-(ox*2), self.cardHeight-(oy*2))
	end

	love.graphics.setCanvas()	-- reset render target to the screen
	self.cardBackTexture = canvas

	-- card shadow
	canvas = love.graphics.newCanvas(self.cardWidth, self.cardHeight)
	love.graphics.setCanvas(canvas)	-- direct drawing operations to the canvas
	love.graphics.setLineWidth(1)
	love.graphics.setColor(love.math.colorFromBytes(0, 0, 0, 128))
	love.graphics.rectangle('fill', 0, 0, self.cardWidth, self.cardHeight, self.cardRadiusX, self.cardRadiusY)
	love.graphics.setCanvas()	-- reset render target to the screen
	self.cardShadowTexture = canvas
end

---

function Baize:loadScript(vname)
	-- for v, _ in pairs(_G.LSOL_VARIANTS) do
	-- 	log.info(v)
	-- end
	local vinfo = _G.LSOL_VARIANTS[vname]
	if not vinfo then
		log.error('Unknown variant', vname)
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
	Util.play('undo')

	for i = 1, #self.piles do
		local pile = self.piles[i]
		local savedPile = saved.piles[i]
		-- if different(pile, savedPile) then
			pile:updateFromSaved(savedPile)
		-- end
	end

	self.bookmark = saved.bookmark
	self.ui:updateWidget('gotobookmark', nil, self.bookmark ~= 0)
	self:setRecycles(saved.recycles)	-- updates stock rune
end

function Baize:undoPush()
	local saved = self:getSavable()
	table.insert(self.undoStack, saved)

	self.ui:updateWidget('undo', nil, #self.undoStack > 1)
	self.ui:updateWidget('restartdeal', nil, #self.undoStack > 1)

	if self.stock:hidden() then
		self.ui:updateWidget('stock', '')
	else
		if self.waste then
			self.ui:updateWidget('stock', string.format('STOCK:%d  WASTE:%d', #self.stock.cards, #self.waste.cards))
		else
			self.ui:updateWidget('stock', string.format('STOCK:%d', #self.stock.cards))
		end
	end

	if self:complete() then
		self.ui:updateWidget('complete', 'COMPLETE')
	elseif self:conformant() then
		self.ui:updateWidget('complete', 'CONFORMANT')
	else
		local percent = self:percentComplete()
		self.ui:updateWidget('complete', string.format('%d%% COMPLETE', percent))
	end
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
		self.ui:toast('Nothing to undo', 'blip')
		return
	end
	if self:complete() then
		self.ui:toast('Cannot undo a completed game', 'blip')
		return
	end
	local _ = self:undoPop()	-- remove current state
	local saved = self:undoPop()
	assert(saved)
	self:updateFromSaved(saved)
	self:undoPush()	-- replace current state
end

local savedUndoStackFname = 'undoStack.bitser'

function Baize:loadUndoStack()
	local undoStack
	local info = love.filesystem.getInfo(savedUndoStackFname)
	if type(info) == 'table' and type(info.type) == 'string' and info.type == 'file' then
		undoStack = bitser.loadLoveFile(savedUndoStackFname)
		log.info('loaded', savedUndoStackFname)
	else
		log.info('not loading', savedUndoStackFname)
	end
	love.filesystem.remove(savedUndoStackFname)	-- either way, delete it
	self.undoStack = undoStack	-- it's ok for this to be nil
end

function Baize:saveUndoStack()
	if not self:complete() then
		self:undoPush()
		bitser.dumpLoveFile(savedUndoStackFname, self.undoStack)
		log.info('saved', savedUndoStackFname)
	end
end

function Baize:toggleMenuDrawer()
	self.ui:toggleMenuDrawer()
end

function Baize:showVariantTypesDrawer()
	self.ui:showVariantTypesDrawer()
end

function Baize:showVariantsDrawer(vtype)
	self.ui:showVariantsDrawer(vtype)
end


function Baize:showStatsDrawer()
	self.ui:showStatsDrawer()
	self.stats:log(self.settings.variantName)
end

function Baize:showSettingsDrawer()
	self.ui:showSettingsDrawer()
end

function Baize:toggleSetting(var)
	self.settings[var] = not self.settings[var]
	if var == 'simpleCards' or var == 'fourColorCards' then
		self:createCardTextures()
	end
end

function Baize:changeVariant(vname)
	log.trace('changing variant from', self.settings.variantName, 'to', vname)
	if vname == self.settings.variantName then
		return
	end
	local script = _G.BAIZE:loadScript(vname)
	if script then
		if #self.undoStack > 1 then
			local percent = self:percentComplete()
			if percent < 100 then
				self.stats:recordLostGame(self.settings.variantName, percent)
			end
		end
		--
		self.settings.variantName = vname
		self.script = script
		self:resetPiles()
		self.script:buildPiles()
		self:layout()
		self:resetState()
		self.ui:toast('Starting a new game of ' .. self.settings.variantName, 'deal')
		self.script:startGame()
		self:undoPush()
		self.ui:updateWidget('title', vname)
		self.ui:hideFAB()
	else
		self.ui:toast('Do not know how to play ' .. vname, 'blip')
	end
end

function Baize:newDeal()
	if #self.undoStack > 1 then
		local percent = self:percentComplete()
		if percent < 100 then
			self.stats:recordLostGame(self.settings.variantName, percent)
		end
	end
	self:stopSpinning()
	self.ui:hideFAB()
	for _, p in ipairs(self.piles) do
		p.cards = {}
	end
	for _, c in ipairs(self.deck) do
		self.stock:push(c)
	end
	self.stock:shuffle()
	self:resetState()
	self.ui:toast('Starting a new game of ' .. self.settings.variantName, 'deal')
	self.script:startGame()
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
	self.ui:updateWidget('gotobookmark', nil, self.bookmark ~= 0)
	self.ui:toast('Position bookmarked')
end

function Baize:gotoBookmark()
	if self.bookmark == 0 then
		self.ui:toast('No bookmark', 'blip')
		return
	end
	local saved
	while #self.undoStack + 1 > self.bookmark do
		saved = self:undoPop()
	end
	self:updateFromSaved(saved)
	self.ui:updateWidget('gotobookmark', nil, self.bookmark ~= 0)
	self:undoPush()
end

function Baize:layout()
	local oldCardWidth, oldCardHeight = self.cardWidth, self.cardheight

	local maxSlotX = 0
	for _, pile in ipairs(self.piles) do
		if not (pile.slot.x < 0 or pile.slot.y < 0) then
			if pile.slot.x > maxSlotX then
				-- Duchess rule
				if pile.fanType == 'FAN_RIGHT3' or pile.fanType == 'FAN_RIGHT' then
					maxSlotX = pile.slot.x + 1
				else
					maxSlotX = pile.slot.x
				end
			end
		end
	end

	local windowWidth, _, _ = love.window.getMode()
	local slotWidth = windowWidth / (maxSlotX + 1) -- +1 gives a half card width gap either side
	local pilePaddingX = slotWidth / 10
	self.cardWidth = math.floor(slotWidth - pilePaddingX)
	self.cardRadiusX = math.floor(self.cardWidth / 16)
	local slotHeight = slotWidth * self.settings.cardRatio
	local pilePaddingY = slotHeight / 10
	self.cardHeight = math.floor(slotHeight - pilePaddingY)
	self.cardRadiusY = math.floor(self.cardHeight / 16)
	local leftMargin = self.cardWidth / 2 + pilePaddingX
	local topMargin = 48 + pilePaddingY

	if self.cardWidth ~= oldCardWidth or self.oldCardHeight ~= oldCardHeight then
		self.labelFont = love.graphics.newFont('assets/fonts/Acme-Regular.ttf', self.cardWidth)
		self.runeFont = love.graphics.newFont('assets/fonts/DejaVuSans.ttf', self.cardWidth)
		self:createCardTextures()
	end

	-- log.info('card width, height', self.cardWidth, self.cardHeight)

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
	self.script:afterMove()
	self:undoPush()
	-- TODO we are calculating complete and conformant twice
	if self:complete() then
		self.ui:toast(self.settings.variantName .. ' complete', 'complete')
		self.ui:showFAB{icon='star', baizeCmd='newDeal'}
		self:startSpinning()
		self.stats:recordWonGame(self.settings.variantName)
	elseif self:conformant() then
		self.ui:showFAB{icon='done_all', baizeCmd='collect'}
	else
		self.ui:hideFAB()
	end
	-- TODO FABs stuck (new deal), can_collect (collect)
end

function Baize:findCardAt(x, y)
	for j = #self.piles, 1, -1 do
		local pile = self.piles[j]
		for i = #pile.cards, 1, -1 do
			local card = pile.cards[i]
			if Util.inRect(x, y, card:screenRect()) then
				return card, pile
			end
		end
	end
	return nil, nil
end

function Baize:findPileAt(x, y)
	for _, pile in ipairs(self.piles) do
		if Util.inRect(x, y, pile:screenRect()) then
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
	local cx, cy, cw, ch = card:baizeRect()
	for _, p in ipairs(self.piles) do
		local px, py, pw, ph = p:fannedBaizeRect()
		local area = Util.overlapArea(cx, cy, cw, ch, px, py, pw, ph)
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

	local w = self.ui:findWidgetAt(s.x, s.y)
	if w then
		self.stroke:setDraggedObject(w, 'widget')
		-- tell the widget's parent (a container) that we may be dragging
		if w.parent then
			-- TODO FAB does not have a parent because it's not a container subclass
			w.parent:startDrag(s.x, s.y)
		end
		-- log.info('strokeStart on widget', w.text or w.icon)
	else
		local con = self.ui:findContainerAt(s.x, s.y)
		if con then
			log.info('strokeStart on container')
			self.stroke:setDraggedObject(con, 'container')
			con:startDrag(s.x, s.y)
		else
			-- we didn't touch a widget, or container, so there's no need for a drawer to be open?
			self.ui:hideDrawers()

			local card, pile = self:findCardAt(s.x, s.y)
			if card then
				if not card.spinning then
					local tail = pile:makeTail(card)
					for _, c in ipairs(tail) do
						c:startDrag()
					end
					-- hide the cursor
					self.stroke:setDraggedObject(tail, 'tail')
					-- print(tostring(card), 'tail len', #tail)
				end
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
	end
end

function Baize:strokeMove(s)
	if s.type == 'tail' then
		for _, c in ipairs(s.object) do
			c:dragBy(s.dx, s.dy)
		end
	elseif s.type == 'widget' then
		local wgt = s.object
		wgt.parent:dragBy(s.dx, s.dy)
	elseif s.type == 'container' then
		local con = s.object
		con:dragBy(s.dx, s.dy)
	elseif s.type == 'baize' then
		self:dragBy(s.dx, s.dy)
	end
end

function Baize:strokeTap(s)
	-- log.info(s.event, s.x, s.y)
	if s.type == 'widget' then
		local wgt = s.object
		if type(wgt.baizeCmd) == 'string' and type(_G.BAIZE[wgt.baizeCmd]) == 'function' then
			self.ui:hideDrawers()
			if wgt.enabled then
				self[wgt.baizeCmd](self, wgt.param)	-- w.param may be nil
			end
		end
	elseif s.type == 'container' then
		-- do nothing when tapping on a container
	elseif s.type == 'tail' then
		-- print('TRACE tap on', tostring(s.object[1]), 'parent', s.object[1].parent.category)
		-- offer tailTapped to the script first
		-- the script can then call Pile.tailTapped if it likes
		local oldSnap = self:stateSnapshot()
		self.script:tailTapped(s.object)
		local newSnap = self:stateSnapshot()
		if Util.baizeChanged(oldSnap, newSnap) then
			self:afterUserMove()
		end
	elseif s.type == 'pile' then
		-- print('TRACE tap on', s.object.category)
		local oldSnap = self:stateSnapshot()
		self.script:pileTapped(s.object)
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
			log.trace('intersection found', src.category, 'to', dst.category)
			if src == dst then
				for _, c in ipairs(tail) do c:cancelDrag() end
			else
				local err = src:canMoveTail(tail)
				if err then
					self.ui:toast(err, 'blip')
					for _, c in ipairs(tail) do c:cancelDrag() end
				else
					err = dst:canAcceptTail(tail)
					if err then
						self.ui:toast(err, 'blip')
						for _, c in ipairs(tail) do c:cancelDrag() end
					else
						err = self.script:tailMoveError(tail)
						if err then
							self.ui:toast(err, 'blip')
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
			self.ui:toast('No more recycles', 'blip')
		elseif self.recycles == 1 then
			self.ui:toast('One more recycle')
		elseif self.recycles < 10 then
			self.ui:toast(string.format('%d recycles remaining', self.recycles))
		end
	else
		self.ui:toast('No more recycles', 'blip')
	end
end

function Baize:conformant()
	for _, pile in ipairs(self.piles) do
		if not pile:conformant() then
			return false
		end
	end
	return true
end

function Baize:complete()
	for _, pile in ipairs(self.piles) do
		if not pile:complete() then
			return false
		end
	end
	return true
end

function Baize:collect()
	local outerState = self:stateSnapshot()
	while true do
		local innerState = self:stateSnapshot()
		for _, pile in ipairs(self.piles) do
			pile:collect()
		end
		if not Util.baizeChanged(innerState, self:stateSnapshot()) then
			break
		end
	end
	if Util.baizeChanged(outerState, self:stateSnapshot()) then
		self:afterUserMove()
	end
end

function Baize:startSpinning()
	for _, pile in ipairs(self.piles) do
		for _, card in ipairs(pile.cards) do
			card:startSpinning()
		end
	end
end

function Baize:stopSpinning()
	for _, pile in ipairs(self.piles) do
		for _, card in ipairs(pile.cards) do
			card:stopSpinning()
		end
		pile:refan(Card.transitionTo)
	end
end

function Baize:twoColorCards()
	self.settings.fourColorCards = false
	self:createCardTextures()
end

function Baize:fourColorCards()
	self.settings.fourColorCards = true
	self:createCardTextures()
end

function Baize:resetSettings()
	local vname = self.settings.variantName
	self.settings = {}
	for k,v in pairs(_G.LSOL_DEFAULT_SETTINGS) do
		self.settings[k] = v
	end
	self.settings.variantName = vname
	-- for k,v in pairs(self.settings) do
	-- 	log.trace(k, v)
	-- end
end

function Baize:wikipedia()
	local url = self.script.wikipedia
	if not url then
		self.ui:toast('No wikipedia entry for ' .. self.settings.variantName, 'blip')
	else
		love.system.openURL(url)
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
