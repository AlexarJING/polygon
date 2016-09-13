local function lineTest(p1, p2, p3, p4)
	local	x1 = p1[1];
	local	y1 = p1[2];
	local	x2 = p2[1];
	local	y2 = p2[2];
	local	x3 = p3[1];
	local	y3 = p3[2];
	local	x4 = p4[1];
	local	y4 = p4[2];
	local a1, a2, b1, b2, c1, c2
	local r1, r2, r3, r4
	local denom, offset;         
	local x, y             

	a1 = y2 - y1;
	b1 = x1 - x2;
	c1 = x2 * y1 - x1 * y2;


	r3 = a1 * x3 + b1 * y3 + c1;
	r4 = a1 * x4 + b1 * y4 + c1;

	if ( r3 ~= 0 and r4 ~= 0 and ((r3 >= 0 and r4 >= 0) or (r3 < 0 and r4 < 0))) then
		return
	end

	a2 = y4 - y3;
	b2 = x3 - x4;
	c2 = x4 * y3 - x3 * y4;

	r1 = a2 * x1 + b2 * y1 + c2;
	r2 = a2 * x2 + b2 * y2 + c2;

	if (r1 ~= 0 and r2 ~= 0 and ((r1 >= 0 and r2 >= 0) or (r1 < 0 and r2 < 0))) then
		return
	end

	denom = a1 * b2 - a2 * b1;

	if ( denom == 0 ) then
		return true;
	end

	offset = denom < 0 and - denom / 2 or denom / 2;

	x = b1 * c2 - b2 * c1;
	y = a2 * c1 - a1 * c2;
  	return {x / denom, y / denom}
end

local function pointTest(node,polygon)
	local x, y = node[1],node[2]
	local pX={}
	local pY={}
	for i,v in ipairs(polygon) do
		table.insert(pX, v[1])
		table.insert(pY, v[2])
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

local function area(polygon) 
	local e0 = {0,0};
	local e1 = {0, 0};


	local area = 0;
	local first = polygon[1];

	for i = 3 , #polygon do
		local p = polygon[i-1]
		local c = polygon[i]
		e0[1] = first[1] - c[1];
	    e0[2] = first[2] - c[2];
	    e1[1] = first[1] - p[1];
	    e1[2] = first[2] - p[2];
	    area = area + (e0[1] * e1[2]) - (e0[1] * e1[2])
	end
	
	return area/2
end

function sign(x)
	if x>0 then return 1
	elseif x<0 then return -1
	else return 0 end
end

function table.push(tab,tab2)
	for i,v in ipairs(tab2) do
		table.insert(tab,v)
	end
end

function table.unshift(tab,tab2)
	--table.reverse(tab2)
	for i,v in ipairs(tab2) do
		table.insert(tab,i,v)
	end

end

function table.reverse(tab)
	local len = #tab
	local rt = {}
	for i,v in ipairs(tab) do
		rt[len-i+1] = v
	end
end

local function copy(tab)
	return {unpack(tab)}
end

local Node = {}
function Node:new(vec,alpha,intersection)
	local new = {
		vec = vec,
		next = nil,
		prev = nil,
		nextPoly =nil,
		neighbor = nil,
		intersect = intersection,
		entry = nil,
		visited = false,
		alpha = alpha or 0
	}
	setmetatable(new, self)
	self.__index = self
	return new
end

function Node:nextNonIntersection()
	local a = self
	while a and a.intersect do
		a = a.next
	end
	return a
end

function Node:last()
	local a = self
	while a.next and a.next~=self do
		a = a.next
	end
	return a
end

function Node:createLoop()
	local last = self:last()
	last.prev.next = self
	self.prev = last.prev
end

function Node:firstNodeOfInterest()
	local a = self
	

	while a do
		a = a.next
		if not a then break end
		if a == self then break end
		if a.intersect and not a.visited then break end
	end
	
	return a
end

function Node:insertBetween(first,last)
	local a = first
	while a~=last and a.alpha<self.alpha do
		a = a.next
	end

	self.next = a
	self.prev = a.prev
	
	if self.prev  then
		self.prev.next = self
	end

	self.next.prev = self;
end

local function createLinkedList(vecs)
	local ret,where

	for i,v in ipairs(vecs) do
		if where then
			where.next = Node:new(v)
			where.next.prev = where
			where = where.next
		else
			where = Node:new(v)
			ret = where
		end
	end

	return ret
end

local function distance(v1,v2)
	return math.sqrt((v1[1]-v2[1])^2,(v1[2]-v2[2])^2)
end

local function clean(array)

	for i = #array-1 , 1 , -1 do
		local c = array[i]
		local p = array[i+1]
		if c[1] == p[1] and c[2] == p[2] then
			table.remove(array,i)
		end
	end
	return array
end

local function indentifyIntersections(subjectList, clipList)
	local subject,clip
	local auxs = subjectList:last()
	auxs.next = Node:new(clipList.vec,auxs)
	auxs.next.prev = auxs

	local auxc = clipList:last()
	auxc.next = Node:new(clipList.vec,auxc)
	auxc.next.prev = auxc
	

	local found = false 
	subject = subjectList
	
	while subject.next do
		if not subject.intersect then
			clip = clipList
			while clip.next do
				if not clip.intersect then

					local a = subject.vec
					local b = subject.next:nextNonIntersection().vec
					local c = clip.vec
					local d = clip.next:nextNonIntersection().vec
					
					local i = lineTest(a,b,c,d)
					
					if i and i~=true then
						found = true
						local intersectionSubject = Node:new(i,distance(a,i)/distance(a,b),true)
						local intersectionClip = Node:new(i,distance(c,i)/distance(c,d),true)
						intersectionSubject.neighbor = intersectionClip
						intersectionClip.neighbor = intersectionSubject
						
						intersectionSubject:insertBetween(subject,subject.next:nextNonIntersection())
						intersectionClip:insertBetween(clip,clip.next:nextNonIntersection())
					end
				end
				clip = clip.next
			end

		end
		subject = subject.next
	end
	return found
end

local function indentifyIntersectionType(subjectList, clipList, clipPoly, subjectPoly, type)
	local subject,clip
	local se = pointTest(subjectList.vec,clipPoly)
	if type == "and" then
		se = not se
	end
	subject = subjectList
	while subject do
		if subject.intersect then
			subject.entry = se
			se = not se
		end
		subject = subject.next
	end

	local ce = not pointTest(clipList.vec,subjectPoly)
	if (type == "or") then ce = not ce end


	while clip do
		if clip.intersect then
			clip.entry = ce
			ce = not ce
		end
		clip = clip.next
	end
end

local function collectClipResults(subjectList, clipList)
	subjectList:createLoop()
	clipList:createLoop()

	print("list subject")
	local test = subjectList.next
	while test and test ~= subjectList do
		print(test.vec[1],test.vec[2])
		test = test.next
	end

	print("list clip")
	local test = clipList.next
	while test and test ~= clipList do
		print(test.vec[1],test.vec[2])
		test = test.next
	end

	local crt , results = {} , {}

	while true do
		crt = subjectList:firstNodeOfInterest()
		if crt== subjectList then break end
		result = {}
		while true do
			crt.visited = not crt.visited
			if crt ~= crt.neighbor then break end
			table.insert(crt.vec)
			local forward = crt.entry
			while true do
				crt.visited = true
				crt = forward and crt.next or crt.prev
				if crt.intersect then
					crt.visited = true
					break
				else
					--print(crt.vec[1],crt.vec[2])
					table.insert(result,crt.vec)
				end

			end
		end

		table.insert(results,clean(result))
	end

	return results
end

local function toPoly(verts)
	local rt = {}
	for i = 1, #verts-1 , 2 do
		table.insert(rt,{verts[i],verts[i+1]})
	end
	return rt
end

local function toVerts(poly)
	local rt = {}
	for i,v in ipairs(poly) do
		table.insert(rt,v[1])
		table.insert(rt,v[2])
	end
	return rt
end


local function polygonBoolean(subjectVerts, clipVerts, operation)
	local subjectPoly = toPoly(subjectVerts)
	local clipPoly = toPoly(clipVerts)
	local subjectList = createLinkedList(subjectPoly)
	local clipList = createLinkedList(clipPoly)
    local subject, clip, res
    local isects = indentifyIntersections(subjectList, clipList);

	if isects then
	    indentifyIntersectionType(
	      subjectList,
	      clipList,
	      clipPoly,
	      subjectPoly,
	      operation)
		
		res = collectClipResults(subjectList, clipList)	
	else 
		local inner = pointTest(subjectPoly[1],clipPoly)
    	local outer = pointTest(clipPoly[1],subjectPoly)
		res = {}

		if operation == "or" then
			if not inner and not outer then
				table.push(res,copy(subjectPoly))
				table.push(res,copy(clipPoly))
			elseif inner then
				table.push(res,copy(clipPoly))
			elseif outer then
				table.push(res,copy(subjectPoly))
			end
		elseif operation == "and" then
			if inner then
				table.push(res,copy(subjectPoly))
			elseif outer then
				table.push(res,copy(clipPoly))
			else
				error("oops")
			end
		elseif operation == "not" then	
			local sclone = copy(subjectPoly)
			local cclone = copy(clipPoly)

			local sarea = area(sclone)
			local carea = area(cclone)

			if sign(sarea) == sign(carea) then
				if outer then
					table.reverse(cclone)
				elseif inner then
					table.reverse(sclone)
				end
			end

			table.push(res,sclone)

			if math.abs(sarea)> math.abs(carea) then
				table.push(res,cclone)
			else
				table.unshift(res,cclone)
			end
		end
		
	end
	print("results")
	for i,v in ipairs(res) do
		print(v[1],v[2])
	end
	return toVerts(res)
end

return polygonBoolean