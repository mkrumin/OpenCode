function fig2a_plotExampleTracesCrops()
baseDir = load_paper_dirs;

%baseD= 'C:\...' %change to your working directory which holds the OpenData and OpenCode folders

dataDir = fullfile(baseDir, 'OpenData', 'NeuralBehavioral');


ii = 0;
mN 		= 'JL035';
NPl     = 2;

ii = ii + 1;
xD{ii}     = '2019-06-25';
tN{ii}     = {'SW', 'blankwheel', 'TM', 'blankball', 'passiiveBall'}; 

ii = ii + 1;
xD{ii}     = '2019-06-26';
tN{ii}     = {'TM', 'blankball', 'SW', 'blankwheel', 'passiveWheel'}; 

allRegiIdxs = regi.getRegiIdxs(mN,xD,tN,NPl);

%% show a couple example ROIs to show they're recovered across days
allPics{1}  = cropROIs(mN,xD{1},tN{1},NPl, 'normstd', 5);
regiPics{1} = allPics{1}(allRegiIdxs(:,1));
allPics{2}  = cropROIs(mN,xD{2},tN{2},NPl, 'normstd', 5);
regiPics{2} = allPics{2}(allRegiIdxs(:,2));

for dd = 1:length(xD)
    NTasks = length(tN{dd});
    TMIdx(dd) = find(strcmp(tN{dd}, 'TM'));
    SWIdx(dd) = find(strcmp(tN{dd}, 'SW'));

    var = load(fullfile(dataDir, sprintf('%s_%s.mat', mN, xD{dd}))); % load "session" struct
    for tsk = [TMIdx(dd) SWIdx(dd)]
        session{dd}{tsk} = var.session{tsk};
    end

    filtTM{dd} = my_conv2(catPlanesToSize(session{dd}{TMIdx(dd)}.spData), 10,2);
    filtSW{dd} = my_conv2(catPlanesToSize(session{dd}{SWIdx(dd)}.spData), 10,2);
    regiTM{dd} = filtTM{dd}(allRegiIdxs(:,dd),:);
    regiSW{dd} = filtSW{dd}(allRegiIdxs(:,dd),:);
end
allFour = [regiTM{1} regiTM{2} regiSW{1} regiSW{2}];
yMax    = prctile(allFour, 99.9)+10;

%example neurons used in manuscript
exampleTM = 25
exampleSW = 8

%% TM example, both tasks and days (4 total traces)
for dd = 1:2
    figure('Position', [680 948 185 30])
    plot(regiTM{dd}(exampleTM, :), 'Color', 0.5*ones(1,3), 'linewidth', 0.3)    
    axis tight off; 
    ylim([0 70]); 
    
    figure('Position', [680 948 185 30])
    plot(regiSW{dd}(exampleTM, :), 'Color', 0.5*ones(1,3), 'linewidth', 0.3);
    axis tight off;
    ylim([0 70]); 
end

%% SW example, both tasks and days (4 total traces)
for dd = 1:2
    figure('Position', [680 948 185 30])
    plot(regiTM{dd}(exampleSW, :), 'Color', 0.5*ones(1,3), 'linewidth', 0.3)    
    axis tight off; 
    ylim([0 333]); 
    figure('Position', [680 948 185 30])
    plot(regiSW{dd}(exampleSW, :), 'Color', 0.5*ones(1,3), 'linewidth', 0.3);
    axis tight off;
    ylim([0 333]); 
end

%%

figure('Position', [1554 889 120 31])
imagesc(regiPics{1}{exampleTM});
caxis([-5 5])
axis image tight off; colormap gray;

figure('Position', [1554 889 120 31])
imagesc(regiPics{2}{exampleTM});
caxis([-5 5])
axis image tight off; colormap gray;

figure('Position', [1554 889 120 31])
imagesc(regiPics{1}{exampleSW});
caxis([-5 5])
axis image tight off; colormap gray;

figure('Position', [1554 889 120 31])
imagesc(regiPics{2}{exampleSW});
caxis([-5 5])
axis image tight off; colormap gray;
