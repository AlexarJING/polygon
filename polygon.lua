local Delaunay = require "delaunay"
local getDist = function(x1,y1,x2,y2) return math.sqrt((x1-x2)^2+(y1-y2)^2) end

local getRot  = function (x1,y1,x2,y2,toggle) 
	if x1==x2 and y1==y2 then return 0 end 
	local angle=math.atan((x1-x2)/(y1-y2))
	if y1-y2<0 then angle=angle-math.pi end
	if toggle==true then angle=angle+math.pi end
	if angle>0 then angle=angle-2*math.pi end
	if angle==0 then return 0 end
	return -angle
end

local axisRot = function(x,y,rot) return math.cos(rot)*x-math.sin(rot)*y,math.cos(rot)*y+math.sin(rot)*x  end
local polygonTrans= function(x,y,rot,size,v)
	local tab={}
	for i=1,#v/2 do
		tab[2*i-1],tab[2*i]=axisRot(v[2*i-1],v[2*i],rot)
		tab[2*i-1]=tab[2*i-1]*size+x
		tab[2*i]=tab[2*i]*size+y
	end
	return tab
end
local clamp= function (a,low,high)
	if low>high then 
		return math.max(high,math.min(a,low))
	else
		return math.max(low,math.min(a,high))
	end
end

local function newHexagon(x,y,l)
	local i=(l/2)*3^0.5
	return {x,y,x+l,y,x+1.5*l,y+i,x+l,y+2*i,x,y+2*i,x-l*0.5,y+i}
end

local function pointTest(x,y,verts)
	local pX={}
	local pY={}
	for i=1,#verts,2 do
		table.insert(pX, verts[i])
		table.insert(pY, verts[i+1])
	end
	local oddNodes=false
	local pCount=#pX
	local j=pCount
	for i=1,pCount do
		if ((pY[i]<y and pY[j]>=y) or (pY[j]<y and pY[i]>=y))
			and (pX[i]<=x or pX[j]<=x) then
			if pX[i]+(y-pY[i])/(pY[j]-pY[i])*(pX[j]-pX[i])<x then
				oddNodes=not oddNodes
			end
		end
		j=i
	end
	return oddNodes
end

local function convexHull(verts)
	local v={}
	local rt={}
	local lastK=0
	local lastX=0
	local lastY=0
	local lastRad=0

	for i=1,#verts-1,2 do
		local index = (i+1)/2
		v[index]={}
		v[index].x=verts[i]
		v[index].y=verts[i+1]
	end
	local maxY=-1/0
	local oK=0
	for k,v in ipairs(v) do
		if v.y>maxY then
			maxY=v.y
			oK=k
		end	
	end
	lastK=oK
	lastX=v[lastK].x
	lastY=v[lastK].y
	table.insert(rt,v[lastK].x)
	table.insert(rt,v[lastK].y)
	local i=0
	while true do
		i=i+1
		local minRad=2*math.pi
		local minK=0
		for k,v in pairs(v) do
			local rad= getRot(v.x,v.y,lastX,lastY)
			if rad and rad>lastRad then
				if rad<minRad then
					minRad=rad
					minK=k
				end
			end
		end
		if minK==maxK or minK==0 then return rt end --outside
		lastK=minK
		lastRad=minRad
		lastX=v[lastK].x
		lastY=v[lastK].y
		table.insert(rt,v[lastK].x)
		table.insert(rt,v[lastK].y)
	end
end

local function randomPolygon(x,y,count,size)
	local v = {}
	for i=1,count*2 do
		table.insert(v,love.math.random(-50,50)*size)
	end
	return polygonTrans(x,y,0,1,convexHull(v))
end

local inv3=1/3

--return center,area verts[1],verts[2] = x ,y
local function getArea(verts) 
	local count=#verts/2
	local cx,cy=0,0
	local area = 0

	local refx,refy=0,0
	for i=1,#verts-1,2 do
		local p1x,p1y=refx,refy
		local p2x,p2y=verts[i],verts[i+1]
		local p3x = i+2>#verts and verts[1] or verts[i+2]
		local p3y = i+2>#verts and verts[2] or verts[i+3]

		local e1x= p2x-p1x
		local e1y= p2y-p1y
		local e2x= p3x-p1x
		local e2y= p3y-p1y

		local d=math.vec2.cross(e1x,e1y,e2x,e2y)
		local triAngleArea=0.5*d
		area=area+triAngleArea
		cx = cx + triAngleArea*(p1x+p2x+p3x)/3
		cy = cy + triAngleArea*(p1y+p2y+p3y)/3
	end

	if area~=0 then
		cx= cx/area
		cy= cy/area
		return cx,cy,math.abs(area)
	end
end


local function concaveHull(threshold,source)
	local Point    = Delaunay.Point
	local points = {}

	for i = 1, #source-1,2 do
		table.insert(points, Point(source[i],source[i+1]))
	end

	local triangles = Delaunay.triangulate(points)

	for i=#triangles,1,-1 do
		if triangles[i]:getCircumRadius()>threshold then
			table.remove(triangles, i)
		end
	end


	local edges={}
	for i,t in ipairs(triangles) do
		table.insert(edges,t.e1)
		table.insert(edges,t.e2)
		table.insert(edges,t.e3)
	end


	for i,t in ipairs(triangles) do
		
		for j,e in ipairs(edges) do
			if t.e1:same(e) and e~=t.e1 then
				table.remove(edges, j)	
				break
			end
		end
		
		for j,e in ipairs(edges) do
			if t.e2:same(e) and e~=t.e2 then
				table.remove(edges, j)
				break
			end
		end

		for j,e in ipairs(edges) do
			if t.e3:same(e) and e~=t.e3 then
				table.remove(edges, j)	
				break
			end
		end
	end

	local target={}
	table.remove(edges, 1)
	while #edges~=0 do
		local verts={edges[1].p1.x,edges[1].p1.y,edges[1].p2.x,edges[1].p2.y}
			table.insert(target, verts)
		repeat
			local test
			for i,e in ipairs(edges) do
				if e.p1.x==verts[#verts-1] and e.p1.y==verts[#verts] then
					table.insert(verts, e.p2.x)
					table.insert(verts, e.p2.y)
					table.remove(edges, i)
					test=true
					break
				end

				if e.p2.x==verts[#verts-1] and e.p2.y==verts[#verts] then
					table.insert(verts, e.p1.x)
					table.insert(verts, e.p1.y)
					table.remove(edges, i)
					test=true
					break
				end
			end
			
		until not test or #edges==0
		
		if not(verts[#verts-1]==verts[1] and verts[#verts]==verts[2]) then
			local x,y=verts[1],verts[2]
			verts[1],verts[2]=verts[3],verts[4]
			verts[3],verts[4]=x,y
		end
	end
	
	local rt = {}
	for i,v in ipairs(target) do
		local test,triangles = pcall(love.math.triangulate,v)
		if test then
			for i,v in ipairs(triangles) do
				table.insert(rt,v)
			end
		end
	end

	return rt
end





return {
	hexagon = newHexagon, -- x,y,r
	convexHull = convexHull, --verts
	random = randomPolygon, --count,size
	area = getArea, --verts
	concaveHull = concaveHull, --verts
	translate = polygonTrans, -- x,y,rot,size,verts
	pointTest = pointTest,
}