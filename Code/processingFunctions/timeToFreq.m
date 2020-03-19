function freqSeries = timeToFreq(timeSeries,freqSpan,scanTime,t0)
%convert a time series to a frequency series based on the size and rate of the freq.
%scan window

scanRate=freqSpan/scanTime;
freqSeries=scanRate*(timeSeries-t0);

end

