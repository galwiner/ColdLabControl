function pts=geodesic(p1,p2,nPts)
p1c=toCartesian(p1);
p2c=toCartesian(p2);
t=linspace(0,1,nPts);
pts=p1c'+t.*(p2c'-p1c');
scatter3(pts(1,:),pts(2,:),pts(3,:))
end
