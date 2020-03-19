function [pt,pr]=plotGate(chN_phot_time,chN_gates_each_cycle,varargin)
if length(varargin)==1
    plotOn=varargin{1};
else
    plotOn=1;
end
meas_channels = 1:2; %we might want to change this in the future. 03/10/19
Tgate = 20;
G2.Ti_pulse = 1;
G2.Tf_pulse = 10;
% figure;
    time_bin_for_pulse=0.01; %in uS
    pulse_edge_time=(0:time_bin_for_pulse:Tgate/2); %edges of the pulse time vector, for histogram
    pulse_photon_rate=zeros(4,length(pulse_edge_time)-1);
    pulse_photon_rate_noiseless=pulse_photon_rate;
    %        parfor Ic=meas_channels
    for Ic=meas_channels
        ch_photons = chN_phot_time{Ic}(:,2);
        gates_to_include=sum(chN_gates_each_cycle{Ic});
        if ~isempty(ch_photons)
            [n1,Xt]=hist(ch_photons,pulse_edge_time);
            pulse_photon_rate(Ic,:)=n1(1:end-1)/gates_to_include; %normalized photon rate per channel
        end
    end
    pulse_times=(pulse_edge_time(1:end-1)+pulse_edge_time(2:end))/2; %pulse time centers  
    I_TiTfpulse=false(size(pulse_times));   
    %construct a vector containing all possible included times
    for TiTf_ind=1:length(G2.Ti_pulse)
        I_TiTfpulse=I_TiTfpulse | (pulse_times>=G2.Ti_pulse(TiTf_ind) & pulse_times<=G2.Tf_pulse(TiTf_ind));
    end
    if plotOn
    figure
    for Ic=meas_channels
        subplot(2,2,Ic);
        plot(pulse_times,pulse_photon_rate(Ic,:),'b',pulse_times(I_TiTfpulse),pulse_photon_rate(Ic,I_TiTfpulse),'r');hold on;
        xlabel('time [{\mu}s]');ylabel('photons per gate');
        title(['Ch.' num2str(Ic), ' Total:' num2str(sum(pulse_photon_rate(Ic,:))) ' per gate; bin=' num2str(time_bin_for_pulse) '{\mu}s']);
        subplot(2,2,3);hold all;
        plot(pulse_times,pulse_photon_rate(Ic,:)/mean(pulse_photon_rate(Ic,:)));
        title('pulse photon rate\{channel\}/mean photon rate')
        xlabel('time [{\mu}s]');ylabel('normalized photons');
    end
    end
    Tf_pulse=G2.Tf_pulse; Ti_pulse=G2.Ti_pulse;
    pt=pulse_times;
    pr=sum(pulse_photon_rate,1);
    if plotOn
    subplot(2,2,4);plot(pt,pr);
    title('sum of photons per time bin (both detectors)')
    end
end
