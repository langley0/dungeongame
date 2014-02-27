smallfont = TTFont.new("text/mtcg.ttf", 16, true)
verysmallfont = TTFont.new("text/mtcg.ttf", 8, true)


normalfont = TTFont.new("text/mtcg.ttf", 32, true)
normalfont_outline = TTFont.new("text/mtcg.ttf", 34, true)

function CreateText(text)
	if text then 
		return TextField.new(normalfont, text)
	else 
		return TextField.new(normalfont, "")
	end
end

function CreateSmallText(text)
	if text then 
		return TextField.new(smallfont, text)
	else 
		return TextField.new(smallfont, "")
	end
end

function CreateVerySmallText(text)
	if text then 
		return TextField.new(verysmallfont, text)
	else 
		return TextField.new(verysmallfont, "")
	end
end

function CreateTextOutLine(text)
	local base = Sprite.new()
--	local outline = TextField.new(normalfont_outline, text)
--	outline:setTextColor(0x000000)
	local ttt = TextField.new(normalfont, text)
	ttt:setTextColor(0xffffff)
	--ttt:setPosition(1,-1)
	
	--base:addChild(outline)
	base:addChild(ttt)
	
	return base
end

function CreateTextWithSize(text, size)
	if not size then
		return CreateText(text)
	end
	
	if text then 
		return TextField.new(TTFont.new("text/mtcg.ttf", size, true), text)
	else 
		return TextField.new(TTFont.new("text/mtcg.ttf", size, true),"")
	end
end