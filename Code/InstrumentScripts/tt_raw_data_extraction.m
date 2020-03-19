% This script collects the time tag stream from two input channels.

%It is then can be analyzed with any of the relevant codes in:
%D:\Box Sync\Lab\Matlab scripts\Analysis\Single photon source analysis\single photons analysis

%Last updated 15.11.2018 OD
%based on OD script. revised by GW

%% Connect to time tagger
tagger = TimeTagger; %Connecting to the the Time Tagger. 
 
tagger.reset(); %Resets the tagger to its startup state
%% Parameters
idler_channel = 1;
% signal_channel = 1;
chan=TTDelayedChannel(tagger,1,10000);
signal_channel=chan.getChannel;
channels = [signal_channel,idler_channel]; %The channels to collect tags from
Buffer_size = 30e6; %The buffer size the tagger accumeltaes before overflowwing
measurement_time = 0.1; %The wanted measurement time in seconds




%% Control the trigger level of the channels
for ii=1:1
    tagger.setTriggerLevel(1, 1.5); %Sets the trigger level
end

%% Take raw time tag stream

tagger.sync(); %Makes sure the new stream waits until all previous tags have been processed
Time_tag_object = TTTimeTagStream(tagger,Buffer_size,channels); %This object acquires the timetags stream from the buffer

pause(measurement_time)

Time_tag_stamps_struct = Time_tag_object.getData();

Time_tag_stamps = double(Time_tag_stamps_struct.tagTimestamps); %This is a vector of all the time stamps (from all channels)
Time_tag_chans = double(Time_tag_stamps_struct.tagChannels); %This is the channel number of the corresponding time stamp

% %Moved to the analysis script into order not to save twice the data needed
% Time_tag_stamps_signal=Time_tag_stamps(Time_tag_chans==signal_channel); %Time stamps vector of signal channel
% Time_tag_stamps_idler=Time_tag_stamps(Time_tag_chans==idler_channel); %Time stamps vector of idler channel

%Stop the measurement:
Time_tag_object.stop();


%% Disconnecting communication with time tagger

%Freeing the time tagger:
tagger.free();

%% Plotting the histogram


%% Saving data
% addpath('D:\Box Sync\Lab\Matlab scripts\Sequences\Single photon source codes\Swabian Time Tagger acquisition');
% clear tagger correlation_object %Do not want to save the tagger object

% save_data_Source;

%% Parameters for the cross correlation function
%All times are in ps
bin_size = 100; %Time bin size
min_time = -10e3; %The minimal time before the idler photon arrivel to check for coincidences with the signal photon
max_time = 20e3; %The maximal time to check for cross-correlation
time_vector = min_time:bin_size:max_time;  
cross_correlation = zeros(1,length(time_vector)); %The cross correlation value
%% Convering the time stamp vector to the two channels
Time_tag_stamps_signal=Time_tag_stamps(Time_tag_chans==signal_channel);
Time_tag_stamps_idler=Time_tag_stamps(Time_tag_chans==idler_channel);
        
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

%% Calculating the coincidence generation rate and heralding efficiency

background = mean(cross_correlation(1:10));  
coincidence_count_rate = sum(cross_correlation) - background*length(cross_correlation);
heralding_efficiency = coincidence_count_rate/(length(Time_tag_stamps_idler)/measurement_time);

%cross correlated counts per second PER total signal counts per second PER
%total idler counts per second
normalized_g_2 = cross_correlation/((bin_size*1e-12)*(length(Time_tag_stamps_signal)/measurement_time)*(length(Time_tag_stamps_idler)/measurement_time)); %The normalized g_2


%% Plotting

figure;
yyaxis left
plot(time_vector*1e-3,cross_correlation)
xlabel('time [ns]')
ylabel('G^{(2)}_{S,I}(\tau)')
hold on
yyaxis right
plot(time_vector*1e-3,normalized_g_2)
ylabel('g^{(2)}_{S,I}(\tau)')

count_rate_text1 = ['The coincidence count rate'];
count_rate_text2 = ['(background subtracted) is: '];
count_rate_text3 = [num2str(round(coincidence_count_rate/1000)),' kHz'];
count_rate_text4 = ['The heralding efficiency is: '];
count_rate_text5 = [num2str(round(100*heralding_efficiency,1)), '%'];
count_rate_text = {count_rate_text1; count_rate_text2; count_rate_text3;...
count_rate_text4; count_rate_text5};

dim_text_box = [.55 .5 .3 .3]; %The position of the textbox
annotation('textbox',dim_text_box,'String',count_rate_text,'FitBoxToText','on');


