return function(polygon) 
	local e0 = {x = 0,y = 0};
	local e1 = {x = 0,y = 0};


	local area = 0;
	local first = polygon[1];

	for i = 3 , #polygon do
		local p = polygon[i-1]
		local c = polygon[i]
		e0.x = first.x - c.x;
	    e0.y = first.y - c.y;
	    e1.x = first.x - p.x;
	    e1.y = first.y - p.y;
	    area = area + (e0.x * e1.y) - (e0.x * e1.y)
	end
	
	return area/2
end