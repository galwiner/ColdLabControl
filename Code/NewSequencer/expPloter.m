function expPloter(expDate,expNumbers)
%expDate is the date of the experiments. Format: ddmmyy, i.e 130618 for 13 of June 2018.
%If expDate is empty it is set fot today
%expNumbers is the list of experiments to plot (all in the same day and type). If it
%is empty it is set to the latest one of the date.
%Format {'ind1','ind2',,,,}, i.e {'01','15','32'}

%% Load the data
if nargin==0
    Now = datetime('now');
    year = Now.Year;
    month = Now.Month;
    day = Now.Day;
    if month<10
        expDate = sprintf('%d0%d%d',day,month,year-2000);
    else
        expDate = sprintf('%d%d%d',day,month,year-2000);
    end
end
if nargin<2
    latestNum = getLatestExp(expDate);
    if latestNum< 10
        expNumbers = {['0',num2str(latestNum)]};
    else
        expNumbers = {num2str(latestNum)};
    end
    if expNumbers{1} ==0
        error('No experiments found in %s',expDate)
    end
end
fileStr = sprintf('%s_%s.mat',expDate,expNumbers{1});
try
    load(fileStr);
catch err
    error(err.identifier,'%s: Can''t load file %s.',err.message,fileStr);
end
%% Plot
figure;

%Check if window must be maximized, and set font size
if p.plotingParams.MaximizedWindow
    FontSize = 22;
else
    FontSize = 16;
end

%Average over the data, if needed. Assumes that the average dimension is the
%last one
if p.NAverage>1
    for ii = 1 : length(p.plotingParams.yaxes)
        if iscell(p.plotingParams.yaxes{ii})
            for jj = 1:length(p.plotingParams.yaxes{ii})
                yvals{ii}{jj} = squeeze(mean(p.plotingParams.yaxes{ii}{jj},ndims(p.plotingParams.yaxes{ii}{jj})));
                yerrors{ii}{jj} = squeeze(std(p.plotingParams.yaxes{ii}{jj},[],ndims(p.plotingParams.yaxes{ii}{jj})));
            end
        else
            yvals{ii} = squeeze(mean(p.plotingParams.yaxes{ii},ndims(p.plotingParams.yaxes{ii})));
            yerrors{ii} = squeeze(std(p.plotingParams.yaxes{ii},[],ndims(p.plotingParams.yaxes{ii})));
        end
    end
else
    for ii = 1 : length(p.plotingParams.yaxes)
        if iscell(p.plotingParams.yaxes{ii})
            for jj = 1:length(p.plotingParams.yaxes{ii})
                yvals{ii}{jj} = squeeze(p.plotingParams.yaxes{ii}{jj});
                yerrors{ii}{jj} = squeeze(zeros(size(yvals{ii}{jj})));
            end
        else
            yvals{ii} = squeeze(p.plotingParams.yaxes{ii});
            yerrors{ii} = squeeze(zeros(size(yvals{ii})));
        end
    end
end
xvals = p.plotingParams.xaxis;
if length(xvals)==1
    for ii = 1:length(yvals)
       xvals{ii} = xvals{1};
    end
end
%Start the ploting
N = p.plotingParams.NSubPlots;
culnum = 3;
rownum=ceil(N/3);
for ii = 1:N
    subplot(rownum,culnum,ii)
    if iscell(yvals{ii})
        hold on
        for jj = 1:length(yvals{ii})
            if iscell(xvals{ii})
            errorbar(xvals{ii}{jj},yvals{ii}{jj},yerrors{ii}{jj},'-o','LineWidth',2);
            else
            errorbar(xvals{ii},yvals{ii}{jj},yerrors{ii}{jj},'-o','LineWidth',2); 
            end
        end
    else
        errorbar(xvals{ii},yvals{ii},yerrors{ii},'-o','LineWidth',2);
    end
    xlabel(p.plotingParams.xlabel)
    ylabel(p.plotingParams.ylabels{ii})
    if iscell(p.plotingParams.titles)
        title(p.plotingParams.titles{ii})
    end
    set(gca,'FontSize',FontSize)
end
suptitle(p.plotingParams.SupTitle,FontSize);
if p.plotingParams.MaximizedWindow
    jFrame = get(handle(gcf),'JavaFrame');
    pause(0.01);
    jFrame.setMaximized(true)
end
end


