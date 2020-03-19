% function process_WIS_v1(filename)
% close all
clear G2;
global p
% filename='D:\Box Sync\Lab\ExpCold\Measurements\2019\07\02\tt\tt_MIT_020719_20__Zeeman Pump Probe Spectroscopy';
% load(filename);
% runs=500;
%  savedir='D:\Box Sync\Lab\Temp\g2_ofer_mit\20140715';
% savedir='test';
savedir=getCurrentSaveFolder;
prefix='MIT_';
% %  prefix='pr_1.266_2phPerus_blue_18MHz_1.25MHzfromPeak_2phRes';
% prefix='g2_MIT__bin0.02_tau1_Tipulse2_Tfpulse9_Nph835947_phPerCyc2792_bunch1-1of498'
% prefix='test';
%  runs=779;
% runs=100;
% G2.min_phot_cycl=0.9e4;G2.max_phot_cycl=2e4; %photons per cycle, for data filltering

% G2.min_phot_cycl=18000;G2.max_phot_cycl=21000; %photons per cycle, for data filltering
runs=max(chN_phot_cycles{1});
G2.min_phot_cycl=0.6*p.g2PhotPerCycle;G2.max_phot_cycl=1.2*p.g2PhotPerCycle; %photons per cycle, for data filltering

G2.neighbors_variation_phot_cycle=0.2;G2.neighbor_range_phot_cycle=5;
max_bunch_size=runs;
if isfield(p,'gateTime')
    Tgate=p.gateTime;
else
    Tgate=20;
end
% Tgate=2*p.gateTime;
% gates_i=[0]; gates_f=[500]; This doesent do anything (L.D 23/09/19)
g2_yrange=[0 4]; %this is the plotting range of the g2
is_noise=0;
% runs=779; 
% skip_runs=[1:50];

% prefix_gated=[prefix '_gates0toInf'];

G2.Ti_pulse=[p.g2Params.Ti_pulse];
G2.Tf_pulse=[p.g2Params.Tf_pulse]; 
% G2.Ti_pulse=[];
% G2.Tf_pulse=[]; 

G2.bin=0.02; %binwidth
G2.taui=-0.3; 
G2.tauf=0.3; 
G2.tau2i=G2.taui;   G2.tau2f=G2.tauf;

G2.bin=0.04; %binwidth
G2.taui=-0.8; 
G2.tauf=0.8; 
G2.tau2i=G2.taui;   G2.tau2f=G2.tauf;


%% handle multi pulses in the gate
%G2.Tf_pulse and G2.Ti_pulse define both the range to plot pulse and to
%calculate g2. All pulses are included in g2(tau). Bins outside this range is set to contain zero photons in the histogram. However, If tau is too long, correlations between different pulses
%within the gate will be calculated. Also, g2(t1,t2) will not collapse the
%latter pulses onto the first one.
%%
meas_channels=[1 2];
% G2.pairs=   {[1;2], [2;3], [1;3]};
G2.pairs=   {[1;2]};
% G3.triplets= [1;2;3]; 
G3.triplets= []; 

%% set g2 g3 parameters
is_plot_pulses=1;
is_G23=1;
is_g2_only=1;
G2.is_G23STD=1;
is_output_two_dim=0;
 plot_for_delay=0;
% G2.Ti=(0:1e3:9e3)*Tgate;     G2.Tf=(1e3:1e3:10e3)*Tgate; time from first
% gate in cycle
G2.Ti=p.g2Params.startGate*Tgate;     G2.Tf=(p.g2Params.endGate)*Tgate;
super_gate_length=1;is_super_gate_correlations=0;
is_g2_random_access=1;is_g3_random_access=0;
is_PostSelection_by_outgoing_rate=1;
bunches_to_analyze=[]; % Put [] for all bunches 

% load([savedir '\' prefix_gated,'.mat']);
% load(filename)
% chN_phot_time{1}=chN_phot_time{1}/10^6;
% chN_phot_time{2}=chN_phot_time{2}/10^6;

chN_phot_gc{1}(:,1)=chN_phot_gc{1}(:,2);
chN_phot_gc{2}(:,1)=chN_phot_gc{2}(:,2);
%% Bunching setup
%
if max_bunch_size<0, max_bunch_size=runs;end
num_of_bunches=ceil(runs/max_bunch_size);
bunch_map=reshape(repmat(1:num_of_bunches,max_bunch_size,1),num_of_bunches*max_bunch_size,1);
bunch_map=bunch_map(1:runs);
%bunch_map is a vector containing the bunch ID associated with each run
%e.g. [1 1 1 2 2 2 3 3 3] is a bunch map with 3 bunches each containing 3
%runs


%% Post-selection
%if size(ch1_photons,2)==4, chIcycle=4;chIt=2;chIgate=3; else chIcycle=3;chIt=1;chIgate=2; end;
%if size(ch1_photons,2)==4, chIcycle=4;chIcycle=3;chIt=1;chIgate=2; else chIcycle=3;chIt=1;chIgate=2; end;


%accumulate the photons per cycle across channels (average number in all detectors together)
% phot_per_cycle=0;
Iremoved=[];
% for Ic=meas_channels
%     %%% replace "chN_photons_each_cycle{Ic}" with the actual calcualtion of
%     %%% a vector of number of photons in each cycle
% %     phot_per_cycle=phot_per_cycle+chN_photons_each_cycle{Ic};
%     phot_per_cycle
% end



%then use the total number across detectors to post select (i.e. remove
%cycles with too high or too low photon flux
if is_PostSelection_by_outgoing_rate
    Iremoved=phot_per_cycle<G2.min_phot_cycl | phot_per_cycle>G2.max_phot_cycl; %a vector with removed cycle indices
    for ind_run=1:runs
        include_in_reference= ~Iremoved & (1:runs)>=ind_run-G2.neighbor_range_phot_cycle & (1:runs)<=ind_run+G2.neighbor_range_phot_cycle;
        reference_level=median(phot_per_cycle(include_in_reference)); %median intensity of light in the neighbourhood of this run
%         reference_level=
        Iremoved(ind_run)= Iremoved(ind_run) || abs(1-phot_per_cycle(ind_run)/reference_level)>G2.neighbors_variation_phot_cycle; %remove runs which are more than some percentage above or below the median light intensity
    end
    bunch_map(Iremoved)=0; %if a run is removed, it is associated with bunch # 0
    if 1
        figure('Name','Good Data Selection','NumberTitle','off');all_runs=1:length(phot_per_cycle);
        plot(all_runs,phot_per_cycle,'.b');hold all;plot(all_runs(Iremoved),phot_per_cycle(Iremoved),'.r');legend('included','removed');
        plot(all_runs,all_runs*0+G2.min_phot_cycl,':k',all_runs,all_runs*0+G2.max_phot_cycl,':k');hold off;drawnow;
    end    
end

phot_per_cycle(Iremoved)=0;average_phot_per_cycle=mean(phot_per_cycle);

%set bunch_map to 0 to remove corresponding runs from g2 calculation
% bunch_map(1:?)=0;
% hold on;plot(all_runs,smooth(all_runs,phot_per_cycle,100,'sgolay'),'k')

num_of_bunches=max(bunch_map);
bunch_size=hist(bunch_map,0:max(bunch_map));bunch_size(1)=[]; %after we've removed some of the runs, this step gives us an updated vector with the size of each bunch

%% plot phot per gate
 if p.g2Params.isplotSupGate
superGate = p.superGate; 
sectionsList = {1:superGate:(p.gateNum+superGate)};
sectionByList = string(p.plotByString);
sectionedRes = sectionTTResV2(chN_phot_cycles,chN_phot_gc,chN_phot_time,sectionsList,sectionByList,p.NAverage);
gateCoords = movmean(sectionsList{1},2);gateCoords(1) = [];
figure;
plot(sectionedRes.phot_per_cycle);
title(sprintf('phot per super gate = %d gates',superGate));
xlabel('gateNum');
ylabel('phot per supergate');
 end



%% Plot pulses.
 if is_plot_pulses
figure;
time_bin_for_pulse=0.01; %in uS
%the following line was commented out on 25/09/19 by LD. noise_range_Ti
%and noise_range_Tf are not used
% noise_range_Ti=[0]; noise_range_Tf=[Tgate/2];%%enter integer of time_bin_for_pulse only!
pulse_edge_time=(0:time_bin_for_pulse:Tgate/2); %edges of the pulse time vector, for histogram
runs_to_include=find(bunch_map>0);
pulse_photon_rate=zeros(4,length(pulse_edge_time)-1);
pulse_photon_rate_noiseless=pulse_photon_rate;   
       parfor Ic=meas_channels
% for Ic=meas_channels
        ch_photons=[];gates_to_include=0;
        for ind_run=runs_to_include'
            % a matrix whose columns are the arrival times (from gate start) for all included runs
            ch_photons=[ch_photons;chN_phot_time{Ic}(chN_phot_cycles{Ic}==ind_run,2)]; 
%             ch_photons=[ch_photons;chN_phot_time{Ic}({Ic}==ind_run,2)]; 
            % a matrix whose columns are the number of gates for all
            % included runs (for normalization)
            gates_to_include=gates_to_include+chN_gates_each_cycle{Ic}(ind_run);
        end        
        
        if ~isempty(ch_photons)
            [n1,Xt]=hist(ch_photons,pulse_edge_time);
            pulse_photon_rate(Ic,:)=n1(1:end-1)/gates_to_include; %normalized photon rate per channel
        end
       end
       
    pulse_times=(pulse_edge_time(1:end-1)+pulse_edge_time(2:end))/2; %pulse time centers
         
    I_TiTfpulse=false(size(pulse_times));
    
    %mechanism for removing pulses(=gates) by time - i.e. only take gates
    %between Ti and Tf
    
    %construct a vector containing all possible included times 
    for TiTf_ind=1:length(G2.Ti_pulse)
        I_TiTfpulse=I_TiTfpulse | (pulse_times>=G2.Ti_pulse(TiTf_ind) & pulse_times<=G2.Tf_pulse(TiTf_ind));   
    end
%    a_noise=[];
%    a_noise.pulse_times=(noise_range_Ti+time_bin_for_pulse/2):time_bin_for_pulse:(noise_range_Tf+time_bin_for_pulse/2);
if is_noise
a_noise=load(noise_level_file);
end



for Ic=meas_channels
    subplot(2,4,Ic);
    %          a_noise.pulse_photon_rate(Ic,(noise_range_Ti/time_bin_for_pulse+1):(noise_range_Tf/time_bin_for_pulse+1))=pulse_photon_rate(Ic,(noise_range_Ti/time_bin_for_pulse+1):(noise_range_Tf/time_bin_for_pulse+1));
    plot(pulse_times,pulse_photon_rate(Ic,:),'b',pulse_times(I_TiTfpulse),pulse_photon_rate(Ic,I_TiTfpulse),'r');hold on;
    %plot(a_noise.pulse_times,a_noise.pulse_photon_rate(Ic,(noise_range_Ti/time_bin_for_pulse+1):(noise_range_Tf/time_bin_for_pulse+1)),'g');hold all;
    if is_noise
        plot(a_noise.pulse_times,a_noise.pulse_photon_rate(Ic,:),'g');hold all;
    end
    xlabel('time [{\mu}s]');ylabel('photons per gate');
    title(['Ch.' num2str(Ic), ' Total:' num2str(sum(pulse_photon_rate(Ic,:))) ' per gate; bin=' num2str(time_bin_for_pulse) '{\mu}s']);
    subplot(2,4,[5 6]);hold all;
    plot(pulse_times,pulse_photon_rate(Ic,:)/mean(pulse_photon_rate(Ic,:)));
    title('pulse photon rate\{channel\}/mean photon rate')
    %         plot(pulse_times,pulse_photon_rate(Ic,:)/max(pulse_photon_rate(Ic,:)));
    xlabel('time [{\mu}s]');ylabel('normalized photons');
end
     Tf_pulse=G2.Tf_pulse; Ti_pulse=G2.Ti_pulse;
    subplot(2,4,[7 8]);plot(pulse_times,sum(pulse_photon_rate,1));    
    title('sum of photons per time bin (both detectors)')
    saveas(gcf,[savedir '\' 'pulse_' prefix  '_Tipulse' num2str(G2.Ti_pulse(1)) '_Tfpulse' num2str(G2.Tf_pulse(1)) '.fig']) ;
    save([savedir '\' 'pulse_' prefix '_Tipulse' num2str(G2.Ti_pulse(1)) '_Tfpulse' num2str(G2.Tf_pulse(1)) '_Total' num2str(sum(sum(pulse_photon_rate,1)),3) '.mat'],'pulse_times','pulse_photon_rate','Ti_pulse','Tf_pulse');    
if plot_for_delay
    figure;sum_photon_rate=sum(pulse_photon_rate,1);
    plot(pulse_times,sum(pulse_photon_rate,1),'b',pulse_times(I_TiTfpulse),sum_photon_rate(I_TiTfpulse),'r'); hold all;
   if is_noise
      plot(a_noise.pulse_times,a_noise.pulse_photon_rate(Ic,:),'g');
        noise_pulse_photon_rate=a_noise.pulse_photon_rate;
    noise_pulse_times=a_noise.pulse_times;
   end
      saveas(gcf,[savedir '\' 'delay_pulse_' prefix  '_Tipulse' num2str(G2.Ti_pulse(1)) '_Tfpulse' num2str(G2.Tf_pulse(1)) '.fig']) ;
   if is_noise
      save([savedir '\' 'delay_pulse_' prefix  '_Tipulse' num2str(G2.Ti_pulse(1)) '_Tfpulse' num2str(G2.Tf_pulse(1)) '_Total' num2str(sum(pulse_photon_rate(Ic,:))) '.mat'],'pulse_times','pulse_photon_rate','noise_pulse_times','noise_pulse_photon_rate');    
   else
       save([savedir '\' 'delay_pulse_' prefix  '_Tipulse' num2str(G2.Ti_pulse(1)) '_Tfpulse' num2str(G2.Tf_pulse(1)) '_Total' num2str(sum(pulse_photon_rate(Ic,:))) '.mat'],'pulse_times','pulse_photon_rate');    
   end
      xlabel('time [{\mu}s]');ylabel('photons per gate');
 title([' Total:' num2str(sum(sum_photon_rate)) ' per gate; bin=' num2str(time_bin_for_pulse) '{\mu}s']); 
end
 end

% if is_plot_pulses, figure; end
% single_counts_vs_gates=cell(1,4);
% for Ic=meas_channels
%     [d,Xg]=histc(chN_phot_gc{Ic}(:,2),gates);
%     single_counts_vs_gates{Ic}=d(1:end-1)/length(runs_to_include);
%     if is_plot_pulses
%         subplot(2,4,Ic);bar(gates(1:end-1),d(1:end-1)/length(runs_to_include),1);
%         subplot(2,4,[5 6 7 8]);plot(gates(1:end-1),d(1:end-1)/sum(d(1:end-1)));hold all;
%     end
% end


%% G2
%!!this is where the interesting bit starts
if is_G23==1   
    tstart_g2=tic;
    G2.tau=(G2.taui+G2.bin/2):G2.bin:(G2.tauf-G2.bin/2); %a vector containing the time difference values
    G2.tau_n=length(G2.tau)-1; %the number of bins in the tau vector
    G2.tau2=(G2.tau2i+G2.bin/2):G2.bin:(G2.tau2f-G2.bin/2); %seems to be identical to G2.tau. we'll see what it does later.
    G2.tau2_n=length(G2.tau2)-1;
    
    if mod(G2.taui,G2.bin)~=0, error('G2.taui/G2.bin must be an integer'); end
    
    %     if G2.tauf~=G2.tau(end)+G2.bin/2, warning('G2.tauf-G2.taui is not an integer multiple of G2.bin'); end
    
    G2.Npairs=length(G2.pairs); %which pairs of detectos should we calculate G2 with? 
    
    temp_mat=cell2mat(G2.pairs); %a matrix whose columns are the detector pairs we want
    act_channels=sort(unique(abs([temp_mat(:);G3.triplets(:)]))); %a sorted vector containing all channels in use for this analysis
    act_channels=act_channels(:)';
    
    arbitrary_Ic=act_channels(1); %select the first channel
    
    %perform the following fit: (gate number in cycle) = a*(time from
    %cycle start)+b. the a param gives the average gate period per microsecond
    gate_period=polyfit(chN_phot_time{arbitrary_Ic}(:,1),double(chN_phot_gc{arbitrary_Ic}(:,2)),1);
   
    G2_tau_cell=cell(G2.Npairs,length(G2.Ti));    %TODO: a cell array for earliest times per pair (not sure how this is used right now)
    
    super_gate_delay=G2.Tf_pulse(end); %this is the latest time excluded from pulse calculations
    
    if ~is_super_gate_correlations, super_gate_delay=super_gate_delay+max(abs([G2.tauf G2.taui]));end
    

    G2.T= 0:G2.bin:super_gate_length*super_gate_delay;    %TODO: don't get it right now
    G2.T_n  =length(G2.T)-1;
    
for ind_Tdiv=1:length(G2.Ti)
        display(['Time division ' num2str(ind_Tdiv) '/' num2str(length(G2.Ti)) ]);
        
        %prepare empty variables: 
        B2_tau=cell(G2.Npairs,1);B2_tau_avr_G2=cell(G2.Npairs,1);B2_tau_STD=cell(G2.Npairs,1);B2_tt_num_STD=cell(G2.Npairs,1);
        B2_tau_den=cell(G2.Npairs,1);B2_tau_num=cell(G2.Npairs,1);B2_tt_den=cell(G2.Npairs,1);B2_tt_num=cell(G2.Npairs,1);
        G2_tt_den=cell(G2.Npairs,1);G2_tt_num=cell(G2.Npairs,1);G2_tt_num_STD=cell(G2.Npairs,1);
        G2_tau_den=cell(G2.Npairs,1);G2_tau_num=cell(G2.Npairs,1);G2_tau=cell(G2.Npairs,1);G2_tau_STD=cell(G2.Npairs,1);G2_tau_avr_G2=cell(G2.Npairs,1);
        G2_tau_den_fold=cell(G2.Npairs,1);G2_tau_num_fold=cell(G2.Npairs,1);G2_tau_fold=cell(G2.Npairs,1);G2_tau_STD_fold=cell(G2.Npairs,1);G2_tau_avr_G2_fold=cell(G2.Npairs,1);
        G2_tau_axis=cell(G2.Npairs,1);G2_tau2_axis=cell(G2.Npairs,1);
        B_num_of_pulses_in_bunch=zeros(num_of_bunches,1);B2_single_counts=zeros(G2.Npairs,2,num_of_bunches);g2_single_counts=zeros(G2.Npairs,2);B3_single_counts=zeros(1,3,num_of_bunches);g3_single_counts=zeros(1,3);
        
        for Ip=1:G2.Npairs
            B2_tau{Ip}=zeros(G2.tau_n,num_of_bunches);B2_tau_avr_G2{Ip}=zeros(G2.tau_n,num_of_bunches);B2_tau_STD{Ip}=zeros(G2.tau_n,num_of_bunches);  
            B2_tau_den{Ip}=zeros(G2.tau_n,num_of_bunches);B2_tau_num{Ip}=zeros(G2.tau_n,num_of_bunches);
            B2_tt_den{Ip}=zeros(G2.tau_n,G2.T_n,num_of_bunches);B2_tt_num{Ip}=zeros(G2.tau_n,G2.T_n,num_of_bunches); 
            B2_tt_num_STD{Ip}=zeros(G2.tau_n,G2.T_n,num_of_bunches);  
        end
        
        
        B3_tau={zeros(G2.tau_n,G2.tau2_n,num_of_bunches)};B3_tau_avr_G3=cell(1,1);B3_tau_STD={zeros(G2.tau_n,G2.tau2_n,num_of_bunches)};  
        B3_tau_den={zeros(G2.tau_n,G2.tau2_n,num_of_bunches)};B3_tau_num={zeros(G2.tau_n,G2.tau2_n,num_of_bunches)};
        B3_tt_den={zeros(G2.tau_n,G2.T_n,G2.tau2_n,num_of_bunches)};B3_tt_num={zeros(G2.tau_n,G2.T_n,G2.tau2_n,num_of_bunches)}; 
        B3_tt_num_STD={zeros(G2.tau_n,G2.T_n,G2.tau2_n,num_of_bunches)};
        G3_tt_den=cell(1,1);G3_tt_num=cell(1,1);G3_tt_num_STD=cell(1,1);
        G3_tau_den=cell(1,1);G3_tau_num=cell(1,1);G3_tau=cell(1,1);G3_tau_STD=cell(1,1);G3_tau_avr_G3=cell(1,1);        
        G3_tau_den_sort=cell(1,1);G3_tau_num_sort=cell(1,1);G3_tau_sort=cell(1,1);G3_tau_STD_sort=cell(1,1);
        %which gates are included in the cycle (cycgates == cycle gates)
        included_cycgates=ceil(polyval(gate_period,G2.Ti(ind_Tdiv))):floor(polyval(gate_period,G2.Tf(ind_Tdiv))-1);
        chN_within_T=cell(4,1);
        
        for Ic=act_channels
            I=false(size(chN_phot_time{Ic}(:,2)));
            for TiTf_ind=1:length(G2.Ti_pulse),
                I = I | (chN_phot_time{Ic}(:,2)>=G2.Ti_pulse(TiTf_ind) & chN_phot_time{Ic}(:,2)<G2.Tf_pulse(TiTf_ind));
            end
            I=I & chN_phot_gc{Ic}(:,2)>=min(included_cycgates) & chN_phot_gc{Ic}(:,2)<=max(included_cycgates);
            chN_within_T{Ic}=[chN_phot_time{Ic}(I,2) single(chN_phot_gc{Ic}(I,1)) single(chN_phot_cycles{Ic}(I)) single(chN_phot_gc{Ic}(I,2))];
        end
        chIt=1;chIgate=2;chIcycle=3;chIgcycle=4;
        % FOR G2: creating re-index matrices for automatic transformation of
        % square (t1,t2) to diamond (t1,t2-t1)
        I_tau_2D=round(repmat(G2.tau(1:end-1)'/G2.bin+1/2,1,G2.T_n))+repmat(1:G2.T_n,G2.tau_n,1);
        II_tau_2D_out_of_bound= (I_tau_2D<1) | (I_tau_2D>G2.T_n);
        I_tau_2D(II_tau_2D_out_of_bound)=G2.T_n+1;
        % FOR G3: creating re-index matrices for automatic transformation of
        % box (t1,t2,t3) to super-diamond (t1,t2-t1,t3-t1)
        tau2_array=zeros(G2.tau_n,G2.T_n,G2.tau2_n);
        for k=1:G2.tau2_n, tau2_array(:,:,k)=round(G2.tau(k)/G2.bin+1/2); end
        I_tau_3D=round(repmat(G2.tau(1:end-1)'/G2.bin+1/2,[1 G2.T_n G2.tau2_n]))+repmat(1:G2.T_n, [G2.tau_n 1 G2.tau2_n]);
        I_tau2_3D=tau2_array+repmat(1:G2.T_n, [G2.tau_n 1 G2.tau2_n]);
        II_tau_3D_out_of_bound= (I_tau_3D<1) | (I_tau_3D>G2.T_n);
        I_tau_3D(II_tau_3D_out_of_bound)=G2.T_n+1;
        II_tau2_3D_out_of_bound= (I_tau2_3D<1) | (I_tau2_3D>G2.T_n);
        I_tau2_3D(II_tau2_3D_out_of_bound)=G2.T_n+1;
        maximum_number_of_gates=ceil(length(included_cycgates)/super_gate_length);
        total_number_of_photons=0;
        total_number_of_pulses=0;
        
        for ind_bunch=1:max(bunch_map)
            if bunch_size(ind_bunch)==0, continue, end;
            cycles_to_scan=find(bunch_map==ind_bunch);
            g2_phot_per_bin_SUM=cell(G2.Npairs,2);g2_phot_per_bin_NOISE=cell(G2.Npairs,2);
            g2_pair_per_bin_SUM=cell(G2.Npairs,1);g2_pair_per_bin_NOISE=cell(G2.Npairs,1);            
            phot_per_bin_SUM_1_first=0;phot_per_bin_SUM_1_second=0;phot_per_bin_NOISE_1_first=0;phot_per_bin_NOISE_1_second=0;g2_pair_per_bin_SUM_1=uint32(zeros(G2.tau_n,G2.T_n));g2_pair_per_bin_NOISE_1=zeros(G2.tau_n,G2.T_n);
            phot_per_bin_SUM_2_first=0;phot_per_bin_SUM_2_second=0;phot_per_bin_NOISE_2_first=0;phot_per_bin_NOISE_2_second=0;g2_pair_per_bin_SUM_2=uint32(zeros(G2.tau_n,G2.T_n));g2_pair_per_bin_NOISE_2=zeros(G2.tau_n,G2.T_n);
            phot_per_bin_SUM_3_first=0;phot_per_bin_SUM_3_second=0;phot_per_bin_NOISE_3_first=0;phot_per_bin_NOISE_3_second=0;g2_pair_per_bin_SUM_3=uint32(zeros(G2.tau_n,G2.T_n));g2_pair_per_bin_NOISE_3=zeros(G2.tau_n,G2.T_n);
            phot_per_bin_SUM_4_first=0;phot_per_bin_SUM_4_second=0;phot_per_bin_NOISE_4_first=0;phot_per_bin_NOISE_4_second=0;g2_pair_per_bin_SUM_4=uint32(zeros(G2.tau_n,G2.T_n));g2_pair_per_bin_NOISE_4=zeros(G2.tau_n,G2.T_n);
            g3_phot_per_bin_SUM=cell(1,3);g3_phot_per_bin_NOISE=cell(1,3);
            g3_triplet_per_bin_SUM=uint32(zeros(G2.tau_n,G2.T_n,G2.tau2_n));g3_triplet_per_bin_NOISE=zeros(G2.tau_n,G2.T_n,G2.tau2_n);            
            g3_phot_per_bin_SUM_first=0;g3_phot_per_bin_SUM_second=0;g3_phot_per_bin_SUM_third=0;g3_phot_per_bin_NOISE_first=0;g3_phot_per_bin_NOISE_second=0;g3_phot_per_bin_NOISE_third=0;
            num_of_pulses=0;  skipped_runs=0;
            tstart_bunch_collection=tic;            

              parfor ind_within_bunch=1:bunch_size(ind_bunch)
%             for ind_within_bunch=1:bunch_size(ind_bunch)
                tstart=tic;
%                 gates_this_run=[];
                signal=cell(4,1);
                ind=cycles_to_scan(ind_within_bunch);                                
                if mod(ind,10)==0, display(num2str(ind));end;   
                
                for Ic=act_channels
                    signal{Ic}=chN_within_T{Ic}(chN_within_T{Ic}(:,chIcycle)==ind,:);
                    %row below was commented out by LD & GW 15/5/19
%                     gates_this_run=[gates_this_run chN_gates_each_cycle{Ic}(ind)];  %#ok<AGROW>
                end
                %if any(gates_this_run~=gates_this_run(1)), continue; end 
                
                %the max_gate number is the experiment, based on the
                %gates_per_cycle parameter that is supplied by the user. 
%                 max_gate=max(chN_gates_each_cycle{1});
                max_gate=mean(chN_gates_each_cycle{1}); %4/7/19 attempt
                gates_per_cycle=max_gate;
                %skip runs where the difference between max gate and the actual number of gates is different by more
                %than 5% compared to the user supplied parameter
                if (max_gate-chN_gates_each_cycle{arbitrary_Ic}(ind))/gates_per_cycle>0.05
                    skipped_runs=skipped_runs+1;
                    continue;                    
%                     max_gate=max_gate-gates_per_cycle;
                end
                super_gates=1:max_gate;
                super_gates(~ismember(mod(super_gates,gates_per_cycle),included_cycgates))=[];                
                num_of_super_gates=floor(length(super_gates)/super_gate_length);
                super_gates=super_gates(1:(num_of_super_gates*super_gate_length));                
                gates_table=zeros(chN_gates_each_cycle{arbitrary_Ic}(ind),1);
                gates_table(super_gates)=repmat((1:super_gate_length)',num_of_super_gates,1);
                
                for k=1:num_of_super_gates %%% Dont use: parfor k=1:num_of_super_gates                
                    signal_pulse=cell(4,1);chNphot_per_bin=cell(4,1);
                    num_of_pulses=num_of_pulses+1;
                    total_number_of_pulses=total_number_of_pulses+1;
                    for Ic=act_channels
                        if super_gate_length==1
                            signal_pulse{Ic}=signal{Ic}(signal{Ic}(:,chIgate)==super_gates(k),chIt);
                        else
                            II=ismember(signal{Ic}(:,chIgate),super_gates((k-1)*super_gate_length+1:k*super_gate_length));
                            signal_pulse{Ic}=signal{Ic}(II,chIt)+(gates_table(signal{Ic}(II,chIgate))-1)*super_gate_delay; 
                        end                        
                        chNphot_per_bin{Ic}=uint16(histc(signal_pulse{Ic},G2.T));
                        I_TiTfG2=false(size(G2.T));
                     
    for include_ind=1:length(G2.Ti_pulse),
        I_TiTfG2=I_TiTfG2 | (G2.Tf_pulse(include_ind)>=G2.T & G2.Ti_pulse(include_ind)<=G2.T);   
    end
    remove_I_TiTfG2=~I_TiTfG2;
    chNphot_per_bin{Ic}(remove_I_TiTfG2)=0;%remove photons outside the range defined by G2.Ti_pulse and G2.Tf_pulse
                        if size(chNphot_per_bin{Ic},2)>1, chNphot_per_bin{Ic}=chNphot_per_bin{Ic}'; end
                    end
% % %                     if ~isempty(merge_channels)
% % %                         % the merging of channels is done in a cyclic manner
% % %                         % (e.g. 2nd channel is added to 1st, 3rd to 2nd, 1st to 3rd)
% % %                         added_number_of_photons=sum(chNphot_per_bin{merge_channels(1)});
% % %                         temp_phot_per_bin=chNphot_per_bin{merge_channels(1)};
% % %                         for ind_merge=2:length(merge_channels),
% % %                             added_number_of_photons=added_number_of_photons+sum(chNphot_per_bin{ind_merge});
% % %                             chNphot_per_bin{ind_merge-1}=chNphot_per_bin{ind_merge-1}+chNphot_per_bin{ind_merge};
% % %                         end
% % %                         chNphot_per_bin{merge_channels(end)}=chNphot_per_bin{merge_channels(end)}+temp_phot_per_bin;
% % %                     end
                    is_empty_channel=zeros(1,4);
                    for Ic=act_channels
                        channel_num_of_photons=sum(chNphot_per_bin{Ic}(1:end-1));
                        if channel_num_of_photons==0, is_empty_channel(Ic)=1;
                        else total_number_of_photons=total_number_of_photons+channel_num_of_photons; end %#ok<SEPEX>
                    end
                    
                    % G2 matrices filling
                    phot_per_bin_first=cell(4,1);phot_per_bin_second=cell(4,1);
                    for Ipp=1:G2.Npairs
                        phot_per_bin_SUM_first=0;phot_per_bin_SUM_second=0;g2_pair_per_bin_SUM_temp=zeros(G2.tau_n,G2.T_n,'uint16');
                        for Ic1=G2.pairs{Ipp}(1,:), phot_per_bin_SUM_first=phot_per_bin_SUM_first+chNphot_per_bin{Ic1}(1:end-1); end
                        for Ic2=G2.pairs{Ipp}(2,:), phot_per_bin_SUM_second=phot_per_bin_SUM_second+chNphot_per_bin{Ic2}(1:end-1); end
                        % the reason for working in the combersome way below (with variables named "1", "2", etc.)
                        % is to enable the parallel loop. Addressing by cell indices didn't work.
                        switch Ipp
                            case 1, phot_per_bin_SUM_1_first=phot_per_bin_SUM_1_first+uint32(phot_per_bin_SUM_first);phot_per_bin_SUM_1_second=phot_per_bin_SUM_1_second+uint32(phot_per_bin_SUM_second);
                            case 2, phot_per_bin_SUM_2_first=phot_per_bin_SUM_2_first+uint32(phot_per_bin_SUM_first);phot_per_bin_SUM_2_second=phot_per_bin_SUM_2_second+uint32(phot_per_bin_SUM_second);
                            case 3, phot_per_bin_SUM_3_first=phot_per_bin_SUM_3_first+uint32(phot_per_bin_SUM_first);phot_per_bin_SUM_3_second=phot_per_bin_SUM_3_second+uint32(phot_per_bin_SUM_second);
                            case 4, phot_per_bin_SUM_4_first=phot_per_bin_SUM_4_first+uint32(phot_per_bin_SUM_first);phot_per_bin_SUM_4_second=phot_per_bin_SUM_4_second+uint32(phot_per_bin_SUM_second);
                            otherwise error(9123,'more than 4 g2 pairs?'); %#ok<SEPEX>
                        end                    
                        if ~(all(is_empty_channel(G2.pairs{Ipp}(1,:))) || all(is_empty_channel(G2.pairs{Ipp}(2,:))))
                           % All merged-channel in this G2 pair have photons.
                           if is_g2_random_access % "Randon access" method -- loops through pairs and triplets
                               nonzero1=(phot_per_bin_SUM_first>0)';nonzero2=(phot_per_bin_SUM_second>0)';
                               % Loop through all the combination of triplets from the three histograms.
                               for ind_t1=find(nonzero1)
                                   for ind_t2=find(nonzero2 & abs((1:G2.T_n)-ind_t1)<=(G2.tau_n-1)/2) %the second condition discards detections too distant in time
                                       ind_tau=ind_t2-ind_t1+(G2.tau_n+1)/2;
                                       g2_pair_per_bin_SUM_temp(ind_tau,ind_t1)=g2_pair_per_bin_SUM_temp(ind_tau,ind_t1)+...
                                           phot_per_bin_SUM_first(ind_t1)*phot_per_bin_SUM_second(ind_t2);
                                   end
                               end
                           else % "Matrix reshape" method -- no loop, coincidence counted by matrix product
                               for Ic1=G2.pairs{Ipp}(1,:), 
                                   if isempty(phot_per_bin_first{Ic1})
                                       phot_per_bin_first{Ic1}=repmat(chNphot_per_bin{Ic1}(1:end-1)',G2.tau_n,1);
                                   end  
                               end
                               for Ic2=G2.pairs{Ipp}(2,:)
                                   if isempty(phot_per_bin_second{Ic2})
                                       phot_per_bin_second{Ic2}=[chNphot_per_bin{Ic2}(1:end-1);NaN];
                                       phot_per_bin_second{Ic2}=phot_per_bin_second{Ic2}(I_tau_2D);
                                   end
                               end
                               for Ic1=G2.pairs{Ipp}(1,:)
                                   for Ic2=G2.pairs{Ipp}(2,:)
                                       g2_pair_per_bin_SUM_temp=g2_pair_per_bin_SUM_temp+phot_per_bin_first{Ic1}.*phot_per_bin_second{Ic2};
                                   end
                               end
                           end
                           switch Ipp
                               case 1, g2_pair_per_bin_SUM_1=g2_pair_per_bin_SUM_1+uint32(g2_pair_per_bin_SUM_temp);
                               case 2, g2_pair_per_bin_SUM_2=g2_pair_per_bin_SUM_2+uint32(g2_pair_per_bin_SUM_temp);
                               case 3, g2_pair_per_bin_SUM_3=g2_pair_per_bin_SUM_3+uint32(g2_pair_per_bin_SUM_temp);
                               case 4, g2_pair_per_bin_SUM_4=g2_pair_per_bin_SUM_4+uint32(g2_pair_per_bin_SUM_temp);
                           end
                        end
                    end % End of G2 matrices filling
                    
                    % G3 matrices filling
                    if is_g2_only~=1
                    phot_per_bin_SUM_first=0;phot_per_bin_SUM_second=0;phot_per_bin_SUM_third=0;
                    if size(G3.triplets,2)>1 || is_g3_random_access
                        for Ic1=G3.triplets(1,:), phot_per_bin_SUM_first=phot_per_bin_SUM_first+chNphot_per_bin{Ic1}(1:end-1); end
                        for Ic2=G3.triplets(2,:), phot_per_bin_SUM_second=phot_per_bin_SUM_second+chNphot_per_bin{Ic2}(1:end-1); end
                        for Ic3=G3.triplets(3,:), phot_per_bin_SUM_third=phot_per_bin_SUM_third+chNphot_per_bin{Ic3}(1:end-1); end
                        g3_phot_per_bin_SUM_first=g3_phot_per_bin_SUM_first+uint32(phot_per_bin_SUM_first);
                        g3_phot_per_bin_SUM_second=g3_phot_per_bin_SUM_second+uint32(phot_per_bin_SUM_second);
                        g3_phot_per_bin_SUM_third=g3_phot_per_bin_SUM_third+uint32(phot_per_bin_SUM_third);
                    else
                        for Ic1=G3.triplets(1,:), g3_phot_per_bin_SUM_first=g3_phot_per_bin_SUM_first+uint32(chNphot_per_bin{Ic1}(1:end-1)); end
                        for Ic2=G3.triplets(2,:), g3_phot_per_bin_SUM_second=g3_phot_per_bin_SUM_second+uint32(chNphot_per_bin{Ic2}(1:end-1)); end
                        for Ic3=G3.triplets(3,:), g3_phot_per_bin_SUM_third=g3_phot_per_bin_SUM_third+uint32(chNphot_per_bin{Ic3}(1:end-1)); end
                    end
                    if ~(all(is_empty_channel(G3.triplets(1,:))) || all(is_empty_channel(G3.triplets(2,:))) || all(is_empty_channel(G3.triplets(3,:))))
                        % All merged-channel in G3 have photons.                        
                        phot_per_bin_first=cell(4,1);phot_per_bin_second=cell(4,1);phot_per_bin_third=cell(4,1);
                        if is_g3_random_access % "Randon access" method -- loops through pairs and triplets
                            nonzero1=(phot_per_bin_SUM_first>0)';nonzero2=(phot_per_bin_SUM_second>0)';nonzero3=(phot_per_bin_SUM_third>0)';
                            % Loop through all the combination of triplets from the three histograms.
                            g3_triplet_per_bin_SUM_temp=zeros(G2.tau_n,G2.T_n,G2.tau2_n,'uint16');
                            for ind_t1=find(nonzero1)
                                for ind_t2=find(nonzero2 & abs((1:G2.T_n)-ind_t1)<=(G2.tau_n-1)/2) %the second condition discards detections to distant in time
                                    for ind_t3=find(nonzero3 & abs((1:G2.T_n)-ind_t1)<=(G2.tau2_n-1)/2)
                                        ind_tau=ind_t2-ind_t1+(G2.tau_n+1)/2;
                                        ind_tau2=ind_t3-ind_t1+(G2.tau2_n+1)/2;
                                        g3_triplet_per_bin_SUM_temp(ind_tau,ind_t1,ind_tau2)=g3_triplet_per_bin_SUM_temp(ind_tau,ind_t1,ind_tau2)+...
                                            phot_per_bin_SUM_first(ind_t1)*phot_per_bin_SUM_second(ind_t2)*phot_per_bin_SUM_third(ind_t3);
                                    end
                                end
                            end
                        else % "Matrix reshape" method -- no loop, coincidence counted by matrix product
                            for Ic1=G3.triplets(1,:), 
                                if isempty(phot_per_bin_first{Ic1}),
                                    phot_per_bin_first{Ic1}=repmat(chNphot_per_bin{Ic1}(1:end-1)',[G2.tau_n 1 G2.tau2_n]);
                                end
                            end
                            for Ic2=G3.triplets(2,:)
                                if isempty(phot_per_bin_second{Ic2})
                                    phot_per_bin_second{Ic2}=[chNphot_per_bin{Ic2}(1:end-1);NaN];
                                    phot_per_bin_second{Ic2}=phot_per_bin_second{Ic2}(I_tau_3D);
                                end
                            end
                            for Ic3=G3.triplets(3,:)
                                if isempty(phot_per_bin_third{Ic3})
                                    phot_per_bin_third{Ic3}=[chNphot_per_bin{Ic3}(1:end-1);NaN];
                                    phot_per_bin_third{Ic3}=phot_per_bin_third{Ic3}(I_tau2_3D);
                                end
                            end
                            g3_triplet_per_bin_SUM_temp=0;
                            for Ic1=G3.triplets(1,:)
                                for Ic2=G3.triplets(2,:)
                                    for Ic3=G3.triplets(3,:)
                                         g3_triplet_per_bin_SUM_temp=g3_triplet_per_bin_SUM_temp+phot_per_bin_first{Ic1}.*phot_per_bin_second{Ic2}.*phot_per_bin_third{Ic3};
                                    end
                                end
                            end
                        end
                        g3_triplet_per_bin_SUM=g3_triplet_per_bin_SUM+uint32(g3_triplet_per_bin_SUM_temp);
                    end % End of G3 matrices filling
                    end
                end
%                 display(num2str(ind));toc(tstart);
            end

            display(['Skipped runs: ' num2str(round(skipped_runs/bunch_size(ind_bunch)*100)) '%']);
            toc(tstart_bunch_collection)
            g2_phot_per_bin_SUM{1,1}=phot_per_bin_SUM_1_first;g2_phot_per_bin_SUM{1,2}=phot_per_bin_SUM_1_second;g2_pair_per_bin_SUM{1}=g2_pair_per_bin_SUM_1;
            g2_phot_per_bin_SUM{2,1}=phot_per_bin_SUM_2_first;g2_phot_per_bin_SUM{2,2}=phot_per_bin_SUM_2_second;g2_pair_per_bin_SUM{2}=g2_pair_per_bin_SUM_2;
            g2_phot_per_bin_SUM{3,1}=phot_per_bin_SUM_3_first;g2_phot_per_bin_SUM{3,2}=phot_per_bin_SUM_3_second;g2_pair_per_bin_SUM{3}=g2_pair_per_bin_SUM_3;
            g2_phot_per_bin_SUM{4,1}=phot_per_bin_SUM_4_first;g2_phot_per_bin_SUM{4,2}=phot_per_bin_SUM_4_second;g2_pair_per_bin_SUM{4}=g2_pair_per_bin_SUM_4;                                
            g3_phot_per_bin_SUM{1,1}=g3_phot_per_bin_SUM_first;g3_phot_per_bin_SUM{1,2}=g3_phot_per_bin_SUM_second;g3_phot_per_bin_SUM{1,3}=g3_phot_per_bin_SUM_third;g3_triplet_per_bin_SUM={g3_triplet_per_bin_SUM};
            
            % Calculate g2(t1,t2), g2(tau)
            for Ip=1:G2.Npairs
                temp_second=[double(g2_phot_per_bin_SUM{Ip,2});NaN];
                B2_tt_num{Ip}(:,:,ind_bunch)=double(g2_pair_per_bin_SUM{Ip});
                B2_tt_den{Ip}(:,:,ind_bunch)=repmat(double(g2_phot_per_bin_SUM{Ip,1})',G2.tau_n,1).*temp_second(I_tau_2D)/num_of_pulses;
                
                I=isnan(B2_tt_den{Ip}(:,:,ind_bunch));
                G2_tt_num_NaNclean=B2_tt_num{Ip}(:,:,ind_bunch);G2_tt_num_NaNclean(I)=0;
                G2_tt_den_NaNclean=B2_tt_den{Ip}(:,:,ind_bunch);G2_tt_den_NaNclean(I)=0;                              
                B2_tau_num{Ip}(:,ind_bunch)=sum(G2_tt_num_NaNclean,2);
                B2_tau_den{Ip}(:,ind_bunch)=sum(G2_tt_den_NaNclean,2);
                B2_tau{Ip}(:,ind_bunch)=B2_tau_num{Ip}(:,ind_bunch)./B2_tau_den{Ip}(:,ind_bunch);
                B2_tt=squeeze(B2_tt_num{Ip}(:,:,ind_bunch)./B2_tt_den{Ip}(:,:,ind_bunch));
                num_of_valuable_entries=sum(~isnan(B2_tt),2);
                B2_tt(isnan(B2_tt))=0;
                B2_tau_avr_G2{Ip}(:,ind_bunch)=sum(B2_tt,2)./num_of_valuable_entries;
                if G2.is_G23STD==1
                    total_nbr_of_multiphoton_events_at_tau=sum(B2_tt_num{Ip}(:,:,ind_bunch),2);
                    B2_tau_STD{Ip}(:,ind_bunch)=B2_tau{Ip}(:,ind_bunch)./sqrt(total_nbr_of_multiphoton_events_at_tau);
                    B2_tt_num_STD{Ip}(:,:,ind_bunch)=B2_tt_num{Ip}(:,:,ind_bunch)./sqrt(double(g2_pair_per_bin_SUM{Ip}));
                end
                B2_single_counts(Ip,1,ind_bunch)=mean(double(g2_phot_per_bin_SUM{Ip,1}))/num_of_pulses/super_gate_length;
                B2_single_counts(Ip,2,ind_bunch)=mean(double(g2_phot_per_bin_SUM{Ip,2}))/num_of_pulses/super_gate_length;
            end
            
            % Calculate g3(t1,t2,t3), g3(tau1,tau2)
            if is_g2_only~=1
            Ip=1;
            temp_second=[double(g3_phot_per_bin_SUM{Ip,2});NaN];
            temp_third=[double(g3_phot_per_bin_SUM{Ip,3});NaN];
            B3_tt_num{Ip}(:,:,:,ind_bunch)=double(g3_triplet_per_bin_SUM{Ip});
            B3_tt_den{Ip}(:,:,:,ind_bunch)=repmat(double(g3_phot_per_bin_SUM{Ip,1})',[G2.tau_n 1 G2.tau2_n]).*temp_second(I_tau_3D).*temp_third(I_tau2_3D)/(num_of_pulses^2);            
            I=isnan(B3_tt_den{Ip}(:,:,:,ind_bunch));
            G3_tt_num_NaNclean=B3_tt_num{Ip}(:,:,:,ind_bunch);G3_tt_num_NaNclean(I)=0;
            G3_tt_den_NaNclean=B3_tt_den{Ip}(:,:,:,ind_bunch);G3_tt_den_NaNclean(I)=0;
            B3_tau_num{Ip}(:,:,ind_bunch)=sum(G3_tt_num_NaNclean,2);
            B3_tau_den{Ip}(:,:,ind_bunch)=sum(G3_tt_den_NaNclean,2);
            B3_tau{Ip}(:,:,ind_bunch)=B3_tau_num{Ip}(:,:,ind_bunch)./B3_tau_den{Ip}(:,:,ind_bunch);
            B3_tt=squeeze(B3_tt_num{Ip}(:,:,:,ind_bunch)./B3_tt_den{Ip}(:,:,:,ind_bunch));
            num_of_valuable_entries=sum(~isnan(B3_tt),2);
            B3_tt(isnan(B3_tt))=0;
            B3_tau_avr_G3{Ip}(:,:,ind_bunch)=sum(B3_tt,2)./num_of_valuable_entries;
            if G2.is_G23STD==1
                total_nbr_of_multiphoton_events_at_tau=squeeze(sum(B3_tt_num{Ip}(:,:,:,ind_bunch),2));
                B3_tau_STD{Ip}(:,:,ind_bunch)=B3_tau{Ip}(:,:,ind_bunch)./sqrt(total_nbr_of_multiphoton_events_at_tau);
                B3_tt_num_STD{Ip}(:,:,:,ind_bunch)=B3_tt_num{Ip}(:,:,:,ind_bunch)./sqrt(double(g3_triplet_per_bin_SUM{Ip}));
            end  
            B3_single_counts(Ip,1,ind_bunch)=mean(double(g3_phot_per_bin_SUM{Ip,1}))/num_of_pulses/super_gate_length;
            B3_single_counts(Ip,2,ind_bunch)=mean(double(g3_phot_per_bin_SUM{Ip,2}))/num_of_pulses/super_gate_length;
            B3_single_counts(Ip,3,ind_bunch)=mean(double(g3_phot_per_bin_SUM{Ip,3}))/num_of_pulses/super_gate_length;
            B_num_of_pulses_in_bunch(ind_bunch)=num_of_pulses;
            end
        end
        
%%      %%%%%%% average over different bunches of runs %%%%%%%%%%%        
        kuku=B2_tt_den{1};I=isnan(kuku);kuku(I)=0;den_per_bunch=sqrt(squeeze(sum(sum(kuku,1),2)));
        % bunches_to_analyze=[1:3]        
        % figure;plot(den_per_bunch,'o');
%         bunches_to_analyze=find(den_per_bunch<120 & den_per_bunch>60);
%         bunches_to_analyze=find(den_per_bunch>120);
        if isempty(bunches_to_analyze), bunches_to_analyze=1:size(B2_tt_num{1},3); end        
%          fig_G2=figure; %  fig_pairs=figure;
        for Ip=1:G2.Npairs
            G2_tt_num{Ip}=sum(B2_tt_num{Ip}(:,:,bunches_to_analyze),3);
            G2_tt_den{Ip}=sum(B2_tt_den{Ip}(:,:,bunches_to_analyze),3);
            I=isnan(G2_tt_den{Ip});
            G2_tt_num_NaNclean=G2_tt_num{Ip};G2_tt_num_NaNclean(I)=0;
            G2_tt_den_NaNclean=G2_tt_den{Ip};G2_tt_den_NaNclean(I)=0;
            G2_tau_num{Ip}=sum(G2_tt_num_NaNclean,2);
            G2_tau_den{Ip}=sum(G2_tt_den_NaNclean,2);
            G2_tau{Ip}=G2_tau_num{Ip}./G2_tau_den{Ip};
            G2_tt=G2_tt_num{Ip}./G2_tt_den{Ip};num_of_valuable_entries=sum(~isnan(G2_tt),2);G2_tt(isnan(G2_tt))=0;
            G2_tau_avr_G2{Ip}=sum(G2_tt,2)./num_of_valuable_entries;
            if G2.is_G23STD==1
%           decided not to use this variable so not calculate it:      G2_tt_num_STD{Ip}(:,:,:,ind_bunch)=sqrt(G2_tt_num{Ip});
                total_nbr_of_multiphoton_events_at_tau=squeeze(sum(G2_tt_num{Ip},2));
                G2_tau_STD{Ip}=G2_tau{Ip}./sqrt(total_nbr_of_multiphoton_events_at_tau);
                G2_tt_STD{Ip}=G2_tt./sqrt(G2_tt_num{Ip});
            end
        end
        if is_g2_only~=1
        Ip=1;
        G3_tt_num{Ip}=sum(B3_tt_num{Ip}(:,:,:,bunches_to_analyze),4);
        G3_tt_den{Ip}=sum(B3_tt_den{Ip}(:,:,:,bunches_to_analyze),4);
        I=isnan(G3_tt_den{Ip});
        G3_tt_num_NaNclean=G3_tt_num{Ip};G3_tt_num_NaNclean(I)=0;
        G3_tt_den_NaNclean=G3_tt_den{Ip};G3_tt_den_NaNclean(I)=0;
        G3_tau_num{Ip}=squeeze(sum(G3_tt_num_NaNclean,2));
        G3_tau_den{Ip}=squeeze(sum(G3_tt_den_NaNclean,2));
        G3_tau{Ip}=G3_tau_num{Ip}./G3_tau_den{Ip};
        G3_tt=G3_tt_num{Ip}./G3_tt_den{Ip};num_of_valuable_entries=sum(~isnan(G3_tt),2);G3_tt(isnan(G3_tt))=0;
        G3_tau_avr_G3{Ip}=squeeze(sum(G3_tt,2)./num_of_valuable_entries);
        if G2.is_G23STD==1
%           decided not to use this variable so not calculate it:                  G3_tt_num_STD{Ip}(:,:,:,ind_bunch)=sqrt(G3_tt_num{Ip});
            total_nbr_of_multiphoton_events_at_tau=squeeze(sum(G3_tt_num{Ip},2));
            G3_tau_STD{Ip}=G3_tau{Ip}./sqrt(total_nbr_of_multiphoton_events_at_tau); 
        end
        end
        %% Folding G2(tau), Predicting G3 from G2, and sorting G3(tau1,tau2)
        tau_axis=(G2.tau(1:end-1)+G2.bin/2)';tau2_axis=(G2.tau2(1:end-1)+G2.bin/2)';
        cent=(G2.tau_n+1)/2;tau_axis_half=tau_axis(cent:end);
        cent2=(G2.tau2_n+1)/2;tau_axis_max=0:G2.bin:max(max(tau_axis),max(tau2_axis));
        T_axis=(G2.T(1:end-1)+G2.bin/2)';
        % Folding G2        
        for Ip=1:G2.Npairs           
            G2_tau_num_fold{Ip}=[G2_tau_num{Ip}(cent);flipud(G2_tau_num{Ip}(1:cent-1))+G2_tau_num{Ip}(cent+1:end)];
            G2_tau_den_fold{Ip}=[G2_tau_den{Ip}(cent);flipud(G2_tau_den{Ip}(1:cent-1))+G2_tau_den{Ip}(cent+1:end)];
            G2_tau_fold{Ip}=G2_tau_num_fold{Ip}./G2_tau_den_fold{Ip};
            G2_tau_avr_G2_fold{Ip}=[G2_tau_avr_G2{Ip}(cent);(flipud(G2_tau_avr_G2{Ip}(1:cent-1))+G2_tau_avr_G2{Ip}(cent+1:end))/2];
            if G2.is_G23STD==1, G2_tau_STD_fold{Ip}=G2_tau_fold{Ip}./sqrt(G2_tau_num_fold{Ip}); end
        end         
        
        % Calculating average G2 from all channels (all pairs) 
        % TODO: average numerator and denominator seperatly
        G2_tau_fold_all_pairs=zeros((G2.tau_n+1)/2,1);G2_tau_STD_fold_all_pairs=G2_tau_fold_all_pairs;
        for Ip=1:G2.Npairs
            G2_tau_fold_all_pairs=G2_tau_fold_all_pairs+G2_tau_fold{Ip};
            G2_tau_STD_fold_all_pairs=G2_tau_STD_fold_all_pairs+G2_tau_STD_fold{Ip}.^2;
        end
        G2_tau_fold_all_pairs=G2_tau_fold_all_pairs/G2.Npairs;
        G2_tau_STD_fold_all_pairs=sqrt(G2_tau_STD_fold_all_pairs)/G2.Npairs;
                    
        % Predict g3 from the three g2 curves [1;2], [2;3], [1;3]
       if is_g2_only~=1
        if all(all(cell2mat(G2.pairs)==cell2mat({[1;2], [2;3], [1;3]})))
            G2_12=G2_tt_num{1}./G2_tt_den{1};
            G2_23=G2_tt_num{2}./G2_tt_den{2};
            G2_13=G2_tt_num{3}./G2_tt_den{3};
            G3_tt_fromG2=zeros(G2.tau_n,G2.T_n,G2.tau2_n)*nan;
            for ind_t2Mt1=1:G2.tau_n
                for ind_t1=1:G2.T_n  %40:55 %1:20 %20:40 
                    for ind_t3Mt1=1:G2.tau2_n
                        if ~isnan(G3_tt_den{1}(ind_t2Mt1,ind_t1,ind_t3Mt1))
                            ind_t2=ind_t2Mt1-cent+ind_t1;                            
                            ind_t3Mt2=ind_t3Mt1-ind_t2Mt1+cent;
                            if ind_t3Mt2<=G2.tau_n && ind_t3Mt2>=1
                                G3_tt_fromG2(ind_t2Mt1,ind_t1,ind_t3Mt1)=...
                                    G2_12(ind_t2Mt1,ind_t1)+G2_23(ind_t3Mt2,ind_t2)+G2_13(ind_t3Mt1,ind_t1)-2;
                            end
                        end
                    end
                end
            end
            A=G3_tt_fromG2;num_of_valuable_entries=sum(~isnan(A),2);A(isnan(A))=0;
            G3_tau_fromG2=squeeze(sum(A,2)./num_of_valuable_entries);
        else G3_tt_fromG2=[];G3_tau_fromG2=[]; end;
       end
        % Sort times in g3 to get g3 as a function of 1st_tau interval and 2nd_tau interval 
        Ip=1;
        k_t=1:G2.T_n;k_tau=(1:G2.tau_n)-cent;k_tau2=(1:G2.tau2_n)-cent2;
        [K_t1,K_tau1,K_tau2]=meshgrid(k_t,k_tau,k_tau2); %K_t1 is a 3D marix that gives the time (index) of photon in the 1st detector of the triplet
        K_t2=K_t1+K_tau1;K_t3=K_t1+K_tau2;               %K_t2 and K_t3 are 3D marix that give the time (index) in the 2nd and 3rd detectors
        K_ttt=cat(4,K_t1,K_t2,K_t3);K_sort=sort(K_ttt,4);
        K_tau_1st=squeeze(K_sort(:,:,:,2)-K_sort(:,:,:,1));K_tau_2nd=squeeze(K_sort(:,:,:,3)-K_sort(:,:,:,2));
        half_n=max(cent,cent2);
        if is_g2_only~=1
        G3_tau_den_sort{Ip}=zeros(half_n);G3_tau_num_sort{Ip}=zeros(half_n);
        G3_tau_fromG2_sort=zeros(half_n);G3_fromG2_num_of_valuable_enries=zeros(half_n);
        G3_tauTotal_den=zeros(half_n,1);G3_tauTotal_num=zeros(half_n,1);
        G3_tauTotal_fromG2=zeros(half_n,1);G3_tauTotal_fromG2_num_of_valuable_enries=zeros(half_n,1);
        for ind1=1:G2.tau_n
            for ind2=1:G2.T_n
                for ind3=1:G2.tau2_n
                    if ~isnan(G3_tt_den{Ip}(ind1,ind2,ind3))
                        ind_1st=K_tau_1st(ind1,ind2,ind3)+1;ind_2nd=K_tau_2nd(ind1,ind2,ind3)+1;ind_total=ind_1st+ind_2nd-1;
                        if ind_total<=half_n
                            G3_tau_num_sort{Ip}(ind_1st,ind_2nd)=G3_tau_num_sort{Ip}(ind_1st,ind_2nd)+G3_tt_num{Ip}(ind1,ind2,ind3);
                            G3_tau_den_sort{Ip}(ind_1st,ind_2nd)=G3_tau_den_sort{Ip}(ind_1st,ind_2nd)+G3_tt_den{Ip}(ind1,ind2,ind3);
                            G3_tauTotal_num(ind_total)=G3_tauTotal_num(ind_total)+G3_tt_num{Ip}(ind1,ind2,ind3);
                            G3_tauTotal_den(ind_total)=G3_tauTotal_den(ind_total)+G3_tt_den{Ip}(ind1,ind2,ind3);
                            if ~isnan(G3_tt_fromG2(ind1,ind2,ind3)) %&& (G3_tt_fromG2(ind1,ind2,ind3)>0)
                                G3_tau_fromG2_sort(ind_1st,ind_2nd)=G3_tau_fromG2_sort(ind_1st,ind_2nd)+G3_tt_fromG2(ind1,ind2,ind3);
                                G3_fromG2_num_of_valuable_enries(ind_1st,ind_2nd)=G3_fromG2_num_of_valuable_enries(ind_1st,ind_2nd)+1;
                                G3_tauTotal_fromG2(ind_total)=G3_tauTotal_fromG2(ind_total)+G3_tt_fromG2(ind1,ind2,ind3);
                                G3_tauTotal_fromG2_num_of_valuable_enries(ind_total)=G3_tauTotal_fromG2_num_of_valuable_enries(ind_total)+1;
                            end
                        end
                    end
                end
            end
        end
        G3_tau_sort{Ip}=G3_tau_num_sort{Ip}./G3_tau_den_sort{Ip};
        if G2.is_G23STD==1, G3_tau_STD_sort{Ip}=G3_tau_sort{Ip}./sqrt(G3_tau_num_sort{Ip}); end                      
        G3_tauTotal=G3_tauTotal_num./G3_tauTotal_den;
        if G2.is_G23STD==1, G3_tauTotal_STD=G3_tauTotal./sqrt(G3_tauTotal_num); end                      
        G3_tau_fromG2_sort=G3_tau_fromG2_sort./G3_fromG2_num_of_valuable_enries;
        G3_tauTotal_fromG2=G3_tauTotal_fromG2./G3_tauTotal_fromG2_num_of_valuable_enries;
       end
        %% Figures
        fig_g2=figure;    
        for Ip=1:G2.Npairs
            subplot(4,5,1+5*(Ip-1));    if G2.is_G23STD==1, hp=errorbar(tau_axis,G2_tau{Ip},G2_tau_STD{Ip},'.');hold all;else hp=plot(tau_axis,G2_tau{Ip},'.');hold all; end
            title([num2str(G2.pairs{Ip}(1)) ' & ' num2str(G2.pairs{Ip}(2))],'fontsize',8);
            xlabel(['t_' num2str(G2.pairs{Ip}(2)) '-t_' num2str(G2.pairs{Ip}(1)) ' [us]'],'Fontsize',14); ylabel('g_2','Fontsize',14);
        set(gca,'Fontsize',14,'xlim',[min(tau_axis) max(tau_axis)],'xgrid','on');set(gca,'ylim',g2_yrange);plot(get(gca,'xlim'),[1 1],'k:');
            subplot(4,5,[1 2 6 7]+1);    if G2.is_G23STD==1, hp=errorbar(tau_axis,G2_tau{Ip},G2_tau_STD{Ip},'o');hold all;else hp=plot(tau_axis,G2_tau{Ip},'o');hold all; end
            set(hp,'displayname',[num2str(G2.pairs{Ip}(1)) ' & ' num2str(G2.pairs{Ip}(2))]);
        end
        lh=legend('Location','SouthEast'); set(lh,'fontsize',8);title('#1 refl from the 1st BS; #2 refl from the 2nd BS; #3 trans from the 2nd BS','fontsize',8);
        xlabel('t_2-t_1 [us]','Fontsize',14); ylabel('g_2','Fontsize',14);
        set(gca,'Fontsize',14,'xlim',[min(tau_axis) max(tau_axis)],'xgrid','on');set(gca,'ylim',g2_yrange);plot(get(gca,'xlim'),[1 1],'k:'); 
        if plot_for_delay
            figure;
            hp=errorbar(tau_axis_half,G2_tau_fold{Ip},G2_tau_STD_fold{Ip},'o');hold all;
             xlabel('|t_2-t_1| [us]','Fontsize',14); ylabel('g_2','Fontsize',14);legend off;
               
                g2_save_filename=[prefix '_bin' num2str(G2.bin) '_tau' num2str(G2.tauf) '_Tipulse' num2str(G2.Ti_pulse(1)) '_Tfpulse' num2str(G2.Tf_pulse(1)) '_Nph' num2str(total_number_of_photons),...
                '_phPerCyc', num2str(round(average_phot_per_cycle)),...
                '_bunch' num2str(min(bunches_to_analyze)) '-' num2str(max(bunches_to_analyze)) 'of' num2str(max_bunch_size)];
          set(gca,'Fontsize',14,'xlim',[-0.02 max(tau_axis_half)+0.02],'xgrid','on');set(gca,'ylim',g2_yrange);
      saveas(gcf,[savedir '\for delay_g2_' g2_save_filename '.fig']);  
        end
    figure(fig_g2);
        subplot(4,5,[1 2 6 7]+3);
        for Ip=1:G2.Npairs
            if G2.is_G23STD==1, hp=errorbar(tau_axis_half,G2_tau_fold{Ip},G2_tau_STD_fold{Ip},'o');hold all;
            else hp=plot(tau_axis_half,G2_tau_fold{Ip},'o');hold all; end
        end
        xlabel('|t_2-t_1| [us]','Fontsize',14); ylabel('g_2','Fontsize',14);legend off;
        set(gca,'Fontsize',14,'xlim',[-0.05 max(tau_axis_half)],'xgrid','on');set(gca,'ylim',g2_yrange);plot(get(gca,'xlim'),[1 1],'k:');
        subplot(4,5,[1 2 6 7]+13);
        if G2.is_G23STD==1, hp=errorbar(tau_axis_half,G2_tau_fold_all_pairs,G2_tau_STD_fold_all_pairs,'o');hold all;
        else hp=plot(tau_axis_half,G2_tau_fold_all_pairs,'o');hold all; end
        xlabel('|t_2-t_1| [us]','Fontsize',14); ylabel('g_2','Fontsize',14);legend(['g2(0)=' num2str(G2_tau_fold_all_pairs(1)) '\pm' num2str(G2_tau_STD_fold_all_pairs(1)) '; offset=' num2str( mean(G2_tau_fold_all_pairs(11:end)))]);
        set(gca,'Fontsize',14,'xlim',[-0.05 max(tau_axis_half)],'xgrid','on');set(gca,'ylim',g2_yrange);plot(get(gca,'xlim'),[1 1],'k:');
if is_g2_only~=1
        subplot(4,5,[1 2 6 7]+11);
        tauTotal=(0:half_n-1)*G2.bin;
        if G2.is_G23STD==1, hp=errorbar(tauTotal,G3_tauTotal,G3_tauTotal_STD,'o');hold all;
        else hp=plot(tauTotal,G3_tauTotal,'o');hold all; end
        plot(tauTotal,G3_tauTotal_fromG2,'or');
        xlabel('\tau_{1st}+\tau_{2nd} [us]','Fontsize',14);    ylabel('g^{(3)}','Fontsize',14);    legend('g3','g3 from g2');
        set(gca,'Fontsize',14,'xlim',[-0.05 max(tau_axis_half)],'xgrid','on');set(gca,'ylim',g2_yrange);plot(get(gca,'xlim'),[1 1],'k:');
        
        fig_g3=figure;Ip=1;smoothing_range=0;smoothing_range_g3fromg2=0;
        caxis_range=[1.1 2.4];
%         caxis_range=[0 1.3];
        subplot(2,3,1);
        imagesc(tau_axis,tau2_axis,smooth2a(G3_tau{Ip},smoothing_range));title(['g3 (smooth=' num2str(smoothing_range) ')']);
%         imagesc(tau_axis,tau2_axis,smooth2a(G3_tau_avr_G3{Ip},smoothing_range));title('g3 (average g3)');
        xlabel('t_3-t_1 [us]','Fontsize',14);  ylabel('t_2-t_1 [us]','Fontsize',14);colorbar;caxis(caxis_range);set(gca,'YDir','normal','fontsize',14);
        subplot(2,3,4);
        imagesc(tau_axis_max,tau_axis_max,smooth2a(G3_tau_sort{Ip},smoothing_range));title(['g3 (smooth=' num2str(smoothing_range) ')']);
        ylabel('first \tau [us]','Fontsize',14);  xlabel('second \tau [us]','Fontsize',14);colorbar;caxis(caxis_range);      set(gca,'YDir','normal','fontsize',14);
        subplot(2,3,3);
        imagesc(tau_axis,tau2_axis,G3_tau_STD{Ip});
        xlabel('t_3-t_1 [us]','Fontsize',14);  ylabel('t_2-t_1 [us]','Fontsize',14); colorbar;caxis([0 0.5]);title('error bar');          set(gca,'YDir','normal','fontsize',14);
        subplot(2,3,6);
        imagesc(tau_axis_max,tau_axis_max,G3_tau_STD_sort{Ip});
        ylabel('first \tau [us]','Fontsize',14);  xlabel('second \tau [us]','Fontsize',14); colorbar;caxis([0 0.5]);title('error bar');        set(gca,'YDir','normal','fontsize',14);  
        subplot(2,3,2);
        imagesc(tau_axis,tau2_axis,smooth2a(G3_tau_fromG2,smoothing_range_g3fromg2));title(['g3 from g2 (smooth=' num2str(smoothing_range_g3fromg2) ')']);
        xlabel('t_3-t_1 [us]','Fontsize',14);  ylabel('t_2-t_1 [us]','Fontsize',14);colorbar;caxis(caxis_range);      set(gca,'YDir','normal','fontsize',14);
        subplot(2,3,5);
        imagesc(tau_axis_max,tau_axis_max,smooth2a(G3_tau_fromG2_sort,smoothing_range_g3fromg2));title(['g3 from g2 (smooth=' num2str(smoothing_range_g3fromg2) ')']);
        ylabel('first \tau [us]','Fontsize',14);  xlabel('second \tau [us]','Fontsize',14);colorbar;caxis(caxis_range);      set(gca,'YDir','normal','fontsize',14);
end
% fig_2D_g2=figure;
G2_num=0;G2_den=0;G2_STD=0;%matrix dimension problem if using []
for Ip=1:G2.Npairs
        G2_num=G2_num+G2_tt_num{Ip};
        G2_den=G2_den+G2_tt_den{Ip};
        G2_STD=G2_STD+G2_tt_STD{Ip};
end
%     imagesc(T_axis,tau_axis,G2_num./G2_den);title('g^{(2)({\tau},t_1)}');colorbar;caxis(g2_yrange);
% xlabel('t_1 [{\mu}s]','Fontsize',14);  ylabel('{\tau}=t_2-t_1 [{\mu}s]','Fontsize',14);
G2_tau_t1=G2_num./G2_den;
fig_g2_t1_t2=figure;G2_t1_t2_flip=[];G2_t1_t2_compact_flip=[];G2_t1_t2_compact=[];G2_t1_t2_STD_compact=[];smooth_range=2;
G2_t1_t2=zeros(length(T_axis),length(T_axis));
set(fig_g2_t1_t2,'Units','normalized','Position',[0.02 0.1 0.6 0.75]);
Ti_plot=G2.Ti_pulse(1);Tf_plot=G2.Tf_pulse(1);
for i=1:length(tau_axis)
    for j=1:length(T_axis)
        if tau_axis(i)+T_axis(j)>=Ti_plot&&tau_axis(i)+T_axis(j)<=Tf_plot
    G2_t1_t2(i+j-(length(tau_axis)+1)/2,j)=G2_tau_t1(i,j);
    G2_t1_t2_STD(i+j-(length(tau_axis)+1)/2,j)=G2_STD(i,j);
        end
    end
end
I=find(T_axis>=Ti_plot&T_axis<=Tf_plot);
 G2_t1_t2_compact=G2_t1_t2(I,I);G2_t1_t2_STD_compact=G2_t1_t2_STD(I,I);
G2_t1_t2_compact_smooth=smooth2a(G2_t1_t2_compact,smooth_range);
subplot(2,2,1);
imagesc(T_axis(I),T_axis(I),G2_t1_t2_compact);title('g^{(2)(t_2,t_1)}');colorbar;caxis(g2_yrange);
xlabel('t_1 [{\mu}s]','Fontsize',14);  ylabel('t_2 [{\mu}s]','Fontsize',14);
set(gca,'YDir','normal');
subplot(2,2,2);
imagesc(T_axis(I),T_axis(I),G2_t1_t2_compact_smooth);title(['g^{(2)(t_2,t_1)}; smooth range=' num2str(smooth_range)]);colorbar;caxis(g2_yrange);
xlabel('t_1 [{\mu}s]','Fontsize',14);  ylabel('t_2 [{\mu}s]','Fontsize',14);
set(gca,'YDir','normal');
subplot(2,2,3);
imagesc(T_axis(I),T_axis(I),G2_t1_t2_STD_compact);title(['g^{2} STD']);colorbar;caxis(g2_yrange);
xlabel('t_1 [{\mu}s]','Fontsize',14);  ylabel('t_2 [{\mu}s]','Fontsize',14);
set(gca,'YDir','normal');
           drawnow;
                
         
        %%
%         G2_tau_cell{Ip,ind_Tdiv}.G2_tau_mean=G2_tau_mean{Ip};
%         G2_tau_cell{Ip,ind_Tdiv}.G2_tau_avr_den_mean=G2_tau_avr_den_mean{Ip};
%         G2_tau_cell{Ip,ind_Tdiv}.G2_tau_num_mean=G2_tau_num_mean{Ip};
%         G2_tau_cell{Ip,ind_Tdiv}.G2_tau_den_mean=G2_tau_den_mean{Ip};
%         G2_tau_cell{Ip,ind_Tdiv}.G2_tt_num_sum=G2_tt_num_sum{Ip};
%         G2_tau_cell{Ip,ind_Tdiv}.G2_tt_den_sum=G2_tt_den_sum{Ip};
%         if G2.is_G23STD,  G2_tau_cell{Ip,ind_Tdiv}.G2_tau_mean_STD=G2_tau_mean_STD{Ip};    end
%         if G2.is_G23STD,  G2_tau_cell{Ip,ind_Tdiv}.G2_tt_num_sum_STD=G2_tt_num_sum_STD{Ip};    end
%         G2_tau_cell{Ip,ind_Tdiv}.single_counts=single_counts(Ip,:);
        if ~exist('total_number_of_photons'), total_number_of_photons=0, end;
        if length(G2.Ti)==1
         
            g2_save_filename=[prefix '_bin' num2str(G2.bin) '_tau' num2str(G2.tauf) '_Tipulse' num2str(G2.Ti_pulse(1)) '_Tfpulse' num2str(G2.Tf_pulse(1)) '_Nph' num2str(total_number_of_photons),...
                '_phPerCyc', num2str(round(average_phot_per_cycle)),...
                '_bunch' num2str(min(bunches_to_analyze)) '-' num2str(max(bunches_to_analyze)) 'of' num2str(max_bunch_size)];
        else
            if ind_Tdiv==1
                cell_g2_save_filename=['CELLg2_' prefix '_bin' num2str(G2.bin) '_tau' num2str(G2.tauf) '_Tdiv' num2str(length(G2.Ti)),...
                    '_phPerCyc', num2str(round(average_phot_per_cycle)),...
                    '_bunch' num2str(min(bunches_to_analyze)) '-' num2str(max(bunches_to_analyze)) 'of' num2str(max_bunch_size)];
                savedir=cell_g2_save_filename;
                mkdir(['.\' savedir]);
            end
            g2_save_filename=[prefix '_Ti' num2str(G2.Ti(ind_Tdiv)) '_Tf' num2str(G2.Tf(ind_Tdiv)) ,...
                '_Nphot' num2str(total_number_of_photons)];
        end
        figure(fig_g2);saveas(gcf,[savedir '\g2_' g2_save_filename '.fig']);  
        if is_g2_only~=1
        figure(fig_g3);saveas(gcf,[savedir '\g3_' g2_save_filename '.fig']);       
%          save([savedir '\g23_' g2_save_filename '.mat'],...
%               'G2','super_gate_length','runs','B_num_of_pulses_in_bunch',...
%               'B2_single_counts','B2_single_counts','B2_tt_num','B2_tt_den','B3_tt_num','B3_tt_den',...
%               'tau_axis','tau_axis_half','tau2_axis','tau_axis_max','meas_channels',...
%               'G2_tau','G2_tau_avr_G2','G2_tau_STD','G2_tau_fold','G2_tau_STD_fold','G2_tau_num','G2_tau_den','G2_tau_num_fold','G2_tau_den_fold','G2_tt_num','G2_tt_den','G2_tt_num_STD','G3_tau_fromG2','G3_tt_fromG2',...
%               'G3_tau','G3_tau_avr_G3','G3_tau_STD','G3_tau_sort','G3_tau_STD_sort','G3_tau_num','G3_tau_den','G3_tau_num_sort','G3_tau_den_sort','G3_tt_num','G3_tt_den','G3_tt_num_STD');
        else
            Tf_pulse=G2.Tf_pulse; Ti_pulse=G2.Ti_pulse;
            save([savedir '\g2_' g2_save_filename '.mat'],...
              'G2','super_gate_length','runs','B_num_of_pulses_in_bunch',...
              'B2_single_counts','B2_single_counts','B2_tt_num','B2_tt_den','B3_tt_num','B3_tt_den',...
              'tau_axis','tau_axis_half','tau2_axis','tau_axis_max','meas_channels',...
              'G2_tau','G2_tau_avr_G2','G2_tau_STD','G2_tau_fold','G2_tau_STD_fold','G2_tau_num','G2_tau_den',...
              'G2_tau_num_fold','G2_tau_den_fold','G2_tt_num','G2_tt_den','G2_tt_STD','T_axis','G2_t1_t2',...
              'Tf_pulse','Ti_pulse');
   
        end
    end
%          figure(fig_2D_g2);saveas(gcf,[savedir '\g2_2D_' g2_save_filename '.fig']); 
         figure(fig_g2_t1_t2);saveas(gcf,[savedir '\g2_t1_t2_' g2_save_filename '.fig']);
    if length(G2.Ti)>1, save([cell_g2_save_filename '.mat'],'G2','G2_tau_cell','G2_tau_axis','single_counts_vs_gates'); end;    
    toc(tstart_g2);
end

%% Output two-dim
if is_output_two_dim
    xlims=[0 5.5];clim=[1 2];smooth_range=0;
    G2_num=0;G2_den=0;
    for Ip=1:G2.Npairs
        G2_num=G2_num+G2_tt_num{Ip};
        G2_den=G2_den+G2_tt_den{Ip};
    end
    my_T=G2.T;cent=(G2.tau_n+1)/2;cent2=(G2.tau2_n+1)/2;
    if 0
        for ind=1:(G2.tau_n-1)/2
            bins_shift=(G2.tau_n-1)/2-ind+1;
            G2_num(ind,1:(G2.T_n-bins_shift))=G2_num(ind,(1:(G2.T_n-bins_shift))+bins_shift);
            G2_den(ind,1:(G2.T_n-bins_shift))=G2_den(ind,(1:(G2.T_n-bins_shift))+bins_shift);
        end
        G2_num=(G2_num((G2.tau_n-1)/2+1:end,:)+flipud(G2_num(1:(G2.tau_n-1)/2+1,:)))/2;
        G2_den=(G2_den((G2.tau_n-1)/2+1:end,:)+flipud(G2_den(1:(G2.tau_n-1)/2+1,:)))/2;
        my_tau=my_tau((G2.tau_n-1)/2+1:end);
    elseif 1
        for ind=2:(G2.tau_n-1)/2+1
            bins_shift=ind-1;
            G2_num((G2.tau_n-1)/2+1:G2.tau_n,ind)=G2_num(((G2.tau_n-1)/2+1:G2.tau_n)-bins_shift,ind);
            G2_den((G2.tau_n-1)/2+1:G2.tau_n,ind)=G2_den(((G2.tau_n-1)/2+1:G2.tau_n)-bins_shift,ind);
        end
        I_T_cut=2:cent; % we remove the T=0 line since it has no photons (dead time after the gate?)
        G2_num=G2_num(cent+1:G2.tau_n,I_T_cut); % we remove the T=0 line since it has no photons (dead time after the gate?)
        G2_den=G2_den(cent+1:G2.tau_n,I_T_cut);
        my_T=my_T(I_T_cut);
        %             if any(G2_den(:,1)==0)
        %                 Ipulse=G2_den(:,1)>0;
        %                 G2_den=G2_den(Ipulse,Ipulse);
        %                 G2_num=G2_num(Ipulse,Ipulse);
        %                 my_T=my_T(Ipulse);
        %             end
        my_tau=my_T;
    end
    G2_den=smooth2a(G2_den,smooth_range);
    G2_num=smooth2a(G2_num,smooth_range);
    figure;set(gcf,'position',[ 41   145   723   588]+[1*750 0 0 0]);
    ax1=subplot(2,2,1);    imagesc(my_T,my_tau,G2_num);title('Coinc (num.)');colorbar;
    %         set(gca,'xlim',xlims);
    %ax3=subplot(2,2,3);    imagesc(my_T,my_tau,G2_den);title('Singl (den.)');colorbar;
    %         set(gca,'xlim',xlims);
    ax2=subplot(2,2,2);    imagesc(my_T,my_tau,G2_num./G2_den);title('g^{(2)}');caxis(clim);colorbar;
    %         set(gca,'xlim',xlims);
    ax4=subplot(2,2,4);    imagesc(my_T,my_tau,G2_den==0);title('zero den?');colorbar;
    %         set(gca,'xlim',xlims);    
    linkaxes([ax1,ax2,ax3,ax4],'xy');
    figure;
    subplot(2,2,1);plot(my_T,diag(G2_den),my_T,diag(G2_num));legend('Pairs','Single^2');
    subplot(2,2,2);plot(my_T,diag(G2_num)./diag(G2_den));legend('g(2)');
   % subplot(2,2,3);plot(my_T,G3_tt_num{1}(cent,I_T_cut,cent2)./G3_tt_den{1}(cent,I_T_cut,cent2),my_T,G3_tt_fromG2(cent,I_T_cut,cent2));legend('g(3)','g(3) from g(2)');
end
% end
