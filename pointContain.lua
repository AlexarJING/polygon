return function(x,y,polygon)
	local pX={}
	local pY={}
	
	for i = 1 , #polygon-1 ,2 do
		table.insert(pX, polygon[i])
		table.insert(pY, polygon[i+1])
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