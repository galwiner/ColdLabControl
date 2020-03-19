function letestExp = getLatestExp(expDate)
if nargin<1
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
ii = 1;
while ii<1e4
    if ii<10
        if exist(sprintf('%s_0%d.mat',expDate,ii),'file')==2
            ii = ii+1;
            continue
        else
            letestExp = ii-1;
            break
        end
    else
        if exist(sprintf('%s_%d.mat',expDate,ii),'file')==2
            ii = ii+1;
            continue
        else
            letestExp = ii-1;
            break
        end
    end
end
end
        