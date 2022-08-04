%writ 2021-06-17
baseDir = load_paper_dirs;

ii = 0;
mN 		= 'JL035';
NPl     = 2;

ii = ii + 1;
xD{ii}     = '2019-06-25';
tN{ii}     = {'SW', 'blankwheel', 'TM', 'blankball', 'passiveBall'}; 

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

figure('Position', [680 300 300 200])
imagesc(corr([allDBTM allDBSW], 'type', 'spearman'))
axis image
colormap(redblue)
caxis([-1 1])
xticks(1:4)
yticks(1:4)
colorbar
xticklabels({'TM(1)', 'TM(2)', 'SW(1)', 'SW(2)'}) %day 1 and 2
yticklabels({'TM(1)', 'TM(2)', 'SW(1)', 'SW(2)'})

