function y=batmanSignal()
    x=linspace(-6.9,6.9,1000);
    y=zeros(1,length(x));
    y(abs(x)>3)=3*sqrt(-(x(abs(x)>3)/7).^2+1);
    y(abs(x)>4)=3*sqrt(-(x(abs(x)>4)/7).^2+1);
    y(0.75<abs(x)<1)=9-8*abs(x(0.75<abs(x)<1));
    
    y(0.5<abs(x)<0.75)=3*abs(x(0.5<abs(x)<0.75))+0.75;
    y(abs(x)<0.5)=2.25;
    y(3>abs(x)>1)=1.5-0.5*abs(x(3>abs(x)>1))-6*sqrt(10)/14 * (sqrt(3-x(3>abs(x)>1).^2+2*abs(x(3>abs(x)>1)))-2);
    figure;
    plot(x,y)
end
