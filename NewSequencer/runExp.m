function runExp(expName)
global p
if exist(sprintf('.\\experiments\\%s.m',expName),'file')==2
    run(sprintf('.\\experiments\\%s',expName))
else
    error('No %s.m exists in experiments folder!',expName);
end
try
    innerVar=p.loopVars{1};
catch
    innerVar='empty';
end
try
    outerVar=p.loopVars{2};
catch
    outerVar='empty';
end
p.ExpName=expName;
if ~exist('p.ExpDescription','var')
    error('An experiment must have a description!\n');
end
fprintf('runing %s.m. Innerloop var is: %s. Outerloop var is: %s.\n',expName,innerVar,outerVar) 
p.s.run(p.picsPerStep);
end