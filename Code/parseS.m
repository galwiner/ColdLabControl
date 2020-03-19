function s_out=parseS(s_in)
autoStartInd=strfind(s_in,'%AUTO_PLOTTING_STAGE (DO NOT CHANGE THIS LINE)');
if isempty(autoStartInd)
    s_out=s_in;
else
s_out={s_in(1:autoStartInd),s_in(autoStartInd:end)};
end

end

