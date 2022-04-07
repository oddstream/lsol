-- baize

local bitser = require 'bitser'
local json = require 'json'
local log = require 'log'

local Card = require 'card'
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
	o.status = 'virgin'	-- afoot, stuck, collect, complete
	o.percent = 0
	o.ui = UI.new()
	o.lastInput = love.timer.getTime()
	return o
end

local settingsFname = 'settings.json'

function Baize:loadSettings()
	local settings
	local info = love.filesystem.getInfo(settingsFname)
	if type(info) == 'table' and type(info.type) == 'string' and info.type == 'file' then
		local contents, size = love.filesystem.read(settingsFname)
		if not contents then
			log.error(size)
		else
			log.info('loaded', size, 'bytes from', settingsFname)
			settings = json.decode(contents)
		end
	else
		log.info('not loading', settingsFname)
	end
	self.settings = settings or _G.LSOL_DEFAULT_SETTINGS
end

function Baize:saveSettings()
	self.settings.lastVersion = _G.LSOL_VERSION
	local success, message = love.filesystem.write(settingsFname, json.encode(self.settings))
	if success then
		log.info('wrote to', settingsFname)
	else
		log.error(message)
	end
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
		{x=0.5, y=0.5, scale=0.75},
		{x=0.375, y=0.6}, {x=0.625, y=0.6},
		{x=0.375, y=0.833}, {x=0.625, y=0.833},
	},
	--[[ 10 ]] {
		{x=0.375, y=0.166}, {x=0.625, y=0.166},
		{x=0.5, y=0.3, scale=0.75},
		{x=0.375, y=0.4}, {x=0.625, y=0.4},
		{x=0.375, y=0.6}, {x=0.625, y=0.6},
		{x=0.5, y=0.7, scale=0.75},
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
	elseif self.settings.twoColorCards then
		if suit == '♦' or suit == '♥' then
			suitColor = 'heartColor'
		else
			suitColor = 'spadeColor'
		end
	elseif self.settings.oneColorCards then
		suitColor = 'spadeColor'
	elseif self.settings.autoColorCards then
		if self.script.cc == 4 then
			if suit == '♣' then
				suitColor = 'clubColor'
			elseif suit == '♦' then
				suitColor = 'diamondColor'
			elseif suit == '♥' then
				suitColor = 'heartColor'
			elseif suit == '♠' then
				suitColor = 'spadeColor'
			end
		elseif self.script.cc == 2 then
			if suit == '♦' or suit == '♥' then
				suitColor = 'heartColor'
			else
				suitColor = 'spadeColor'
			end
		elseif self.script.cc == 1 then
			suitColor = 'spadeColor'
		else
			log.error('unknown value for color of cards in script')
		end
	else
		log.error('unknown value for color of cards in settings')
	end
	return suitColor
end

function Baize:createSimpleFace(ord, suit)
	local canvas = love.graphics.newCanvas(self.cardWidth, self.cardHeight)
	love.graphics.setCanvas(canvas)	-- direct drawing operations to the canvas
	love.graphics.setLineWidth(1)

	love.graphics.setColor(Util.getColorFromSetting('cardFaceColor'))
	love.graphics.rectangle('fill', 0, 0, self.cardWidth, self.cardHeight, self.cardRadius, self.cardRadius)

	love.graphics.setColor(0.5, 0.5, 0.5, 0.1)
	love.graphics.rectangle('line', 1, 1, self.cardWidth-2, self.cardHeight-2, self.cardRadius, self.cardRadius)

	love.graphics.setColor(Util.getColorFromSetting(self:getSuitColor(suit)))

	local ords = _G.ORD2STRING[ord]
	-- local ordw, ordh = self.ordFont:getWidth(ords), self.ordFont:getHeight(ords)
	love.graphics.setFont(self.ordFont)
	love.graphics.print(ords, self.cardWidth * 0.1, 2)

	-- local suitw, suith = self.ordFont:getWidth(suit), self.ordFont:getHeight(suit)
	love.graphics.setFont(self.suitFont)
	love.graphics.print(suit, self.cardWidth * 0.6, 4)

	love.graphics.setCanvas()	-- reset render target to the screen
	return canvas
end

function Baize:createRegularFace(ord, suit)

	local function printAt(str, rx, ry, font, scale, angle)
		scale = scale or 1.0
		angle = angle or 0.0
		local ox = font:getWidth(str) / 2
		local oy = font:getHeight(str) / 2
		love.graphics.print(str,
			self.cardWidth * rx,
			self.cardHeight * ry,
			angle,
			scale, scale,
			ox, oy)
	end

	local canvas = love.graphics.newCanvas(self.cardWidth, self.cardHeight)
	love.graphics.setCanvas(canvas)	-- direct drawing operations to the canvas
	love.graphics.setLineWidth(1)

	love.graphics.setColor(Util.getColorFromSetting('cardFaceColor'))
	love.graphics.rectangle('fill', 0, 0, self.cardWidth, self.cardHeight, self.cardRadius, self.cardRadius)

	love.graphics.setColor(0.5, 0.5, 0.5, 0.1)
	love.graphics.rectangle('line', 1, 1, self.cardWidth-2, self.cardHeight-2, self.cardRadius, self.cardRadius)

	local suitColor = self:getSuitColor(suit)

	-- every card gets an ord top left and bottom right (inverted)
	love.graphics.setColor(Util.getColorFromSetting(suitColor))
	love.graphics.setFont(self.ordFont)
	printAt(_G.ORD2STRING[ord], 0.15, 0.15, self.ordFont)
	printAt(_G.ORD2STRING[ord], 0.85, 0.85, self.ordFont, 1.0, math.pi)

	if ord > 1 and ord < 11 then
		love.graphics.setColor(Util.getColorFromSetting(suitColor))
		love.graphics.setFont(self.suitFont)
		local pips = pipInfo[ord]
		for _, pip in ipairs(pips) do
			local scale = pip.scale or 1.0
			local angle = 0
			if pip.y > 0.5 then
				angle = math.pi
			end
			printAt(suit, pip.x, pip.y, self.suitFont, scale, angle)
		end
	else
		-- Ace, Jack, Queen, King get suit runes at top right and bottom left
		-- so the suit can be seen when fanned
		-- they also get purdy rectangles in the middle

		love.graphics.setColor(0,0,0,0.05)
		love.graphics.rectangle('fill', self.cardWidth * 0.25, self.cardHeight * 0.25, self.cardWidth * 0.5, self.cardHeight * 0.5)

		love.graphics.setColor(Util.getColorFromSetting(suitColor))
		love.graphics.setFont(self.suitFontLarge)
		printAt(suit, 0.5, 0.5, self.suitFontLarge)

		love.graphics.setFont(self.suitFont)
		printAt(suit, 0.85, 0.15, self.suitFont)
		printAt(suit, 0.15, 0.85, self.suitFont, 1.0, math.pi)
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
		self.ordFontSize = self.cardWidth / 3.75
	end
	self.ordFont = love.graphics.newFont(_G.ORD_FONT, self.ordFontSize)

	if self.settings.simpleCards then
		self.suitFontSize = self.cardWidth / 3
	else
		self.suitFontSize = self.cardWidth / 3.75
	end
	self.suitFont = love.graphics.newFont(_G.SUIT_FONT, self.suitFontSize)
	self.suitFontLarge = love.graphics.newFont(_G.SUIT_FONT, self.suitFontSize * 2)

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

	love.graphics.setColor(Util.getColorFromSetting('cardBackColor'))
	love.graphics.rectangle('fill', 0, 0, self.cardWidth, self.cardHeight, self.cardRadius, self.cardRadius)

	love.graphics.setColor(1, 1, 1, 0.1)
	love.graphics.rectangle('line', 1, 1, self.cardWidth-2, self.cardHeight-2, self.cardRadius, self.cardRadius)

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
		love.graphics.setLineWidth(2)
		love.graphics.rectangle('line', ox, oy, self.cardWidth-(ox*2), self.cardHeight-(oy*2))
	end

	love.graphics.setCanvas()	-- reset render target to the screen
	self.cardBackTexture = canvas

	-- card shadow
	canvas = love.graphics.newCanvas(self.cardWidth, self.cardHeight)
	love.graphics.setCanvas(canvas)	-- direct drawing operations to the canvas
	love.graphics.setLineWidth(1)
	love.graphics.setColor(love.math.colorFromBytes(0, 0, 0, 128))
	love.graphics.rectangle('fill', 0, 0, self.cardWidth, self.cardHeight, self.cardRadius, self.cardRadius)
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

	return result.new(vinfo)
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

function Baize:countMoves()

	local function findHomeForTail(owner, tail)
		if #tail == 1 then
			for _, dst in ipairs(self.foundations) do
				if dst ~= owner then
					local err = dst:acceptTailError(tail)
					if not err then
						return dst
					end
				end
			end
			for _, dst in ipairs(self.cells) do
				if dst ~= owner then
					local err = dst:acceptTailError(tail)
					if not err then
						return dst
					end
				end
			end
		end
		for _, dst in ipairs(self.tableaux) do
			if dst ~= owner then
				local err = dst:acceptTailError(tail)
				if not err then
					return dst
				end
			end
		end
		return nil
	end

	local function meaninglessMove(src, dst, tail)
		if dst.category == 'Foundation' then
			return false
		end
		-- moving an entire pile to another empty pile of the same type is pointless
		if #dst.cards == 0 then
			if #tail == #src.cards then
				if src.category == dst.category then
					return true
				end
			end
		end
		-- TODO disregard if tail is already in middle of a conformant pile
		-- i.e. not the first card in a conformant run
		return false
	end

	if self.settings.debug then
		for _, c in ipairs(self.deck) do
			c.movable = false
		end
	end

	local moves, fmoves = 0, 0

	if #self.stock.cards > 0 then
		moves = moves + 1
	elseif #self.stock.cards == 0 and self.recycles > 0 then
		moves = moves + 1
	end

	if self.waste and #self.waste.cards > 0 then
		local tail = {self.waste:peek()}
		if not self.waste:moveTailError(tail) then
			local dst = findHomeForTail(self.waste, tail)
			if dst then
				moves = moves + 1
				if dst.category == 'Foundation' then
					fmoves = fmoves + 1
				end
				if self.settings.debug then tail[1].movable = true end
			end
		end
	end

	for _, pile in ipairs(self.cells) do
		if #pile.cards > 0 then
			local tail = {pile:peek()}
			if not pile:moveTailError(tail) then
				local dst = findHomeForTail(pile, tail)
				if dst --[[and not meaninglessMove(pile, dst, tail)]] then
					moves = moves + 1
					if dst.category == 'Foundation' then
						fmoves = fmoves + 1
					end
					if self.settings.debug then tail[1].movable = true end
				end
			end
		end
	end

	for _, pile in ipairs(self.reserves) do
		if #pile.cards > 0 then
			local tail = {pile:peek()}
			if not pile:moveTailError(tail) then
				local dst = findHomeForTail(pile, tail)
				if dst then
					moves = moves + 1
					if dst.category == 'Foundation' then
						fmoves = fmoves + 1
					end
					if self.settings.debug then tail[1].movable = true end
				end
			end
		end
	end

	for _, pile in ipairs(self.tableaux) do
		for _, card in ipairs(pile.cards) do
			if not card.prone then
				local tail = pile:makeTail(card)
				if not pile:moveTailError(tail) then
					if not self.script:moveTailError(tail) then
						local dst = findHomeForTail(pile, tail)
						if dst --[[and not meaninglessMove(pile, dst, tail)]] then
							moves = moves + 1
							if dst.category == 'Foundation' then
								fmoves = fmoves + 1
							end
							if self.settings.debug then tail[1].movable = true end
						end
					end
				end
			end
		end
	end

	return moves, fmoves
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

function Baize:updateStatus()
	local moves, fmoves = 0, 0
	if #self.undoStack == 1 then
		self.status = 'virgin'
	elseif #self.undoStack > 1 then
		self.status = 'afoot'
	end

	if self.script:complete() then
		self.status = 'complete'
	else
		moves, fmoves = self:countMoves()
		if moves == 0 then
			self.status = 'stuck'
		elseif fmoves > 0 then
			self.status = 'collect'
		else
			self.status = string.format('afoot moves=%d fmoves=%d', moves, fmoves)
		end
	end

	self.percent = self.script:percentComplete()

	return moves, fmoves
end

--[[
     or
     and
     <     >     <=    >=    ~=    ==
     ..
     +     -
     *     /     %
     not   #     - (unary)
     ^
]]

function Baize:updateUI()

	local anyProneCards = function()
		for _, c in ipairs(self.deck) do
			if c.prone then
				return true
			end
		end
		return false
	end

	self.ui:updateWidget('collect', nil, self.status == 'collect')
	local undoable = #self.undoStack > 1 and self.status ~= 'complete'
	self.ui:updateWidget('undo', nil, undoable)
	self.ui:updateWidget('restartdeal', nil, self.status ~= 'virgin')
	self.ui:updateWidget('gotobookmark', nil, self.bookmark ~= 0)

	if self.stock:hidden() then
		self.ui:updateWidget('stock', '')
	else
		if self.waste then
			self.ui:updateWidget('stock', string.format('%d:%d', #self.stock.cards, #self.waste.cards))
		else
			self.ui:updateWidget('stock', string.format('%d', #self.stock.cards))
		end
	end

	if self.settings.debug then
		-- self.ui:updateWidget('status', string.format('%s(%d)', self.status, #self.undoStack))
		self.ui:updateWidget('status', self.status)
	else
		self.ui:updateWidget('status', string.format('%d', #self.undoStack - 1))
	end

	if self.status == 'complete' then
		self.ui:updateWidget('progress', 'COMPLETE')
	else
		self.ui:updateWidget('progress', string.format('%d%%', self.percent))
	end

	if self.status == 'complete' then
		self.ui:toast(self.settings.variantName .. ' complete', 'complete')
		self.ui:showFAB{icon='star', baizeCmd='newDeal'}
		self:startSpinning()
		self.stats:recordWonGame(self.settings.variantName, #self.undoStack - 1)
	elseif self.status == 'stuck' then
		self.ui:toast(self.settings.variantName .. ' stuck', 'blip')
		self.ui:showFAB{icon='star', baizeCmd='newDeal'}
	elseif (self.status == 'collect') and (self.percent == 100) and (not anyProneCards()) then
		self.ui:showFAB{icon='done_all', baizeCmd='collect'}
	else
		self.ui:hideFAB()
	end

	-- log.trace('updateUI', debug.getinfo(2).name)
end

function Baize:undoPush()
	-- TODO might need to determine status here and save it into the undo stack
	local saved = self:getSavable()
	table.insert(self.undoStack, saved)
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
	if self.status == 'complete' then
		self.ui:toast('Cannot undo a completed game', 'blip')
		return
	end
	local _ = self:undoPop()	-- remove current state
	local saved = self:undoPop()
	assert(saved)
	self:updateFromSaved(saved)
	self:undoPush()	-- replace current state
	self:updateStatus()
	self:updateUI()
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
	if not self.status ~= 'complete' then
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
	self.ui:showStatsDrawer(self.stats:strings(self.settings.variantName))
end

function Baize:showSettingsDrawer()
	self.ui:showSettingsDrawer()
end

function Baize:resetStats()
	local pressedButton = love.window.showMessageBox('Reset statistics', 'Are you sure?', {'No', 'Yes', escapebutton = 1})
	if pressedButton == 2 then
		self.stats:reset(self.settings.variantName)
		self.ui:toast(string.format('Statistics for %s have been reset', self.settings.variantName))
	end
end

function Baize:toggleCheckbox(var)
	self.settings[var] = not self.settings[var]
	if var == 'simpleCards' then
		self:createCardTextures()
	elseif var == 'shortCards' then
		self:layout()
		self:createCardTextures()
	elseif var == 'mirrorBaize' then
		self:undoPush()
		-- local undoStack = self.undoStack
		self:resetPiles()
		self.script:buildPiles()
		if self.settings.mirrorBaize then
			self:mirrorSlots()
		end
		self:layout()
		-- self.undoStack = undoStack
		self:undo()
	elseif var == 'debug' then
		for _, c in ipairs(self.deck) do
			c.movable = false
		end
		self:updateUI()
	end
end

function Baize:toggleRadio(radio)
	-- radio.var will be the button pressed (which should be toggled on)
	-- radio.grp will be the radios in this group (which should be toggled off)
	for _, s in ipairs(radio.grp) do
		self.settings[s] = false
	end
	self.settings[radio.var] = true
	self:createCardTextures()
end

function Baize:changeVariant(vname)
	log.trace('changing variant from', self.settings.variantName, 'to', vname)
	if vname == self.settings.variantName then
		return
	end
	local newScript = _G.BAIZE:loadScript(vname)
	if newScript then
		if #self.undoStack > 1 then
			if self.percent < 100 then
				self.stats:recordLostGame(self.settings.variantName, self.percent)
			end
		end
		--
		self.settings.variantName = vname
		self.script = newScript
		self:resetPiles()
		self.script:buildPiles()
		if self.settings.mirrorBaize then
			self:mirrorSlots()
		end
		self:layout()
		self:resetState()
		self.ui:toast('Starting a new game of ' .. self.settings.variantName, 'deal')
		self.script:startGame()
		self:undoPush()
		self:updateStatus()
		self:updateUI()
		self.ui:updateWidget('title', vname)
		if self.settings.autoColorCards then
			self:createCardTextures()
		end
	else
		self.ui:toast('Do not know how to play ' .. vname, 'blip')
	end
end

function Baize:newDeal()
	if #self.undoStack > 1 then
		if self.percent < 100 then
			self.stats:recordLostGame(self.settings.variantName, self.percent)
		end
	end
	self:stopSpinning()
	self.ui:hideFAB()
	for _, p in ipairs(self.piles) do
		p.faceFanFactor = 0.28
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
	self:updateStatus()
	self:updateUI()
end

function Baize:restartDeal()
	local saved
	while #self.undoStack > 0 do
		saved = self:undoPop()
	end
	self:updateFromSaved(saved)
	self:undoPush()
	self:updateStatus()
	self:updateUI()
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
	self:undoPush()
	self:updateStatus()
	self:updateUI()
end

function Baize:layout()
	local oldCardWidth, oldCardHeight = self.cardWidth, self.cardheight

	local maxSlotX = 0
	for _, pile in ipairs(self.piles) do
		if not (pile.slot.x < 0 or pile.slot.y < 0) then
			if pile.slot.x > maxSlotX then
				-- Duchess rule
				if pile.fanType == 'FAN_RIGHT3' or pile.fanType == 'FAN_RIGHT' then
					maxSlotX = pile.slot.x + 2
				else
					maxSlotX = pile.slot.x
				end
			end
		end
	end

	local cardRatio = 1.444
	if self.settings.shortCards then
		cardRatio = 1.222
	end

	local safex, safey, safew, safeh = love.window.getSafeArea()
	-- values returned are in DPI-scaled units (the same coordinate system as most other window-related APIs), not in pixels
	-- safex = love.window.toPixels(safex)
	-- safey = love.window.toPixels(safey)
	-- safew = love.window.toPixels(safew)
	-- safeh = love.window.toPixels(safeh)
	-- if self.settings.debug then
	-- 	local amt = 50
	-- 	local ww, wh, _ = love.window.getMode()
	-- 	safex, safey, safew, safeh = amt, amt, ww - (amt*2), wh - (amt*2)
	-- 	log.info(ww, wh, ':=', safex, safey, safew, safeh)
	-- end
	_G.UI_SAFEX = safex
	_G.UI_SAFEY = safey
	_G.UI_SAFEW = safew
	_G.UI_SAFEH = safeh

	-- local windowWidth, _, _ = love.window.getMode()
	-- local slotWidth = windowWidth / (maxSlotX + 1) -- +1 gives a half card width gap either side
	local slotWidth = safew / (maxSlotX + 1)

	local pilePaddingX = slotWidth / 10
	self.cardWidth = math.floor(slotWidth - pilePaddingX)
	local slotHeight = slotWidth * cardRatio
	local pilePaddingY = slotHeight / 10
	self.cardHeight = math.floor(slotHeight - pilePaddingY)
	-- local leftMargin = self.cardWidth / 2 + pilePaddingX
	local leftMargin = safex + self.cardWidth / 2 + pilePaddingX
	-- local topMargin = _G.TITLEBARHEIGHT + pilePaddingY
	local topMargin = safey + _G.TITLEBARHEIGHT + pilePaddingY

	self.cardRadius = math.floor(self.cardWidth / 16)

	if self.cardWidth ~= oldCardWidth or self.oldCardHeight ~= oldCardHeight then
		self.labelFont = love.graphics.newFont(_G.ORD_FONT, self.cardWidth)
		self.runeFont = love.graphics.newFont(_G.SUIT_FONT, self.cardWidth)
		self:createCardTextures()
	end

	-- log.info('card width, height', self.cardWidth, self.cardHeight)

	for _, pile in ipairs(self.piles) do
		pile:setBaizePos(
			-- slots are 1-based, graphics coords are 0-based
			leftMargin + ((pile.slot.x - 1) * (self.cardWidth + pilePaddingX)),
			topMargin + ((pile.slot.y - 1) * (self.cardHeight + pilePaddingY))
		)
	end

--[[
	piles with fanType == FAN_DOWN, FAN_RIGHT or FAN_LEFT have a 'box'
	within which, all the cards of that pile must fit
	if the cards start to spill outside the box
	then the fan factor is decreased and the cards are refanned

	for example, consider a pile with fanType == FAN_DOWN:
	the box will start at the x,y position of the pile, and be the same width as a card
	the bottom of the box will either be the bottom of the baize,
	or the top of another pile that is directly below this pile
]]

	for _, pile in ipairs(self.piles) do	-- run another loop because x,y will have been set
		if pile.fanType == 'FAN_DOWN' then
			pile.box = {
				x = pile.x,
				y = pile.y,
				width = self.cardWidth,
			}
			if pile.boundaryPile then
				pile.box.height = pile.boundaryPile.y - pile.y
			else
				pile.box.height = -1
			end
		elseif pile.fanType == 'FAN_RIGHT' then
			pile.box = {
				x = pile.x,
				y = pile.y,
				height = self.cardHeight
			}
			if pile.boundaryPile then
				pile.box.width = pile.boundaryPile.x - pile.x
			else
				pile.box.width = -1
			end
		elseif pile.fanType == 'FAN_LEFT' then
			pile.box = {
				x = 0,
				y = pile.y,
				width = pile.x + self.cardWidth,
				height = self.cardHeight
			}
		end

		pile:refan(Card.setBaizePos)
	end

	self.ui:layout()
end

function Baize:mirrorSlots()
--[[
	0 1 2 3 4 5
	5 4 3 2 1 0

	0 1 2 3 4
	4 3 2 1 0
]]
	local minX = 32767
	local maxX = 0
	for _, p in ipairs(self.piles) do
		if p.slot.x > 0 and p.slot.y > 0 then	-- ignore hidden piles
			if p.slot.x < minX then
				minX = p.slot.x
			end
			if p.slot.x > maxX then
				maxX = p.slot.x
			end
		end
	end
	for _, p in ipairs(self.piles) do
		if p.slot.x > 0 and p.slot.y > 0 then	-- ignore hidden piles
			p.slot.x = maxX - p.slot.x + minX
			if p.fanType == 'FAN_RIGHT' then
				p.fanType = 'FAN_LEFT'
			elseif p.fanType == 'FAN_LEFT' then
				p.fanType = 'FAN_RIGHT'
			elseif p.fanType == 'FAN_LEFT3' then
				p.fanType = 'FAN_RIGHT3'
			elseif p.fanType == 'FAN_RIGHT3' then
				p.fanType = 'FAN_LEFT3'
			end
		end
	end
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
	if self.script.afterMove then
		self.script:afterMove()
	end
	self:undoPush()
	self:updateStatus()
	self:updateUI()
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
--[[
	self.dragOffset.x = self.dragStart.x + dx
	if self.dragOffset.x > 0 then
		self.dragOffset.x = 0	-- DragOffset should only ever be 0 or -ve
	end
]]
	self.dragOffset.y = self.dragStart.y + dy
	if self.dragOffset.y > 0 then
		self.dragOffset.y = 0	-- DragOffset should only ever be 0 or -ve
	end
end

function Baize:stopDrag()
	for _, pile in ipairs(self.piles) do
		pile.faceFanFactor = 0.28
		pile:refan(Card.transitionTo)
	end
end

function Baize:mousePressed(x, y, button)
	if self.stroke then
		log.warn('mousePressed', button, 'already a stroke')
		return
	end
	self.stroke = {
		init = {x=x, y=y},
	}
	local w = self.ui:findWidgetAt(x, y)
	if w then
		self.stroke.object = w
		self.stroke.objectType = 'widget'
		-- tell the widget's parent (a container) that we may be dragging
		if w.parent then
			-- TODO FAB does not have a parent because it's not a container subclass
			w.parent:startDrag(x, y)
		end
		-- log.info('strokeStart on widget', w.text or w.icon)
	else
		local con = self.ui:findContainerAt(x, y)
		if con then
			-- log.info('strokeStart on container')
			self.stroke.object = con
			self.stroke.objectType = 'container'
			con:startDrag(x, y)
		else
			-- we didn't touch a widget, or container, so there's no need for a drawer to be open?
			self.ui:hideDrawers()

			local card, pile = self:findCardAt(x, y)
			if card then
				if card.spinDegrees == 0 then
					local tail = pile:makeTail(card)
					for _, c in ipairs(tail) do
						c:startDrag()
					end
					-- hide the cursor
					self.stroke.object = tail
					self.stroke.objectType = 'tail'
					-- print(tostring(card), 'tail len', #tail)
				end
			else
				pile = self:findPileAt(x, y)
				if pile then
					self.stroke.object = pile
					self.stroke.objectType = 'pile'
				else
					self:startDrag()
					self.stroke.object = self
					self.stroke.objectType = 'baize'
				end
			end
		end
	end
end

function Baize:mouseMoved(x, y, dx, dy)
	-- dx, dy The amount moved along the x- and y-axis since the last time love.mousemoved was called.
	if not self.stroke then
		return
	end
	local dx2, dy2 = x - self.stroke.init.x, y - self.stroke.init.y
	if self.stroke.objectType == 'tail' then
		local tail = self.stroke.object
		for _, c in ipairs(tail) do
			c:dragBy(dx2, dy2)
		end
	elseif self.stroke.objectType == 'widget' then
		local wgt = self.stroke.object
		if wgt.parent then	-- FAB does not have a parent
			wgt.parent:dragBy(dx2, dy2)
		end
	elseif self.stroke.objectType == 'container' then
		local con = self.stroke.object
		con:dragBy(dx2, dy2)
	elseif self.stroke.objectType == 'baize' then
		self:dragBy(dx2, dy2)
	end
end

function Baize:mouseTapped(x, y, button)
	if self.stroke.objectType == 'widget' then
		local wgt = self.stroke.object
		if type(wgt.baizeCmd) == 'string' and type(_G.BAIZE[wgt.baizeCmd]) == 'function' then
			self.ui:hideDrawers()
			if wgt.enabled then
				self[wgt.baizeCmd](self, wgt.param)	-- w.param may be nil
			end
		end
	elseif self.stroke.objectType == 'container' then
		-- do nothing when tapping on a container
	elseif self.stroke.objectType == 'tail' then
		-- print('TRACE tap on', tostring(self.stroke.object[1]), 'parent', self.stroke.object[1].parent.category)
		-- offer tailTapped to the script first
		-- the script can then call Pile.tailTapped if it likes
		local tail = self.stroke.object
		for _, c in ipairs(tail) do c:cancelDrag() end
		local oldSnap = self:stateSnapshot()
		self.script:tailTapped(tail)
		local newSnap = self:stateSnapshot()
		if Util.baizeChanged(oldSnap, newSnap) then
			self:afterUserMove()
		else
			Util.play('blip')
		end
	elseif self.stroke.objectType == 'pile' then
		-- print('TRACE tap on', self.stroke.object.category)
		-- nb there is no Pile:pileTapped()
		if self.script.pileTapped then
			local oldSnap = self:stateSnapshot()
			self.script:pileTapped(self.stroke.object)
			local newSnap = self:stateSnapshot()
			if Util.baizeChanged(oldSnap, newSnap) then
				self:afterUserMove()
			else
				Util.play('blip')
			end
		end
	elseif self.stroke.objectType == 'baize' then
		-- TODO close any open UI drawer
	end
end

function Baize:mouseReleased(x, y, button)
	if not self.stroke then
		return
	end
	if math.abs(self.stroke.init.x - x) < 3 and math.abs(self.stroke.init.y - y) < 3 then
		self:mouseTapped(x, y, button)
	else
		if self.stroke.objectType == 'tail' then
			local tail = self.stroke.object
			local src = tail[1].parent
			local dst = self:largestIntersection(tail[1])
			if not dst then
				log.trace('no intersection')
				for _, c in ipairs(tail) do c:cancelDrag() end
			else
				if src == dst then
					log.trace('src == dst')
					for _, c in ipairs(tail) do c:cancelDrag() end
				else
					-- can the tail be moved in general?
					local err = src:moveTailError(tail)
					if err then
						self.ui:toast(err, 'blip')
						for _, c in ipairs(tail) do c:cancelDrag() end
					else
						-- is the variant ok with moving this tail?
						err = self.script:moveTailError(tail)
						if err then
							self.ui:toast(err, 'blip')
							for _, c in ipairs(tail) do c:cancelDrag() end
						else
							err = dst:acceptTailError(tail)
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
		elseif self.stroke.objectType == 'pile' then
			-- do nothing, we don't drag piles
		elseif self.stroke.type == 'baize' then
			self:stopDrag()
		end
	end

	self.lastInput = love.timer.getTime()
	self.stroke = nil
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

function Baize:complete()
	-- Bisley rule - game is complete when all piles except foundations are empty
	-- would normally have 52 / 13 == 4 foundations
	-- Bisley has 8 foundations
	-- 1 pack 52 cards, 13 cards per suit, 4 foundations
	-- 2 packs 104 cards, 13 cards per suit, 8 foundations

	-- Spider rule - game has discard piles
	-- discards should either be empty or contain 13 conformant cards
	-- tableaux should either be empty or contain 13 conformant cards

	-- Normal rule - all piles except foundations are empty
	if self.discards and #self.discards > 0 then
		for _, pile in ipairs(self.piles) do
			if pile.category == 'Discard' then
				-- discard must be empty
				-- or have (eg) 13 cards (which we know are conformant, else they wouldn't have got here)
				if (#pile.cards == 0) then
					-- thats' fine
				elseif (#pile.cards == #self.deck / #self.discards) then
					-- that's fine
				else
					return false
				end
			elseif pile.category == 'Tableau' then
				-- tableau must be empty
				-- or have (eg) 13 conformant cards
				if (#pile.cards == 0) then
					-- that's fine
				elseif (#pile.cards == #self.deck / #self.discards) then
					if Util.unsortedPairs(pile.cards, self.script.tabCompareFn) > 0 then
						return false
					end
				else
					return false
				end
			else
				-- any other pile type must be empty
				if #pile.cards > 0 then
					return false
				end
			end
		end
	else
		for _, pile in ipairs(self.piles) do
			if pile.category ~= 'Foundation' then
				if #pile.cards > 0 then
					return false
				end
			end
		end
	end
	return true
end

function Baize:collect()
	-- collect should be exactly the same as the user tapping repeatedly on the
	-- waste, cell, reserve and tableau piles
	-- nb there is no collecting in games with discard piles (ie spiders)

	-- TODO could move this back to vtable
	local function collectFromPile(pile)
		local cardsMoved = 0
		if pile then
			for _, fp in ipairs(self.foundations) do
				while true do
					local card = pile:peek()
					if not card then break end
					local err = fp:acceptCardError(card)
					if err then
						break	-- done with this foundation, try another
					end
					Util.moveCard(pile, fp)
					cardsMoved = cardsMoved + 1
					self:afterUserMove()
				end
			end
		end
		return cardsMoved
	end

	local totalCardsMoved
	repeat
		totalCardsMoved = collectFromPile(self.waste)
		for _, piles in ipairs({self.cells, self.reserves, self.tableaux}) do
			for _, pile in ipairs(piles) do
				totalCardsMoved = totalCardsMoved + collectFromPile(pile)
			end
		end
	until totalCardsMoved == 0
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

function Baize:j_adoube()

	local function mayNeedAdjusting(pile)
		if not pile.box then
			return false
		end
		if pile.faceFanFactor < 0.28 then
			return true
		end
		if #pile.cards < 2 then
			-- pile may have had, say, 12 scrunched cards, and it's left with 2 after a collect
			return false
		end
		local c = pile:peek()
		local cx, cy, cw, ch = c:baizeRect()
		local box = pile:baizeBox()
		-- make sure card is entirely within pile's box
		if not Util.rectContains(box.x, box.y, box.width, box.height, cx, cy, cw, ch) then
			return true
		end
		return false
	end

	for _, pile in ipairs(self.piles) do
		if mayNeedAdjusting(pile) then
			if pile:calcFanFactor() then
				pile:refan(Card.transitionTo)
			end
		end
	end
end

function Baize:quit()
	love.event.quit(0)
end

function Baize:update(dt_seconds)
	for _, pile in ipairs(self.piles) do
		pile:update(dt_seconds)
	end
	self.ui:update(dt_seconds)

	if not self.stroke then
		if (love.timer.getTime() - self.lastInput) > 2.0 then
			self:j_adoube()
			self.lastInput = love.timer.getTime()
		end
	end
end

function Baize:draw()
	-- -- Transform the coordinate system so the top left in-game corner is in
	-- -- the bottom left corner of the screen.
	-- local screenWidth, screenHeight = love.graphics.getDimensions()
	-- love.graphics.translate(0, screenHeight)
	-- love.graphics.rotate(-math.pi/2)

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

	if self.settings.debug then
		love.graphics.setColor(0,1,0)
		love.graphics.print(string.format('%s sc=%d ww=%d, wh=%d sx=%d sy=%d sw=%d sh=%d',
			love.system.getOS(),
			love.window.getDPIScale(),
			love.graphics.getWidth(), love.graphics.getHeight(),
			_G.UI_SAFEX, _G.UI_SAFEY, _G.UI_SAFEW, _G.UI_SAFEH),
			56, 16)
	end
	-- love.graphics.setFont(self.suitFont)
	-- love.graphics.print(string.format('#undoStack %d', #_G.BAIZE.undoStack, 10, 10))
	-- love.graphics.print(string.format('%f', love.timer.getTime() - self.lastInput), 56, 2)
end

return Baize
