Staff = Core.class(Sprite)

function Staff.create()
	local weapon = {}
	weapon.delay = 1.0
	weapon.cooltime = 0
	weapon.distance = 500
	weapon.flying_speed = 300
	
	weapon.CanFire = Bow.CanFire
	weapon.Fire = Staff.Fire
	weapon.Update = Bow.Update
	weapon.GetRange = Bow.GetRange
	
	return weapon
end


-- 무기 공통함수
function Staff:Fire(invoker, target, world)
	
	-- 아이스볼트를 발사한다
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
	local arrow = IceBolt.create(dx, dy, self.flying_speed, self.distance, invoker, world)
	arrow:setPosition(x2, y2)
	world.effect_layer:addChild(arrow)
	
	self.cooltime = self.delay
	--[[
	if invoker.level >= 2 then 
		-- 레벨이 올라가면 딜레이를 줄이자
		self.cooltime = self.delay * 0.4
	end 
	]]
end 

local icebolt_texture = Texture.new("weapon/icebolt.png")


IceBolt = Core.class(Sprite)
function IceBolt.create(x, y, speed, distance, invoker, world)

	local icebolt = IceBolt.new()
	
	icebolt.image = Bitmap.new(icebolt_texture)
	icebolt.image:setAnchorPoint(0.5, 0.5)
	icebolt.image:setRotation(math.deg(math.atan2(y, x)))
	icebolt.image:setBlendMode(Sprite.ADD)
	icebolt:addChild(icebolt.image)
	
	-- 타겟방향으로 날라간다
	icebolt.moving = { x = x, y = y, speed = speed, distance = distance }
	icebolt.world = world
	icebolt.damage = 6 + invoker.level * 2
	
	icebolt:addEventListener(Event.ENTER_FRAME, icebolt.Update, icebolt)
	icebolt.flying_distance = 0
	
	-- 영향 범위
	icebolt.hitRadius = invoker.level * 1.5 -- 일단은 이렇게...
	icebolt.explosionSize = invoker.level * 1.5
	
	return icebolt

end

function IceBolt:Update(event)

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
	
		local enemies = world:GetAllEnemyInRange(x2, y2, self.hitRadius)
	
		-- 각 enemy마다 대미지 계산
		for i = 1, #enemies, 1 do
			world:Hit(enemies[i], self.damage)
		end
		
		-- 폭! 발! 효과 만들고
		self:makeHitExplosion()
		
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

local icebolt_hit_explosion_textures = {
	Texture.new("weapon/icebolt_hit_explosion/icebolt_hit_0.png"),
	Texture.new("weapon/icebolt_hit_explosion/icebolt_hit_1.png"),
	Texture.new("weapon/icebolt_hit_explosion/icebolt_hit_2.png"),
}

ExplosionSprite = Core.class(Sprite)
function ExplosionSprite:init(scale)
	
	self.frames = {}
	for i = 1, #icebolt_hit_explosion_textures, 1 do
		local frame = Bitmap.new(icebolt_hit_explosion_textures[i])
		frame:setAnchorPoint(0.5, 0.5)
		frame:setScale(scale, scale)
		frame:setBlendMode(Sprite.ADD)
		self.frames[i] = frame
	end
	
	self.currentFrame = 1
	self.endFrame = #self.frames
	
	self.curentSubFrame = 0
	self.endSubFrame = 5
	
	self:addEventListener(Event.ENTER_FRAME, self.update, self)
	self:addChild(self.frames[self.currentFrame])
	
end

function ExplosionSprite:update()
	self.curentSubFrame = self.curentSubFrame + 1
	if self.curentSubFrame == self.endSubFrame then
		self:removeChild(self.frames[self.currentFrame])
		self.currentFrame = self.currentFrame + 1
		self.curentSubFrame = 0
		
		if self.currentFrame > self.endFrame then
			self:selfDestroy()
		else
			self:addChild(self.frames[self.currentFrame])
		end
	end
end

function ExplosionSprite:selfDestroy()
	self:removeEventListener(Event.ENTER_FRAME, self.update, self)
	self:removeFromParent()
	--self:removeChild(self.frames[self.currentFrame])
	--self.frames = nil
end


function IceBolt:makeHitExplosion()
	local x, y = self:getPosition()
	local explosionSprite = ExplosionSprite.new(self.explosionSize)
	explosionSprite:setPosition(x, y)
	self:getParent():addChild(explosionSprite)
end
