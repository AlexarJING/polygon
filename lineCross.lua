return function (x1,y1,x2,y2,x3,y3,x4,y4)
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
  	return x / denom, y / denom
end

---nil 无交点/true 共线/交点坐标