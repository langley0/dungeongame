-- 게임메뉴를 만든다

GameMenu = Core.class(Sprite)


function GameMenu.create()
	local menu = GameMenu.new()
	
	menu.buttons = {}
	menu.buttons[1] = Button.create("정보", nil, nil, 320, 64)
	menu.buttons[2] = Button.create("스킬", nil, nil, 320, 64)
	menu.buttons[3] = Button.create("아이템", nil, nil, 320, 64)
	menu.buttons[4] = Button.create("자동전투 ON/OFF", menu._ToggleAutoBattle, menu, 320, 64)
	menu.buttons[5] = Button.create("끝내기", nil, nil, 320, 64)
	
	menu.buttons[1]:setPosition(1280,32)
	menu.buttons[2]:setPosition(1280,104)
	menu.buttons[3]:setPosition(1280,176)
	menu.buttons[4]:setPosition(1280,248)
	menu.buttons[5]:setPosition(1280,320)
	
	menu.screen = Bitmap.new(Texture.new("dungeon/blackscreen.png"))
	menu.screen:setAlpha(0)
	
	--menu:addChild(menu.screen)
	menu:addChild(menu.buttons[1])
	menu:addChild(menu.buttons[2])
	menu:addChild(menu.buttons[3])
	menu:addChild(menu.buttons[4])
	menu:addChild(menu.buttons[5])
	
	menu.value = -1
	menu.autobattle = true
	
	menu:addEventListener(Event.ENTER_FRAME, menu.Update, menu)
	
	return menu
end 

function GameMenu:_ToggleAutoBattle()
	if self.autobattle then 
		self.autobattle = false
	else 
		self.autobattle = true
	end 
end 

function GameMenu:Show()
	self.show = true
end 

function GameMenu:Hide()
	self.show = nil
end 

function GameMenu:Update(event)
	
	if self.show then 
		-- 보여준다
		--총 1초동안 나오고 각각의 메뉴는 0.5초동안 이동한다
		-- 따라서 각각 0 초. 0.167 0.333 0.5 초에 등장하면 된다
		self.value = math.min(self.value + event.deltaTime * 2, 1)
	else 
		
		
		-- 사라진다
		self.value = math.max(self.value - event.deltaTime * 2, -1)
	end 
	
	self.screen:setAlpha(self.value)
	self.buttons[1]:setPosition(1280 - 320 * math.min(0.5, self.value) / 0.5, 32)
	self.buttons[2]:setPosition(1280 - 320 * math.min(0.5, self.value - 0.125) / 0.5, 104)
	self.buttons[3]:setPosition(1280 - 320 * math.min(0.5, self.value - 0.250) / 0.5, 176)
	self.buttons[4]:setPosition(1280 - 320 * math.min(0.5, self.value - 0.375) / 0.5, 248)
	self.buttons[5]:setPosition(1280 - 320 * math.min(0.5, self.value - 0.5) / 0.5, 320)
end 