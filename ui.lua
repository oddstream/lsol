-- ui

local Titlebar = require 'ui_titlebar'
local MenuDrawer = require 'ui_menudrawer'
local Statusbar = require 'ui_statusbar'
local TextWidget = require 'ui_textwidget'

local Util = require 'util'

local UI = {
	-- titlebar
	-- toast manager
	-- statusbar
}
UI.__index = UI

local menuWidgets = {
	{text='New deal', baizeCmd='newDeal'},
	{text='Restart deal', baizeCmd='restartDeal'},
	{text='Find game...', baizeCmd='showVariantTypesDrawer'},
	{text='Bookmark', baizeCmd='setBookmark'},
	{text='Go to bookmark', baizeCmd='gotoBookmark'},
}

function UI.new()
	local o = {}
	setmetatable(o, UI)

	o.toasts = {} -- a queue of toasts; oldest to the left
	o.toastFont = love.graphics.newFont('assets/Roboto-Regular.ttf', 14)

	local tw
	o.titlebar = Titlebar.new()
		tw = TextWidget.new({parent=o.titlebar, text='Menu', align='left', baizeCmd='toggleMenuDrawer'})
		table.insert(o.titlebar.widgets, tw)
		tw = TextWidget.new({parent=o.titlebar, text='', align='center'})
		table.insert(o.titlebar.widgets, tw)
		tw = TextWidget.new({parent=o.titlebar, text='Undo', align='right', baizeCmd='undo'})
		table.insert(o.titlebar.widgets, tw)
		tw = TextWidget.new({parent=o.titlebar, text='Coll', align='right', baizeCmd='collect'})
		table.insert(o.titlebar.widgets, tw)

	o.menudrawer = MenuDrawer.new()
	for _, winfo in ipairs(menuWidgets) do
		winfo.parent = o.menudrawer
		table.insert(o.menudrawer.widgets, TextWidget.new(winfo))
	end

	o.statusbar = Statusbar.new()
		tw = TextWidget.new({parent=o.statusbar, text='Stock', align='left'})
		table.insert(o.statusbar.widgets, tw)
		tw = TextWidget.new({parent=o.statusbar, text='', align='center'})
		table.insert(o.statusbar.widgets, tw)
		tw = TextWidget.new({parent=o.statusbar, text='Complete', align='right'})
		table.insert(o.statusbar.widgets, tw)

	o.containers = {o.titlebar, o.menudrawer, o.statusbar}

	o.drawers = {o.menudrawer}

	return o
end

function UI:findContainerAt(x, y)
	for _, con in ipairs(self.containers) do
		if Util.inRect(x, y, con:screenRect()) then
			return con
		end
	end
	return nil
end

function UI:findWidgetAt(x, y)
	local con = self:findContainerAt(x, y)
	if con then
		for _, w in ipairs(con.widgets) do
			if Util.inRect(x, y, w:screenRect()) then
				return w
			end
		end
	end
	return nil
end

function UI:setTitle(text)
	self.titlebar.widgets[2].text = text
	self.titlebar:layout()
end

function UI:setStock(text)
	self.statusbar.widgets[1].text = text
	self.statusbar:layout()
end

function UI:setComplete(text)
	self.statusbar.widgets[3].text = text
	self.statusbar:layout()
end

function UI:toggleMenuDrawer()
	if self.menudrawer:visible() then
		self.menudrawer:hide()
	else
		self.menudrawer:show()
	end
end

function UI:hideDrawers()
	for _, drw in ipairs(self.drawers) do
		drw:hide()
	end
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
	for _, con in ipairs(self.containers) do
		con:layout()
	end
end

function UI:update(dt)

	for _, con in ipairs(self.containers) do
		con:update(dt)
	end

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

	for _, con in ipairs(self.containers) do
		con:draw()
	end

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
