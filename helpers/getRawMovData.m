% this function was originally written by Carsen Stringer 
% adapted by Julie J Lee to cut movies into individual experimental acquisitions

function [currExp,dat] = getRawMovData(mName,expDate,pl)

% this function is provided for reference only
% it requires the raw "proc" files outputed by suite2p and 
% the raw binaries of the 2p TIFF movies, which are too large to upload
% the purpose of this function is to read the 2p movies and split by each task condition
error('this function is provided for reference only')

%load "proc" file from suite2p for parameters 
load(sprintf('F_%s_%s_plane%d_proc', mName,expDate,pl))

ops = dat.ops;
stat=dat.stat;
if ~isfield(stat, 'radius')
    error('missing radius')
end
Ly = numel(dat.ops.yrange);
Lx = numel(dat.ops.xrange);
ix = 0;
fid = fopen(ops.RegFile, 'r');

frewind(fid);
tbin = 12; %bin raw binary file

mov = zeros(Ly, Lx, ceil(sum(ops.Nframes)/tbin), 'single');
xp = 1;

NFrEaExp = cell2mat(cellfun(@(x) size(x,2), dat.Fcell, 'UniformOutput', 0)); %JL

nimgbatch = min(7488,NFrEaExp(xp)); 

ncumulframes = 0; doNextExp = 0;
while 1
    if nimgbatch < 0
        nimgbatch = NFrEaExp(xp);
    end
    if nimgbatch == NFrEaExp(xp)
        doNextExp = 1;
    end
    % load frames
    nimgbatch

    %read raw binary file (a certain number of bytes in a batch)
    data = fread(fid,  ops.Ly*ops.Lx*nimgbatch, '*int16'); 

    numel(data)
    if isempty(data)
        break;
    end
    data = single(data);
    data = reshape(data, ops.Ly, ops.Lx, []);
    data = data(ops.yrange, ops.xrange, :);

    nt = size(data,3)

    %reshape data into [ypix xpix nframeseachbin nframes] then average over each bin of tbin frames
    data = squeeze(mean(reshape(data(:,:,1:floor(nt/tbin)*tbin), Ly, Lx, tbin, floor(nt/tbin)),3));

    mov(:,:, ix + (1:size(data,3))) = data;

    ix = ix + size(data,3);

    if doNextExp == 1 

        mov = mov(:, :, 1:ix);
        try
            size(mov,3)
            ops.Nframes(xp)/tbin
            assert(abs(size(mov,3)-(ops.Nframes(xp)/tbin)) < 20) 
        catch
            abs(size(mov,3)-(ops.Nframes(xp)/tbin))
            keyboard 
        end
        
        mov = reshape(mov,[],size(mov,3));

        currExp{xp} = mov;
        %reset donextexp!!!
        doNextExp = 0; ncumulframes = 0; nt = 0;

        xp = xp+1;
        mov = []; data = [];
        ix = 0;
        if xp > numel(NFrEaExp)%numel tasks
            
            break;
        end
        nimgbatch = min(7488,NFrEaExp(xp)*2);
        % because int16, every value is represented by *two bytes* so, need to read two at once

    end

    ncumulframes = ncumulframes + nt;
    if (ncumulframes+nimgbatch > NFrEaExp(xp))
        %if the next batch of frames would exceed that of the current exp,
        %revise the number of frames to read to be only within
        nimgbatch = NFrEaExp(xp) - ncumulframes;
        doNextExp = 1;
    end
end


fclose(fid);

ix %this should be > 0  
