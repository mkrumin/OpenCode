%returns labels just given by fixed (hard-coded) threshold as a heuristic
function labels = getThreshLabels(NClust, mName,expDate,expNumStr,taskName,threshVal, whichTasks)

    threshValUp     = threshVal; %must be higher than this
    threshValDown   = threshVal; %must be lower than this

    baseDir = 'E:\OneDrive - University College London\04_Data\'
    %baseDir = 'C:\...' %change to your working directory which holds the OpenData and OpenCode folders
    dataDir = fullfile(baseDir, 'OpenData', 'PrecomputedData');

    load(fullfile(dataDir sprintf('isolationdists_%s_%s.mat', mName,expDate)))

    if nargin < 7
        whichTasks={'TM', 'SW'};
    end

    tskIdxs{1} = find(strcmp(taskName, whichTasks{1}));
    tskIdxs{2} = find(strcmp(taskName, whichTasks{2}));

    labels = NaN(size(allDB{tskIdxs{1}}));

    %same convention as clusterGMM (check)
    labels(allDB{tskIdxs{1}}>threshValUp & allDB{tskIdxs{2}}<threshValDown) = 1; %TM
    labels(allDB{tskIdxs{1}}<threshValDown & allDB{tskIdxs{2}}>threshValUp) = 3; %SW

    labels(allDB{tskIdxs{1}}>threshValUp & allDB{tskIdxs{2}}>threshValUp) = 2; %both

    if NClust==4
        labels(allDB{tskIdxs{1}}<=threshValDown & allDB{tskIdxs{2}}<=threshValDown) = 4;
    end

end
