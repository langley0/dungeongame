
math.easeInQuad = function (currentTime, startValue, changeInValue, duration)
	currentTime = currentTime / duration;
	return changeInValue*currentTime*currentTime + startValue;
end

math.easeInOutQuad = function (currentTime, startValue, changeInValue, duration)
	currentTime = currentTime / (duration/2);
	if currentTime < 1 then
		return changeInValue/2*currentTime*currentTime + startValue
	end
	currentTime = currentTime - 1;
	return -changeInValue/2 * (currentTime*(currentTime-2) - 1) + startValue;
end