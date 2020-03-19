function pulses = findPulses(data)
%L.D 07/11/18
%this function finds the pulses inside data. It dose this by finding the
%maximal and minimal derivatives.
%data must be a matrix or a vector. if data is a matrix, pulses will be an
%cell array of size {# of columbs,pulses}
data = squeeze(data);
if ndims(data)>2
    error('data must be a vector');
end
if size(data,2)>1 && size(data,1)==1
   data = data';
end
pulses = {};
for jj = 1:size(data,2)
grads = diff(data(:,jj));
sigma = std(abs(grads));
[pks,locs] = findpeaks(abs(grads),'MinPeakProminence',8*sigma);
risingEdgeFlag = 0;
risingLocs = [];
fallingLocs = [];
fallingEdgeFlag = 0;
for ii = 1:length(locs)
    if grads(locs(ii))>0 && risingEdgeFlag*fallingEdgeFlag~=0
        pulses{jj,end+1} = [locs(max(risingLocs)),locs(min(fallingLocs))];
        risingLocs = [];
        fallingLocs = [];
        fallingEdgeFlag = 0;
    end
    if grads(locs(ii))>0
        risingLocs(end+1) = ii;
        risingEdgeFlag = 1;
    end
    if grads(locs(ii))<0
        fallingLocs(end+1) = ii;
        fallingEdgeFlag = 1;
    end
    if ii==length(locs) && risingEdgeFlag*fallingEdgeFlag~=0
        pulses{jj,end+1} = [locs(max(risingLocs)),locs(min(fallingLocs))];
        risingLocs = [];
        fallingLocs = [];
        fallingEdgeFlag = 0;
    end
end
end