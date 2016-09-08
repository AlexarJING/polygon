local function copy(tab)
	return {unpack(Tab)}
end

local Node = {}
function Node:new(vec,alpha,intersection)
	local new = {
		vec = vec,
		next = nil,
		prev = nil,
		nextPoly =nil,
		neighbor = nil,
		intersecti = intersection,
		entry = nil,
		visited = false,
		alpha = alpha or 0
	}
	setmetatable(new, self)
	self.__index = self
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
	if a then
		repeat 
			a = a.next
		until not(a~=self and (not a.intersect or a.intersect and a.visited))

	end
end

function Node:insertBetween(first,last)
	local a = first
	while a~=last and a.alpha<self.alpha do
		a = a.next
	end
	self.next = a
	self.prev = a.prev

	if self.prev  then
		self.next.prev = self
	end
end

local function createLinkedList(vecs)
	local ret,where
	for i = 1, #vecs do
		local current = vecs[i]
		if not ret then
			where = Node:new(current)
			ret = where
		else
			where.next = Node:new(current)
			where.next.prev = where
			where = where.next
		end

	end
	return ret
end

local function distance(v1,v2)
	return math.sqrt((v1[1]-v2[1])^2,(v1[2]-v2[2]))
end

local function clean(array)

	for i = #array-1 , 1 , -1 do
		local c = array[i]
		local p = array[i+1]
		if c[1] == p[1] and c[2] == p[2] then
			table.remove(array,i)
		end
	end

end