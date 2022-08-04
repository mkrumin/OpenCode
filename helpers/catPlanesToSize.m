
%takes 3x1 cell of plane fData, cuts frames to match minimum and returns vertcat matrix of neurons

function [catPlanes,nEachPlane,minNFrames] = catPlanesToSize(fData)
try
    nEachPlane = cumsum([0 cell2mat(cellfun(@(x) size(x,1), fData, 'UniformOutput', 0))])+1;
catch
    nEachPlane = cumsum([0; cell2mat(cellfun(@(x) size(x,1), fData, 'UniformOutput', 0))])+1;
end
minNFrames = min(cell2mat(cellfun(@length, fData, 'UniformOutput', 0))); %find minimum "length" over cell array
cutPlanes = cellfun(@(x) x(:,1:minNFrames), fData, 'UniformOutput', 0); %cuts each by this length
catPlanes = vertcat(cutPlanes{:}); %vertcats
