path='d:\box sync';
d=dir(path);
if isempty(d)
    path='e:\box sync';
    d=dir(path);
    if isempty(d)
        error("can't find box sync");
    end
end

        
savedir=[path '\Lab\Calculations\g2_ofer_mit\20140715'];
 prefix='pr_1.266_2phPerus_blue_18MHz_1.25MHzfromPeak_2phRes';
 
%  runs=779;
runs=10;
max_bunch_size=2;
G2.min_phot_cycl=0;G2.max_phot_cycl=4000;max_bunch_size=200;
G2.neighbors_variation_phot_cycle=0.2;G2.neighbor_range_phot_cycle=5;
gates_i=[0]; gates_f=[inf];Tgate=40;cycleT=280000;gates_per_cycle=977;
 g2_yrange=[0 2];is_noise=0;
 G2.Ti_pulse=[3];
 G2.Tf_pulse=[17]; %take out the spike on chan3
G2.bin=0.02; %binwidth
G2.taui=-0.1; 
G2.tauf=0.1; 
G2.tau2i=G2.taui;   G2.tau2f=G2.tauf;
is_G23=1;
is_g2_only=0;
G2.is_G23STD=1;
is_output_two_dim=0;
plot_for_delay=0;
G2.Ti=0;
G2.Tf=39000;
super_gate_length=1;is_super_gate_correlations=0;
is_g2_random_access=1;is_g3_random_access=1;
is_PostSelection_by_outgoing_rate=1;
bunches_to_analyze=[]; % Put [] for all bunches 
prefix_gated=[prefix '_gates0toInf'];
G2.Ti_pulse=[3];
G2.Tf_pulse=[17]; %take out the spike on chan3
G2.bin=0.02; %binwidth
G2.taui=-0.1;
G2.tauf=0.1;
G2.tau2i=G2.taui;   G2.tau2f=G2.tauf;
meas_channels=[1 2 3];
G2.pairs=   {[1;2], [2;3], [1;3]};
G3.triplets= [1;2;3]; 

load([savedir '\' prefix_gated,'.mat']);
%%
if max_bunch_size<0, max_bunch_size=runs;end;
num_of_bunches=ceil(runs/max_bunch_size);
bunch_map=reshape(repmat(1:num_of_bunches,max_bunch_size,1),num_of_bunches*max_bunch_size,1);
bunch_map=bunch_map(1:runs);
num_of_bunches=max(bunch_map);
bunch_size=hist(bunch_map,0:max(bunch_map));bunch_size(1)=[]; %after we've removed some of the runs, this step gives us an updated vector with the size of each bunch

%% tstart_g2=tic;
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
%cycle start)+b. the a param gives the average gate period per
%microsecond
gate_period=polyfit(chN_phot_time{arbitrary_Ic}(:,1),double(chN_phot_gc{arbitrary_Ic}(:,2)),1);
%     gates_per_cycle=median(round((chN_gates_each_run{arbitrary_Ic}+1)./chN_cycles_each_run{arbitrary_Ic}));

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
        chN_within_T{Ic}=[chN_phot_time{Ic}(I,2) single(chN_phot_gc{Ic}(I,1)) single(chN_phot_runs{Ic}(I)) single(chN_phot_gc{Ic}(I,2))];
    end
    chIt=1;chIgate=2;chIrun=3;chIgcycle=4;
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
    maximum_number_of_gates=ceil(length(included_cycgates)*max(chN_cycles_each_run{arbitrary_Ic})/super_gate_length);
    total_number_of_photons=0;
    total_number_of_pulses=0;
    
    for ind_bunch=1:max(bunch_map)
        if bunch_size(ind_bunch)==0, continue, end;
        runs_to_scan=find(bunch_map==ind_bunch);
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
        
        %              parfor ind_within_bunch=1:bunch_size(ind_bunch)
        for ind_within_bunch=1:bunch_size(ind_bunch)
            %             for ind_within_bunch=1:bunch_size(ind_bunch)
            tstart=tic;
            gates_this_run=[];signal=cell(4,1);
            ind=runs_to_scan(ind_within_bunch);
            if mod(ind,10)==0, display(num2str(ind));end;
            
            for Ic=act_channels
                signal{Ic}=chN_within_T{Ic}(chN_within_T{Ic}(:,chIrun)==ind,:);
                gates_this_run=[gates_this_run chN_gates_each_run{Ic}(ind)];  %#ok<AGROW>
            end
            %if any(gates_this_run~=gates_this_run(1)), continue; end
            
            %the max_gate number is the experiment, based on the
            %gates_per_cycle parameter that is supplied by the user.
            max_gate=gates_per_cycle*chN_cycles_each_run{arbitrary_Ic}(ind);
            %skip runs where the difference between max gate and the actual number of gates is different by more
            %than 5% compared to the user supplied parameter
            if (max_gate-chN_gates_each_run{arbitrary_Ic}(ind))/gates_per_cycle>0.05
                skipped_runs=skipped_runs+1;
                continue;
                %                     max_gate=max_gate-gates_per_cycle;
            end
            super_gates=1:max_gate;
            super_gates(~ismember(mod(super_gates,gates_per_cycle),included_cycgates))=[];
            num_of_super_gates=floor(length(super_gates)/super_gate_length);
            super_gates=super_gates(1:(num_of_super_gates*super_gate_length));
            gates_table=zeros(chN_gates_each_run{arbitrary_Ic}(ind),1);
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
                    else total_number_of_photons=total_number_of_photons+channel_num_of_photons; end
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
    fig_g2_t1_t2=figure;G2_t1_t2_flip=[];G2_t1_t2_compact_flip=[];G2_t1_t2_compact=[];G2_t1_t2_STD_compact=[];smooth_range=1;
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
        %               'G2','super_gate_length','runs','goodruns','B_num_of_pulses_in_bunch',...
        %               'B2_single_counts','B2_single_counts','B2_tt_num','B2_tt_den','B3_tt_num','B3_tt_den',...
        %               'tau_axis','tau_axis_half','tau2_axis','tau_axis_max','meas_channels',...
        %               'G2_tau','G2_tau_avr_G2','G2_tau_STD','G2_tau_fold','G2_tau_STD_fold','G2_tau_num','G2_tau_den','G2_tau_num_fold','G2_tau_den_fold','G2_tt_num','G2_tt_den','G2_tt_num_STD','G3_tau_fromG2','G3_tt_fromG2',...
        %               'G3_tau','G3_tau_avr_G3','G3_tau_STD','G3_tau_sort','G3_tau_STD_sort','G3_tau_num','G3_tau_den','G3_tau_num_sort','G3_tau_den_sort','G3_tt_num','G3_tt_den','G3_tt_num_STD');
    else
        Tf_pulse=G2.Tf_pulse; Ti_pulse=G2.Ti_pulse;
        save([savedir '\g2_' g2_save_filename '.mat'],...
            'G2','super_gate_length','runs','goodruns','B_num_of_pulses_in_bunch',...
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
