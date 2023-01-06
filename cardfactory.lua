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
	--[[
		X X
		 X
		X X
		X X
		 X
		X X
	--]]
		{x=0.375, y=0.166, scale=0.75}, {x=0.625, y=0.166},
		{x=0.5, y=0.285, scale=0.75},
		{x=0.375, y=0.4}, {x=0.625, y=0.4},
		{x=0.375, y=0.6}, {x=0.625, y=0.6},
		{x=0.5, y=0.715, scale=0.75},
		{x=0.375, y=0.833}, {x=0.625, y=0.833, scale=0.75},

	--[[
		 X
		X X
		X X
		X X
		X X
		 X
		{x=0.5, y=0.166},
		{x=0.375, y=0.3}, {x=0.625, y=0.3},
		{x=0.2, y=0.45}, {x=0.8, y=0.45},
		{x=0.2, y=0.6}, {x=0.8, y=0.6},
		{x=0.375, y=0.75}, {x=0.625, y=0.75},
		{x=0.5, y=0.833},
	]]
	},
	--[[ 11 ]] {},
	--[[ 12 ]] {},
	--[[ 13 ]] {},
}

local function getSuitColor(suit)
	-- returns {r, g, b} table that can be passed to love.graphics.setColor
	-- after unpacking and passing through getColorFromBytes
	local suitColorSetting
	if _G.SETTINGS.autoColorCards then
		if _G.BAIZE.script.cc == 4 then
			if suit == '♣' then
				suitColorSetting = 'clubColor'
			elseif suit == '♦' then
				suitColorSetting = 'diamondColor'
			elseif suit == '♥' then
				suitColorSetting = 'heartColor'
			elseif suit == '♠' then
				suitColorSetting = 'spadeColor'
			end
		elseif _G.BAIZE.script.cc == 2 then
			if suit == '♦' or suit == '♥' then
				suitColorSetting = 'heartColor'
			else
				suitColorSetting = 'spadeColor'
			end
		elseif _G.BAIZE.script.cc == 1 then
			suitColorSetting = 'spadeColor'
		else
			log.error('unknown script.cc value')
		end
	else
		if suit == '♦' or suit == '♥' then
			return _G.LSOL_COLORS['Crimson']
		else
			return _G.LSOL_COLORS['Black']
		end
	end

	local fallback = {0.5, 0.5, 0.5}
	local setting = _G.SETTINGS[suitColorSetting]
	if not setting then
		log.error('No setting called', suitColorSetting)
		return fallback
	end
	local rgb = _G.LSOL_COLORS[setting]
	if not rgb then
		log.error('No color for setting', suitColorSetting)
		return fallback
	end

	return rgb	-- alpha is optional and defaults to 1
end

--[[
local function createAltFace(ordFont, width, height, radius, ord, suit)
	local canvas = love.graphics.newCanvas(width, height)
	love.graphics.setCanvas({canvas, stencil=true})	-- direct drawing operations to the canvas

	love.graphics.setColor(love.math.colorFromBytes(unpack(getSuitColor(suit))))
	love.graphics.rectangle('fill', 0, 0, width, height, radius, radius)
	love.graphics.setLineWidth(1)
	love.graphics.rectangle('line', 1, 1, width - 2, height - 2, radius, radius)

	love.graphics.setColor(1, 1, 1, 1)
	local ords = _G.ORD2STRING[ord]
	love.graphics.setFont(ordFont)
	love.graphics.print(ords, width * 0.5, height * 0.5)

	love.graphics.setCanvas()	-- reset render target to the screen
	return canvas
end
]]

local function createSimpleFace(cardFaceTexture, ordFont, suitFont, width, height, ord, suit)
	-- could/should be a function within factory
	local canvas = love.graphics.newCanvas(width, height)
	love.graphics.setCanvas({canvas, stencil=true})	-- direct drawing operations to the canvas

	love.graphics.setColor(1,1,1,1)
	love.graphics.draw(cardFaceTexture)

	love.graphics.setColor(love.math.colorFromBytes(unpack(getSuitColor(suit))))

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
		-- scale = scale or 1.0
		angle = angle or 0.0
		local ox = font:getWidth(str) / 2
		local oy = font:getHeight(str) / 2
		love.graphics.print(str,
			width * rx,
			height * ry,
			angle,
			1.0, 1.0,	--scale, scale,
			ox, oy)
	end

	local canvas = love.graphics.newCanvas(width, height)
	love.graphics.setCanvas({canvas, stencil=true})	-- direct drawing operations to the canvas

	love.graphics.setColor(1,1,1,1)
	love.graphics.draw(cardFaceTexture)

	local suitRGB = getSuitColor(suit)

	-- every card gets an ord top left and bottom right (inverted)
	love.graphics.setColor(love.math.colorFromBytes(unpack(suitRGB)))
	love.graphics.setFont(ordFont)
	printAt(_G.ORD2STRING[ord], 0.15, 0.15, ordFont)
	printAt(_G.ORD2STRING[ord], 0.85, 0.85, ordFont, 1.0, math.pi)

	if ord > 1 and ord < 11 then
		-- cards 2 .. 10 get pips in the middle

		love.graphics.setColor(love.math.colorFromBytes(unpack(suitRGB)))
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
		love.graphics.rectangle('fill', width * 0.25, height * 0.25, width * 0.5, height * 0.5, width / 20, height / 20)

		love.graphics.setColor(love.math.colorFromBytes(unpack(suitRGB)))
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
		love.graphics.rectangle('fill', 0, 0, width, height, radius, radius)
		if _G.SETTINGS.cardOutline then
			love.graphics.setLineWidth(1)
			if _G.SETTINGS.debug then
				love.graphics.setColor(1, 0, 0, 1)		-- set color to red to see why width, height are - 2
			else
				if _G.SETTINGS.gradientShading then
					love.graphics.setColor(0, 0, 0, 0.05)	-- cartoon outlines are black, so why not
				else
					love.graphics.setColor(0, 0, 0, 0.1)	-- cartoon outlines are black, so why not
				end
			end
			love.graphics.rectangle('line', 1, 1, width - 2, height - 2, radius, radius)
		end
	end

	-- create fonts

	local ordFontSize
	if _G.SETTINGS.simpleCards then
		ordFontSize = width / 2.5
	else
		ordFontSize = width / 3.5
	end
	local ordFont = love.graphics.newFont(_G.ORD_FONT, ordFontSize)

	local suitFontSize
	if _G.SETTINGS.simpleCards then
		suitFontSize = width / 2.5
	else
		suitFontSize = width / 3.75
	end
	local suitFont = love.graphics.newFont(_G.SUIT_FONT, suitFontSize)
	local suitFontLarge = love.graphics.newFont(_G.SUIT_FONT, suitFontSize * 2)

	-- create textures

	local canvas

	-- turn off anti-aliasing to prevent Gargantua stock corner artifacts
	-- https://love2d.org/wiki/FilterMode
	-- love.graphics.setDefaultFilter('nearest', 'nearest', 1)

	-- blank card face

	canvas = love.graphics.newCanvas(width, height)
	love.graphics.setCanvas({canvas, stencil=true})	-- direct drawing operations to the canvas

	if love.gradient and _G.SETTINGS.gradientShading then
		local frontColor, backColor = Util.getGradientColors('cardFaceColor', 'Ivory', 0.06)
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
		Util.setColorFromSetting('cardFaceColor')
		drawCardRect()
	end

	love.graphics.setCanvas()	-- reset render target to the screen
	local cardFaceTexture = canvas

	-- card back

	canvas = love.graphics.newCanvas(width, height)
	love.graphics.setCanvas({canvas, stencil=true})	-- direct drawing operations to the canvas

	if love.gradient and _G.SETTINGS.gradientShading then
		local frontColor, backColor = Util.getGradientColors('cardBackColor', 'CornflowerBlue', 0.09)
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
		Util.setColorFromSetting('cardBackColor')
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
	-- love.graphics.setDefaultFilter('linear', 'linear', 1)

	--

	local cardFaceTextures = {}
	for _, ord in ipairs{1,2,3,4,5,6,7,8,9,10,11,12,13} do
		for _, suit in ipairs{'♣','♦','♥','♠'} do
			local key = Util.cardTextureId(ord, suit)
			if _G.SETTINGS.simpleCards then
				cardFaceTextures[key] = createSimpleFace(cardFaceTexture, ordFont, suitFont, width, height, ord, suit)
			else
				cardFaceTextures[key] = createRegularFace(cardFaceTexture, ordFont, suitFont, suitFontLarge, width, height, ord, suit)
			end
		end
	end

	return cardFaceTextures, cardBackTexture, cardShadowTexture
end
