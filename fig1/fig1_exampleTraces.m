%% header here
%example session used 
mName 			= 'JL035';
expDate 		= '2019-06-15';
taskName        = {'TM', 'blankball', 'SW', 'blankwheel'}; 
NPlanes         = 2;

baseDir = 'E:\OneDrive - University College London\04_Data\'

%baseDir = 'C:\...' %change to your working directory which holds the OpenData and OpenCode folders

dataDir = fullfile(baseDir, 'OpenData', 'NeuralBehavioral');

load(fullfile(dataDir, sprintf('%s_%s.mat', mName, expDate)))

TMIdx = find(strcmp(taskName, 'TM'));
SWIdx = find(strcmp(taskName, 'SW'));

Fs = 10;
convSize = 1;
convGauss       = gausswin(Fs*convSize); 
convGauss       = convGauss./sum(convGauss); %normalise

NTasks = length(taskName);
for tsk = [TMIdx SWIdx]
    spData{tsk}     = catPlanesToSize(session{tsk}.spData);
    eachF{tsk}      = conv2(1, convGauss, spData{tsk}, 'same'); %don;t zscore, just keep units
end

whichCells = [3 72]; %example cells
entireMax = max(reshape([spData{TMIdx} spData{SWIdx}], 1, []));
normSp{TMIdx} = spData{TMIdx}./entireMax;
normSp{SWIdx} = spData{SWIdx}./entireMax;

%% TM example
ci = 3;
figure('name', 'T-maze selective example cell', 'Position', [100 832 500 60])
subplot(1,2,1)
plot(session{TMIdx}.fFT{1}/60, normSp{TMIdx}(ci, :), 'Color', 0.5*ones(1,3), 'linewidth', 0.5)
axis tight
box off;
ylim([-0.05 0.5])
set(gca, 'FontName', 'Arial', 'FontSize', 7)
xticks(0:5:max(session{SWIdx}.fFT{1})); xticklabels('');
title('during T-maze')
subplot(1,2,2)
plot(session{SWIdx}.fFT{1}/60, normSp{SWIdx}(ci, :), 'Color', 0.5*ones(1,3), 'linewidth', 0.5)
axis tight
xticks(0:5:max(session{SWIdx}.fFT{1})); xticklabels('');
box off;
ylim([-0.05 0.5])
set(gca, 'FontName', 'Arial', 'FontSize', 7)
title('during SW task')

%% SW example
ci = 72;
figure('name', 'SW task selective example cell', 'Position', [100 832 500 60])
subplot(1,2,1)
plot(session{TMIdx}.fFT{1}/60, normSp{TMIdx}(ci, :), 'Color', 0.5*ones(1,3), 'linewidth', 0.5)
axis tight
xticks(0:5:max(session{TMIdx}.fFT{1})); xticklabels('');
box off;
ylim([-0.05 0.5])
set(gca, 'FontSize', 7)
title('during T-maze')
subplot(1,2,2)
plot(session{SWIdx}.fFT{1}/60, normSp{SWIdx}(ci, :), 'Color', 0.5*ones(1,3), 'linewidth', 0.5)
axis tight
xticks(0:5:max(session{SWIdx}.fFT{1})); xticklabels('');
box off;
ylim([-0.05 0.5])
set(gca, 'FontSize', 7)
title('during SW task')
