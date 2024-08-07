-- ui

local log = require 'log'

local Titlebar = require 'ui_titlebar'
local Drawer = require 'ui_drawer'
local Statusbar = require 'ui_statusbar'
local IconWidget = require 'ui_iconwidget'
local TextWidget = require 'ui_textwidget'
local MenuItemWidget = require 'ui_menuitemwidget'
local DivWidget = require 'ui_divwidget'
local Checkbox = require 'ui_checkbox'
local Radio = require 'ui_radio'
local FAB = require 'ui_fab'
local ModalDialog = require 'ui_modaldialog'

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
	{text='Statistics...', icon='poll', baizeCmd='showStatsDrawer'},
	{text='Settings...', icon='settings', baizeCmd='showSettingsDrawer'},
	-- {text='Colors...', icon='palette', baizeCmd='showColorDrawer'},
	-- {text='Card speed...', icon='speed', baizeCmd='showAniSpeedDrawer'},
	{},
	{text='Wikipedia...', icon='wikipedia', baizeCmd='wikipedia'},
	{text='About...', icon='info', baizeCmd='showAboutDrawer'},
	{text='Save and quit', icon='close', baizeCmd='quit'},
}

local settingsWidgets = {
	{text='Simple cards', var='simpleCards'},
	{text='Colorful cards', var='autoColorCards'},
	{text='Gradient shading', var='gradientShading'},
	{text='Compress piles', var='cardScrunching'},
	{text='Power moves', var='powerMoves'},
	{text='Auto collect', var='autoCollect'},
	{text='Safe collect', var='safeCollect'},
	{text='Mirror baize', var='mirrorBaize'},
	{text='Mute sounds', var='muteSounds'},
}

local aniSpeedWidgets = {
	{text="Fast", var="aniSpeed", val=0.3},
	{text="Normal", var="aniSpeed", val=0.5},
	{text="Slow", var="aniSpeed", val=0.9},
}

if love.system.getOS() == 'Android' then
	table.insert(settingsWidgets, {text='Allow orientation', var='allowOrientation'})
end

function UI.new()
	local o = {}
	setmetatable(o, UI)

	local wgt	-- temporary widget variable used temporaryly for readability

	o.toasts = {} -- a queue of toasts; oldest to the left
	o.toastFont = love.graphics.newFont(_G.UI_REGULAR_FONT, _G.UIFONTSIZE_SMALL)

	-- titlebar

	o.titlebar = Titlebar.new({})
		wgt = IconWidget.new({parent=o.titlebar, name='menu', icon='menu', align='left', baizeCmd='toggleMenuDrawer'})
		table.insert(o.titlebar.widgets, wgt)

		wgt = TextWidget.new({parent=o.titlebar, name='title', text='', align='center'})
		table.insert(o.titlebar.widgets, wgt)

		wgt = IconWidget.new({parent=o.titlebar, name='undo', icon='undo', align='right', baizeCmd='undo'})
		table.insert(o.titlebar.widgets, wgt)
		wgt = IconWidget.new({parent=o.titlebar, name='collect', icon='done', align='right', baizeCmd='collect'})
		table.insert(o.titlebar.widgets, wgt)
		wgt = IconWidget.new({parent=o.titlebar, name='hint', icon='lightbulb', align='right', baizeCmd='hint'})
		table.insert(o.titlebar.widgets, wgt)

	-- main menu drawer

	o.menuDrawer = Drawer.new({width=300 * _G.UI_SCALE})
	for _, winfo in ipairs(menuWidgets) do
		winfo.parent = o.menuDrawer
		if winfo.text then
			table.insert(o.menuDrawer.widgets, MenuItemWidget.new(winfo))
		else
			table.insert(o.menuDrawer.widgets, DivWidget.new(winfo))
		end
	end

	-- variant types drawer

	o.typesDrawer = Drawer.new({width=300 * _G.UI_SCALE})
	for k, _ in pairs(_G.VARIANT_TYPES) do
		wgt = MenuItemWidget.new({parent=o.typesDrawer, text=k, baizeCmd='showVariantsDrawer', param=k})
		table.insert(o.typesDrawer.widgets, wgt)
	end
	table.sort(o.typesDrawer.widgets, function(a, b) return a.text < b.text end)

	-- all/subtypes variant drawer (dynamically filled)

	o.variantsDrawer = Drawer.new({width=300 * _G.UI_SCALE})

	-- stats drawer (dynamically filled)

	o.statsDrawer = Drawer.new({width=400 * _G.UI_SCALE})

	-- settings drawer

	o.settingsDrawer = Drawer.new({width=300 * _G.UI_SCALE})

	wgt = MenuItemWidget.new({parent=o.settingsDrawer, icon='palette', text="Colors ...", baizeCmd='showColorDrawer'})
	table.insert(o.settingsDrawer.widgets, wgt)

	wgt = MenuItemWidget.new({parent=o.settingsDrawer, icon='speed', text="Card speed ...", baizeCmd='showAniSpeedDrawer'})
	table.insert(o.settingsDrawer.widgets, wgt)

	for _, winfo in ipairs(settingsWidgets) do
		winfo.parent = o.settingsDrawer
		if winfo.val then
			table.insert(o.settingsDrawer.widgets, Radio.new(winfo))
		else
			table.insert(o.settingsDrawer.widgets, Checkbox.new(winfo))
		end
	end

	wgt = TextWidget.new({parent=o.settingsDrawer, text='[ Reset ]', baizeCmd='resetSettings'})
	table.insert(o.settingsDrawer.widgets, wgt)

	-- color types drawer  (dynamically filled)

	o.colorTypesDrawer = Drawer.new({width=256 * _G.UI_SCALE})

	-- color picker drawer (dynamically filled)

	o.allColorsDrawer = Drawer.new({width=256 * _G.UI_SCALE})

	-- card animation speed drawer

	o.aniSpeedDrawer = Drawer.new({width=256 * _G.UI_SCALE})
	for _, winfo in ipairs(aniSpeedWidgets) do
		winfo.parent = o.aniSpeedDrawer
		table.insert(o.aniSpeedDrawer.widgets, Radio.new(winfo))
	end

	-- simple about... drawer

	o.aboutDrawer = Drawer.new({width=360 * _G.UI_SCALE, font=o.toastFont})

	-- status bar

	o.statusbar = Statusbar.new({})
		wgt = TextWidget.new({parent=o.statusbar, name='stock', text='', align='left'})
		table.insert(o.statusbar.widgets, wgt)
		wgt = TextWidget.new({parent=o.statusbar, name='status', text='', align='center'})
		table.insert(o.statusbar.widgets, wgt)
		wgt = TextWidget.new({parent=o.statusbar, name='progress', text='', align='right'})
		table.insert(o.statusbar.widgets, wgt)

	-- list of all containers

	o.containers = {o.titlebar, o.menuDrawer, o.typesDrawer, o.variantsDrawer, o.statsDrawer, o.settingsDrawer, o.aniSpeedDrawer, o.colorTypesDrawer, o.allColorsDrawer, o.aboutDrawer, o.statusbar}

	-- list of all drawers

	o.drawers = {o.menuDrawer, o.typesDrawer, o.variantsDrawer, o.statsDrawer, o.settingsDrawer, o.aniSpeedDrawer, o.colorTypesDrawer, o.allColorsDrawer, o.aboutDrawer}

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
	if self.modalDialog then
		if Util.inRect(x, y, self.modalDialog:screenRect()) then
			for _, w in ipairs(self.modalDialog.widgets) do
				if Util.inRect(x, y, w:screenRect()) then
					return w
				end
			end
		end
		log.trace('dialog widget not found')
		return nil	-- if a dialog is open, no other widget should work
	end

	local con = self:findContainerAt(x, y)
	if con then
		for _, w in ipairs(con.widgets) do
			if Util.inRect(x, y, w:hitRect()) then
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
	if self.menuDrawer:isOpen() then
		self.menuDrawer:hide()
	else
		self.menuDrawer:show()
	end
end

function UI:showVariantTypesDrawer()
	self.typesDrawer:show()
end

function UI:showStatsDrawer(strs)
	self.statsDrawer.widgets = {}
	for _, str in ipairs(strs) do
		local wgt = TextWidget.new({parent=self.statsDrawer, text=str})
		table.insert(self.statsDrawer.widgets, wgt)
	end
	local wgt = DivWidget.new({parent=self.statsDrawer})
	table.insert(self.statsDrawer.widgets, wgt)
	wgt = TextWidget.new({parent=self.statsDrawer, text='[ Reset ]', baizeCmd='resetStats'})
	table.insert(self.statsDrawer.widgets, wgt)
	self.statsDrawer:layout()
	self.statsDrawer:show()
end

function UI:showSettingsDrawer()
	for _, wgt in ipairs(self.settingsDrawer.widgets) do
		-- log.trace(wgt.var, 'is', _G.SETTINGS[wgt.var])
		if wgt.var then
			if _G.SETTINGS[wgt.var] then
				wgt.checked = true
				wgt.img = wgt.imgChecked
			else
				wgt.checked = false
				wgt.img = wgt.imgUnchecked
			end
		end
	end
	self.settingsDrawer:show()
end

function UI:showColorDrawer()
	self.colorTypesDrawer.widgets = {}

	-- build this dynamically because colors change
	local textColor = Util.getForegroundColor(_G.SETTINGS['baizeColor'])
	local wgt = {text='Background', backColor=_G.SETTINGS['baizeColor'], textColor=textColor, baizeCmd='colorBackground', parent=self.colorTypesDrawer}
	table.insert(self.colorTypesDrawer.widgets, MenuItemWidget.new(wgt))

	textColor=Util.getForegroundColor(_G.SETTINGS['cardFaceColor'])
	wgt = {text='Card face', backColor=_G.SETTINGS['cardFaceColor'], textColor=textColor, baizeCmd='colorCardFace', parent=self.colorTypesDrawer}
	table.insert(self.colorTypesDrawer.widgets, MenuItemWidget.new(wgt))

	textColor = Util.getForegroundColor(_G.SETTINGS['cardBackColor'])
	wgt = {text='Card back', backColor=_G.SETTINGS['cardBackColor'], textColor=textColor, baizeCmd='colorCardBack', parent=self.colorTypesDrawer}
	table.insert(self.colorTypesDrawer.widgets, MenuItemWidget.new(wgt))

	textColor = Util.getForegroundColor(_G.SETTINGS['clubColor'])
	wgt = {text='Colorful club', backColor=_G.SETTINGS['clubColor'], textColor=textColor, baizeCmd='colorClub', parent=self.colorTypesDrawer}
	table.insert(self.colorTypesDrawer.widgets, MenuItemWidget.new(wgt))

	textColor = Util.getForegroundColor(_G.SETTINGS['diamondColor'])
	wgt = {text='Colorful diamond', backColor=_G.SETTINGS['diamondColor'], textColor=textColor, baizeCmd='colorDiamond', parent=self.colorTypesDrawer}
	table.insert(self.colorTypesDrawer.widgets, MenuItemWidget.new(wgt))

	textColor = Util.getForegroundColor(_G.SETTINGS['heartColor'])
	wgt = {text='Colorful heart', backColor=_G.SETTINGS['heartColor'], textColor=textColor, baizeCmd='colorHeart', parent=self.colorTypesDrawer}
	table.insert(self.colorTypesDrawer.widgets, MenuItemWidget.new(wgt))

	textColor = Util.getForegroundColor(_G.SETTINGS['spadeColor'])
	wgt = {text='Colorful spade', backColor=_G.SETTINGS['spadeColor'], textColor=textColor, baizeCmd='colorSpade', parent=self.colorTypesDrawer}
	table.insert(self.colorTypesDrawer.widgets, MenuItemWidget.new(wgt))

	textColor = Util.getForegroundColor(_G.SETTINGS['hintColor'])
	wgt = {text='Hints', backColor=_G.SETTINGS['hintColor'], textColor=textColor, baizeCmd='colorHint', parent=self.colorTypesDrawer}
	table.insert(self.colorTypesDrawer.widgets, MenuItemWidget.new(wgt))

	self.colorTypesDrawer:layout()
	self.colorTypesDrawer:show()
end

function UI:showAniSpeedDrawer()
	-- determine which radio buttons should be checked
	for _, wgt in ipairs(self.aniSpeedDrawer.widgets) do
		wgt:setChecked(_G.SETTINGS[wgt.var] == wgt.val)
	end
	-- self.aniSpeedDrawer:layout()	-- TODO is this needed?
	self.aniSpeedDrawer:show()
end

function UI:showColorPickerDrawer(setting)
	-- fill dynamically because setting changes
	local palette = {}
	for k, _ in pairs(_G.LSOL_COLORS) do
			table.insert(palette, k)
		end
	self.allColorsDrawer.widgets = {}
	for _, str in ipairs(palette) do
		local textColor = Util.getForegroundColor(str)
		local wgt = MenuItemWidget.new({parent=self.allColorsDrawer, text=str, textColor=textColor, backColor=str, baizeCmd='modifySetting', param={setting=setting, value=str}})
		table.insert(self.allColorsDrawer.widgets, wgt)
	end
	table.sort(self.allColorsDrawer.widgets, function(a,b) return a.text < b.text end)
	self.allColorsDrawer:layout()
	self.allColorsDrawer:show()
end

function UI:showAboutDrawer(strs)
	self.aboutDrawer.widgets = {}
	for _, str in ipairs(strs) do
		local wgt = TextWidget.new({parent=self.aboutDrawer, text=str})
		if str:find('https://', 1, true) then -- (string, pattern, init, plain)
			wgt.baizeCmd = 'openURL'
			wgt.param = str
			wgt.textColor = 'LightSkyBlue'
		end
		table.insert(self.aboutDrawer.widgets, wgt)
	end
	self.aboutDrawer.widgets[1].font = love.graphics.newFont(_G.ORD_FONT, _G.UIFONTSIZE)
	self.aboutDrawer:layout()
	self.aboutDrawer:show()
end

function UI:showVariantsDrawer(vtype)
	-- content created dynamically
	self.variantsDrawer.widgets = {}
	if _G.VARIANT_TYPES[vtype] then
		if vtype == '> Favorites' then
			local stats = _G.BAIZE.stats
			local tab = {}
			-- make a list of all the variants we have played
			for k, _ in pairs(stats) do
				local vstats = stats[k]
				if vstats and vstats.won and vstats.lost then
					local played = vstats.won + vstats.lost
					if played > 0 then
						table.insert(tab, k)
					end
				end
			end
			-- sort the table by the number of times we have played
			table.sort(tab, function(a,b)
				local aplayed = stats[a].won + stats[a].lost
				local bplayed = stats[b].won + stats[b].lost
				return aplayed > bplayed
			end)
			-- new player?
			if #tab == 0 then
				tab = {'Freecell', 'Klondike', 'Spider', 'Yukon'}
			end
			-- create widgets
			for _, v in ipairs(tab) do
				local wgt = MenuItemWidget.new({parent=self.variantsDrawer, text=v, baizeCmd='changeVariant', param=v})
				table.insert(self.variantsDrawer.widgets, wgt)
			end
		else
			for _, v in ipairs(_G.VARIANT_TYPES[vtype]) do
				local wgt = MenuItemWidget.new({parent=self.variantsDrawer, text=v, baizeCmd='changeVariant', param=v})
				table.insert(self.variantsDrawer.widgets, wgt)
			end
			table.sort(self.variantsDrawer.widgets, function(a, b) return a.text < b.text end)
		end
		-- if _G.SETTINGS.debug then
		-- 	for _, v in ipairs(self.variantsDrawer.widgets) do
		-- 		print('♥ ' .. v.text)
		-- 	end
		-- 	print(#self.variantsDrawer.widgets, 'variants')
		-- end
		self.variantsDrawer:layout()
		self.variantsDrawer:show()
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

function UI:showModalDialog(obj)
	if self.modalDialog then
		log.error('There is already a modal dialog')
		return
	end
	obj.font = self.toastFont
	self.modalDialog = ModalDialog.new(obj)
	self.modalDialog:layout()
end

function UI:cancelModalDialog()
	if self.modalDialog then
		self.modalDialog = nil
	end
end

function UI:toast(message, soundName)

	-- if we are already displaying this message, reset secondsLeft and quit
	for _, t in ipairs(self.toasts) do
		if t.message == message then
			t.secondsLeft = 6
			table.sort(self.toasts, function(a, b) return a.secondsLeft < b.secondsLeft end)
			return
		end
	end
	local t = {message=message, secondsLeft=5 + #self.toasts}
	t.mw = self.toastFont:getWidth(message)
	t.mh = self.toastFont:getHeight()
	t.rw = t.mw + self.toastFont:getWidth('M') * 3
	t.rh = t.mh + self.toastFont:getHeight() * 2

	-- create a texture to avoid calling rectangle, print every frame
	-- https://material.io/archive/guidelines/components/snackbars-toasts.html#snackbars-toasts-specs
	-- Single-line snackbar height: 48dp
	-- Text: Roboto Regular 14sp
	-- Default background fill: #323232 100%

	-- small font gets corrupted with antialiasing on, so turn it off when building toast image
	love.graphics.setDefaultFilter('linear', 'linear', 1)

	local canvas = love.graphics.newCanvas(t.rw, t.rh)
	love.graphics.setCanvas(canvas)
	Util.setColorFromName('UiBackground')
	love.graphics.rectangle('fill', 0, 0, t.rw, t.rh)
	Util.setColorFromName('UiForeground')
	love.graphics.setFont(self.toastFont)
	love.graphics.print(t.message, (t.rw / 2) - (t.mw / 2), (t.rh / 2) - (t.mh / 2))
	love.graphics.setCanvas()
	t.texture = canvas

	love.graphics.setDefaultFilter('nearest', 'nearest', 1)

	table.insert(self.toasts, 1, t)

	if soundName ~= nil then
		Util.play(soundName)
	end
end

function UI:untoast(removeMe)
	for i = 1, #self.toasts do
		if self.toasts[i] == removeMe then
			-- log.info('removing toast', removeMe.message)
			table.remove(self.toasts, i)
			break
		end
	end
end

function UI:findToastAt(x, y)
	for _, t in ipairs(self.toasts) do
		if t.x and t.y then	-- may not exist until toast is drawn
			if Util.inRect(x, y, t.x, t.y, t.x + t.rw, t.y + t.rh) then
				return t
			end
		end
	end
	return nil
end

function UI:layout()
	for _, con in ipairs(self.containers) do
		con:layout()
	end
	-- TODO why not layout toast here?
	-- TODO why are toasts not containers?
	if self.fab then
		-- TODO why is FAB not a container?
		self.fab:layout()
	end
	if self.modalDialog then
		self.modalDialog:layout()
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

	if self.modalDialog then
		self.modalDialog:draw()
	end

	if #self.toasts > 0 then
		love.graphics.setColor(1,1,1,1)
		local y = (_G.UI_SAFEY + _G.UI_SAFEH) - _G.STATUSBARHEIGHT
		for i = 1, #self.toasts do
			local t = self.toasts[i]
			y = y - (t.rh * 1.3333)
			t.x = (_G.UI_SAFEW - t.rw) / 2
			t.y = y
			love.graphics.draw(t.texture, t.x, t.y)
		end
	end

end

return UI
