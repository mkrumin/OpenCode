baseDir = load_paper_dirs();
dataDir = fullfile(baseDir, 'OpenData', 'PrecomputedData');

whichCells = [94 98] %example cells shown in fig5b
%%

%glm.mainGLM
modelType = 'linear';

mName 			= 'JL035';
expDate 		= '2019-06-15';
taskName        = {'', 'blankball', 'SW', 'blankwheel'}; 
NPlanes         = 2;

whichModel = {'trialOnL', 'trialOnR', 'trialEndChooseL', 'trialEndChooseR', ...
    'reward', 'velocity', 'rotVelPos', 'rotVelNeg'};
whichModelSW = {'pdFlipL', 'pdFlipR', 'reward', ...
    'firstMoveL', 'firstMoveR', 'velocityPos', 'velocityNeg'};
     
%provided for reference, data pre-computed 
%resSW = glm.runModelPipelineV2(...
%    mName,expDate,expNumStr,taskName,NPlanes, whichModelSW, 'SW', modelType);
%res = glm.runModelPipelineV2(...
%    mName,expDate,expNumStr,taskName,NPlanes, whichModel2, 'TM', modelType);

load(fullfile(dataDir,sprintf('encodingmodel_%s_%s_TM.mat', mName,expDate)))
resTM = allRes;
load(fullfile(dataDir,sprintf('encodingmodel_%s_%s_SW.mat', mName,expDate)))
resSW = allRes;
taskColors = {[0.9, 0.3 0.1],[0 0.6 0.6]};
cmap = [taskColors{1}; 0.8*ones(1,3); taskColors{2}; 0.5*ones(1,3)];

%color by same cluster labels as clustered using isolation distance
NClust = 4;
clustFN = fullfile(dataDir, sprintf('clusterlabels_N%d_%s_%s.mat', NClust,mName,expDate));
load(clustFN)

[r,p]=corr(resTM.cvErr, resSW.cvErr, 'type', 'spearman')

figure('Position', [680 572 300 250])
scatter(100*resTM.cvErr, 100*resSW.cvErr, 10, labels, 'filled', 'markeredgecolor', 0.05*ones(1,3), ...
    'linewidth', 0.3)
hold on
scatter(100*resTM.cvErr(whichCells), ...
    100*resSW.cvErr(whichCells), ...
    15, 'd', 'markerfacecolor', [1 0.8 0],  'MarkerEdgeColor', 'k', 'linewidth', 0.5)
axis(100*[-0.1 0.35 -0.1 0.35])
xticks(100*[-0.1:0.1:0.4])
yticks(100*[-0.1:0.1:0.4])
axis square
caxis([1 4])
colormap(cmap)
set(gca, 'FontSize', 9, 'linewidth', 0.5)
xlabel('% explained variance (T-maze)')
ylabel('% explained variance (SW)')

