Bow = {}
function Bow.create()
	local weapon = {}
	weapon.delay = 0.5
	weapon.cooltime = 0
	weapon.distance = 500
	weapon.flying_speed = 600
	
	weapon.CanFire = Bow.CanFire
	weapon.Fire = Bow.Fire
	weapon.Update = Bow.Update
	weapon.GetRange = Bow.GetRange
	
	return weapon
end 


-- 무기 공통함수
function Bow:CanFire()
	-- 쿨타임만 계산한다
	if self.cooltime  > 0 then 
		return false
	end 
	
	return true
end

function Bow:GetRange()
	return self.distance
end 

function Bow:Fire(invoker, target, world)
	
	-- 화살을 발사한다
	local x, y = target:getPosition()
	local x2, y2 = invoker:getPosition()
	
	local dx = x - x2
	local dy = y - y2
	
	local length = math.sqrt(dx*dx + dy*dy)
	--if length > self.distance then return end
	
	if length < 0.1 then 
		-- 너무 붙어있다. 화살을 적당히 발사하자
		dx = 1
		dy = 0
	else 
		dx = dx / length
		dy = dy / length
	end 
	
	-- 스피드를 곱해서 적당히 발사하자
	local arrow = Arrow.create(dx, dy, self.flying_speed, self.distance, invoker, world)
	arrow:setPosition(x2, y2)
	world.effect_layer:addChild(arrow)
	
	-- 만약에 레벨이 3 이면 두발 4면 3발을 발사하게 하자
	if invoker.level >= 3 then 
		-- 한발더 
		-- 30도 돌리자
		local theta = math.rad(30)
		local xx = math.cos(theta) * dx - math.sin(theta) * dy
		local yy = math.sin(theta) * dx + math.cos(theta) * dy
		
		local arrow2 = Arrow.create(xx, yy , self.flying_speed, self.distance, invoker, world)
		arrow2:setPosition(x2, y2)
		world.effect_layer:addChild(arrow2)
	end 
	
	if invoker.level >= 4 then 
		-- 다시 한발더
		local theta = math.rad(-30)
		local xx = math.cos(theta) * dx - math.sin(theta) * dy
		local yy = math.sin(theta) * dx + math.cos(theta) * dy
		
		local arrow2 = Arrow.create(xx , yy , self.flying_speed, self.distance, invoker, world)
		arrow2:setPosition(x2, y2)
		world.effect_layer:addChild(arrow2)
	end 
	
	
	self.cooltime = self.delay
	if invoker.level >= 2 then 
		-- 레벨이 올라가면 딜레이를 줄이자
		self.cooltime = self.delay * 0.4
	end 
end 

function Bow:Update(deltaTime)
	self.cooltime  = self.cooltime - deltaTime
end 

local arrow_texture = Texture.new("weapon/arrow.png")


Arrow = Core.class(Sprite)
function Arrow.create(x, y, speed, distance, invoker, world)

	local arrow = Arrow.new()
	
	arrow.image = Bitmap.new(arrow_texture)
	arrow.image:setAnchorPoint(0.5, 0.5)
	arrow.image:setRotation(math.deg(math.atan2(y, x)))
	arrow.image:setBlendMode(Sprite.ADD)
	arrow:addChild(arrow.image)
	-- 타겟방향으로 날라간다
	arrow.moving = { x = x, y = y, speed = speed, distance = distance }
	arrow.world = world
	arrow.damage = 6 + invoker.level * 2
	
	arrow:addEventListener(Event.ENTER_FRAME, arrow.Update, arrow)
	arrow.flying_distance = 0
	
	return arrow

end

function Arrow:Update(event)
	if IsPaused() then return end
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
	
		-- 대미지 계산
		
		world:Hit(enemy, self.damage)
		enemy:Knockback(self.moving.x * 200, self.moving.y * 200)
		
		-- 히트했으면 사라진다
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