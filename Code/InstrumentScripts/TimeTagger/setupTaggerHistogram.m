function setupTaggerHistogram(bin_width,scanTime,varargin)
    global inst
    global p
    tt=inst.tt;
    %bin_width in us 
    bin_width=bin_width*1e6;
    bin_num=ceil(scanTime/bin_width);
    if nargin>2
        trigChan=varargin{1};
        clickChan=varargin{2};
    else 
        trigChan=1;
        clickChan=2;
    end
    % Hist_count=TTHistogram(tagger, click_chan, start_chan, binwidth, num_of_bins);
    Hist_count=TTHistogram(tt, clickChan, trigChan, bin_width,  bin_num); %Get Histogram of channel 1 
end
