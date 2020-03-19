% init exp
% clear all
% global p
% global r
% global inst

function init(DEBUG)

clear -gloabl inst
clear -global p
clear -global r

global p
global r
global inst

if nargin==0
    DEBUG=0;
end

initp
p.hasScopResults=0;
p.hasPicturesResults=0;
p.pfLiveMode=1;
p.tcLiveMode=1;
p.postprocessing=0;
p.DEBUG=DEBUG;
initinst
initr

end
