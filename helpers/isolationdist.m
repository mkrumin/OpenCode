% this function was originally written by Carsen Stringer 
% and adapted by Julie J Lee 

% takes cell masks and neuropil masks from the saved binaries
% and computes the PCs of their activity
% and then takes the distance in this space 

function [expDB, expDsc,un,uc] = isolationdist(varargin)

    % this function is provided for reference only
    % it requires the raw "proc" files outputed by suite2p and the output of getRawMovData
    % which in turn requires the raw binaries (too large to upload)
    error('this function is provided for reference only')

    ncomps = 1 %principal components

    tsk = [];

    if nargin == 3
        currExp = varargin{1};
        dat     = varargin{2};
        tsk     = varargin{3}
    elseif nargin == 2
        currExp = varargin{1};
        dat     = varargin{2};
    elseif nargin > 1
        [currExp,dat] = getRawMovData(mName,expDate,expNumStr,pl);
    end


if iscell(currExp{1})
    error('currExp not inputed properly, please only supply a single plane')
end

oldDir = pwd;

ops = dat.ops;
stat=dat.stat;
Ly = numel(dat.ops.yrange);
Lx = numel(dat.ops.xrange);

if isempty(tsk) 
    NTasks = length(currExp);
    whichTasks = 1:NTasks;
else
    whichTasks = tsk;
end
for xp = whichTasks 
    mov = currExp{xp};
    [~, cellPix, ~] = createCellMasks(stat, Ly, Lx);
    ops.minNeuropilPixels = 400;
    ops.ratioNeuropil = 5;
    ops.innerNeuropil = 3;

    clear neuropMasks cellMasks;
    %only dat.stat.radius is needed
    [~, neuropMasks]    = createNeuropilMasks(ops, stat, cellPix);

    [~, ~, cellMasks]   = createCellMasks(stat, Ly, Lx);

    % mov is NPix x NFrames (NPix being approx 512*512)
    flagged = zeros(1, size(cellMasks,1));
    for j = 1:size(cellMasks,1)
        ipix = (cellMasks(j,:)>0);
        F1 = mov(ipix,:) / 1e3;

        ipix = (neuropMasks(j,:)>0); 
        % compute neuropil fluorescence
        if sum(ipix)==0 
            flagged(j) = 1; 
            continue;
        else
            F1neu = mov(ipix,:) / 1e3;

            [u s v] = svdecon([F1;F1neu] - mean([F1;F1neu],2)); %npix x ntimepoints
            u = u*s;
            uc{j} = u(1:size(F1,1), 1); %each cell's "loadings" on the cell+np time trace
            un{j} = u(size(F1,1)+1:end, 1);
        end
    end


    clear DB;
    for j = 1:numel(uc)
        if flagged(j) == 1
            continue;
        else
            %d1 - cell; d2 - np surround
            d1.mu   = mean(uc{j}(:,1:ncomps),1); %just scalar 
            d1.sig  = cov(uc{j}(:,1:ncomps),1);
            d2.mu   = mean(un{j}(:,1:ncomps),1);
            d2.sig  = cov(un{j}(:,1:ncomps),1);

            sigA = (d1.sig + d2.sig)/2;
            dsc = (d1.mu - d2.mu) * (sigA)^-1 * (d1.mu - d2.mu)'; %Malahanobis

            allDsc(j) = dsc;

            %Bhattacharya distance, doesn't assume SDs are the same (CS)
            DB(j) = 1/8 * dsc + .5 * log(det(sigA) / sqrt(det(d1.sig) * det(d2.sig))); 

        end
    end

    expDB{xp}   = DB;
    expDsc{xp}  = allDsc;

    clear allDsc; clear DB
end

cd(oldDir)
