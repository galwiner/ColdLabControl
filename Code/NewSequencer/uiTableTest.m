global p;
initp
ctRows = p.ct.Properties.RowNames;
fig = uifigure;
cnames = categorical(ctRows,'Protected',true);
tdata = table(cnames,'VariableNames',{'Color'});
uit = uitable(fig,'Data',tdata,'ColumnEditable',true);
uit.Data(2:end,:) = [];