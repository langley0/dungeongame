local spacefriend_texture = Texture.new("player/spacefriend.png")

SpaceFriend = Core.class(Sprite)
function SpaceFriend.create()
	local spacefriend = SpaceFriend.new()
	local bitmaps = {
		Bitmap.new(TextureRegion.new(spacefriend_texture, 0,0,12,8)),
		Bitmap.new(TextureRegion.new(spacefriend_texture, 12,0,12,8)) }
		
	for i = 1, #bitmaps do 
		bitmaps[i]:setAnchorPoint(0.5, 0.5)
		bitmaps[i]:setScale(SPRITE_SCALE,SPRITE_SCALE)
	end
	local movie = MovieClip.new({
		{ 1, 4, bitmaps[1] },
		{ 5, 8, bitmaps[2] }
	})
	
	movie:setGotoAction(8,1)
	
	spacefriend:addChild(movie)
	spacefriend.movie = movie
	--spacefriend.movie:stop()
	spacefriend.stopped = true
	
	spacefriend.movie:play()
	
	-- move에서 사용할 정보들
	spacefriend.moving = {}
	
	return spacefriend
end

function SpaceFriend:Update(event)
	-- 여기선 움직임만 처리한다.
	-- 그 외의 공격 등은 일단 스킬 내에서 알아서 해결한다고 하자.
	if self.moveForce then
		self:MoveTo()
	else
		if self.willMove then
			-- 뜸 들이는 중이라면...
			self.remainTimeToMove = self.remainTimeToMove - event.deltaTime
			if self.remainTimeToMove <= 0 then
				-- 뜸 다 들였으면 이동해야할 곳을 정해준다.
				self:MoveTo()
			end
		else
			local px, py = self.player:getPosition()
			if self.lastPlayerPos.x ~= px or self.lastPlayerPos.y ~= py then
				-- 기억하고 있는 플레이어의 위치와 달라졌다면, 일단 뜸을 들인다.
				self.willMove = true
				if self.nearPlayer then
					self.remainTimeToMove = 0.1
				else
					self.remainTimeToMove = 0.3
				end
			end
		end
	end
	
	self:Move(event)
end

function SpaceFriend:MoveTo()
	self.willMove = false
	self.moveForce = false
	
	-- 이동 정보를 새로 세팅한다.
	local cx, cy = self.moving.x, self.moving.y
	local px, py = self.player:getPosition()
	self.lastPlayerPos.x, self.lastPlayerPos.y = px, py
	
	local dx, dy
	if self.nearPlayer then
		dx = px + self.relativePos.x * 0.5
		dy = py + self.relativePos.y * 0.5
	else
		dx = px + self.relativePos.x
		dy = py + self.relativePos.y
	end
	
	--
	if dx == cx and dy == cy then
		-- 움직일 필요가 없다?!
		if not self.stopped then
			self.stopped = true
			--self.movie:stop()
		end
		
		return
	end
	
	self.moving.startX = cx
	self.moving.startY = cy
	self.moving.destX = dx
	self.moving.destY = dy
	
	if self.stopped then
		-- 멈춰있었다면,
		self.stopped = false
		--self.movie:play()
		self.moving.xv0, self.moving.yv0 = 0, 0
	else
		-- 이동중이었다면,
		local getVelocity = function(t, d, a0, v0)
			return a0*t*(1 - t/d) + v0
		end
		
		self.moving.xv0 = getVelocity(self.moving.time, self.moving.duration, self.moving.xa0, self.moving.xv0)
		self.moving.yv0 = getVelocity(self.moving.time, self.moving.duration, self.moving.ya0, self.moving.yv0)
	end
	
	local getAccel = function(distance, duration, initialV)
		return 6 * (distance / duration - initialV) / duration
	end
	
	if self.nearPlayer then
		self.moving.duration = 0.3
	else
		self.moving.duration = 0.5
	end
	
	self.moving.xa0 = getAccel(dx - cx, self.moving.duration, self.moving.xv0)
	self.moving.ya0 = getAccel(dy - cy, self.moving.duration, self.moving.yv0)
	self.moving.time = 0
end

function SpaceFriend:Move(event)
	if self.stopped then return end
	self.moving.time = self.moving.time + event.deltaTime
	
	local getDistance = function(t, d, a0, v0)
		return a0*t*t/2 - (a0*t*t*t/3)/d + v0*t
	end
	
	if self.moving.time >= self.moving.duration and 
		math.abs(self.moving.x - self.moving.destX) < 2 and
		math.abs(self.moving.y - self.moving.destY) < 2 then
		-- 적당히 가까워졌으면 강제 집행.
		self.moving.x = self.moving.destX
		self.moving.y = self.moving.destY
		
		self.stopped = true
		--self.movie:stop()
	else
		-- x
		if self.moving.xv0 or self.moving.xa0 then
			self.moving.x = getDistance(self.moving.time, self.moving.duration, self.moving.xa0, self.moving.xv0) + self.moving.startX
		end
		
		-- y
		if self.moving.yv0 or self.moving.ya0 then
			self.moving.y = getDistance(self.moving.time, self.moving.duration, self.moving.ya0, self.moving.yv0) + self.moving.startY
		end
	end
	
	self:setPosition(self.moving.x, self.moving.y)
end

function SpaceFriend:AddLinkToPlayer(player, dx, dy)
	self.player = player
	self.relativePos = { x = dx, y = dy }
	local px, py = player:getPosition()
	self.lastPlayerPos = { x = px, y = py }
	-- 시작 위치
	self.moving.x, self.moving.y = px, py
	self:setPosition(px, py)
end

function SpaceFriend:SetNearnessToPlayer(near)
	if not self.nearPlayer or self.nearPlayer ~= near then
		self.moveForce = true
	end
	self.nearPlayer = near
end