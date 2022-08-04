% header:

mName 			= 'JL035';
expDate 		= '2019-06-15';
taskName        = {'TM', 'blankball', 'SW', 'blankwheel'}; 
NPlanes         = 2;

NTasks = length(taskName);

baseDir = load_paper_dirs;

%baseDir = 'C:\...' %change to your working directory which holds the OpenData and OpenCode folders

dataDir = fullfile(baseDir, 'OpenData', 'NeuralBehavioral');

load(fullfile(dataDir, sprintf('%s_%s.mat', mName, expDate))) % load "session" struct

for tsk = 1:NTasks
    fData{tsk} = catPlanesToSize(session{tsk}.fData);
end

TMIdx = find(strcmp(taskName, 'TM'));
SWIdx = find(strcmp(taskName, 'SW'));

Ff = horzcat(my_conv2(fData{TMIdx}, 10, 2), ...
        my_conv2(fData{SWIdx}, 10, 2));

allDB       = calcIsolationDist(mName,expDate,taskName,NPlanes);
allDBSI     = (allDB{TMIdx}-allDB{SWIdx})./(allDB{TMIdx}+allDB{SWIdx});
[~,ix]      = sort(allDBSI, 'descend');

cumulNFrames = countTaskFrames(session);

%% plot all four
if false
    convPlot = Ff;
else
    if false
        convPlot = Ff ./ max(Ff(:));
    else
        mx = repmat(max(Ff, [], 2), 1, size(Ff,2));
        mn = repmat(min(Ff, [], 2), 1, size(Ff,2));
        convPlot = (Ff - mn) ./ (mx-mn);
        %convPlot = zscore(Ff,1,2);
    end
end

%%plot TM and SW separately

figure('Position', [567 720 779 174])
cmap=colormap('gray');
subplot(1,2,1)
imagesc(convPlot(ix,1:size(fData{TMIdx},2)));
colormap(flipud(cmap));
caxis([0.1 1])
title('during T-maze')
ylabel('sorted by task selectivity')
xticks('');yticks('')
subplot(1,2,2)
imagesc(convPlot(ix,size(fData{TMIdx},2)+1:end));
colormap(flipud(cmap));
caxis([0.1 1])
title('during SW task')
xticks('');yticks('')
