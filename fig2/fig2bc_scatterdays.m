% same example sessions as other panels
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

[r(1),p(1)]=corr(allDBTM(:,1), allDBTM(:,2), 'type', 'spearman')
[r(2),p(2)]=corr(allDBTM(:,1), allDBSW(:,2), 'type', 'spearman')
[r(3),p(3)]=corr(allDBSW(:,1), allDBSW(:,2), 'type', 'spearman')
[r(4),p(4)]=corr(allDBSW(:,1), allDBTM(:,2), 'type', 'spearman')

fprintf('%d cells\n', length(allDBTM)) %N=56 cells only..

plotgap = [0.1 0.2]
marg_h = [0.1 0.03]
marg_w = [0.1 0.02]

figure('Position', [680 50 280 250])
subtightplot(2,2,1, plotgap, marg_h, marg_w)
scatter(allDBTM(:,1), allDBTM(:,2), ...
    3.5, 0.8*ones(1,3),'filled', 'MarkerEdgeColor', 'k','linewidth', 0.1)
axis square
axis([-0.2 4.5 -0.2 4.5])
hold on;
box off
%xlabel('TM activity'); 
ylabel('TM activity (day n+1)')
%title(sprintf('r=%2.2f p=%2.2f', rTMTM,pTMTM))
set(gca, 'fontsize', 6, 'linewidth', 0.75, 'DefaultAxesFontName','Arial')
xticks(0:2:5)
yticks(0:2:5)

subtightplot(2,2,2, plotgap, marg_h, marg_w)
scatter(allDBSW(:,1), allDBSW(:,2), ...
    3.5, 0.8*ones(1,3),'filled', 'MarkerEdgeColor', 'k','linewidth', 0.1)
axis square
axis([-0.2 4.5 -0.2 4.5])
hold on;
box off
%xlabel('SW activity'); 
ylabel('SW activity (day n+1)')
%title(sprintf('r=%2.2f p=%2.2f', rSWSW,pSWSW))
set(gca, 'fontsize', 6, 'linewidth', 0.75, 'DefaultAxesFontName','Arial')
xticks(0:2:5)
yticks(0:2:5)

subtightplot(2,2,3, plotgap, marg_h, marg_w)
scatter(allDBTM(:,1), allDBSW(:,2), ...
    3.5, 0.8*ones(1,3),'filled', 'MarkerEdgeColor', 'k','linewidth', 0.1)
axis square
axis([-0.2 4.5 -0.2 4.5])
hold on;
box off
xlabel('TM activity (day n)'); 
ylabel('SW activity (day n+1)')
%title(sprintf('r=%2.2f p=%2.2f', rSWTM,pSWTM))
set(gca, 'fontsize', 6, 'linewidth', 0.75, 'DefaultAxesFontName','Arial')
xticks(0:2:5)
yticks(0:2:5)

subtightplot(2,2,4, plotgap, marg_h, marg_w)
scatter(allDBSW(:,1), allDBTM(:,2), ...
    3.5, 0.8*ones(1,3),'filled', 'MarkerEdgeColor', 'k','linewidth', 0.1)
axis square
axis([-0.2 4.5 -0.2 4.5])
hold on;
box off
xlabel('SW activity (day n)'); 
ylabel('TM activity (day n+1)')
%title(sprintf('r=%2.2f p=%2.2f', rTMSW,pTMSW))
set(gca, 'fontsize', 6, 'linewidth', 0.75, 'DefaultAxesFontName','Arial')
xticks(0:2:5)
yticks(0:2:5)



