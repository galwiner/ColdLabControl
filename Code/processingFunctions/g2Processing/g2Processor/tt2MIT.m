function MITmatPath=tt2MIT(ttBinFile)
if nargin==0
    ttBinFile=getCurrentBinFile();
end
p=struct();
[path,filename]=fileparts(ttBinFile);
MITmatName=getMITmatFileName(filename); %where to save the converted file
ttMatFile=getTtMatFileName(filename);

folder=getCurrentSaveFolder();
MITmatPath=fullfile(folder,MITmatName);
ttMatFile=fullfile(folder,ttMatFile);
if ~exists(fullfile(folder,)
    datMat=binFileToMat(ttBinFile);
else
    load(datMat


% load(ttBinFile)
% load(pFile)

load(ttBinFile)
bunches_to_analyze=[];
chN_cycles_each_run={0,0,0,0};
chN_gates_each_run={0,0,0,0};
chN_phot_gc={0,0,0,0};
chN_phot_runs={0,0,0,0};
chN_phot_time={0,0,0,0};
chN_photons_rach_run={0,0,0,0};
cycleT=0;
d=[];
if isfield(p,'G2')
    G2=p.G2;
else
    G2=makeDefaultG2Params();
end

g2_yrange=[0,2];
G3=struct();
gate_f=Inf;
gate_i=0;
gates_f=Inf;
gates_i=0;
gates_per_cycle=977;
goodruns=779;
is_G23=1;
is_g2_only=0;
is_g2_random_access=1;
is_g3_random_access=1;
is_noise=0;
is_output_two_dim=0;
is_plot_pulses=0;
is_PostSelection_by_outgoing_rate=1;
is_super_gate_correlations=0;
max_bunch_size=200;
meas_channels=[1,2,3];
plot_for_delay=0;
prefix='pr_1.266_2phPerus_blue_18MHz_1.25MHzfromPeak_2phRes'
prefix_gated='pr_1.266_2phPerus_blue_18MHz_1.25MHzfromPeak_2phRes_gates0toInf'
runs=10;
super_fate_length=1;
Tgate=40;

save(MITmatPath,'*')
end
