-- ui

local log = require 'log'

local Titlebar = require 'ui_titlebar'
local MenuDrawer = require 'ui_menudrawer'
local TextDrawer = require 'ui_textdrawer'
local Statusbar = require 'ui_statusbar'
local IconWidget = require 'ui_iconwidget'
local TextWidget = require 'ui_textwidget'
local DivWidget = require 'ui_divwidget'
local Checkbox = require 'ui_checkbox'
local Radio = require 'ui_radio'
local FAB = require 'ui_fab'

local Util = require 'util'

local UI = {}
UI.__index = UI

local menuWidgets = {
	{text='New deal', icon='star', baizeCmd='newDeal'},
	{text='Restart deal', icon='restore', name='restartdeal', enabled=false, baizeCmd='restartDeal'},
	{text='Find game...', icon='search', baizeCmd='showVariantTypesDrawer'},
	{},
	{text='Set bookmark', icon='bookmark_add', baizeCmd='setBookmark'},
	{text='Go to bookmark', icon='bookmark', name='gotobookmark', enabled=false, baizeCmd='gotoBookmark'},
	{},
	{text='Statistics...', icon='list', baizeCmd='showStatsDrawer'},
	{text='Settings...', icon='settings', baizeCmd='showSettingsDrawer'},
	{text='Wikipedia...', icon='info', baizeCmd='wikipedia'},
	{},
	{text='Save and quit', icon='close', baizeCmd='quit'},
}

local settingsWidgets = {
	{text='Simple cards', var='simpleCards'},
	{text='Short cards', var='shortCards'},
	{text='One-color cards', var='oneColorCards', grp={'oneColorCards','twoColorCards','fourColorCards', 'autoColorCards'}},
	{text='Two-color cards', var='twoColorCards', grp={'oneColorCards','twoColorCards','fourColorCards', 'autoColorCards'}},
	{text='Four-color cards', var='fourColorCards', grp={'oneColorCards','twoColorCards','fourColorCards', 'autoColorCards'}},
	{text='Auto-color cards', var='autoColorCards', grp={'oneColorCards','twoColorCards','fourColorCards', 'autoColorCards'}},
	{text='Power moves', var='powerMoves'},
	{text='Mirror baize', var='mirrorBaize'},
	{text='Mute sounds', var='muteSounds'},
	{text='Debug', var='debug'},
}

function UI.new()
	local o = {}
	setmetatable(o, UI)

	o.toasts = {} -- a queue of toasts; oldest to the left
	o.toastFont = love.graphics.newFont(_G.UI_REGULAR_FONT, _G.UIFONTSIZE_SMALL)

	local wgt
	o.titlebar = Titlebar.new({})
		wgt = IconWidget.new({parent=o.titlebar, name='menu', icon='menu', align='left', baizeCmd='toggleMenuDrawer'})
		table.insert(o.titlebar.widgets, wgt)

		wgt = TextWidget.new({parent=o.titlebar, name='title', text='', align='center'})
		table.insert(o.titlebar.widgets, wgt)

		wgt = IconWidget.new({parent=o.titlebar, name='undo', icon='undo', align='right', baizeCmd='undo'})
		table.insert(o.titlebar.widgets, wgt)
		wgt = IconWidget.new({parent=o.titlebar, name='collect', icon='done', align='right', baizeCmd='collect'})
		table.insert(o.titlebar.widgets, wgt)

	o.menudrawer = MenuDrawer.new({width=320 * _G.UI_SCALE})
	for _, winfo in ipairs(menuWidgets) do
		winfo.parent = o.menudrawer
		if winfo.text then
			table.insert(o.menudrawer.widgets, IconWidget.new(winfo))
		else
			table.insert(o.menudrawer.widgets, DivWidget.new(winfo))
		end
	end

	o.typesdrawer = MenuDrawer.new({width=320 * _G.UI_SCALE})
	for k, _ in pairs(_G.VARIANT_TYPES) do
		wgt = TextWidget.new({parent=o.typesdrawer, text=k, baizeCmd='showVariantsDrawer', param=k})
		table.insert(o.typesdrawer.widgets, wgt)
	end
	table.sort(o.typesdrawer.widgets, function(a, b) return a.text < b.text end)

	o.variantsdrawer = MenuDrawer.new({width=320 * _G.UI_SCALE})

	o.statsdrawer = TextDrawer.new({width=420 * _G.UI_SCALE})

	o.settingsdrawer = MenuDrawer.new({width=320 * _G.UI_SCALE})
	for _, winfo in ipairs(settingsWidgets) do
		winfo.parent = o.settingsdrawer
		if winfo.grp then
			table.insert(o.settingsdrawer.widgets, Radio.new(winfo))
		else
			table.insert(o.settingsdrawer.widgets, Checkbox.new(winfo))
		end
	end

	o.statusbar = Statusbar.new({})
		wgt = TextWidget.new({parent=o.statusbar, name='stock', text='', align='left'})
		table.insert(o.statusbar.widgets, wgt)
		wgt = TextWidget.new({parent=o.statusbar, name='status', text='', align='center'})
		table.insert(o.statusbar.widgets, wgt)
		wgt = TextWidget.new({parent=o.statusbar, name='progress', text='', align='right'})
		table.insert(o.statusbar.widgets, wgt)

	o.containers = {o.titlebar, o.menudrawer, o.typesdrawer, o.variantsdrawer, o.statsdrawer, o.settingsdrawer, o.statusbar}

	o.drawers = {o.menudrawer, o.typesdrawer, o.variantsdrawer, o.statsdrawer, o.settingsdrawer}

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
			-- log.trace('FAB found')
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
	if self.menudrawer:isOpen() then
		self.menudrawer:hide()
	else
		self.menudrawer:show()
	end
end

function UI:showVariantTypesDrawer()
	self.typesdrawer:show()
end

function UI:showStatsDrawer(strs)
	self.statsdrawer.widgets = {}
	for _, str in ipairs(strs) do
		local wgt = TextWidget.new({parent=self.statsdrawer, text=str})
		table.insert(self.statsdrawer.widgets, wgt)
	end
	local wgt = DivWidget.new({parent=self.statsdrawer})
	table.insert(self.statsdrawer.widgets, wgt)
	wgt = TextWidget.new({parent=self.statsdrawer, text='[ Reset ]', baizeCmd='resetStats'})
	table.insert(self.statsdrawer.widgets, wgt)
	self.statsdrawer:layout()
	self.statsdrawer:show()
end

function UI:showSettingsDrawer()
	-- TODO go through widgets and determine if they are checked or unchecked
	for _, wgt in ipairs(self.settingsdrawer.widgets) do
		-- log.trace(wgt.var, 'is', _G.BAIZE.settings[wgt.var])
		if wgt.var then
			if _G.BAIZE.settings[wgt.var] then
				wgt.checked = true
				wgt.img = wgt.imgChecked
			else
				wgt.checked = false
				wgt.img = wgt.imgUnchecked
			end
		end
	end
	self.settingsdrawer:show()
end

function UI:showVariantsDrawer(vtype)
	self.variantsdrawer.widgets = {}
	if _G.VARIANT_TYPES[vtype] then
		for _, v in ipairs(_G.VARIANT_TYPES[vtype]) do
			local wgt = TextWidget.new({parent=self.variantsdrawer, text=v, baizeCmd='changeVariant', param=v})
			table.insert(self.variantsdrawer.widgets, wgt)
		end
		table.sort(self.variantsdrawer.widgets, function(a, b) return a.text < b.text end)
		if _G.BAIZE.settings.debug then
			for k, v in ipairs(self.variantsdrawer.widgets) do
				print(k, v.text)
			end
		end
		self.variantsdrawer:layout()
		self.variantsdrawer:show()
	else
		log.error('unknown variant type', vtype)
	end
end

function UI:findOpenDrawer()
	for _, drw in ipairs(self.drawers) do
		if drw:isOpen() then
			return drw
		end
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

	-- if we are already displaying this message, reset secondsLeft and quit
	for _, t in ipairs(self.toasts) do
		if t.message == message then
			t.secondsLeft = 4
			table.sort(self.toasts, function(a, b) return a.secondsLeft > b.secondsLeft end)
			return
		end
	end
	local t = {message=message, secondsLeft=4 + #self.toasts}
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

function UI:update(dt_seconds)

	for _, con in ipairs(self.containers) do
		con:update(dt_seconds)
	end

	if #self.toasts > 0 then
		for _, t in ipairs(self.toasts) do
			t.secondsLeft = t.secondsLeft - dt_seconds
		end
		-- remove the oldest (last in table) if it has expired
		if self.toasts[#self.toasts].secondsLeft < 0.0 then
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
		Util.setColorFromName('UiBackground')
		love.graphics.setFont(self.toastFont)
		local mw = self.toastFont:getWidth(message)
		local mh = self.toastFont:getHeight(message)
		local rw = mw + self.toastFont:getWidth('M') * 2
		local rh = mh + self.toastFont:getHeight('M') * 2
		love.graphics.rectangle('fill', _G.UI_SAFEX + (_G.UI_SAFEW - rw) / 2, _G.UI_SAFEY + ((_G.UI_SAFEH - rh) / 2) + y, rw, rh, _G.BAIZE.cardRadius, _G.BAIZE.cardRadius)
		Util.setColorFromName('UiForeground')
		love.graphics.print(message, _G.UI_SAFEX + (_G.UI_SAFEW - mw) / 2, _G.UI_SAFEY + ((_G.UI_SAFEH - mh) / 2) + y)
	end

	if #self.toasts > 0 then
		for i = 1, #self.toasts do
			-- (i + 2) to nudge to toasts down the screen a little
			drawToast(self.toasts[i].message, (i + 2) * (_G.TITLEBARHEIGHT + self.toastFont:getHeight('M')))
			-- drawToast(string.format('%d %s', self.toasts[i].secondsLeft, self.toasts[i].message), i * (48 + 12))
		end
	end

end

return UI
