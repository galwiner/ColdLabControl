%script to load all required control system params
%assumes ControlSystem code base is in path
load('channelTable.mat')

%%import physical constants in MKS %%
%%_________________________________%%

consts.kb=1.3806e-23; %kboltzman
consts.c=299792458; %c 
consts.amu=1.66054e-27; %AMU in Kg
consts.mrb=86.909180527 * consts.amu; %Rb87 mass
consts.e=1.60217662e-19; %electron charge
consts.rb87D1=2*pi*377.107463380e14; %D1 transition Rb87
consts.rb87D2=2*pi*384.2304844685e14; %D2 transition Rb87



