io.stdout:setvbuf("no")
local polygon = require "polygon"
local polybool = require "polybool"

love.math.setRandomSeed(os.time())

local p1 = polygon.random(400,300,30,3)
local p2 = polygon.random(500,400,30,2)
--local p1 = {200,200,400,200,400,400,200,400}
--local p2 = {300,300,500,300,500,500,300,500}
local p3 = polybool(p1, p2, "not")


function love.draw()
	love.graphics.setPointSize(3)
	love.graphics.setColor(255, 255, 0, 255)

	love.graphics.polygon("line", p1)

	love.graphics.setColor(255, 0, 255, 255)
	love.graphics.polygon("line", p2)

	love.graphics.setColor(0, 0, 255, 50)
	for i,v in ipairs(p3) do
		for i,t in ipairs(love.math.triangulate(v)) do
			love.graphics.polygon("fill", t) 
		end
	end
			

end