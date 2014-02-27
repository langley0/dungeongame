Coin = Core.class(Sprite)

function Coin.create(world)
	local coin = Coin.new()
	coin.world = world
	
	local image = Bitmap.new(Texture.new("drop/cristal.png"))
	image:setScale(3,3)
	image:setAnchorPoint(0.5,0.5)
	
	coin:addChild(image)
	
	coin:addEventListener(Event.ENTER_FRAME, coin.Update, coin)
	coin.time = 0
	
	
	return coin
end 


function Coin:Update(event)
	self.time = self.time + event.deltaTime
	
	-- 플레이어쪽으로 끌어 당겨진다.
	-- 한번 당겨진 코인은 점점 빨라진다.
	local my_x, my_y = self:getPosition()
	local p_x, p_y = self.world.player:getPosition()
	

	local dx = p_x - my_x
	local dy = p_y - my_y
	
	local length = math.sqrt(dx*dx + dy*dy)
	
	
	if self.pulling then 
		if length < 32 then 
			-- 흡수
			self:getParent():removeChild(self)
			self:removeEventListener(Event.ENTER_FRAME, self.Update, self)
		else 
			-- 속도는 1000 까지 2초안에 늘어나고, 그뒤는 1000을 유지
			local speed = math.min(1000, self.time * 500)
			local x = dx / length * speed * event.deltaTime  + my_x
			local y = dy / length * speed * event.deltaTime  + my_y
			
			self:setPosition(x, y)
		end 
	else 
	
		if length < 240 then 
			self.pulling = 0
			self.time = 0
		elseif self.time > 10  then  
			-- 소멸된다
			self:getParent():removeChild(self)
			self:removeEventListener(Event.ENTER_FRAME, self.Update, self)
		end 
	end 
	
	
end 