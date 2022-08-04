
mName 			= 'JL035';
expDate 		= '2019-06-15';
taskName        = {'TM', 'blankball', 'SW', 'blankwheel'}; 
NPlanes         = 2;

NTasks = length(taskName);

baseDir = load_paper_dirs;

%baseDir = 'C:\...' %change to your working directory which holds the OpenData and OpenCode folders

dataDir = fullfile(baseDir, 'OpenData', 'NeuralBehavioral');

TMIdx = find(strcmp(taskName, 'TM'));
SWIdx = find(strcmp(taskName, 'SW'));
BWIdx = find(strcmp(taskName, 'blankwheel'));
BBIdx = find(strcmp(taskName, 'blankball'));

allDB       = calcIsolationDist(mName,expDate,taskName, NPlanes);

[r(1),p(1)] = corr(allDB{TMIdx}, allDB{BBIdx}, 'type', 'spearman')
[r(2),p(2)] = corr(allDB{TMIdx}, allDB{BWIdx}, 'type', 'spearman')
[r(3),p(3)] = corr(allDB{SWIdx}, allDB{BWIdx}, 'type', 'spearman')
[r(4),p(4)] = corr(allDB{SWIdx}, allDB{BBIdx}, 'type', 'spearman')

prs = [SWIdx,BBIdx;...
       TMIdx,BBIdx;
       SWIdx,BWIdx;
       TMIdx,BWIdx];

fontsize = 10;

figure('Position', [680 300 350 350])
subplot(2,2,1)
%plot([0 5], [0 5], 'k--', 'linewidth', 0.5); hold on
scatter(allDB{TMIdx}, allDB{BBIdx}, ...
    8, ones(1,3)*0.8, 'filled', 'markeredgecolor', 'k', 'linewidth', 0.1)
axis square; axis([-0.2 4.5 -0.2 4.5]); hold on; box off 
ylabel('passive treadmill')
set(gca, 'fontsize', fontsize, 'linewidth', 0.5); yticks(0:2:5); xticks('');

subplot(2,2,2)
%plot([0 5], [0 5], 'k--', 'linewidth', 0.5); hold on
scatter(allDB{SWIdx}, allDB{BWIdx}, ...
    8, ones(1,3)*0.8, 'filled', 'markeredgecolor', 'k', 'linewidth', 0.1)
axis square; axis([-0.2 4.5 -0.2 4.5]); hold on; box off 
set(gca, 'fontsize', fontsize, 'linewidth', 0.5); yticks(''); xticks('');

subplot(2,2,3)
%plot([0 5], [0 5], 'k--', 'linewidth', 0.5); hold on
scatter(allDB{TMIdx}, allDB{BWIdx}, ...
    8, ones(1,3)*0.8, 'filled', 'markeredgecolor', 'k', 'linewidth', 0.1)
axis square; axis([-0.2 4.5 -0.2 4.5]); hold on; box off 
xlabel('T-maze activity')
ylabel('passive wheel')
set(gca, 'fontsize', fontsize, 'linewidth', 0.5); yticks(0:2:5); xticks(0:2:5); 

subplot(2,2,4)
%plot([0 5], [0 5], 'k--', 'linewidth', 0.5); hold on
scatter(allDB{SWIdx}, allDB{BBIdx}, ...
    8, ones(1,3)*0.8, 'filled', 'markeredgecolor', 'k', 'linewidth', 0.1)
axis square; axis([-0.2 4.5 -0.2 4.5]); hold on; box off 
xlabel('SW task activity')
set(gca, 'fontsize', fontsize, 'linewidth', 0.5); yticks(''); xticks(0:2:5); 
