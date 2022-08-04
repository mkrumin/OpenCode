%writ 2021-06-17

baseDir = load_paper_dirs();
dataDir = fullfile(baseDir, 'OpenData', 'PrecomputedData');

modelType = 'linear';

mName 			= 'JL035';
expDate 		= '2019-06-15';
taskName        = {'TM', 'blankball', 'SW', 'blankwheel'}; 
NPlanes         = 2;

whichModelTM = {'trialOnL', 'trialOnR', 'trialEndChooseL', 'trialEndChooseR', ...
    'reward', 'velocity', 'rotVelPos', 'rotVelNeg'};
whichModelSW = {'pdFlipL', 'pdFlipR', 'reward', ...
    'firstMoveL', 'firstMoveR', 'velocityPos', 'velocityNeg'};
     
%provided for reference, data pre-computed 
%resSW = glm.runModelPipelineV2(...
%    mName,expDate,expNumStr,taskName,NPlanes, whichModelSW, 'SW', modelType);
%resTM = glm.runModelPipelineV2(...
%    mName,expDate,expNumStr,taskName,NPlanes, whichModelTM2, 'TM', modelType);

load(fullfile(dataDir,sprintf('encodingmodel_%s_%s_TM.mat', mName,expDate)))
resTM = allRes;
load(fullfile(dataDir,sprintf('encodingmodel_%s_%s_SW.mat', mName,expDate)))
resSW = allRes;

SWpred  = catPlanesToSize(resSW.predSignals);
TMpred  = catPlanesToSize(resTM.predSignals);

SWdata  = catPlanesToSize(resSW.fData);
TMdata  = catPlanesToSize(resTM.fData);

taskColors = {[0.9, 0.3 0.1],[0 0.6 0.6]};

iCell = 98; %example cell in T-maze;
figure('Position', [137 727 718 74])
plot(TMdata(iCell,:), 'color', taskColors{1})
hold on
plot(TMpred(iCell,:), 'color', [0.2 0.2 0.2])
axis tight;
box off
xlim([37140 37140+3000])
ylim([-200 1500])
xticks(''); yticks('')

iCell = 94; %example cell in SW task
figure('Position', [137 727 718 74])
plot(SWdata(iCell,:), 'color', taskColors{2})
hold on
plot(SWpred(iCell,:), 'color', [0.2 0.2 0.2])
axis tight;
box off
xlim([2500 5500])
ylim([-200 1500])
xticks(''); yticks('')

