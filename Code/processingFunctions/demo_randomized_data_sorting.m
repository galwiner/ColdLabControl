% randomized_dat=photPerCycle;
randomized_dat = rim1;
% 
% [~,randIdx1]=sort(r.runValsMap{1});
% 
% [~,randIdx2]=sort(r.runValsMap{2});

% dat=1:100;
% dat=reshape(dat,[10,10])
figure(13);
subplot(2,2,1)
title('original image');
% imagesc(dat);
subplot(2,2,2)
title('randomized data')
% randIdx1=randperm(10);
% randIdx2=randperm(10);
% randomized_dat=dat(randIdx1,randIdx2)
imagesc(randomized_dat);
subplot(2,2,3);
title('after sorted 1st idx')
if ~iscolumn(randIdx1)
    randIdx1=randIdx1';
end
sorted1=sortrows([r.runValsMap{1}',randomized_dat]);
sorted1=sorted1(:,2:end);
imagesc(sorted1);

subplot(2,2,4);
if ~iscolumn(randIdx2)
    randIdx2=randIdx2';
end
sorted2=sortrows([r.runValsMap{2}',sorted1']);
sorted2=sorted2(:,2:end);
imagesc(sorted2');
