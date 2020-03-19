logicalCahnnelNames={};
physicalChannelNames={};
LogicalNames={'pixelfly';'cooling';'repump';'CircCoil'};

channelTable=table({'DigOut0';'DigOut1';'DigOut2';'AO0'},...
                   categorical({'D';'D';'D';'A'}),...
                   [0;1;2;0],...
                   'VariableNames',{'PhysicalName' 'D_A' 'Switch'});
channelTable.Properties.RowNames=LogicalNames;

save('channelTable.mat','channelTable')