-- ui

local Titlebar = require 'ui_titlebar'
local Statusbar = require 'ui_statusbar'
local TextWidget = require 'ui_textwidget'

local UI = {
	-- titlebar
	-- toast manager
	-- statusbar
}
UI.__index = UI

function UI.new()
	local o = {}
	setmetatable(o, UI)

	o.toasts = {} -- a queue of toasts; oldest to the left
	o.toastFont = love.graphics.newFont('assets/Roboto-Regular.ttf', 14)
	o.titleFont = love.graphics.newFont('assets/Roboto-Medium.ttf', 24)

	local tw
	o.titlebar = Titlebar.new()
		tw = TextWidget.new({parent=o.titlebar, text='Menu', align=-1, font=o.titleFont})
		table.insert(o.titlebar.widgets, tw)
		tw = TextWidget.new({parent=o.titlebar, text='Title', align=0, font=o.titleFont})
		table.insert(o.titlebar.widgets, tw)
		tw = TextWidget.new({parent=o.titlebar, text='Undo', align=1, font=o.titleFont})
		table.insert(o.titlebar.widgets, tw)

	o.statusbar = Statusbar.new()
		tw = TextWidget.new({parent=o.statusbar, text='Stock', align=-1, font=o.toastFont})
		table.insert(o.statusbar.widgets, tw)
		tw = TextWidget.new({parent=o.statusbar, text='', align=0, font=o.toastFont})
		table.insert(o.statusbar.widgets, tw)
		tw = TextWidget.new({parent=o.statusbar, text='Complete', align=1, font=o.toastFont})
		table.insert(o.statusbar.widgets, tw)

	o.containers = {o.titlebar, o.statusbar}

	return o
end

function UI:setTitle(text)
	self.titlebar.widgets[2].text = text
	self.titlebar.widgets[2]:layout()
end

function UI:setStock(text)
	self.statusbar.widgets[1].text = text
	self.statusbar.widgets[1]:layout()
end

function UI:setComplete(text)
	self.statusbar.widgets[3].text = text
	self.statusbar.widgets[3]:layout()
end

function UI:toast(message)

	local function comp(a, b)
		return a.ticksLeft > b.ticksLeft
	end

	-- if we are already displaying this message, reset ticksLeft and quit
	for _, t in ipairs(self.toasts) do
		if t.message == message then
			t.ticksLeft = 4
			table.sort(self.toasts, comp)
			return
		end
	end
	local t = {message=message, ticksLeft=4 + #self.toasts}
	table.insert(self.toasts, 1, t)
	-- table.sort(self.toasts, comp)
end

function UI:layout()
	self.titlebar:layout()
	self.statusbar:layout()
end

function UI:update(dt)

	if #self.toasts > 0 then
		for _, t in ipairs(self.toasts) do
			t.ticksLeft = t.ticksLeft - dt
		end
		-- remove the oldest (last in table) if it has expired
		if self.toasts[#self.toasts].ticksLeft < 0.0 then
			table.remove(self.toasts)
		end
	end

end

function UI:draw()

	self.titlebar:draw()
	self.statusbar:draw()

	local function drawToast(message, y)
		-- https://material.io/archive/guidelines/components/snackbars-toasts.html#snackbars-toasts-specs
		-- Single-line snackbar height: 48dp
		-- Text: Roboto Regular 14sp
		-- Default background fill: #323232 100%
		local sw, sh, _ = love.window.getMode()
		love.graphics.setColor(love.math.colorFromBytes(0x32, 0x32, 0x32, 255))
		love.graphics.setFont(self.toastFont)
		local mw = self.toastFont:getWidth(message)
		local mh = self.toastFont:getHeight(message)
		local rw = mw + 48
		love.graphics.rectangle('fill', (sw - rw) / 2, ((sh - 48) / 2) + y, rw, 48)
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.print(message, (sw - mw) / 2, ((sh - mh) / 2) + y)
	end

	if #self.toasts > 0 then
		for i = 1, #self.toasts do
			drawToast(self.toasts[i].message, i * (48 + 12))
			-- drawToast(string.format('%d %s', self.toasts[i].ticksLeft, self.toasts[i].message), i * (48 + 12))
		end
	end

end

return UI
