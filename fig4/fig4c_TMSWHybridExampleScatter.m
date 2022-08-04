mName 			= 'JL022';
expDate 		= '2018-06-16';
taskName        = {'STM', 'SW', 'blankwheel', 'scrambledSTMreplaywheel', 'TM', 'blankball'}; 
NPlanes         = 2;

TMIdx   = find(strcmp(taskName, 'TM'));
SWIdx   = find(strcmp(taskName, 'SW'));
STMIdx  = find(strcmp(taskName, 'STM')); %hybrid
allDB   = calcIsolationDist(mName,expDate,taskName, NPlanes);

[r,p] = corr(allDB{SWIdx}, allDB{STMIdx}, 'rows', 'complete', 'type', 'spearman')
[r,p] = corr(allDB{TMIdx}, allDB{STMIdx}, 'rows', 'complete', 'type', 'spearman')

figure('Position', [744 500 350 200])
subplot(1,2,1)
scatter(allDB{SWIdx}, allDB{STMIdx}, 5, ones(1,3)*0.8, 'filled', 'markeredgecolor', 'k', 'linewidth', 0.1)
axis square
axis([-0.2 4.5 -0.2 4.5])
set(gca, 'FontSize', 8, 'linewidth', 0.5)
xlabel('SW activity')
ylabel('STM activity')
xticks(0:4)
yticks(0:4)
subplot(1,2,2)
scatter(allDB{TMIdx}, allDB{STMIdx}, 5, ones(1,3)*0.8, 'filled', 'markeredgecolor', 'k', 'linewidth', 0.1)
axis square
axis([-0.2 4.5 -0.2 4.5])
set(gca, 'FontSize', 8, 'linewidth', 0.5)
xlabel('TM activity')
xticks(0:4)
yticks('')
