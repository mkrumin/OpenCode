%
baseDir = load_paper_dirs;
ii = 0;
mN 		= 'JL035';
NPl     = 2;

ii = ii + 1;
xD{ii}     = '2019-06-25';
tN{ii}     = {'SW', 'blankwheel', 'TM', 'blankball', 'passiiveBall'}; 

ii = ii + 1;
xD{ii}     = '2019-06-26';
tN{ii}     = {'TM', 'blankball', 'SW', 'blankwheel', 'passiveWheel'}; 

FN1 = fullfile(baseDir, 'OpenData', 'PrecomputedData', sprintf('isolationdists_%s_%s_%s.mat', mN,xD{1}));
FN2 = fullfile(baseDir, 'OpenData', 'PrecomputedData', sprintf('isolationdists_%s_%s_%s.mat', mN,xD{2}));

allRegiIdxs = regi.getRegiIdxs(mN,xD,tN,NPl);
for dd = 1:2
    allDB{dd}   = calcIsolationDist(mN,xD{dd},tN{dd}, NPl);
    TMIdx = find(strcmp(tN{dd}, 'TM'));
    SWIdx = find(strcmp(tN{dd}, 'SW'));
    allDBTM(:,dd) = allDB{dd}{TMIdx}(allRegiIdxs(:,dd));
    allDBSW(:,dd) = allDB{dd}{SWIdx}(allRegiIdxs(:,dd));
    allSI(:,dd) = (allDBTM(:,dd) - allDBSW(:,dd))./ (allDBTM(:,dd) + allDBSW(:,dd));
end

figure('Position', [680 200 300 300])
plot([-1 1], [0 0], 'k--', 'linewidth', 0.75)
hold on;
plot([0 0], [-1 1], 'k--', 'linewidth', 0.75)
scatter(allSI(:,1), allSI(:,2), ...
    10, 0.8*ones(1,3),'filled', 'MarkerEdgeColor', 'k','linewidth', 0.1)
allSI(:,dd) = (allDBTM(:,dd) - allDBSW(:,dd))./ (allDBTM(:,dd) + allDBSW(:,dd));
axis square
axis([-1 1 -1 1])
xlabel('task preference'); 
ylabel('task preference (next day)')
set(gca, 'fontsize', 10)
xticks(-1:0.5:1)
yticks(-1:0.5:1)
box off
[r,p]=corr(allSI(:,1), allSI(:,2), 'rows', 'complete')
