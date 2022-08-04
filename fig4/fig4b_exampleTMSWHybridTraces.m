
baseDir = 'E:\OneDrive - University College London\04_Data\'

%baseDir = 'C:\...' %change to your working directory which holds the OpenData and OpenCode folders

dataDir = fullfile(baseDir, 'OpenData', 'NeuralBehavioral');

mName 			= 'JL022';
expDate 		= '2018-06-16';
taskName        = {'STM', 'SW', 'blankwheel', 'scrambledSTMreplaywheel', 'TM', 'blankball'}; 
NPlanes         = 2;

STMIdx  = find(strcmp(taskName, 'STM'));
TMIdx   = find(strcmp(taskName, 'TM'));
SWIdx   = find(strcmp(taskName, 'SW'));

Fs = 10;
convSize = 1;
convGauss       = gausswin(Fs*convSize); 
convGauss       = convGauss./sum(convGauss); %normalise

load(fullfile(dataDir, sprintf('%s_%s.mat', mName, expDate))) % load "session" struct

NTasks = length(taskName);
for tsk = [STMIdx TMIdx SWIdx]
    spData{tsk}     = catPlanesToSize(session{tsk}.spData);
    eachF{tsk}      = conv2(1, convGauss, spData{tsk}, 'same'); 
end

entireMax = max(reshape([spData{TMIdx} spData{STMIdx} spData{SWIdx}], 1, []));
normSp{STMIdx}  = eachF{STMIdx}./entireMax;
normSp{TMIdx}   = eachF{TMIdx}./entireMax;
normSp{SWIdx}   = eachF{SWIdx}./entireMax;

cells = [1 9 43]; %three example neurons
for ii = 1:3
    ci = cells(ii);
    figure('Position', [143 500 800 70])
    subplot(1,3,1)
    plot(normSp{TMIdx}(ci,:), 'color', 'k')
    axis tight off; ylim([0 0.2]); 
    subplot(1,3,2)
    plot(normSp{STMIdx}(ci,:), 'color', 'k')
    axis tight off; ylim([0 0.2]);
    subplot(1,3,3)
    plot(normSp{SWIdx}(ci,:), 'color', 'k')
    axis tight off; ylim([0 0.2]); 
end
