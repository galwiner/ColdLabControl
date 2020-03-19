%Gal. W 080917 
%script to load all required control system params and generate p params
%object
%assumes ControlSystem code base is in path
%p is the parameter structure
load('channelTable.mat');
load('p.mat');

sequencesDir=dir(fileparts(which('LoadMotSeq')));
sequencesDir=sequencesDir(~ismember({sequencesDir.name},{'.','..'}));

% p=updatep(p);

% ControlSystemDir=whi
%%import physical constants in MKS %%
%%_________________________________%%

consts.kb=1.3806e-23; %kboltzman
consts.c=299792458; %c 
consts.amu=1.66054e-27; %AMU in Kg
consts.mrb=86.909180527 * consts.amu; %Rb87 mass
consts.e=1.60217662e-19; %electron charge
consts.rb87D1=2*pi*377.107463380e14; %D1 transition Rb87
consts.rb87D2=2*pi*384.2304844685e14; %D2 transition Rb87
consts.hbar=1.0545718e-34;%m^2*kg/s
consts.Gamma=6.066; %natural line width in MHz
%pixelfly params structure
% p.cam_params(1);
BiasPsu1=BiasPSU('TCPIP::10.10.10.106::inst0::INSTR'); %Y bias coils on Chan 1, Z Bias coil on Chan 2
BiasPsu2=BiasPSU('TCPIP::10.10.10.107::inst0::INSTR'); %X Bias coil on Chan 2


