Science_EnergyBall = Core.class(Sprite)

function Science_EnergyBall.create()
	local energyball =  Science_EnergyBall.new()

	energyball.name = "에너지볼"
	energyball.delay = 0.6
	energyball.cooltime = 0
	energyball.distance = 250
	energyball.flying_speed = 500
	energyball.type = "autopassive"
	
	return energyball
end


-- 무기 공통함수
function Science_EnergyBall:CanUse(invoker, world)
	-- 쿨타임만 계산한다
	if self.cooltime  > 0 then 
		return false
	end 
	
	return true
end

function Science_EnergyBall:GetRange()
	return self.distance
end 

function Science_EnergyBall:Update(deltaTime)
	self.cooltime  = self.cooltime - deltaTime
end 


-- 무기 공통함수
function Science_EnergyBall:Use(invoker, world)
	
	local x2, y2 = invoker:getPosition()
	
	local target = world:GetClosestEnemyFrom(x2, y2)
	if target == nil then return end 
	
	-- 에너지볼을 발사한다
	local x, y = target:getPosition()
	local dx = x - x2
	local dy = y - y2
	
	local length = math.sqrt(dx*dx + dy*dy)
	
	if length < 0.1 then 
		-- 너무 붙어있다. 적당히 발사하자
		dx = 1
		dy = 0
	else 
		dx = dx / length
		dy = dy / length
	end 
	
	-- 스피드를 곱해서 적당히 발사하자
	local energyball = EnergyBall.create(dx, dy, self.flying_speed, self.distance, invoker.level, world)
	energyball:setPosition(x2, y2)
	world.effect_layer:addChild(energyball)
	
	if invoker.GetFriends then
		local friends = invoker:GetFriends()
		
		for i = 1, #friends do
			local friend = friends[i]
			local fx, fy = friend:getPosition()
			
			local energyball = EnergyBall.create(dx, dy, self.flying_speed, self.distance, 1, world)
			energyball:setPosition(fx, fy)
			world.effect_layer:addChild(energyball)
		end
	end
	
	self.cooltime = self.delay
end 

local energyball_texture = Texture.new("weapon/energyball.png")


EnergyBall = Core.class(Sprite)
function EnergyBall.create(x, y, speed, distance, level, world)

	local energyball = EnergyBall.new()
	
	energyball.image = Bitmap.new(energyball_texture)
	energyball.image:setAnchorPoint(0.5, 0.5)
	energyball.image:setRotation(math.deg(math.atan2(y, x)))
	energyball.image:setBlendMode(Sprite.ADD)
	energyball:addChild(energyball.image)
	
	-- 타겟방향으로 날라간다
	energyball.moving = { x = x, y = y, speed = speed, distance = distance }
	energyball.world = world
	energyball.damage = 6 + level * 2
	
	energyball:addEventListener(Event.ENTER_FRAME, energyball.Update, energyball)
	energyball.flying_distance = 0
	
	return energyball

end

function EnergyBall:Update(event)

	local x, y = self:getPosition()
	
	local distance = self.moving.speed *event.deltaTime
	
	-- 화살이 날라간다
	local x2 = self.moving.x * distance + x
	local y2 = self.moving.y * distance + y
	
	
	self:setPosition(x2, y2)
	
	-- 적과 충돌했는지 확인
	local world = self.world
	local enemy = world:GetEnemyOnPosition(x2, y2)
	
	if enemy then 
	
		world:Hit(enemy, self.damage)
		-- 사라진다
		self:removeEventListener(Event.ENTER_FRAME, self.Update, self)
		self:getParent():removeChild(self)
		
	else 
		self.flying_distance = self.flying_distance + distance
		if self.flying_distance > self.moving.distance then 
			-- 사거리가 넘어가면 사라진다
			self:removeEventListener(Event.ENTER_FRAME, self.Update, self)
			self:getParent():removeChild(self)
		end 
	end 
	
end 

