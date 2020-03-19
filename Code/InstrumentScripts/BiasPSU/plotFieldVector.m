function plotFieldVector(field)
%takes field in form: [Bx,By,Bz] and plots the arrow direction. or matrix
%with dim (nRowX3) and then plots full evolution
%example: x=1:10; plotFieldVector([cos(pi/2*x/10).*[1,0,0]'+sin(pi/2*x/10).*[0,1,0]'+x/10.*[0,0,1]']')
if nargin==0
    field=(rand(10,3)-0.5);
end

figure;

nRows=size(field,1);
quiver3(zeros(nRows,1),zeros(nRows,1),zeros(nRows,1),field(:,1),field(:,2),field(:,3));
xlim([-2,2])
ylim([-2,2])
zlim([-2,2])
line([0,1],[0,0],[0,0],'Color','k','LineWidth',4)
text([0,1],[0,0],[0,0],'x','FontSize',14)
line([0,0],[0,1],[0,0],'Color','k','LineWidth',4)
text([0,0],[0,1],[0,0],'y','FontSize',14)
line([0,0],[0,0],[0,1],'Color','k','LineWidth',4)
text([0,0],[0,0],[0,1],'z','FontSize',14)