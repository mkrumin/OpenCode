%taken from 11/mainPassiveBoxPlot 2020-11-12

xpdb = load_session_list();
r = NaN(length(xpdb),4);
p = NaN(length(xpdb),4);
for xp = 1:length(xpdb)
    mName       = xpdb{xp}.mName;
    expDate     = xpdb{xp}.expDate;
    taskName    = xpdb{xp}.taskName;
    NPlanes     = xpdb{xp}.NPlanes;

    allDB   = calcIsolationDist(mName,expDate,taskName, NPlanes);

    TMIdx   = find(strcmp(taskName, 'TM'));
    SWIdx   = find(strcmp(taskName, 'SW'));

    BBIdx   = find(strcmp(taskName, 'blankball'));
    BWIdx   = find(strcmp(taskName, 'blankwheel'));

    if ~isempty(TMIdx) & ~isempty(SWIdx)
        if ~isempty(BBIdx) & ~isempty(BWIdx)
            [r(xp,1),p(xp,1)] = corr(allDB{TMIdx}, allDB{BBIdx}, 'type', 'spearman');
            [r(xp,2),p(xp,2)] = corr(allDB{TMIdx}, allDB{BWIdx}, 'type', 'spearman');
            [r(xp,3),p(xp,3)] = corr(allDB{SWIdx}, allDB{BWIdx}, 'type', 'spearman');
            [r(xp,4),p(xp,4)] = corr(allDB{SWIdx}, allDB{BBIdx}, 'type', 'spearman');
        end
    end
end

[pAnov,~,st] = anova1(r);
foo=multcompare(st)
pMult = foo(:,6); %pvals

figure('Position', [743 300 500 300])
for ii = 1:4
    plot(ii,r(:,ii), 'o', 'color', 0.5*ones(1,3), 'markersize', 5)
    hold on
    plot(ii,r(p(:,ii)<0.05, ii), ...
        'ko-', 'markerfacecolor', 0.5*ones(1,3), 'markersize', 5, 'linewidth', 0.05)
end
xlim([0.5 4.5])
xticks(1:4)
xticklabels({'TM treadmill', 'TM wheel', 'SW wheel', 'SW treadmill'})
xtickangle(45)
ylabel('correlation of activity')
box off;
ylim([-1.2 1.2])
hold on; plot(xlim, [0 0], 'k--')
plot(xlim, [0 0], 'k--', 'linewidth', 0.75)
set(gca, 'fontsize', 10, 'linewidth', 0.5)
