%brought from +regi/allScatterRegiIsoDist.m 2020-11-11
%edited 2020-12-06
%edited 2020-12-17

regi.regi_xp_db_prs;
NPairs = length(mName);
pvmultTM = NaN(NPairs,1);
pvmultSW = NaN(NPairs,1);

TMSW = NaN(NPairs,1);
TMTM = NaN(NPairs,1);
SWTM = NaN(NPairs,1);
SWSW = NaN(NPairs,1);

varTMSW = NaN(NPairs,1);
varTMTM = NaN(NPairs,1);
varSWTM = NaN(NPairs,1);
varSWSW = NaN(NPairs,1);

for pr = 1:NPairs
    try
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
            allSI(:,dd)     = (allDBTM(:,dd)-allDBSW(:,dd))./...
                              (allDBTM(:,dd)+allDBSW(:,dd));
        end
        [rSI(pr),pSI(pr)] = corr(allSI(:,1), allSI(:,2), ...
                            'rows', 'complete', 'type', 'spearman')

        [rTMTM(pr),pTMTM(pr)] = corr(allDBTM(:,1), allDBTM(:,2), ...            
            'Type', 'Spearman', 'Rows', 'complete');
        %SWSW; r=0.77
        [rSWSW(pr),pSWSW(pr)] = corr(allDBSW(:,1), allDBSW(:,2), ...            
                'Type', 'Spearman', 'Rows', 'complete');
        %SWTM; r=-0.27, p = 0.045
        [rSWTM(pr),pSWTM(pr)] = corr(allDBSW(:,1), allDBTM(:,2), ...
                'Type', 'Spearman', 'Rows', 'complete');
        %TMSW; r=NS
        [rTMSW(pr),pTMSW(pr)] = corr(allDBTM(:,1), allDBSW(:,2), ...
                'Type', 'Spearman', 'Rows', 'complete');

        varSWSW(pr) = vartest2(allDBTM(:,1), allDBTM(:,2)); 
        varTMTM(pr) = vartest2(allDBSW(:,1), allDBSW(:,2)); 
        varSWTM(pr) = vartest2(allDBSW(:,1), allDBTM(:,2)); 
        varTMSW(pr) = vartest2(allDBTM(:,1), allDBSW(:,2)); 

        clear allDBTM allDBSW allDB
    catch ME
        disp(sprintf('error, skipping pair %s %s %s', mN,xD{1},xD{2}))
        warning(ME.message)
    end
end

%% average SWTM and TMSW
avAcross = nanmean([TMSW(:) SWTM(:)],2);
allConds = {rTMTM(:), [rTMSW(:);rSWTM(:)], rSWSW(:)};
allPV = {pTMTM(:), [pTMSW(:);pSWTM(:)], pSWSW(:)};

hTM = NaN
hSW = NaN
[hTM,pTM]=ttest2(rTMTM, rTMSW)
[hSW,pSW]=ttest2(rSWSW, rSWTM)

%v2 
allConds2   = {rTMTM(:), rTMSW(:), rSWSW(:), rSWTM(:)};
allPV2      = {pTMTM(:), pTMSW(:),pSWSW(:), pSWTM(:)};

%fig opts
sz  = 12; %of scatter points
jtr = 0.2; %amount to jitter horizontaqlly
exampPairIdx = 4 
nonExampIdxs=setdiff([1:NPairs], exampPairIdx);

figure('Position', [680 300 350 200])
%% plot exampl as diamond?
NComps = 4;
for ii = 1:NComps %4 conditions
    nonExampNonSignifPoints = allConds2{ii}(nonExampIdxs);
    nonExampNonSignifPoints = nonExampNonSignifPoints(allPV2{ii}(nonExampIdxs) >=0.05);
    scatter(ii*ones(1,numel(nonExampNonSignifPoints)), nonExampNonSignifPoints, ...
        sz, 0.5*ones(1,3), 'filled', 'markeredgecolor', 'k',...
        'jitter', 'on', 'jitteramount', jtr, 'linewidth', 0.1)
    nonExampSignifPoints = allConds2{ii}(nonExampIdxs);
    nonExampSignifPoints = nonExampSignifPoints(allPV2{ii}(nonExampIdxs) <0.05);
    scatter(ii*ones(1,numel(nonExampSignifPoints)), nonExampSignifPoints, ...
        sz, 0.5*ones(1,3), 'filled', 'markeredgecolor', 'k',...
        'jitter', 'on', 'jitteramount', jtr, 'linewidth', 0.1)
    exampNonSignifPoint = allConds2{ii}(exampPairIdx);
    exampNonSignifPoint = exampNonSignifPoint(allPV2{ii}(exampPairIdx) >=0.05);
    exampSignifPoint = allConds2{ii}(exampPairIdx);
    exampSignifPoint = exampSignifPoint(allPV2{ii}(exampPairIdx) <0.05);
    if ~isempty(exampNonSignifPoint)
        scatter(ii,exampNonSignifPoint,sz, 'd', 'k',...
            'jitter', 'on', 'jitteramount', jtr, 'linewidth', 0.2)
    end
    if ~isempty(exampSignifPoint)
        hold on
        scatter(ii, exampSignifPoint, ...
            sz, 'd', 'markerfacecolor', 0.8*ones(1,3), 'markeredgecolor', 'k',...
            'jitter', 'on', 'jitteramount', jtr, 'linewidth', 0.2)
    end
end
xlim([0.5 4.5])
xticks('')
%xtickangle(45)
ylabel('correlation of activity')
box off;
ylim([-1.2 1.2])
%significance asterisks
if hTM 
    plot(1.5, 1.1, 'k*', 'markersize', 7)
end
if hSW
    plot(3.5, 1.1, 'k*', 'markersize', 7)
end
set(gca, 'fontsize', 10, 'linewidth', 0.5)
