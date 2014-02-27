Boss_FireBallShot = Core.class()


function Boss_FireBallShot.create()
	local skill = Boss_FireBallShot.new()
	skill.name = ""
	skill.delay = 0.15
	skill.cooltime = 0
	skill.distance = 700
	skill.flying_speed = 300
	
	skill.stamina= 5
	skill.type = "charge"
	
	return skill
end 

function Boss_FireBallShot:Use(invoker, world)
	
	-- 플레이어를 향해 발사
	local x2, y2 = invoker:getPosition()
	local target = world:GetPlayer()
	local x, y = target:getPosition()
	
	local dx = x - x2
	local dy = y - y2
	
	local length = math.sqrt(dx*dx + dy*dy)
	if length < 0.1 then 
		-- 너무 붙어있다. 화살을 적당히 발사하자
		dx = 1
		dy = 0
	else 
		dx = dx / length
		dy = dy / length
	end 
	
	-- 스피드를 곱해서 적당히 발사하자
	local arrow = Boss_FireBall.create(dx, dy, self.flying_speed, self.distance, invoker, world)
	arrow:setPosition(x2, y2)
	world.effect_layer:addChild(arrow)
	
	do
		-- 한발더 
		-- 30도 돌리자
		local theta = math.rad(15)
		local xx = math.cos(theta) * dx - math.sin(theta) * dy
		local yy = math.sin(theta) * dx + math.cos(theta) * dy
		
		local arrow2 = Boss_FireBall.create(xx, yy , self.flying_speed, self.distance, invoker, world)
		arrow2:setPosition(x2, y2)
		world.effect_layer:addChild(arrow2)
	end 
	
	do
		-- 다시 한발더
		local theta = math.rad(-15)
		local xx = math.cos(theta) * dx - math.sin(theta) * dy
		local yy = math.sin(theta) * dx + math.cos(theta) * dy
		
		local arrow2 = Boss_FireBall.create(xx , yy , self.flying_speed, self.distance, invoker, world)
		arrow2:setPosition(x2, y2)
		world.effect_layer:addChild(arrow2)
	end 
	
	do
		-- 한발더 
		-- 30도 돌리자
		local theta = math.rad(30)
		local xx = math.cos(theta) * dx - math.sin(theta) * dy
		local yy = math.sin(theta) * dx + math.cos(theta) * dy
		
		local arrow2 = Boss_FireBall.create(xx, yy , self.flying_speed, self.distance, invoker, world)
		arrow2:setPosition(x2, y2)
		world.effect_layer:addChild(arrow2)
	end 
	
	do
		-- 다시 한발더
		local theta = math.rad(-30)
		local xx = math.cos(theta) * dx - math.sin(theta) * dy
		local yy = math.sin(theta) * dx + math.cos(theta) * dy
		
		local arrow2 = Boss_FireBall.create(xx , yy , self.flying_speed, self.distance, invoker, world)
		arrow2:setPosition(x2, y2)
		world.effect_layer:addChild(arrow2)
	end 
	
	self.cooltime = self.delay
end 

local fireball_texture = Texture.new("boss_skill/fireball.png")


Boss_FireBall = Core.class(Sprite)
function Boss_FireBall.create(x, y, speed, distance, invoker, world)

	local arrow = Boss_FireBall.new()
	
	arrow.image = Bitmap.new(fireball_texture)
	arrow.image:setAnchorPoint(0.5, 0.5)
	arrow.image:setRotation(math.deg(math.atan2(y, x)))
	arrow.image:setBlendMode(Sprite.ADD)
	arrow:addChild(arrow.image)
	-- 타겟방향으로 날라간다
	arrow.moving = { x = x, y = y, speed = speed, distance = distance }
	arrow.world = world
	arrow.damage = 15
	
	arrow:addEventListener(Event.ENTER_FRAME, arrow.Update, arrow)
	arrow.flying_distance = 0
	
	return arrow

end

function Boss_FireBall:Update(event)
	if IsPaused() then return end
	local x, y = self:getPosition()
	
	local distance = self.moving.speed *event.deltaTime
	
	-- 화살이 날라간다
	local x2 = self.moving.x * distance + x
	local y2 = self.moving.y * distance + y
	
	
	self:setPosition(x2, y2)
	
	-- 플레이어와 충돌했는지 확인
	local world = self.world
	
	
	local player = world:GetPlayer()
	local px, py = player:getPosition()
	local dx = px - x2
	local dy = py - y2
	
	if dx*dx + dy*dy < 24*24 then 
		-- 충돌하였다
		world:HitPlayer(30)
		
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