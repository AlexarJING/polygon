function math.sign(x)
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
	tab = rt
end

function table.copy(tab)
	return {unpack(tab)}
end

function math.distance(x1,y1,x2,y2)
	return math.sqrt((x1-x2)^2+(y1-y2)^2)
end