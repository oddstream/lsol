-- gradient
-- https://github.com/HugoBDesigner/love.gradient/blob/master/gradient.lua

love.gradient = {}

love.gradient.types = {"linear", "radial", "angle", "rhombus", "square"}
love.gradient.images = {}

for _, v in ipairs(love.gradient.types) do
	local img = love.image.newImageData(512, 512)
	for x = 0, img:getWidth()-1 do
		for y = 0, img:getHeight()-1 do
			local r, g, b, a = 1, 1, 1, 0
			if v == "linear" then
				a = x / (img:getWidth()-1)
			elseif v == "radial" then
				local d = math.sqrt( (x-img:getWidth()/2)^2 + (y-img:getHeight()/2)^2 )
				a = 1-math.min(1, d/(img:getWidth()/2) )
			elseif v == "angle" then
				local angle = -math.atan2(y-img:getHeight()/2, x-img:getWidth()/2) % (math.pi*2)
				a = angle/(math.pi*2)
			elseif v == "rhombus" then
				local px = x >= img:getWidth()/2 and img:getWidth()-x or x
				local py = y >= img:getHeight()/2 and img:getHeight()-y or y
				a = math.min(1, px + py - img:getWidth()/2 )/( img:getWidth()/2 )
			elseif v == "square" then
				local px = x >= img:getWidth()/2 and img:getWidth()-x or x
				local py = y >= img:getHeight()/2 and img:getHeight()-y or y
				a = math.min(px, py) / (img:getWidth()/2)
			end
			img:setPixel(x, y, r, g, b, a)
		end
	end
	love.gradient.images[v] = love.graphics.newImage(img)
end

function love.gradient.draw(drawFunc, gradientType, centerX, centerY, radialWidth, radialHeight, color1, color2, angle, scaleX, scaleY)
	angle = angle or 0
	scaleX = scaleX or 1
	scaleY = scaleY or 1

	--Huge, detailed error handler

	assert(type(drawFunc) == "function",
		"Gradient's argument #1 must be a drawing function.")
	assert(type(gradientType) == "string",
		"Gradient's argument #1 must be a gradient type (" .. table.concat(love.gradient.types, ", ") .. ").")
	gradientType = string.lower(gradientType) -- For convenience
	local containsGradientType = false
	for _, v in ipairs(love.gradient.types) do
		if v == gradientType then
			containsGradientType = true
			break
		end
	end
	assert(containsGradientType,
		"Gradient's argument #2 must be a gradient type (" .. table.concat(love.gradient.types, ", ") .. ").")
	assert(type(centerX) == "number",
		"Gradient's argument #3 must be a number (the central point's X coordinate).")
	assert(type(centerY) == "number",
		"Gradient's argument #4 must be a number (the central point's Y coordinate).")
	assert(type(radialWidth) == "number",
		"Gradient's argument #5 must be a number (the gradient's radial width).")
	assert(type(radialHeight) == "number",
		"Gradient's argument #6 must be a number (the gradient's radial height).")
	assert(pcall(love.graphics.setColor, color1),
		"Gradient's argument #7 must be a valid color table.")
	assert(pcall(love.graphics.setColor, color2),
		"Gradient's argument #8 must be a valid color table.")
	assert(type(angle) == "number",
		"Gradient's argument #9 must be a number (the gradient's angle) or nil (default: 0).")
	assert(type(scaleX) == "number",
		"Gradient's argument #10 must be a number (the gradient's X scale) or nil (default: 1).")
	assert(type(scaleY) == "number",
		"Gradient's argument #11 must be a number (the gradient's Y scale) or nil (default: 1).")

	love.graphics.push("all")
	love.graphics.setColor(color1)
	drawFunc() -- Sneaky sneaky!

	love.graphics.stencil(drawFunc)
	love.graphics.setStencilTest()

	love.graphics.translate(centerX, centerY)
	if angle ~= 0 then
		love.graphics.rotate(angle)
	end

	love.graphics.setColor(color2)
	local gradientImg = love.gradient.images[gradientType]
	love.graphics.draw(gradientImg, -radialWidth, -radialHeight, 0,
		radialWidth * 2 * scaleX / gradientImg:getWidth(), radialHeight * 2 * scaleY / gradientImg:getHeight())

	love.graphics.pop()
	love.graphics.setStencilTest()
end
