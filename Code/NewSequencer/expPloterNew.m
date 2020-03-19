function expPloterNew(r,p,plotParams)
%This function gets an experiment (r and p) and plots it according to the
%parameters listed in plotParams. LD 08/08/18
%r is the results variable, p is the general parameter variable, and
%plotParams are the parameters relevant to plot
%list of plotParams:
%nRows - total number of rows
%nColumns - total number of columns
%xVars - list of x vars. structure is: {{subPlot_xParams,subPlot}}, example
%{{'coolingDet',1},{'circCoilCurrent',2}}. The vars must be in p.
%yVarsRight - list of y vars to be plotted on the right. structure is same
%as xVars, exept the vars must be in r
%yVarsLeft - list of y vars to be plotted on the left. structure is same
%as yVarsRight
figure;
xVars = plotParams.xVars;
yVarsLeft = plotParams.yVarsLeft;
nRows = plotParams.nRows;
nCol = plotParams.nColumns;
for ii=1:length(xVars)
    if ~isfield(p,xVars{ii}{1})
        error('%s is not a field of p!',xVars{ii}{1})
    end
    subplot(nRows,nCol,xVars{ii}{2})
    if yVarsLeft{ii}{2}~=xVars{ii}{2}
       error('error in loop #%d:subPlot valeus of xVars and yVarsLeft must be equal!',ii)
    end
    xVals = p.(xVars{ii}{1});
    yValsLeft = r.(yVarsLeft{ii}{1});
    plot(xVals,yValsLeft)
end
end


