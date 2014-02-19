Magic_FrozenOrb = Core.class(Sprite)

function Magic_FrozenOrb.create()
	local orb =  Magic_FrozenOrb.new()

	orb.name = "프로즌오브"
	orb.delay = 1.0 -- 여긴 대충 쓴값
	orb.cooltime = 0
	orb.distance = 500
	orb.flying_speed = 300
	orb.type = "action"
	return orb
end


-- 무기 공통함수
function Magic_FrozenOrb:CanUse(invoker, world)
	-- 쿨타임만 계산한다
	if self.cooltime  > 0 then 
		return false
	end 
	
	return true
end

function Magic_FrozenOrb:GetRange()
	return self.distance
end 

function Magic_FrozenOrb:Update(deltaTime)
	self.cooltime  = self.cooltime - deltaTime
end 

function Magic_FrozenOrb:Use(invoker, world)
	print("여기서 프로즌 오브 발사")

end 
