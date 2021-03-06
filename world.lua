World = Core.class(Sprite)

function IsPaused()
	return gamemenu.value > 0 and gamemenu.autobattle == false
end 

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
	w.pad = Pad.create()
	w.hud = PlayerHUD.create()
	
	w:addChild(w.pad)
	w:addChild(w.hud)
	return w

end 

function World:Destroy()

	r:removeEventListener(Event.ENTER_FRAME, w.Update, w)
	w:removeEventListener(Event.TOUCHES_BEGIN, w.TouchBegin, w)
	w:removeEventListener(Event.TOUCHES_MOVE, w.TouchMove, w)
	w:removeEventListener(Event.TOUCHES_END, w.TouchEnd, w)
	
end 

function World:EnterPlayer(player)
	-- 플레이어가 월드에 들어온다
	self.player = player
	
	player.world = self
	player.movie:stop()
	player:Warp(16,16)
	self:AddLight(player.light)
	self.character_layer:addChild(player)
	self.hud:SetPlayer(player)
	self.effect_layer:addChild(player.lockon)
	
	--player:addChild(player.direction.image)
	
	
	for i = 1, #player.skills do
		self.pad:AssignSkill(i, player.skills[i])
	end 
	
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

function World:GetClosestEnemyFrom2(x, y, rad)
	
	local found 
	local length = 9999999

	-- 주어진 좌표에서 가장 가까운 적을 찾는다, 주어진 rad 와 큰차이가 없어야 한다.
	for i = 1, #self.enemies do 
		local enemy = self.enemies[i]
		local ex, ey = enemy:getPosition()
		
		local dx = ex - x
		local dy = ey - y 
		
		local d_rad = math.atan2(dy, dx) - rad
		while d_rad  < -math.pi do
			d_rad = d_rad + math.pi*2
		end 
		
		while d_rad  > math.pi do
			d_rad = d_rad - math.pi*2
		end 
		
		
		if math.abs(d_rad ) < math.pi / 6 then 
			print(math.atan2(dy, dx) .."-"..rad.."="..d_rad)
			local l_sqr = dx*dx + dy*dy
			if l_sqr < length then 
				found = enemy 
				length = l_sqr
			end 
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
	local range_sqr = (range + 24)*(range + 24)
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

function World:GetAllEnemyInCapsuleRange(capsuleRange)
	local result = {}
	
	for i = 1, #self.enemies do 
		local enemy = self.enemies[i]
		local ex, ey = enemy:getPosition()
		
		local sphereRange = {}
		sphereRange.centerPoint = Vector2.new(ex, ey)
		sphereRange.radius = 12
		
		if HitTestCapsuleAndSphere(capsuleRange, sphereRange) then
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
		-- 코인을 떨어트린다
		if math.random(100) < 20 then 
			local coin = Coin.create(self)
			coin:setPosition(enemy:getPosition())
			
			self.character_layer:addChild(coin)
		end 
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
		
		self:Hit(enemy, damage)
		--[[
		enemy.hp = enemy.hp - damage
		enemy:ShowHP()
		enemy.damage_text:AddText(damage)
	
		if enemy.hp <= 0 then 
			self:RemoveMonster(enemy)
			enemy:Die()
		end 
		]]
	end 
	
end

function World:HitCapsuleRange(capsuleRange, damage)
	--[[
	-- for test
	local pointText = TextField.new(normalfont, "A")
	pointText:setPosition(capsuleRange.pointA.x, capsuleRange.pointA.y)
	pointText:setTextColor(0xff0000)
	self:addChild(pointText)
	local pointText2 = TextField.new(normalfont, "B")
	pointText2:setPosition(capsuleRange.pointB.x, capsuleRange.pointB.y)
	pointText2:setTextColor(0x0000ff)
	self:addChild(pointText2)
	]]
	local result = self:GetAllEnemyInCapsuleRange(capsuleRange)
	for i = 1, #result do 
		local enemy = result[i]
		
		self:Hit(enemy, damage)
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

function World:EnterFriend(friend)
	-- 친구가 월드에 들어온다
	self.character_layer:addChild(friend)
	
	friend:addEventListener(Event.ENTER_FRAME, friend.Update, friend)
end 

function World:Update(event)
	if IsPaused() then return end
	self:CheckStageClear()
end 

function World:TouchBegin(event)
	
	if self.pad:OnTouchBegin(event, self.player, self) then 
		-- 터치..
	else 
		self.stickid = event.touch.id
		self.pad:ShowStick(event.touch.x  , event.touch.y)
		
		-- 디렉션설정
		do 
			local lx, ly = self.layers:getPosition()
			local px, py = self.player:getPosition()
			
			local dx = event.touch.x - px - lx
			local dy = event.touch.y - py - ly 
			self.player.direction.x = dx
			self.player.direction.y = dy
		end
	end
end

function World:TouchMove(event)
	
	if event.touch.id == self.stickid then 
		local dx, dy = self.pad:SetStick(event.touch.x, event.touch.y)
		self.player:Move2(dx, dy)
	end 
	
	-- 디렉션설정
	do 
		local lx, ly = self.layers:getPosition()
		local px, py = self.player:getPosition()
		local dx = event.touch.x - px - lx
		local dy = event.touch.y - py - ly
		self.player.direction.x = dx
		self.player.direction.y = dy
	end 
end


function World:TouchEnd(event)
	if self.stickid == event.touch.id then 
		self.player:Stop()
		self.pad:Hide()
	end 
	self.pad:OnTouchEnd(event)
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
			if self.show_missionclear then 
				-- 미션 클리어를 이미 보여주었다
			else 
				self.show_missionclear = true
				local bmp = Bitmap.new(Texture.new("dungeon/mission_clear.png"))
				self:addChild(bmp)
				
				-- 집으로 돌아가기 버튼을 넣는다
				local bt = Button.create("처음으로", self.GotoLobby, self, 250, 50)
				bt:setPosition(500, 400)
				self:addChild(bt)
			end 
		end 
	end 
	
	if self.player.dead then 
		if self.show_missionfail then 
			-- 이미 보여주었다
		else 
			self.show_missionfail = true
			local bmp = Bitmap.new(Texture.new("dungeon/mission_fail.png"))
			self:addChild(bmp)
			
			-- 집으로 돌아가기 버튼을 넣는다
			local bt = Button.create("처음으로", self.GotoLobby, self, 250, 50)
			bt:setPosition(500, 400)
			self:addChild(bt)
		end 
	end 
	
	
end 