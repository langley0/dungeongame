Button = Core.class(Sprite)

local button_default_texture = Texture.new("button/button_default.png")
local button_over_texture = Texture.new("button/button_over.png")

function Button.create(text, onClick, onClickArg, width, height)
	
	local button = Button.new()
	
	-- 텍스트에 맞추어서 버튼을 만든다
	
	local textfield = CreateText(text)
	textfield:setTextColor(0xffffff)
	local texture = button_default_texture
	
	local text_width = textfield:getWidth()
	local text_height = textfield:getHeight()
	
	-- 메쉬를 만든다
	local mesh = Mesh.new()
	mesh:setTexture(texture)
	mesh:setTextureCoordinateArray(0,0,texture:getWidth(),0,texture:getWidth(),texture:getHeight(),0,texture:getHeight())
	
	if width == nil then width = text_width  + 100 end
	if height == nil then height = text_height + 30 end
	
	mesh:setVertexArray(0,0,width,0,width,height, 0 ,height)
	mesh:setIndexArray(1,2,3,1,3,4)
	
	textfield:setPosition((width - text_width) /2 , height/2 + text_height/2)
	
	button:addChild(mesh)
	button:addChild(textfield)
	button.onClick = onClick
	button.onClickArg = onClickArg
	button.mesh = mesh
	button.touched = false
	button.text = textfield
	
	button:addEventListener(Event.TOUCHES_BEGIN, button.TouchBegin, button)
	button:addEventListener(Event.TOUCHES_END, button.TouchEnd, button)
	
	return button
end

function Button:TouchBegin(event)
	
	-- 자신이 터치되었는지 확인
	if self:hitTestPoint(event.touch.x, event.touch.y) then 
		-- 내가 터치되었다!
		-- 텍스쳐를 바꾼다
		self.mesh:setTexture(button_over_texture)
		self.text:setTextColor(0x000000)
		self.touched = true
	end
end


function Button:TouchEnd(event)
	if self.touched then
		-- 일단 텍스쳐는 바꾸고. 히트테스트를 한번 더한다
		self.mesh:setTexture(button_default_texture)
		self.text:setTextColor(0xffffff)
		
		if self:hitTestPoint(event.touch.x, event.touch.y) then 
			-- 클릭이벤트 발생
			if self.onClick then
				self.onClick(self.onClickArg)
			end
		end
		
	end
end