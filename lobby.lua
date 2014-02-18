-- 로비에서는 캐릭터는 선택해서 월드로 넘기는 일을 한다
Lobby = Core.class(Sprite)

function Lobby.create()
	
	local instance = Lobby.new()
	
	instance:addEventListener(Event.TOUCHES_BEGIN, instance.OnToucheBegin, instance)
	instance:addEventListener(Event.TOUCHES_MOVE, instance.OnToucheMove, instance)
	instance:addEventListener(Event.TOUCHES_END, instance.OnToucheEnd, instance)
	
	
	local button = Button.create("PLAY", instance.OnPlayClick, instance, 300, 50)
	button:setPosition(100,600)
	instance:addChild(button)
	
	-- 각영웅을 그린다
	local hero = {}
	hero[1] = Player.create("warrior")
	hero[2] = Player.create("archer")
	hero[3] = Player.create("wizard")
	
	hero[1]:setPosition(400, 300)
	hero[2]:setPosition(600, 300)
	hero[3]:setPosition(800, 300)
	
	instance:addChild(hero[1])
	instance:addChild(hero[2])
	instance:addChild(hero[3])
	
	instance.hero = hero
	
	
	local stats = {}
	stats[1] = Sprite.new()
	stats[2] = Sprite.new()
	stats[3] = Sprite.new()
	
	for i = 1, #hero do 
		local name = CreateText(hero[i].name)
		name:setTextColor(0xffffff)
		stats[i]:addChild(name)
	end 
	stats[1]:setPosition(400 - 50, 400)
	stats[2]:setPosition(600 - 50, 400)
	stats[3]:setPosition(800 - 50, 400)
	
	instance.hero_stat = stats
	return instance
	
end 


function Lobby.destroy(instance)
	
	instance:removeEventListener(Event.TOUCHES_BEGIN, instance.OnToucheBegin, instance)
	instance:removeEventListener(Event.TOUCHES_MOVE, instance.OnToucheMove, instance)
	instance:removeEventListener(Event.TOUCHES_END, instance.OnToucheEnd, instance)
	
end 

function Lobby:OnToucheBegin(event)
	
	-- 영웅이 터치되었다면 선택한다
	for i = 1, #self.hero do 
		if (self.hero[i]:hitTestPoint(event.touch.x, event.touch.y)) then 
			-- 이것을 선택한다
			if self.selection == nil then 
				local bmp = Bitmap.new(Texture.new("intro/lobby_selection.png"))
				bmp:setAnchorPoint(0.5,0.5)
				bmp:setScale(3,3)
				self.selection = bmp
				self:addChild(bmp)
			end 
			
			if self.selected_hero then
				self.selected_hero.movie:stop()
				self.selected_hero_stat:getParent():removeChild(self.selected_hero_stat)
			end 
			
			self.selected_hero = self.hero[i]
			self.selected_hero.movie:play()
			self.selected_hero_stat = self.hero_stat[i]
			
			self:addChild(self.selected_hero_stat)
			
			
			
			self.selection:setPosition(self.hero[i]:getPosition())
			break
		end 
	end 
	
end 

function Lobby:OnToucheMove()
	
end 

function Lobby:OnToucheEnd()
	
end 

function Lobby:OnPlayClick()
	-- 게임을 시작한다
	if self.selected_hero and self.StartPlay then 
		
		self.selected_hero:getParent():removeChild(self.selected_hero)
		self:StartPlay(self.selected_hero)
	end
end