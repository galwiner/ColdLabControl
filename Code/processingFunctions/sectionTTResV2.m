function sectionedRes = sectionTTResV2(chN_phot_cycles,chN_phot_gc,chN_phot_time,sectionsList,sectionByList,varargin)
%This function takes procesed tt results and sectiones them by the rows of
%sectionsList.
% sectionsList should be a cell array. each cell contains a vector of sections borders (right border included), including the first and last.
%If you have 40 cycles and you want to section the data into individual
%cycles, sectionsList{1} should be 1:41. The number of cels should equal
%the length of sectionByList.
%sectionByList is a string array containg a list of the hierarch to section
%by. Possible entries are: gate,cycle,timeInGate (add more if you need).
%The final results will be an array with n dimentions, where n is the
%length of sectionByList.
%for examplt sectionByList=["gate","cycle"]. Note the use of "" and NOT ''.
%if you use '' you get a char array, not a string array!
%varargin{1} = avarageNum
if ~isempty(varargin)
    avarageNum = varargin{1};
else
    avarageNum = 1;
end
    
if ischar(sectionByList)
    sectionByList = string(sectionByList);
end
if ~iscell(sectionsList)
    tmpsectionsList = sectionsList;
    clear sectionsList
    sectionsList{1} = tmpsectionsList;
end
sectionedRes = defineStruct(sectionsList,sectionByList,max(1,floor(max(chN_phot_cycles{1})/avarageNum)));
tmpList = sectionsList{1};
minCycle = min(min(chN_phot_cycles{1}),min(chN_phot_cycles{2}));
maxCycle = max(max(chN_phot_cycles{1}),max(chN_phot_cycles{2}));
for kk = 1:2 %loop over detectors
    switch length(sectionByList)
        case 1
            for jj = 1:length(tmpList)-1 %loop over sectionsList in pos 2:end
                switch lower(sectionByList(1))
                    case "gate"
                        indString = string(sprintf('chN_phot_gc{%d}(:,2)>=%d&chN_phot_gc{%d}(:,2)<%d',kk,tmpList(jj),kk,tmpList(jj+1)));
                    case "timeingate"
                        indString = string(sprintf('chN_phot_time{%d}(:,2)>=%d&chN_phot_time{%d}(:,2)<%d',kk,tmpList(jj),kk,tmpList(jj+1)));
                    otherwise
                        error('%s is not a valid sectionByList entry.',sectionByList(1))
                end
                sectionedRes.chN_phot_cycles{kk,jj} = chN_phot_cycles{kk}(eval(indString));
                sectionedRes.chN_phot_gc{kk,jj} = chN_phot_gc{kk}(eval(indString),:);
                sectionedRes.chN_phot_time{kk,jj} = chN_phot_time{kk}(eval(indString),:);
                try
                sectionedRes.phot_per_cycle(:,jj) = sectionedRes.phot_per_cycle(:,jj)+count_phot_per_cycle(sectionedRes.chN_phot_cycles{kk,jj},avarageNum,minCycle,maxCycle)';
                catch err
%                    sectionedRes.phot_per_cycle(:,jj) = nan;
                    warning('Error: %s',err.message);
                end
            end
        case 2
            firstList = sectionsList{1};
            secondList = sectionsList{2};
            for jj = 1:length(firstList)-1 %loop over sectionsList{1}
                for mm = 1:length(secondList)-1
                    switch lower(sectionByList(1))
                        case "gate"
                            indString = string(sprintf('chN_phot_gc{%d}(:,2)>=%d&chN_phot_gc{%d}(:,2)<%d&chN_phot_time{%d}(:,2)>=%d&chN_phot_time{%d}(:,2)<%d',...
                              kk,firstList(jj),kk,firstList(jj+1),kk,secondList(mm),kk,secondList(mm+1)));
                        case "timeingate"
                            indString = string(sprintf('chN_phot_time{%d}(:,2)>=%d&chN_phot_time{%d}(:,2)<%d&chN_phot_gc{%d}(:,2)>=%d&chN_phot_gc{%d}(:,2)<%d',...
                                kk,firstList(jj),kk,firstList(jj+1),kk,secondList(mm),kk,secondList(mm+1)));
                        otherwise
                            error('%s is not a valid sectionByList entry.',sectionByList(1))
                    end
                    sectionedRes.chN_phot_cycles{kk,jj,mm} = chN_phot_cycles{kk}(eval(indString));
                    sectionedRes.chN_phot_gc{kk,jj,mm} = chN_phot_gc{kk}(eval(indString),:);
                    sectionedRes.chN_phot_time{kk,jj,mm} = chN_phot_time{kk}(eval(indString),:);
                    sectionedRes.phot_per_cycle(:,jj,mm) = sectionedRes.phot_per_cycle(:,jj,mm)+count_phot_per_cycle(sectionedRes.chN_phot_cycles{kk,jj,mm},avarageNum,minCycle,maxCycle)';
                end
            end
        otherwise
            error('only 2 options are implemented')
    end
end
    function dataStruct = defineStruct(sectionsList,sectionByList,cycleLength)
        switch length(sectionByList)
            case 1
                dataStruct.chN_phot_cycles = cell(2,length(sectionsList{1})-1);
                dataStruct.chN_phot_gc = cell(2,length(sectionsList{1})-1);
                dataStruct.chN_phot_time = cell(2,length(sectionsList{1})-1);
                dataStruct.phot_per_cycle = zeros(cycleLength,length(sectionsList{1})-1);
            case 2
                dataStruct.chN_phot_cycles = cell(2,length(sectionsList{1}-1),length(sectionsList{2})-1);
                dataStruct.chN_phot_gc = cell(2,length(sectionsList{1})-1,length(sectionsList{2})-1);
                dataStruct.chN_phot_time = cell(2,length(sectionsList{1})-1,length(sectionsList{2})-1);
                dataStruct.phot_per_cycle = zeros(cycleLength,length(sectionsList{1})-1,length(sectionsList{2})-1);
            otherwise
                error('only 2 options are implemented')
        end
        
    end
end
