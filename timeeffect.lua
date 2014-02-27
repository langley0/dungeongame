lvup_texture = Texture.new("effect/levelup_effect.png")
player_hit_texture = Texture.new("effect/player_hit_effect.png")
newstage_texture = Texture.new("effect/new_stage.png")

TimeEffect = Core.class(Sprite)

function TimeEffect.create(texture, duration, blend)

	local image = Bitmap.new(texture)
	image:setAnchorPoint(0.5, 0.5)
	if blend then 
		image:setBlendMode(blend)
	end
	
	local effect = TimeEffect.new()
	effect.time = 0
	effect.duration = duration
	effect.image = image
	
	effect:addChild(image)
	effect:addEventListener(Event.ENTER_FRAME, effect.Update, effect)
	
	
	return effect
		
end 

function TimeEffect:Finish()
	self:removeEventListener(Event.ENTER_FRAME, self.Update, self)
	self:getParent():removeChild(self)
		
	self.finished = true
end 

function TimeEffect:Update(event)
	if IsPaused() then return end
	if self.finished then return end 

	-- 레벨업 이펙트를 실행
	self.time = self.time + event.deltaTime
	
	self.image:setAlpha(self.duration - self.time)
	
	if self.time > self.duration then 
		self:Finish()
	end 
	
end 