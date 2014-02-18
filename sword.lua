Sword = Core.class(Sprite)

function Sword.create(owner)
	local sword = Sword.new()
	
	sword.delay = 0.2
	sword.cooltime = 0
	sword.distance = 100
	sword.flying_speed = 100
	
	return sword
end

function Sword:GetRange()
	return self.distance
end 

function Sword:CanFire()
	-- 쿨타임만 계산한다
	if self.cooltime  > 0 then 
		return false
	end 
	
	return true
end 

function Sword:Fire(invoker, target, world)
	
	local x, y = target:getPosition()
	local x2, y2 = invoker:getPosition()
	
	local dx = x - x2
	local dy = y - y2
	
	local length = math.sqrt(dx*dx + dy*dy)
	if length < 0.01 then 
		dx = 1
		dy = 0
	else 
		dx = dx / length
		dy = dy / length
	end 
	
	-- 스피드를 곱해서 적당히 발사하자
	local sword = SwordAttack.create(dx, dy, self.flying_speed, self.distance, invoker, world)
	sword:setPosition(x2, y2)
	world.effect_layer:addChild(sword)
	
	self.cooltime = self.delay
end 


function Sword:Update(deltaTime)
	self.cooltime  = self.cooltime - deltaTime
end 


sword_texture = Texture.new("weapon/sword.png")

SwordAttack = Core.class(Sprite)
function SwordAttack.create(x, y, speed, distance, invoker, world)

	local sword = SwordAttack.new()
	
	sword.image = Bitmap.new(sword_texture)
	sword.image:setAnchorPoint(0.5, 0.5)
	sword.image:setScale(2,2)
	sword.image:setRotation(math.deg(math.atan2(y, x)))
	sword.image:setBlendMode(Sprite.ADD)
	sword:addChild(sword.image)
	-- 타겟방향으로 날라간다
	sword.moving = { x = x, y = y, speed = speed, distance = distance }
	sword.world = world
	sword.invoker = invoker
	
	sword.damage = 6 + invoker.level * 2
	
	sword:addEventListener(Event.ENTER_FRAME, sword.Update, sword)
	sword.flying_distance = 0
	-- 16 은 무기 길이의 절반. 칼끝을 가르킨다
	sword.hit_test = { x = x * 16, y = y * 16, radius = 8 } 
	
	return sword

end

function SwordAttack:Update(event)

	local x, y = self:getPosition()
	
	local distance = self.moving.speed *event.deltaTime
	
	-- 화살이 날라간다
	local x2 = self.moving.x * distance + x
	local y2 = self.moving.y * distance + y
	self:setPosition(x2, y2)
	
	self.flying_distance = self.flying_distance + distance
	--print(self.flying_distance.."/"..self.moving.distance)
	
	if self.flying_distance > 20 then 
		
		local world = self.world
		
		-- 사거리가 넘어가면 사라진다
		self:removeEventListener(Event.ENTER_FRAME, self.Update, self)
		self:getParent():removeChild(self)
		
		-- 히트를 만든다
		local hit_x = x + self.hit_test.x 
		local hit_y = y + self.hit_test.y 
		
		local all_enemy = world:GetAllEnemyInRange(hit_x, hit_y, self.hit_test.radius)
		-- 적들을 살짝 밀친다
		for i = 1, #all_enemy do 
			self.world:Hit(all_enemy[i], self.damage)
			--all_enemy[i]:Knockback()
		end 
	end 
end 