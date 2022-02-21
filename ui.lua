-- ui

local log = require 'log'

local Titlebar = require 'ui_titlebar'
local MenuDrawer = require 'ui_menudrawer'
local Statusbar = require 'ui_statusbar'
local IconWidget = require 'ui_iconwidget'
local TextWidget = require 'ui_textwidget'
local DivWidget = require 'ui_divwidget'
local FAB = require 'ui_fab'

local Util = require 'util'

local UI = {
	-- titlebar
	-- toast manager
	-- statusbar
}
UI.__index = UI

local menuWidgets = {
	{text='New deal', baizeCmd='newDeal'},
	{text='Restart deal', name='restartdeal', enabled=false, baizeCmd='restartDeal'},
	{text='Find game...', baizeCmd='showVariantTypesDrawer'},
	{},
	{text='Set bookmark', baizeCmd='setBookmark'},
	{text='Go to bookmark', name='gotobookmark', enabled=false, baizeCmd='gotoBookmark'},
	{},
	{text='Settings...'},
	{text='Wikipedia...', baizeCmd='wikipedia'},
}

function UI.new()
	local o = {}
	setmetatable(o, UI)

	o.toasts = {} -- a queue of toasts; oldest to the left
	o.toastFont = love.graphics.newFont('assets/fonts/Roboto-Regular.ttf', 14)

	local wgt
	o.titlebar = Titlebar.new()
		wgt = IconWidget.new({parent=o.titlebar, name='menu', icon='menu', align='left', baizeCmd='toggleMenuDrawer'})
		table.insert(o.titlebar.widgets, wgt)

		wgt = TextWidget.new({parent=o.titlebar, name='title', text='', align='center'})
		table.insert(o.titlebar.widgets, wgt)

		wgt = IconWidget.new({parent=o.titlebar, name='undo', icon='undo', align='right', baizeCmd='undo'})
		table.insert(o.titlebar.widgets, wgt)
		wgt = IconWidget.new({parent=o.titlebar, name='collect', icon='done', align='right', baizeCmd='collect'})
		table.insert(o.titlebar.widgets, wgt)

	o.menudrawer = MenuDrawer.new()
	for _, winfo in ipairs(menuWidgets) do
		winfo.parent = o.menudrawer
		if winfo.text then
			table.insert(o.menudrawer.widgets, TextWidget.new(winfo))
		else
			table.insert(o.menudrawer.widgets, DivWidget.new(winfo))
		end
	end

	o.typesdrawer = MenuDrawer.new()
	for k, _ in pairs(_G.VARIANT_TYPES) do
		wgt = TextWidget.new({parent=o.typesdrawer, text=k, baizeCmd='showVariantsDrawer', param=k})
		table.insert(o.typesdrawer.widgets, wgt)
	end
	table.sort(o.typesdrawer.widgets, function(a, b) return a.text < b.text end)

	o.variantsdrawer = MenuDrawer.new({width=320})

	o.statusbar = Statusbar.new()
		wgt = TextWidget.new({parent=o.statusbar, name='stock', text='', align='left'})
		table.insert(o.statusbar.widgets, wgt)
		wgt = TextWidget.new({parent=o.statusbar, text='', align='center'})
		table.insert(o.statusbar.widgets, wgt)
		wgt = TextWidget.new({parent=o.statusbar, name='complete', text='', align='right'})
		table.insert(o.statusbar.widgets, wgt)

	o.containers = {o.titlebar, o.menudrawer, o.typesdrawer, o.variantsdrawer, o.statusbar}

	o.drawers = {o.menudrawer, o.typesdrawer, o.variantsdrawer}

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
	if self.fab then
		if Util.inRect(x, y, self.fab:screenRect()) then
			log.trace('FAB found')
			return self.fab
		end
	end
	return nil
end

function UI:updateWidget(name, text, enabled)
	for _, con in ipairs(self.containers) do
		local layoutRequired = false
		for _, wgt in ipairs(con.widgets) do
			-- widgets might not have a .name
			if wgt.name == name then
				-- log.trace('updating widget', name, enabled)
				if text ~= nil and wgt.text ~= text then
					wgt.text = text
					layoutRequired = true
				end
				if enabled ~= nil then wgt.enabled = enabled end
			end
		end
		if layoutRequired then
			con:layout()
		end
	end
end

function UI:toggleMenuDrawer()
	if self.menudrawer:visible() then
		Util.play('menuclose')
		self.menudrawer:hide()
	else
		Util.play('menuopen')
		self.menudrawer:show()
	end
end

function UI:showVariantTypesDrawer()
	self.typesdrawer:show()
end

function UI:showVariantsDrawer(vtype)
	self.variantsdrawer.widgets = {}
	if _G.VARIANT_TYPES[vtype] then
		for _, v in ipairs(_G.VARIANT_TYPES[vtype]) do
			local wgt = TextWidget.new({parent=self.variantsdrawer, text=v, baizeCmd='changeVariant', param=v})
			table.insert(self.variantsdrawer.widgets, wgt)
		end
		table.sort(self.variantsdrawer.widgets, function(a, b) return a.text < b.text end)
		self.variantsdrawer:layout()
		self.variantsdrawer:show()
		Util.play('menuopen')
	else
		log.error('unknown variant type', vtype)
	end
end

function UI:hideDrawers()
	for _, drw in ipairs(self.drawers) do
		drw:hide()
	end
end

function UI:showFAB(o)
	if self.fab then
		self:hideFAB()
	end
	self.fab = FAB.new(o)
	self.fab:layout()
end

function UI:hideFAB()
	self.fab = nil
end

function UI:toast(message, soundName)

	-- if we are already displaying this message, reset ticksLeft and quit
	for _, t in ipairs(self.toasts) do
		if t.message == message then
			t.ticksLeft = 4
			table.sort(self.toasts, function(a, b) return a.ticksLeft > b.ticksLeft end)
			return
		end
	end
	local t = {message=message, ticksLeft=4 + #self.toasts}
	table.insert(self.toasts, 1, t)

	if soundName then
		Util.play(soundName)
	end
end

function UI:layout()
	for _, con in ipairs(self.containers) do
		con:layout()
	end
	if self.fab then
		self.fab:layout()
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

	if self.fab then
		self.fab:draw()
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
		local rw = mw + self.toastFont:getWidth('M') * 2
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
