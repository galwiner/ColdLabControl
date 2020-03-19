%block test
clear b
clear s
initp
b=Block();
b.name = 'MyBlock';
% b.addAction({'Load MOT','coolingPower',p.INNERLOOPVAR});
% b.addAction({'pause','duration',4});
b.addAction({'ToF','coolingPower',4});
% b.addAction({'setDDSfreq','duration',4});
% b.addAction({'TakePic'})
b.atomizeAll;
b.setTimeline(0);
disp(b)
fprintf('\n')
% b.setInnerParameter('this')
% s=sqncr(b)







