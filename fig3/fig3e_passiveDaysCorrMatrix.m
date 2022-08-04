%taken 2021-06-24 from 11_controls/regi4condsmat
baseDir = 'E:\OneDrive - University College London\04_Data\';
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
    BWIdx   = find(strcmp(tN{dd}, 'blankwheel'));
    BBIdx   = find(strcmp(tN{dd}, 'blankball'));
    allDBBB(:,dd) = allDB{dd}{BBIdx}(allRegiIdxs(:,dd));
    allDBBW(:,dd) = allDB{dd}{BWIdx}(allRegiIdxs(:,dd));
end

figure('Position', [680 295 300 250])
imagesc(corr([allDBTM allDBBB allDBSW allDBBW], 'type', 'spearman'))
axis image
colormap(redblue)
caxis([-1 1])
xticklabels({'TM(1)', 'TM(2)', 'BB(1)', 'BB(2)', 'SW(1)', 'SW(2)', 'BW(1)', 'BW(2)'}) %day 1 or 2
yticklabels({'TM(1)', 'TM(2)', 'BB(1)', 'BB(2)', 'SW(1)', 'SW(2)', 'BW(1)', 'BW(2)'})

