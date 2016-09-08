local polygon = require "polygon"
io.stdout:setvbuf("no")

local class = {}

function class:test()
	return 1
end

function class:new()
	local new = {
	text = "123"
}
	setmetatable(new, self)
	self.__index = self
	return new
end


local a = class:new()
print(a:test())
print(a.text)










love.math.setRandomSeed(os.time())

local p1 = polygon.random(400,300,30,3)
local p2 = polygon.random(500,400,30,2)
local p3 = polygon.clip(p1,p2,"diff")
local p4 = polygon.booleanWork(p1,p2,p3)


function love.draw()
	love.graphics.setPointSize(3)
	love.graphics.setColor(255, 255, 0, 255)

	love.graphics.polygon("line", p1)

	love.graphics.setColor(255, 0, 255, 255)
	love.graphics.polygon("line", p2)

	love.graphics.setColor(0, 0, 255, 255)
	if p3[1] then love.graphics.polygon("line", p3) end

	love.graphics.setColor(255, 0, 0, 255)
	
		for i = 1, #p4-1,2 do
			love.graphics.print(tostring((i+1)/2), p4[i],p4[i+1])
		end
		love.graphics.points(p4)
	

end