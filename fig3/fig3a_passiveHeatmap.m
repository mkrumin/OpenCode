%
mName 			= 'JL035';
expDate 		= '2019-06-15';
taskName        = {'TM', 'blankball', 'SW', 'blankwheel'}; 
NPlanes         = 2;

NTasks = length(taskName);

baseDir = 'E:\OneDrive - University College London\04_Data\'

%baseDir = 'C:\...' %change to your working directory which holds the OpenData and OpenCode folders

dataDir = fullfile(baseDir, 'OpenData', 'NeuralBehavioral');

load(fullfile(dataDir, sprintf('%s_%s.mat', mName, expDate))) % load "session" struct

for tsk = 1:NTasks
    fData{tsk} = catPlanesToSize(session{tsk}.fData);
end

TMIdx = find(strcmp(taskName, 'TM'));
SWIdx = find(strcmp(taskName, 'SW'));

BBIdx = find(strcmp(taskName, 'blankball'));
BWIdx = find(strcmp(taskName, 'blankwheel'));

convEach = {my_conv2(fData{TMIdx}, 10, 2), ...
            my_conv2(fData{BBIdx}, 10, 2), ...
            my_conv2(fData{SWIdx}, 10, 2), ...
            my_conv2(fData{BWIdx}, 10, 2)};
Ff = horzcat(convEach{:});;

allDB       = calcIsolationDist(mName,expDate,taskName, NPlanes);
allDBSI     = (allDB{TMIdx}-allDB{SWIdx})./(allDB{TMIdx}+allDB{SWIdx});
[~,ix]      = sort(allDBSI, 'descend');

%% plot all four
mx = repmat(max(Ff, [], 2), 1, size(Ff,2));
mn = repmat(min(Ff, [], 2), 1, size(Ff,2));
convPlot = (Ff - mn) ./ (mx-mn);

%%plot TM and SW separately
cmap=colormap('gray');

cumulNFrames = countTaskFrames(session);

for ii = 1:4
    convReEach{ii} = convPlot(:,cumulNFrames(ii):cumulNFrames(ii+1)-1); %yup
end

% chunks of 15 minutes each
convPart = {convReEach{1}(:,30000:39000) ...
            convReEach{2}(:,5000:14000) ...
            convReEach{3}(:,20000:29000) ...
            convReEach{4}(:,20:9020)};

figure('Position', [100 500 1000 200])
for ii = 1:4
    subplot(1,4, ii)
    imagesc(convPart{ii}(ix,:))
    colormap(flipud(cmap));
    caxis([0.1 1])
    axis off
end

