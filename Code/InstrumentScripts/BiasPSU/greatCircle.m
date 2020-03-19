function greatCircle(v1,v2)
    v1u=v1./norm(v1);
    v2u=v2./norm(v2);
    v3u=cross(v1u,v2u);
    a=v3u(1);
    b=v3u(2);
    c=v3u(3);
    x=v1u(1):0.001:v2u(1);
    y=a*b*x+c*sqrt(-a^2*x.^2-b*x.^2-c*x.^2+c.^2)/(b^2+c^2);
    z=sqrt(1-x.^2-y.^2);
    figure;
    scatter3(v1(1),v1(2),v1(3))
    hold on
    scatter3(v2(1),v2(2),v2(3))
    
    scatter3(x,y,z)