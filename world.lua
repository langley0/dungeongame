World = Core.class(Sprite)

function World.create()

	local w = World.new()
	
	
	w.light_layer = Sprite.new()
	w.tile_layer = Sprite.new()
	w.corpse_layer = Sprite.new()
	w.character_layer = Sprite.new()
	w.effect_layer = Sprite.new()
	
	-- 배경을 만든다
	w.map = Map.create()
	w.tile_layer:addChild(w.map)
	
	
	width = w.map.width
	height = w.map.height

	w:addEventListener(Event.ENTER_FRAME, w.Update, w)
	w:addEventListener(Event.TOUCHES_BEGIN, w.TouchBegin, w)
	w:addEventListener(Event.TOUCHES_MOVE, w.TouchMove, w)
	w:addEventListener(Event.TOUCHES_END, w.TouchEnd, w)
	
	w.pad = Pad.create()
	
	w.enemies = {}
	w.current_level = 0
	
	w.lights = {}
	w.layers = Sprite.new()
	
	w.layers:addChild(w.light_layer)
	w.layers:addChild(w.tile_layer)
	w.layers:addChild(w.corpse_layer)
	w.layers:addChild(w.character_layer)
	w.layers:addChild(w.effect_layer)
	w:addChild(w.layers)
	
	-- ui
	w:addChild(w.pad)
	return w

end 

function World:EnterPlayer(player)
	-- 플레이어가 월드에 들어온다
	self.player = player
	
	player.world = self
	player.movie:stop()
	player:Warp(16,16)
	self:AddLight(player.light)
	self.character_layer:addChild(player)
	
	player:addEventListener(Event.ENTER_FRAME, player.Update, player)
end 

function World:LeavePlayer()
	local player = self.player
	
	player:removeEventListenerEvent(Event.ENTER_FRAME, player.Update, player)
	
end 

id_provider = 1
function World:SpawnMonster(enemy)
	
	-- 월드에서 몬스터의 위치를 구해온다
	local x, y = enemy:getPosition()
	local tx, ty = self.map:GetTileIndexOnPosition(x,y)
	
	if self.map:IsMovableCell(tx, ty) then 
		self.enemies[#self.enemies + 1] = enemy
		self.character_layer:addChild(enemy)
		
		enemy.movementtile = { x = tx, y = ty }
		self.map.movement_grid[tx][ty] = enemy
		enemy.id = id_provider
		id_provider = id_provider + 1
	else 
		enemy.world = nil
		enemy:removeEventListener(Event.ENTER_FRAME, enemy.Update, enemy)
	end 
end 


function World:GetPlayer()

	return self.player
end 


function World:GetClosestEnemyFrom(x, y)
	
	local found 
	local length = 9999999

	-- 주어진 좌표에서 가장 가까운 적을 찾는다
	for i = 1, #self.enemies do 
		local enemy = self.enemies[i]
		local ex, ey = enemy:getPosition()
		
		local dx = x - ex
		local dy = y - ey
		
		local l_sqr = dx*dx + dy*dy
		if l_sqr < length then 
			found = enemy 
			length = l_sqr
		end 
	end 
	
	return found
end 

function World:GetEnemyOnPosition(x, y)

	local length = 24*24

	for i = 1, #self.enemies do 
		local enemy = self.enemies[i]
		local ex, ey = enemy:getPosition()
		
		local dx = x - ex
		local dy = y - ey
		
		if dx*dx + dy*dy < length then 
			return enemy 
		end 
	end 
	
	return nil
end 

function World:GetAllEnemyInRange(x, y, range)
	
	-- 적들의 반경을 더한다
	local range_sqr = (range * 24)*(range * 24)
	local result = {}
	
	
	for i = 1, #self.enemies do 
		local enemy = self.enemies[i]
		local ex, ey = enemy:getPosition()
		
		local dx = x - ex
		local dy = y - ey
		
		if dx*dx + dy*dy < range_sqr then 
			result[#result + 1] = enemy 
		end 
	end 
	
	return result
end 

function World:GetWallOnPosition(x, y)

	return nil
end 

function World:Hit(enemy, damage)
	
	enemy.hp = enemy.hp - damage
	enemy:ShowHP()
	enemy.damage_text:AddText(damage)

	if enemy.hp <= 0 then 
		self:RemoveMonster(enemy)
		enemy:HideHP()
		enemy:Die()
		-- 플레이어에게는 경험치를 준다
		self.player:AddExp(enemy.exp)
	end 
end 


function World:HitPlayer(damage)
	
	local player = self.player
	player:OnHit(damage)
end 


function World:HitRange(x, y, radius, damage)
	
	-- 주변의 모든 적에게 대미지를 입힌다
	local result = self:GetAllEnemyInRange(x, y, radius)
	
	for i = 1, #result do 
		local enemy = result[i]
		
		enemy.hp = enemy.hp - damage
	
		if enemy.hp <= 0 then 
			self:RemoveMonster(enemy)
			enemy:Die()
		end 
	end 
	
end 

function World:RemoveMonster(monster)
	
	local new = { }
	local j = 1
	for i = 1, #self.enemies do 
		local enemy = self.enemies[i]
		if enemy ~= monster then 
			new[j] = enemy 
			j = j + 1
		end 
	end 
	
	self.enemies = new
	
end

function World:Update(event)
	self:CheckStageClear()
end 

function World:TouchBegin(event)
	
	-- 화면의 오른쪽 3/1 에서 터치가 되었나?
	-- 터치 시작
	--self.control = { x = event.touch.x, y = event.touch.y }
	if event.touch.x < 750 then 
		self.stickid = event.touch.id
		self.pad:ShowStick(event.touch.x  , event.touch.y)
	elseif event.touch.x > 850 then
		-- 무기를 발사한다
		self.pad:StartFire(event.touch.id)
	end
	
end

function World:TouchMove(event)
	
	if event.touch.id == self.stickid then 
		local dx, dy = self.pad:SetStick(event.touch.x, event.touch.y)
		self.player:Move2(dx, dy)
	end 
end


function World:TouchEnd(event)
	if self.stickid == event.touch.id then 
		self.player:Stop()
		self.pad:Hide()
	end 
	self.pad:StopFire(event.touch.id)
end


function World:AddLight(light)
	self.lights[#self.lights + 1] = light
	self.light_layer:addChild(light)
end 

function World:RemoveLight(light)
	local new = {}
	
	local j = 1
	for i = 1, #self.lights do 
		local l = self.lights[i]
		if l ~= light then 
			new[j] = l
			j = j + 1
		else 
			-- 찾았다.
			light:getParent():removeChild(light)
		end 
	end 
	self.lights = new
end 

function World:LocateCenter(x, y)
	
	-- 화면의 중앙값을 계산한다
	-- 랜드스케이프라 height/width 를 스웝해야한다. (WHY??)
	local cx = application:getLogicalHeight() / 2
	local cy = application:getLogicalWidth() / 2
	
	-- (cx, cy) -> (x, y) 트랜스폼을 구한다
	local dx = cx - x
	local dy = cy - y
	
	-- 월드를 움직인다
	self.layers:setPosition(dx, dy)
end

function _TIMER_Spawn(arg)

	-- 해당 레벨의 몬스터를 스폰한다
	SpawnMonster(arg.world, arg.level)
	arg.world.activated = true
end

function World:ResetStageTo(level)

	-- 스테이지 시작
	local effect = TimeEffect.create(newstage_texture, 3, Sprite.ADD)
	effect:setPosition(640,100)
	stage:addChild(effect)
	
	
	local backup = {}
	-- 모든 적을 없앤다
	for i = 1, #self.enemies do
		backup[i] = self.enemies [i]
	end 
	
	for i = 1, #backup do
		self:RemoveMonster(backup[i])
	end 
	
	-- 모든 시체도 없앤다
	local corpse_num = self.corpse_layer:getNumChildren()
	for i = 1, corpse_num do
		self.corpse_layer:removeChildAt(1)
	end 
	--
	
	self.current_level = level
	local arg = { world = self, level = level}
	Timer.delayedCall(3000, _TIMER_Spawn, arg)
end 




function World:CheckStageClear()
	if self.activated and #self.enemies == 0 then 
		self.activated = false
		local next_level = self.current_level + 1
		if next_level <= #spawndata then 
			self:ResetStageTo(next_level)
		else 
			-- 미션 완료
			local bmp = Bitmap.new(Texture.new("dungeon/mission_clear.png"))
			stage:addChild(bmp)
		end 
	end 
end 