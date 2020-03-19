function g2Vect= calculateG2(tags,chan1num,chan2num,min_time,max_time,bin_size,measurement_time)
%Repackaged code, originally written by OD. adapted here by GW
%chan3 is gate

% bin_size = 100; %Time bin size
% min_time = -10e3; %The minimal time before the idler photon arrivel to check for coincidences with the signal photon
% max_time = 20e3; %The maximal time to check for cross-correlation
time_vector = min_time:bin_size:max_time;
cross_correlation = zeros(1,length(time_vector)); %The cross correlation value
signal_channel=chan1num;
idler_channel=chan2num; %signal and idler names are chosed to conform to Omri Davidson's code
gate_channel=3;
Time_tag_chans=tags(2,:);
Time_tag_stamps=tags(1,:);
Time_tag_stamps_signal=Time_tag_stamps(Time_tag_chans==signal_channel);
Time_tag_stamps_idler=Time_tag_stamps(Time_tag_chans==idler_channel);
Time_tag_stamps_gate=Time_tag_stamps(Time_tag_chans==gate_channel);

      %% Finding the cross correlation coincidence counts
inner_loop_starting_index = 1;

for ii = 1:length(Time_tag_stamps_idler)%go over all time stamps in one channel

    for jj = inner_loop_starting_index:length(Time_tag_stamps_signal) %% go over all time stamps in other channel
        
        if Time_tag_stamps_signal(jj) - Time_tag_stamps_idler(ii) >= min_time 
            
            if Time_tag_stamps_signal(jj) - Time_tag_stamps_idler(ii) <= max_time
                %if we are further than min_time and closer than max_time,
                %find the bin number and add 1 to the correlation histogram
                time_difference = bin_size*round((Time_tag_stamps_signal(jj) - Time_tag_stamps_idler(ii) )/bin_size);
                time_index = find(time_vector == time_difference);
                cross_correlation(time_index) = cross_correlation(time_index) + 1; 
                
            else
                %if we are further apart than max_time, do not consider the
                %begining of the idler timestamp vector
                if jj > 1
                    inner_loop_starting_index = jj-1; %This is true when the dead time of the SPCM is similar to min\max times we are looking at. If it is less we need jj - dead_time*time_interval                    
                end
                
                break %Breaking out of inner loop
                
            end %end of positive time difference condition
            
        end %end of neagative time difference condition
    end %inner loop (signal photon)
end %Outer loop (idler photon)

cross_correlation = cross_correlation/measurement_time; %Normalizing the G_2 to count rate per second
normalized_g_2 = cross_correlation/((bin_size*1e-12)*(length(Time_tag_stamps_signal)/measurement_time)*(length(Time_tag_stamps_idler)/measurement_time)); %The normalized g_2
g2Vect=normalized_g_2;
end

