-- cardfactory

local Util = require 'util'

local log = require 'log'

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
		{x=0.5, y=0.285, scale=0.75},
		{x=0.375, y=0.4}, {x=0.625, y=0.4},
		{x=0.375, y=0.6}, {x=0.625, y=0.6},
		{x=0.5, y=0.715, scale=0.75},
		{x=0.375, y=0.833}, {x=0.625, y=0.833},

	},
	--[[ 11 ]] {},
	--[[ 12 ]] {},
	--[[ 13 ]] {},
}

local function getSuitColor(suit)
	local suitColor
	if _G.SETTINGS.fourColorCards then
		if suit == '♣' then
			suitColor = 'clubColor'
		elseif suit == '♦' then
			suitColor = 'diamondColor'
		elseif suit == '♥' then
			suitColor = 'heartColor'
		elseif suit == '♠' then
			suitColor = 'spadeColor'
		end
	elseif _G.SETTINGS.twoColorCards then
		if suit == '♦' or suit == '♥' then
			suitColor = 'heartColor'
		else
			suitColor = 'spadeColor'
		end
	elseif _G.SETTINGS.oneColorCards then
		suitColor = 'spadeColor'
	elseif _G.SETTINGS.autoColorCards then
		if _G.BAIZE.script.cc == 4 then
			if suit == '♣' then
				suitColor = 'clubColor'
			elseif suit == '♦' then
				suitColor = 'diamondColor'
			elseif suit == '♥' then
				suitColor = 'heartColor'
			elseif suit == '♠' then
				suitColor = 'spadeColor'
			end
		elseif _G.BAIZE.script.cc == 2 then
			if suit == '♦' or suit == '♥' then
				suitColor = 'heartColor'
			else
				suitColor = 'spadeColor'
			end
		elseif _G.BAIZE.script.cc == 1 then
			suitColor = 'spadeColor'
		else
			log.error('unknown value for color of cards in script')
		end
	else
		log.error('unknown value for color of cards in settings')
	end
	return suitColor
end

local function createSimpleFace(cardFaceTexture, ordFont, suitFont, width, height, ord, suit)
	-- could/should be a function within factory
	local canvas = love.graphics.newCanvas(width, height)
	love.graphics.setCanvas({canvas, stencil=true})	-- direct drawing operations to the canvas

	love.graphics.setColor(1,1,1,1)
	love.graphics.draw(cardFaceTexture)

	love.graphics.setColor(Util.getColorFromSetting(getSuitColor(suit)))

	local ords = _G.ORD2STRING[ord]
	-- local ordw, ordh = self.ordFont:getWidth(ords), self.ordFont:getHeight(ords)
	love.graphics.setFont(ordFont)
	love.graphics.print(ords, width * 0.1, 2)

	-- local suitw, suith = self.ordFont:getWidth(suit), self.ordFont:getHeight(suit)
	love.graphics.setFont(suitFont)
	love.graphics.print(suit, width * 0.6, 4)

	love.graphics.setCanvas()	-- reset render target to the screen
	return canvas
end

local function createRegularFace(cardFaceTexture, ordFont, suitFont, suitFontLarge, width, height, ord, suit)
	-- could/should be a function within factory

	local function printAt(str, rx, ry, font, scale, angle)
		scale = scale or 1.0
		angle = angle or 0.0
		local ox = font:getWidth(str) / 2
		local oy = font:getHeight(str) / 2
		love.graphics.print(str,
			width * rx,
			height * ry,
			angle,
			scale, scale,
			ox, oy)
	end

	local canvas = love.graphics.newCanvas(width, height)
	love.graphics.setCanvas({canvas, stencil=true})	-- direct drawing operations to the canvas

	love.graphics.setColor(1,1,1,1)
	love.graphics.draw(cardFaceTexture)

	local suitColor = getSuitColor(suit)

	-- every card gets an ord top left and bottom right (inverted)
	love.graphics.setColor(Util.getColorFromSetting(suitColor))
	love.graphics.setFont(ordFont)
	if ord == 10 then
		printAt(_G.ORD2STRING[ord], 0.15, 0.15, ordFont, 0.9)
		printAt(_G.ORD2STRING[ord], 0.85, 0.85, ordFont, 0.9, math.pi)
	else
		printAt(_G.ORD2STRING[ord], 0.15, 0.15, ordFont)
		printAt(_G.ORD2STRING[ord], 0.85, 0.85, ordFont, 1.0, math.pi)
	end

	if ord > 1 and ord < 11 then
		love.graphics.setColor(Util.getColorFromSetting(suitColor))
		love.graphics.setFont(suitFont)
		local pips = pipInfo[ord]
		for _, pip in ipairs(pips) do
			local scale = pip.scale or 1.0
			local angle = 0
			if pip.y > 0.5 then
				angle = math.pi
			end
			printAt(suit, pip.x, pip.y, suitFont, scale, angle)
		end
	else
		-- Ace, Jack, Queen, King get suit runes at top right and bottom left
		-- so the suit can be seen when fanned
		-- they also get purdy rectangles in the middle

		love.graphics.setColor(0,0,0,0.05)
		love.graphics.rectangle('fill', width * 0.25, height * 0.25, width * 0.5, height * 0.5)

		love.graphics.setColor(Util.getColorFromSetting(suitColor))
		love.graphics.setFont(suitFontLarge)
		printAt(suit, 0.5, 0.5, suitFontLarge)

		love.graphics.setFont(suitFont)
		printAt(suit, 0.85, 0.15, suitFont)
		printAt(suit, 0.15, 0.85, suitFont, 1.0, math.pi)
	end

	love.graphics.setCanvas()	-- reset render target to the screen
	return canvas
end

function _G.cardTextureFactory(width, height, radius)
	-- assert(width and width ~= 0)
	-- assert(height and height ~= 0)

	local halfWidth = width / 2
	local halfHeight = height / 2

	local function drawCardRect()
		love.graphics.rectangle('fill', 0, 0, width, height, radius, radius, 16)
		if _G.SETTINGS.cardOutline then
			-- outline probably not needed with gradient
			love.graphics.setLineWidth(1)
			if _G.SETTINGS.debug then
				love.graphics.setColor(1, 0, 0, 1)		-- set color to red to see why width, height are - 2
			else
				love.graphics.setColor(0, 0, 0, 0.1)	-- cartoon outlines are black, so why not
			end
			love.graphics.rectangle('line', 1, 1, width - 2, height - 2, radius, radius, 16)
		end
	end

	-- create fonts

	local ordFontSize
	if _G.SETTINGS.simpleCards then
		ordFontSize = width / 3
	else
		ordFontSize = width / 3.75
	end
	local ordFont = love.graphics.newFont(_G.ORD_FONT, ordFontSize)

	local suitFontSize
	if _G.SETTINGS.simpleCards then
		suitFontSize = width / 3
	else
		suitFontSize = width / 3.5
	end
	local suitFont = love.graphics.newFont(_G.SUIT_FONT, suitFontSize)
	local suitFontLarge = love.graphics.newFont(_G.SUIT_FONT, suitFontSize * 2)

	-- create textures

	local canvas

	-- turn off anti-aliasing to prevent Gargantua stock corner artifacts
	-- https://love2d.org/wiki/FilterMode
	love.graphics.setDefaultFilter('nearest', 'nearest', 1)

	-- blank card face

	canvas = love.graphics.newCanvas(width, height)
	love.graphics.setCanvas({canvas, stencil=true})	-- direct drawing operations to the canvas

	if love.gradient then
		local frontColor, backColor = Util.getGradientColors('cardFaceColor', 'Ivory', 0.09)
		love.gradient.draw(
			function()
				drawCardRect()
			end,
			'radial',
			halfWidth, halfHeight,
			halfWidth, halfHeight,
			backColor,
			frontColor
		)
	else
		love.graphics.setColor(Util.getColorFromSetting('cardFaceColor'))
		drawCardRect()
	end

	love.graphics.setCanvas()	-- reset render target to the screen
	local cardFaceTexture = canvas

	-- card back

	canvas = love.graphics.newCanvas(width, height)
	love.graphics.setCanvas({canvas, stencil=true})	-- direct drawing operations to the canvas

	if love.gradient then
		local frontColor, backColor = Util.getGradientColors('cardBackColor', 'CornflowerBlue', 0.1)
		love.gradient.draw(
			function()
				drawCardRect()
			end,
			'radial',
			halfWidth, halfHeight,
			halfWidth, halfHeight,
			backColor,
			frontColor
		)
	else
		love.graphics.setColor(Util.getColorFromSetting('cardBackColor'))
		drawCardRect()
	end

	if not _G.SETTINGS.simpleCards then
		local pipWidth = suitFont:getWidth('♠') * 0.8
		local pipHeight = suitFont:getHeight() * 0.8
		love.graphics.setFont(suitFont)
		love.graphics.setColor(0,0,0, 0.1)
		love.graphics.print('♦', width / 2, height / 2 - pipHeight)	-- top right
		love.graphics.print('♥', width / 2 - pipWidth, height / 2)	-- bottom left
		love.graphics.setColor(0,0,0, 0.2)
		love.graphics.print('♣', width / 2 - pipWidth, height / 2 - pipHeight)	-- top left
		love.graphics.print('♠', width / 2, height / 2)	-- bottom right
	end

	love.graphics.setCanvas()	-- reset render target to the screen
	local cardBackTexture = canvas

	-- card shadow

	canvas = love.graphics.newCanvas(width, height)
	love.graphics.setCanvas(canvas)	-- direct drawing operations to the canvas
	love.graphics.setLineWidth(1)
	love.graphics.setColor(love.math.colorFromBytes(0, 0, 0, 128))
	drawCardRect()
	love.graphics.setCanvas()	-- reset render target to the screen
	local cardShadowTexture = canvas

	-- put FilterMode back to default otherwise toast text, pips are garbled
	-- https://love2d.org/wiki/FilterMode
	love.graphics.setDefaultFilter('linear', 'linear', 1)

	--

	local cardFaceTextures = {}
	for _, ord in ipairs{1,2,3,4,5,6,7,8,9,10,11,12,13} do
		for _, suit in ipairs{'♣','♦','♥','♠'} do
			if _G.SETTINGS.simpleCards then
				cardFaceTextures[string.format('%02u%s', ord, suit)] = createSimpleFace(cardFaceTexture, ordFont, suitFont, width, height, ord, suit)
			else
				cardFaceTextures[string.format('%02u%s', ord, suit)] = createRegularFace(cardFaceTexture, ordFont, suitFont, suitFontLarge, width, height, ord, suit)
			end
		end
	end

	return cardFaceTextures, cardBackTexture, cardShadowTexture
end
