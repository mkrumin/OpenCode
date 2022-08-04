%% Code to reproduce psychometric curves in Figure 1a and 1b in Lee et al. (2022)
%% takes average and mean proportions per contrast, and the average of their psycho curves

function fig1_summaryPC()
baseDir = 'E:\OneDrive - University College London\04_Data\'

%baseDir = 'C:\...' %change to your working directory which holds the OpenData and OpenCode folders

dataDir = fullfile(baseDir, 'OpenData', 'NeuralBehavioral');

taskColors  = {[0.9, 0.3 0.1],[0 0.6 0.6]};

rerunComputation = true; 

xpdb = load_session_list()

if rerunComputation == false
    load('pcdata.mat') % data is pre-saved for convenience, or re-compute it:
elseif rerunComputation == true

    pTM = NaN(length(xpdb),9); %9 = number of contrast values
    nTM = NaN(length(xpdb),9);
    pSW = NaN(length(xpdb),9);
    nSW = NaN(length(xpdb),9);
    for xp = 1:length(xpdb)
        mName       = xpdb{xp}.mName;
        expDate     = xpdb{xp}.expDate;
        taskName    = xpdb{xp}.taskName;

        load(fullfile(dataDir, sprintf('%s_%s.mat', mName, expDate)))

        TMIdx = find(strcmp(taskName, 'TM'));
        SWIdx = find(strcmp(taskName, 'SW'));

        [ccTM, ppTM, nnTM] = fig1_getPCdata(session{TMIdx});
        [ccSW, ppSW, nnSW] = fig1_getPCdata(session{SWIdx});

        pTM(xp,:) = ppTM; 
        nTM(xp,:) = nnTM;
        pSW(xp,:) = ppSW; 
        nSW(xp,:) = nnSW;
    end
end

cc = [-50 -25 -12 -6 0 6 12 25 50]; % contrast list


%%% average within subject
for xp = 1:length(xpdb)
    whichMn{xp} = xpdb{xp}.mName;
end

%% average proportion per subject (weighted by nsessions/subject)
uqNames = unique(whichMn);
for mn = 1:length(uqNames)
    whichSessions = strcmp(whichMn, uqNames{mn});

    pMnTM(mn,:) = nanmean(pTM(whichSessions,:),1);
    pMnSW(mn,:) = nanmean(pSW(whichSessions,:),1);

    nMnTM = sum(nTM(whichSessions,:), 1, 'omitnan');
    nMnSW = sum(nSW(whichSessions,:), 1, 'omitnan');

    [erfMnTM(mn,:), cAxis] = getPsychoCurve(cc,pMnTM(mn,:),nMnTM);
    [erfMnSW(mn,:), cAxis] = getPsychoCurve(cc,pMnSW(mn,:),nMnSW); %fit psychometric curve
end

pAllTM      = nanmean(pMnTM)
pAllTMSE    = nanstd(pMnTM)./sqrt(length(pMnTM));

pAllSW      = nanmean(pMnSW)
pAllSWSE    = nanstd(pMnSW)./sqrt(length(pMnSW));

figure('Position', [680 892 120 86])
for mn = 1:length(uqNames)
    plot(cAxis, erfMnTM(mn,:), 'color', ones(1,3)*0.85, 'linewidth', 0.5)
    hold on
end
plot(cAxis, nanmean(erfMnTM, 1), 'color', taskColors{1}, 'linewidth', 0.75)
errorbar(cc, pAllTM, pAllTMSE, 'o', 'color', taskColors{1}, ...
    'markerfacecolor', taskColors{1}, 'linewidth', 0.75, 'markersize', 2, 'capsize', 2 )
ylim([-0.05 1.05])
xlim([-55 50]);
xticks([-50 -25 0 25 50])
box off
yticks([0 0.5 1])
yticklabels({'0', '0.5', '1.0'})
ylabel('P(choose right)')
xlabel(sprintf('Contrast (%%)'))
set(gca, 'FontName', 'Arial', 'FontSize', 5,'linewidth',0.5,'plotboxaspectratio', [1.2 1 1])

figure('Position', [680 892 120 86])
for mn = 1:length(uqNames)
    plot(cAxis, erfMnSW(mn,:), 'color', ones(1,3)*0.85, 'linewidth', 0.5)
    hold on
end
plot(cAxis, nanmean(erfMnSW, 1), 'color', taskColors{2}, 'linewidth', 0.75)
errorbar(cc, pAllSW, pAllSWSE, 'o', 'color', taskColors{2}, ...
    'markerfacecolor', taskColors{2}, 'linewidth', 0.75, 'markersize', 2, 'capsize', 2 )
ylim([-0.05 1.05])
xlim([-55 50]);
xticks([-50 -25 0 25 50])
box off
yticks([0 0.5 1])
yticklabels({'0', '0.5', '1.0'})
ylabel('P(choose right)')
xlabel(sprintf('Contrast (%%)'))
set(gca, 'FontName', 'Arial', 'FontSize', 5,'linewidth',0.5,'plotboxaspectratio', [1.2 1 1])
end
