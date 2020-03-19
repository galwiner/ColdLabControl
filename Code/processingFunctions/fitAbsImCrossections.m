function fp = fitAbsImCrossections(xcross,ycross,fp0,varargin)
%xcross (ycross) is a vector with a cross section of the abso image in the x (y)
%direction
%fp0 = [OD,A,bg,x0,xstd,y0,ystd]
%varargin{1} = xvec;varargin{2} = yvec;

if ~isempty(varargin)
    xvec = varargin{1};
    yvec = varargin{2};
else
    xvec = 1:length(xcross);
    yvec = 1:length(ycross);
end

if ~isrow(xcross)
    xcross=xcross';
end

if ~isrow(ycross)
    ycross=ycross';
end

if nargin==2||isempty(fp0)
    fpx = getExpGaussianGuess(xcross);
    fpy = getExpGaussianGuess(ycross);
    fp0 = [5,mean([fpx(1),fpy(1)]),mean([fpx(2),fpy(2)]),xvec(round(fpx(3))),fpx(4)*(xvec(2)-xvec(1)),yvec(round(fpy(3))),fpy(4)*(xvec(2)-xvec(1))];
%     disp(fp0);
    
end
fp = fminsearch(@(p) sum((fit_func(xvec,p,1) - xcross).^2+(fit_func(yvec,p,0) - ycross).^2), fp0, optimset('Display', 'off', 'MaxIter', 1e6,'TolFun',1e-16,'MaxFunEvals',1e5,'TolX',1e-8));

function res = fit_func(x,p,state)
%state selects between x and y cross
switch state
    case 1 %x
        res = p(3)+p(2)*exp(-p(1)*exp(-(x-p(4)).^2/(2*p(5)^2)));
    case 0 %y
       res = p(3)+p(2)*exp(-p(1)*exp(-(x-p(6)).^2/(2*p(7)^2)));
end 
end
end
