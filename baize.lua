-- baize

local bitser = require 'bitser'
local log = require 'log'

require 'gradient'	-- comment out to not use gradient

local Card = require 'card'
local Pile = require 'pile'
local Util = require 'util'

require 'cardfactory'

-- local UI = require 'ui'

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
	o.dragOffset = {x=0, y=0}
	o.dragStart = {x=0, y=0}
	o.undoStack = {}
	o.recycles = 32767
	o.bookmark = 0
	o.status = 'virgin'	-- afoot, stuck, collect, complete
	o.percent = 0
	o.lastInput = love.timer.getTime()
	o.showMovable = false
	o.moves = 0
	o.fmoves = 0
	return setmetatable(o, Baize)
end

function Baize:getSavable()
	local piles = {}
	for _, pile in ipairs(self.piles) do
		table.insert(piles, pile:getSavable())
	end
	return {recycles=self.recycles, bookmark=self.bookmark, piles=piles}
end

function Baize:isSavable(obj)
	if type(obj) == 'table' then
		if type(obj.recycles) == 'number' then
			if type(obj.bookmark) == 'number' then
				if type(obj.piles) == 'table' then
					if #obj.piles > 0 then
						if Pile.isSavable(obj.piles[1]) then
							return true
						end
					end
				end
			end
		end
	end
	log.error('not a saved baize')
	return false
end

function Baize:createCardTextures()
	self.cardTextureLibrary, self.cardBackTexture, self.cardShadowTexture = _G.cardTextureFactory(self.cardWidth, self.cardHeight, self.cardRadius)
end

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

function Baize:findAllMovableTails()

	local tails = {}	-- {dst=<pile>, tail=<tail>}

	for _, pile in ipairs(self.piles) do
		local t2 = pile:movableTails()
		if t2 and #t2 > 0 then
			for _, t in ipairs(t2) do
				table.insert(tails, t)
			end
		end
	end

	--[[
	for _, t in ipairs(tails) do
		local c = t.tail[1]
		log.info(c.parent.category, tostring(c), 'to', t.dst.category)
	end
	]]

	return tails
end

function Baize:countMoves()

	--[[
	if a movable card has a card before it in a tableau
	and that pair is conformant
	then don't show it as weakly movable
	if card can move to foundation then it's strongly movable

	0 - can't move, or pointless move
	1 - weak move (conformant with card above)
	2 - move to cell or empty pile
	3 - move
	4 - move to foundation
	]]

	local function isWeakMove(src, card)
		local idx = src:indexOf(card)
		if idx > 1 then
			local card0 = src.cards[idx-1]
			local fn = self.script.tabCompareFn
			local err = fn({card0, card})
			return not err
		end
		return false
	end

	-- remind me, why calc fmoves? so we know when to enable collect button

	self.moves, self.fmoves = 0, 0

	for _, c in ipairs(self.deck) do
		c.movable = 0
	end

	if #self.stock.cards == 0 then
		if self.recycles > 0 then
			self.moves = self.moves + 1
		end
	else
		self.moves = self.moves + 1
		self.stock:peek().movable = 3	-- TODO set according to dst
	end

	for _, tail in ipairs(self:findAllMovableTails()) do
		-- list of {dst=<pile>, tail=<tail>}
		local movable = true
		local card = tail.tail[1]
		local src = tail.tail[1].parent
		local dst = tail.dst
		-- moving an entire pile from place to another is pointless
		if #dst.cards == 0 and #tail.tail == #src.cards then
			if src.label == dst.label then
				if src.category == dst.category then
					movable = false
				end
			end
		end
		if movable then
			self.moves = self.moves + 1
			if dst.category == 'Foundation' then
				self.fmoves = self.fmoves + 1
				card.movable = math.max(card.movable, 4)
			elseif dst.category == 'Tableau' and isWeakMove(src, card) then
				card.movable = math.max(card.movable, 1)
			elseif #dst.cards == 0 then
				card.movable = math.max(card.movable, 2)
			else
				card.movable = math.max(card.movable, 3)
			end
		end
	end
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
	self:setRecycles(saved.recycles)
end

function Baize:updateStatus()
	self.moves, self.fmoves = 0, 0

	if #self.undoStack == 1 then
		self.status = 'virgin'
	elseif #self.undoStack > 1 then
		self.status = 'afoot'
	end

	if self.script:complete() then
		self.status = 'complete'
	else
		self:countMoves()
		if self.moves == 0 then
			self.status = 'stuck'
		elseif self.fmoves > 0 then
			self.status = 'collect'
		else
			self.status = string.format('afoot mvs=%d recyc=%d', self.moves, self.recycles)
		end
	end

	self.percent = self.script:percentComplete()
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

	if self.moves == 0 or self.showMovable == true then
		self.ui:updateWidget('hint', nil, false)
	else
		self.ui:updateWidget('hint', nil, true)
	end
	self.ui:updateWidget('collect', nil, self.status == 'collect')
	local undoable = #self.undoStack > 1 and self.status ~= 'complete'
	self.ui:updateWidget('undo', nil, undoable)
	self.ui:updateWidget('restartdeal', nil, #self.undoStack > 1 --[[self.status ~= 'virgin']])
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

	if _G.SETTINGS.debug then
		self.ui:updateWidget('status', self.status)
	else
		self.ui:updateWidget('status', string.format('%d', #self.undoStack - 1))
	end

	if self.status == 'complete' then
		self.ui:updateWidget('progress', 'COMPLETE')
	else
		self.ui:updateWidget('progress', string.format('%d%%', self.percent))
	end

	-- TODO this doesn't belong here
	if self.status == 'complete' then
		self.ui:toast(_G.SETTINGS.variantName .. ' complete', 'complete')
		self.ui:showFAB{icon='star', baizeCmd='newDeal'}
		self:startSpinning()
		self.stats:recordWonGame(_G.SETTINGS.variantName, #self.undoStack - 1)
	elseif self.status == 'stuck' then
		self.ui:toast(_G.SETTINGS.variantName .. ' stuck', 'blip')
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
	self:unhint()

	local _ = self:undoPop()	-- remove current state
	local saved = self:undoPop()
	if not saved then
		log.error('undoPop returned nil')
	else
		self:updateFromSaved(saved)
	end
	self:undoPush()	-- replace current state
	self:updateStatus()
	self:updateUI()
end

local savedUndoStackFname = 'undoStack.bitser'

function Baize:loadUndoStack()
	local ok, undoStack
	local info = love.filesystem.getInfo(savedUndoStackFname)
	if type(info) == 'table' and type(info.type) == 'string' and info.type == 'file' then
		ok, undoStack = pcall(bitser.loadLoveFile, savedUndoStackFname)
		if not ok then
			-- undoStack is now an error message
			log.error('error loading', savedUndoStackFname, undoStack)
			undoStack = nil
		end
	end
	love.filesystem.remove(savedUndoStackFname)	-- delete it even if error
	--[[
		undoStack will be an array of objects created by Baize:getSavable()
			piles (table, array of objects created by Pile:getSavable())
			recycles (number)
			bookmark (number)
	--]]
	if undoStack and #undoStack > 0 then
		if not self:isSavable(undoStack[1]) then
			undoStack = nil
		end
	end
	if undoStack then
		log.info(string.format('undo stack loaded, depth %d', #undoStack))
	else
		log.info('undo stack not loaded')
	end
	self.undoStack = undoStack	-- it's ok for this to be nil
end

function Baize:saveUndoStack()
	self:undoPush()
	bitser.dumpLoveFile(savedUndoStackFname, self.undoStack)
	log.info('undo stack saved')
end

function Baize:rmUndoStack()
	if love.filesystem.remove(savedUndoStackFname) then
		log.info('removed', savedUndoStackFname)
	else
		log.info(savedUndoStackFname, 'not removed')
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
	self.ui:showStatsDrawer(self.stats:strings(_G.SETTINGS.variantName))
end

function Baize:showSettingsDrawer()
	self.ui:showSettingsDrawer()
end

function Baize:showColorDrawer()
	self.ui:showColorDrawer()
end

function Baize:colorBackground()
	self.ui:showColorPickerDrawer('baizeColor')
end

function Baize:colorCardFace()
	self.ui:showColorPickerDrawer('cardFaceColor')
end

function Baize:colorCardBack()
	self.ui:showColorPickerDrawer('cardBackColor')
end

function Baize:colorClub()
	self.ui:showColorPickerDrawer('clubColor')
end

function Baize:colorDiamond()
	self.ui:showColorPickerDrawer('diamondColor')
end

function Baize:colorHeart()
	self.ui:showColorPickerDrawer('heartColor')
end

function Baize:colorSpade()
	self.ui:showColorPickerDrawer('spadeColor')
end

function Baize:colorHint()
	self.ui:showColorPickerDrawer('hintColor')
end

function Baize:modifySetting(tbl)
	-- log.info(tbl.setting, ':=', tbl.value)
	if _G.SETTINGS[tbl.setting] ~= nil then
		_G.SETTINGS[tbl.setting] = tbl.value
		_G.saveSettings()
		self.backgroundCanvas = nil
		self:createCardTextures()
	end
end

function Baize:showAboutDrawer()
	local strs = {
		love.filesystem.getIdentity(),
		string.format('Version %d %s', _G.LSOL_VERSION, _G.LSOL_VERSION_DATE),
		'',
		'https://oddstream.games',
		'https://love2d.org',
		'',
		'This program comes with',
		'absolutely no warranty',
	}
	self.ui:showAboutDrawer(strs)
end

function Baize:resetStats()
	local pressedButton = love.window.showMessageBox('Are you sure?', 'Reset statistics for ' .. _G.SETTINGS.variantName .. '?', {'Yes', 'No', escapebutton = 2}, 'warning')
	if pressedButton == 1 then
		self.stats:reset(_G.SETTINGS.variantName)
		self.ui:toast(string.format('Statistics for %s have been reset', _G.SETTINGS.variantName))
	end
end

function Baize:toggleCheckbox(var)
	_G.SETTINGS[var] = not _G.SETTINGS[var]
	_G.saveSettings()
	if var == 'simpleCards' or var == 'autoColorCards' then
		self:createCardTextures()
	elseif var == 'mirrorBaize' then
		self:undoPush()
		-- local undoStack = self.undoStack
		self:resetPiles()
		self.script:buildPiles()
		if _G.SETTINGS.mirrorBaize then
			self:mirrorSlots()
		end
		self:layout()
		-- self.undoStack = undoStack
		self:undo()
	end
end

function Baize:toggleRadio(radio)
	-- radio.var will be the button pressed (which should be toggled on)
	-- radio.grp will be the radios in this group (which should be toggled off)
	for _, s in ipairs(radio.grp) do
		_G.SETTINGS[s] = false
	end
	_G.SETTINGS[radio.var] = true
	_G.saveSettings()
	self:createCardTextures()
end

--[[
function Baize:buttonPressed(text)
	-- for k,v in pairs(love.handlers) do
	-- 	print(k, v)
	-- end
	log.trace('Baize:buttonPressed(', text, ')')
	love.event.push('permissionButton', text)
end

function Baize:getPermission(text)
	_G.BAIZE.ui:showModalDialog({
		text=text,
		buttons={'Yes','No'}
	})
	local eventName, result
	repeat
		eventName, result = love.event.wait()
	until eventName == 'permissionButton'
	return result == 'Yes'
end
]]

local function resignGameAreYouSure()
	-- local pressedButton = love.window.showMessageBox('Are you sure?', 'The current game will count as a loss. Continue?', {'Yes', 'No', escapebutton = 2}, 'warning')
	-- return pressedButton == 1
	return true
end

function Baize:changeVariant(vname)
	-- log.trace('changing variant from', _G.SETTINGS.variantName, 'to', vname)
	if vname == _G.SETTINGS.variantName then
		return
	end
	local newScript = _G.BAIZE:loadScript(vname)
	if newScript then
		if #self.undoStack > 1 then
			if self.status ~= 'complete' then
				if not resignGameAreYouSure() then
					return
				end
				self.stats:recordLostGame(_G.SETTINGS.variantName, self.percent)
			end
		end
		--
		_G.SETTINGS.variantName = vname
		_G.saveSettings()
		self.script = newScript
		self:resetPiles()
		self.script:buildPiles()
		if _G.SETTINGS.mirrorBaize then
			self:mirrorSlots()
		end
		self:layout()
		self:resetState()
		self.ui:toast('Starting a new game of ' .. _G.SETTINGS.variantName, 'deal')
		self.script:startGame()
		self:undoPush()
		self:unhint()
		self:updateStatus()
		self:updateUI()
		self.ui:updateWidget('title', vname)
		self:createCardTextures()
	else
		self.ui:toast('Do not know how to play ' .. vname, 'blip')
	end
end

function Baize:newDeal()
	if #self.undoStack > 1 then
		if self.status ~= 'complete' then
			if not resignGameAreYouSure() then
				return
			end
			self.stats:recordLostGame(_G.SETTINGS.variantName, self.percent)
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
	self.ui:toast('Starting a new game of ' .. _G.SETTINGS.variantName, 'deal')
	self.script:startGame()
	self:undoPush()
	self:unhint()
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
	self:unhint()
	self:updateStatus()
	self:updateUI()
end

function Baize:setBookmark()
	-- no point setting a bookmark if virgin or complete, but we allow it
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

function Baize:createBackgroundCanvas()
	local ww, wh, _ = love.window.getMode()
	local ww2, wh2 = ww / 2, wh / 2

	local canvas = love.graphics.newCanvas(ww, wh)
	love.graphics.setCanvas({canvas, stencil=true})	-- direct drawing operations to the canvas

	local frontColor, backColor = Util.getGradientColors('baizeColor', 'darkGreen', 0.2)
	love.gradient.draw(
		function()
			love.graphics.rectangle('fill', 0, 0, ww, wh)
		end,
		'radial',		-- gradient type
		ww2, wh2,		-- center of shape
		ww2, ww2,		-- width of shape
		backColor,		-- back color
		frontColor)		-- front color

	love.graphics.setCanvas()

	self.backgroundCanvas = canvas
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

	local safex, safey, safew, safeh = love.window.getSafeArea()
	-- values returned are in DPI-scaled units (the same coordinate system as most other window-related APIs), not in pixels
	-- safex = love.window.toPixels(safex)
	-- safey = love.window.toPixels(safey)
	-- safew = love.window.toPixels(safew)
	-- safeh = love.window.toPixels(safeh)
	-- if _G.SETTINGS.debug then
	-- 	local amt = 50
	-- 	local ww, wh, _ = love.window.getMode()
	-- 	safex, safey, safew, safeh = amt, amt, ww - (amt*2), wh - (amt*2)
	-- 	log.info(ww, wh, ':=', safex, safey, safew, safeh)
	-- end
	_G.UI_SAFEX = safex
	_G.UI_SAFEY = safey
	_G.UI_SAFEW = safew
	_G.UI_SAFEH = safeh

	local landscape = safew > safeh		-- add a one-card-width border either side

	local slotWidth
	if landscape then
		slotWidth = safew / (maxSlotX + 3) -- +3 gives a 1.5 card width gap either side
	else
		slotWidth = safew / (maxSlotX + 1) -- +1 gives a 0.5 card width gap either side
	end
	local slotHeight = slotWidth * _G.SETTINGS.cardRatio

	local pilePaddingX = slotWidth / 10
	self.cardWidth = slotWidth - pilePaddingX
	local pilePaddingY = slotHeight / 10
	self.cardHeight = slotHeight - pilePaddingY

	local leftMargin
	if landscape then
		leftMargin = safex + self.cardWidth / 2 + pilePaddingX + self.cardWidth
	else
		leftMargin = safex + self.cardWidth / 2 + pilePaddingX
	end
	local topMargin = safey + _G.TITLEBARHEIGHT + pilePaddingY

	self.cardRadius = self.cardWidth / _G.SETTINGS.cardRoundness

	if self.cardWidth ~= oldCardWidth or self.oldCardHeight ~= oldCardHeight then
		self.labelFont = love.graphics.newFont(_G.ORD_FONT, self.cardWidth * 0.666)
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
	self:unhint()
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
				return card
			end
		end
	end
	return nil
end

function Baize:findPileAt(x, y)
	for _, pile in ipairs(self.piles) do
		if Util.inRect(x, y, pile:screenRect()) then
			return pile
		end
	end
	return nil
end

function Baize:isPileOverlapped(p1)
	local ax, ay, aw, ah = p1:baizeRect()
	for _, p2 in ipairs(self.piles) do
		if p1 ~= p2 then
			local bx, by, bw, bh = p2:baizeRect()
			local area = Util.overlapArea(ax, ay, aw, ah, bx, by, bw, bh)
			if area > 0 then
				return p2
			end
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
		local t = self.ui:findToastAt(x, y)
		if t then
			-- log.info('found a toast', t.message)
			self.stroke.object = t
			self.stroke.objectType = 'toast'
		else
			-- we drag the menu drawer containers up/down
			local con = self.ui:findContainerAt(x, y)
			if con then
				-- log.info('strokeStart on container')
				self.stroke.object = con
				self.stroke.objectType = 'container'
				con:startDrag(x, y)
			else
				-- we didn't touch a widget, or container, so there's no need for a drawer to be open?
				self.ui:hideDrawers()

				local card = self:findCardAt(x, y)
				if card then
					if card.spinDegrees == 0 then
						local tail = card.parent:makeTail(card)
						for _, c in ipairs(tail) do
							c:startDrag()
						end
						love.mouse.setVisible(false)
						self.stroke.object = tail
						self.stroke.objectType = 'tail'
						-- print(tostring(card), 'tail len', #tail)
					end
				else
					local pile = self:findPileAt(x, y)
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
		self.ui:hideDrawers()
		self.ui:cancelModalDialog()	-- do this before running baizeCmd
		local wgt = self.stroke.object
		-- log.trace('widget baizeCmd', wgt.baizeCmd)
		if type(wgt.baizeCmd) == 'string' and type(_G.BAIZE[wgt.baizeCmd]) == 'function' then
			if wgt.enabled then
				self[wgt.baizeCmd](self, wgt.param)	-- w.param may be nil
			end
		end
	elseif self.stroke.objectType == 'toast' then
		self.ui:untoast(self.stroke.object)
	elseif self.stroke.objectType == 'container' then
		-- do nothing when tapping on a container
	elseif self.stroke.objectType == 'tail' then
		-- offer tailTapped to the script first
		-- the script can then call Pile.tailTapped if it likes
		local tail = self.stroke.object
		for _, c in ipairs(tail) do c:cancelDrag() end
		local err = tail[1].parent:moveTailError(tail)
		if err then
			self.ui:toast(err, 'blip')
		else
			err = self.script:moveTailError(tail)
			if err then
				self.ui:toast(err, 'blip')
			else
				local oldSnap = self:stateSnapshot()
				self.script:tailTapped(tail)
				local newSnap = self:stateSnapshot()
				if Util.baizeChanged(oldSnap, newSnap) then
					self:afterUserMove()
				else
					Util.play('blip')
				end
			end
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
		-- nothing (could be something, maybe a context menu or somesuch?)
	end
end

function Baize:mouseReleased(x, y, button)
	if not self.stroke then
		return
	end
	love.mouse.setVisible(true)
	if math.abs(self.stroke.init.x - x) < 4 and math.abs(self.stroke.init.y - y) < 4 then
		self:mouseTapped(x, y, button)
	else
		if self.stroke.objectType == 'tail' then
			local tail = self.stroke.object
			local src = tail[1].parent
			local dst = self:largestIntersection(tail[1])
			if not dst then
				-- log.trace('no intersection')
				for _, c in ipairs(tail) do c:cancelDrag() end
			else
				if src == dst then
					-- log.trace('src == dst')
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
	-- nb there is no collecting in games with discard piles

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

function Baize:hint()
	if _G.SETTINGS.debug then
		self.showMovable = not _G.SETTINGS.debug
	else
		self.showMovable = true
	end
	self:updateUI()
end

function Baize:unhint()
	if _G.SETTINGS.debug then
		self.showMovable = _G.SETTINGS.debug
	else
		self.showMovable = false
	end
	-- self:updateUI()
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
	local pressedButton = love.window.showMessageBox('Are you sure?', 'Reset settings?', {'Yes', 'No', escapebutton = 2}, 'warning')
	if pressedButton == 1 then
		local vname = _G.SETTINGS.variantName
		_G.SETTINGS = {}
		for k,v in pairs(_G.LSOL_DEFAULT_SETTINGS) do
			_G.SETTINGS[k] = v
		end
		_G.SETTINGS.variantName = vname
		_G.saveSettings()

		self:createCardTextures()
	end
	-- for k,v in pairs(_G.SETTINGS) do
	-- 	log.trace(k, v)
	-- end
end

function Baize:wikipedia()
	local url = self.script.wikipedia
	if not url then
		self.ui:toast('No wikipedia entry for ' .. _G.SETTINGS.variantName, 'blip')
	else
		love.system.openURL(url)
	end
end

function Baize:openURL(url)
	love.system.openURL(url)
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
		if (love.timer.getTime() - self.lastInput) > 1.0 then
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


	love.graphics.setColor(Util.getColorFromSetting('baizeColor'))	-- otherwise debug print color fills background (!?)
	if love.gradient then
		if not self.backgroundCanvas then
			self:createBackgroundCanvas()
		end
		love.graphics.draw(self.backgroundCanvas, 0, 0)
	end

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

	if _G.SETTINGS.debug then
		love.graphics.setColor(0,1,0)
		love.graphics.print(string.format('%s fps=%d sc=%d ww=%d, wh=%d sx=%d sy=%d sw=%d sh=%d',
			love.system.getOS(),
			love.timer.getFPS(),
			love.window.getDPIScale(),
			love.graphics.getWidth(), love.graphics.getHeight(),
			_G.UI_SAFEX, _G.UI_SAFEY, _G.UI_SAFEW, _G.UI_SAFEH),
			56, 16)
		love.graphics.setColor(0,0,0,1)
		local x = _G.UI_SAFEX + (_G.UI_SAFEW / 2)
		love.graphics.line(x, _G.UI_SAFEY, x, _G.UI_SAFEY + _G.UI_SAFEH)
	end
	-- love.graphics.setFont(self.suitFont)
	-- love.graphics.print(string.format('#undoStack %d', #_G.BAIZE.undoStack, 10, 10))
	-- love.graphics.print(string.format('%f', love.timer.getTime() - self.lastInput), 56, 2)
end

return Baize
