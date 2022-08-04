%written 2019-09-29
%very similar to catRegiIdxs but doesn't assume session as an input 

%returns NDays x NCells matrix for indexing

function [allRegiIdxs,session] = getRegiIdxs(mName,expDates,taskNames,NPlanes)

baseDir = 'E:\OneDrive - University College London\04_Data\'

%baseDir = 'C:\...' %change to your working directory which holds the OpenData and OpenCode folders

dataDir = fullfile(baseDir, 'OpenData', 'NeuralBehavioral');

NDays = length(expDates);
for dd = 1:NDays
    NTasks = length(taskNames{dd});
    var = load(fullfile(dataDir, sprintf('%s_%s.mat', mName, expDates{dd}))); % load "session" struct
    for tsk = 1:NTasks
        session{dd}{tsk} = var.session{tsk};
    end
end

for dd = 1:NDays
    cumulNeuronsPlane(dd,:) = cumsum([0 cell2mat(cellfun(@(x) size(x,1), session{dd}{1}.fData, 'UniformOutput', 0))])+1;
end

%load regi
for pl = 1:NPlanes
    plRegis{pl} = load(fullfile(baseDir, 'OpenData', 'PreComputedData', ...
                    sprintf('%s_%s_plane%d_%s_%s_plane%d_reg.mat', ...
                        mName, expDates{1}, pl+1, mName, expDates{2}, pl+1)), 'regi');
end

regiIdxs = cell(NDays,1);
%concatenate all registered over planes 
for dd=1:NDays
    for pl = 1:NPlanes
        regiIdxs{dd} = vertcat(regiIdxs{dd}, ...
            plRegis{pl}.regi.rois.iscell_idcs(:,dd)+cumulNeuronsPlane(dd,pl)-1);%*
        %for every plane, add the "previous" plane's number of neurons (0 for the first plane)
    end
end

allRegiIdxs = horzcat(regiIdxs{:});
