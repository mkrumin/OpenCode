
xpdb = STM_xp_db; %database of hybrid task experimental sessions

rSWSTM  = NaN(length(xpdb),1);
pSWSTM  = NaN(length(xpdb),1);
rSWTM   = NaN(length(xpdb),1);
pSWTM   = NaN(length(xpdb),1);
rTMSTM  = NaN(length(xpdb),1);
pTMSTM  = NaN(length(xpdb),1);

for xp = 1:length(xpdb)
    mName       = xpdb{xp}.mName;
    expDate     = xpdb{xp}.expDate;
    taskName    = xpdb{xp}.taskName;
    NPlanes     = xpdb{xp}.NPlanes;

    TMIdx   = find(strcmp(taskName, 'TM'));
    SWIdx   = find(strcmp(taskName, 'SW'));
    STMIdx  = find(strcmp(taskName, 'STM'));
    allDB   = calcIsolationDist(mName,expDate,taskName, NPlanes);

    if ~isempty(STMIdx) & ~isempty(SWIdx)
        [rSWSTM(xp),pSWSTM(xp)] = corr(allDB{STMIdx}, allDB{SWIdx},'type', 'spearman')
    else
        rSWSTM(xp) = NaN;
        pSWSTM(xp) = NaN;
    end

    if ~isempty(TMIdx) & ~isempty(SWIdx)
        [rSWTM(xp),pSWTM(xp)]   = corr(allDB{TMIdx}, allDB{SWIdx},'type', 'spearman')
    else
        rSWTM(xp) = NaN;
        pSWTM(xp) = NaN;
    end

    if ~isempty(TMIdx) & ~isempty(STMIdx)
        [rTMSTM(xp),pTMSTM(xp)] = corr(allDB{TMIdx}, allDB{STMIdx},'type', 'spearman')
    else
        rTMSTM(xp) = NaN;
        pTMSTM(xp) = NaN;
    end
end

sz = 7; %of scatter point
jtr = 0.1; %amount to jitter horizontaqlly
figure('Position', [680 399 300 150])
scatter(ones(size(rSWSTM)), rSWSTM, sz, 'k', ...
    'jitter', 'on', 'jitteramount', jtr, 'linewidth', 0.05)
hold on
scatter(2*ones(size(rSWTM)), rSWTM, sz, 'k', ...
    'jitter', 'on', 'jitteramount', jtr, 'linewidth', 0.05)
scatter(3*ones(size(rTMSTM)), rTMSTM, sz, 'k', ...
    'jitter', 'on', 'jitteramount', jtr, 'linewidth', 0.05)
scatter(ones(size(rSWSTM(pSWSTM<0.05))),rSWSTM(pSWSTM<0.05),...
    sz, 0.5*ones(1,3), 'filled', 'markeredgecolor', 'k',...
    'jitter', 'on', 'jitteramount', jtr, 'linewidth', 0.05)
scatter(2*ones(size(rSWTM(pSWTM<0.05))),rSWTM(pSWTM<0.05),...
    sz, 0.5*ones(1,3), 'filled', 'markeredgecolor', 'k',...
    'jitter', 'on', 'jitteramount', jtr, 'linewidth', 0.05)
scatter(3*ones(size(rTMSTM(pTMSTM<0.05))),rTMSTM(pTMSTM<0.05),...
    sz, 0.5*ones(1,3), 'filled', 'markeredgecolor', 'k',...
    'jitter', 'on', 'jitteramount', jtr, 'linewidth', 0.05)
box off;
xlim([0.5 3.5])
xticks(1:3)
ylim([-1.2 1.2])
hold on; plot(xlim, [0 0], 'k--')
xticklabels({'SW/STM', 'SW/TM', 'TM/STM'})
ylabel('correlation of activity')
hold on; plot(xlim, [0 0], 'k--')
plot(xlim, [0 0], 'k--', 'linewidth', 0.75)
set(gca, 'fontsize', 8, 'linewidth', 0.5)

%% group comparison using one-way ANOVA
%concatenate non nans
SWSTM   = rSWSTM(~isnan(rSWSTM));
SWTM    = rSWTM(~isnan(rSWTM));
TMSTM   = rTMSTM(~isnan(rTMSTM));

numel(SWSTM)
numel(SWTM)
numel(TMSTM)

flatCorrs   = [SWSTM(:);SWTM(:);TMSTM(:)];
grp         = [ones(numel(SWSTM),1); ...
                2*ones(numel(SWTM),1); ...
                3*ones(numel(TMSTM),1)]

[~,~,stats] = anova1(flatCorrs, grp)

multcompare(stats)
