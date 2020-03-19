function [OD,coeffs] = getODFromProbeScan(r,p)

if length(p.loopVals)>1
    kkNum = length(p.loopVals{2});
else
    kkNum = 1;
end
for jj=1:p.NAverage
    figure;
    for kk = 1:kkNum
        for ii=1:length(p.loopVals{1})
            clear Upfreq
            clear absor
            [freq,StartInds,EndInds] = getDDSTriangleRampFreqVec(r.scopeRes{1}(:,1,kk,ii,jj),r.scopeDigRes{1}(:,9,kk,ii,jj),75,0);
            data = r.scopeRes{1}(StartInds(1):EndInds(1),5,kk,ii,jj)-0.015;
            % data = smooth(data,100);
            bg = fliplr(r.scopeRes{1}(StartInds(2):EndInds(2),5,kk,ii,jj)')'-0.015;
            % bg = smooth(bg,100);
            % bg = (r.scopeRes{1}(DownStartInd:DownEndInd,5,ii));
%             if length(bg)>length(data)
%                 bg((length(data)+1):end) = [];
%             elseif length(bg)<length(data)
%                 data((length(bg)+1):end) = [];
%                 Upfreq((length(bg)+1):end) = [];
%             end
            absor{:,kk,ii,jj} = data./bg;
            % plot(ax,Upfreq+(ii-1)*20,absor{:,ii})
            if min(absor{:,kk,ii,jj})<0.1.2
                %         scale = Upfreq(2)-Upfreq(1);
                %         FWHM = getFWHM(1./(absor{:,ii,jj}+0.2),'scale',scale);
                ODGues = 6;
            else
                ODGues = log(min(absor{:,kk,ii,jj})./max(absor{:,kk,ii,jj}));
            end
            if ii==1
                
                initParams = [ODGues,2,1,0.1,0];
                lower = initParams-[1.5,0.1,0.05,0.09,5];
                lower(2) = 1.9;
                upper = initParams+[5.5,0.1,0.05,0.11,5];
                upper(2) = 2.1;
                upper(1) = 100;
            else
                initParams = coeffs(:,kk,ii-1,jj);
                lower = initParams-[5,0.5,0.1,0,5]';
                lower(2) = 1.9;
                upper = initParams+[5,0.5,0.1,0,5]';
                upper(2) = 2.1;
                upper(1) = 100;
                lower(4) = 0.09;
                upper(4) = 0.11;
                initParams(1) = ODGues;
            end
            try
                if ii ==3 && kk==3 
                   disp('3,3');
                end
                [fitobject,gof,output,fitFunc] = fitExpLorentzian(freq,absor{:,kk,ii,jj},initParams,lower,upper);
                r2(ii,jj) = gof.rsquare;
            catch e
                   error(e.message)
                if jj==1
                    if ii~=1
                        coeffs(:,kk,ii,jj)= coeffs(:,kk,ii-1,jj);
                    end
                else
                    coeffs(:,kk,ii,jj) = coeffs(:,kk,ii,jj-1);
                end
                continue;
            end
            coeffs(:,kk,ii,jj) = coeffvalues(fitobject);
            subplot(kkNum,length(p.loopVals{1}),ii+(kk-1)*kkNum)
            plot(freq,absor{:,kk,ii,jj})
            hold on;
            plot(fitobject);
            legend('off')
            OD(kk,ii,jj) = coeffs(1,kk,ii,jj);
        end
        
    end
    
end
end