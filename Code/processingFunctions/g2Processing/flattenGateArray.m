function flatArray=flattenGateArray(gateArray)
%assumes (and checks for) a single detector cell array as input

tmparry = gateArray;
ii = 1;
while 1
   if iscell(tmparry{1})
      tmparry = tmparry{1};
      ii = ii+1;
   else
       break
   end
end
if ii>1
    error('gateArray must contain a single channel!')
end
flatArray=[];
for ind=1:length(gateArray)
    for jnd=1:length(gateArray{ind})
        flatArray(end+1)=gateArray{ind}(jnd);
    end
end

end
