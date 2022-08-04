%uses isolation distance function described in Stringer & Pachitariu (2019) to compute 
%"distance" between each neuron and its corresponding surrounding neuropil
%% NOTE: this function requires the raw binaries of each acquisition, which are too large to upload
%% therefore, the pre-computed isolation distances are saved in this directory
%% these functions are included for reference to show how these measures were obtained

%DB = bhattacharyya distance
%allDsc = Mahalanobis distance
function allDB = calcIsolationDist(mName,expDate,taskName, NPlanes)

    baseDir = load_paper_dirs;

    %baseDir = 'C:\...' %change to your working directory which holds the OpenData and OpenCode folders

    dataDir = fullfile(baseDir, 'OpenData', 'PrecomputedData');

    FN = fullfile(dataDir, sprintf('isolationdists_%s_%s.mat', mName,expDate));

    if false %~exist(FN, 'file')
        % provided for ref
        TMIdx = find(strcmp(taskName, 'TM'));
        SWIdx = find(strcmp(taskName, 'SW'));
        for pl = 1:NPlanes
            if NPlanes>1
                [currExp{pl},dat]   = getRawMovData(mName,expDate,pl+1); %needs raw binary
            elseif NPlanes == 1
                [currExp{pl},dat]   = getRawMovData(mName,expDate,pl); %needs raw binary
            end
            [DB{pl},allDsc{pl}] = isolationdist(currExp{pl}, dat); 

            NTasks = length(DB{pl});
            for tsk = 1:NTasks
                tskDB{tsk}{pl} = DB{pl}{tsk}(logical([dat.stat.iscell]))';
            end
        end

        for tsk = 1:NTasks
            allDB{tsk}  = vertcat(tskDB{tsk}{:});
        end

        save(FN, 'allDB')
    else
        load(FN, 'allDB')
    end
