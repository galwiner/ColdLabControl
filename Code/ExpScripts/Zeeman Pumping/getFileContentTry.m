initp
p.runAutoPlot=0;
p.expName='tryGetContent';
sq=sqncr();
sq.addBlock({'pause','duration',100});
sq.run()

if p.runAutoPlot==0
    return
end
%AUTO_PLOTTING_STAGE (DO NOT CHANGE THIS LINE)
   
figure;
plot(1:10);
