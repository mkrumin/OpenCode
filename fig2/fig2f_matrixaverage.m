%writ 2021-06-17

regi.regi_xp_db_prs;
NPairs = length(mName);
corrMat = NaN(4,4,NPairs);
for pr = 1:NPairs
    mN  = mName{pr};
    xD  = expDates{pr};
    tN  = taskName{pr};
    NPl = NPlanes{pr};

    allRegiIdxs = regi.getRegiIdxs(mN,xD,tN,NPl);
    allSI = [];
    allDBTM = [];
    allDBSW = [];
    for dd = 1:2
        allDB{dd}   = calcIsolationDist(mN,xD{dd},tN{dd}, NPl);
        TMIdx = find(strcmp(tN{dd}, 'TM'));
        SWIdx = find(strcmp(tN{dd}, 'SW'));
        allDBTM(:,dd)   = allDB{dd}{TMIdx}(allRegiIdxs(:,dd));
        allDBSW(:,dd)   = allDB{dd}{SWIdx}(allRegiIdxs(:,dd));
    end
    corrMat(:,:,pr) = corr([allDBTM allDBSW]);
end

figure('Position', [680 853 206 113])
imagesc(mean(corrMat, 3))
axis image
colormap(redblue)
caxis([-1 1])
xticks(1:4)
yticks(1:4)

xticklabels({'TM(1)', 'TM(2)', 'SW(1)', 'SW(2)'}) %day 1 and 2
yticklabels({'TM(1)', 'TM(2)', 'SW(1)', 'SW(2)'})
