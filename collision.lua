
function Vector2.dot(v1, v2)
	return v1.x * v2.x + v1.y * v2.y
end

function HitTestCapsuleAndSphere(C, S)
	--[[
	C.pointA -- Vector2
	C.pointB
	C.height -- distance from pointA to pointB
	C.radius
	
	S.centerPoint
	S.radius
	]]
	local v = C.pointB - C.pointA
	local w = S.centerPoint - C.pointA
	
	local projection = Vector2.dot(w, v) / (C.height * C.height)
	
	local point
	
	if projection <= 0 then
		point = C.pointA
	elseif projection >= 1 then
		point = C.pointB
	else
		point = C.pointA + v * projection
	end
	
	local distance = Vector2.distance(S.centerPoint, point)
	return distance < C.radius + S.radius
end