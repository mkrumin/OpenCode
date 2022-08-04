%header:

baseDir = load_paper_dirs;

%baseDir = 'C:\...' %change to your working directory which holds the OpenData and OpenCode folders

dataDir = fullfile(baseDir, 'OpenData', 'PrecomputedData');

mName 			= 'JL035';
expDate 		= '2019-06-15';
taskName        = {'TM', 'blankball', 'SW', 'blankwheel'}; 
NPlanes         = 2;

TMIdx = find(strcmp(taskName, 'TM'));
SWIdx = find(strcmp(taskName, 'SW'));
allDB = calcIsolationDist(mName,expDate,taskName, NPlanes);

taskColors = {[0.9, 0.3 0.1],[0 0.6 0.6]};
cmap = [taskColors{1}; 0.8*ones(1,3); taskColors{2}; 0.5*ones(1,3)];

% load precomputed cluster labels (see function clusterGMM.m for reference)
NClust = 4;
clustFN = fullfile(dataDir, sprintf('clusterlabels_N%d_%s_%s.mat', NClust,mName,expDate));
load(clustFN)

%example cells from before
TMcell = 3;
SWcell = 72;
whichCells      = [TMcell SWcell];
whichCellIdx    = zeros(size(allDB{TMIdx}));
whichCellIdx(whichCells) = 1;

figure('Position', [600 667 168 153])
scatter(allDB{TMIdx}(~whichCellIdx),allDB{SWIdx}(~whichCellIdx), 8, labels(~whichCellIdx), ...
    'filled', 'MarkerEdgeColor', 'k', 'linewidth', 0.15)
hold on
scatter(allDB{TMIdx}(TMcell),allDB{SWIdx}(TMcell), 10, 'w', 'filled', 'd', 'MarkerEdgeColor', taskColors{1}, 'linewidth', 0.5)
scatter(allDB{TMIdx}(SWcell),allDB{SWIdx}(SWcell), 10, 'w', 'filled', 'd', 'MarkerEdgeColor', taskColors{2}, 'linewidth', 0.5)
axis square
xlabel('T-maze activity')
ylabel('SW task activity')
xticks(0:4); yticks(0:4)
axis([-0.2 4.5 -0.2 4.5])
text(0.35, 0.77, ...
    sprintf('N = %d cells', length(allDB{TMIdx})), 'units', 'normalized', 'fontsize', 8)
set(gca, 'FontSize', 9, 'linewidth', 0.5)
caxis([1 4])
colormap(cmap)
