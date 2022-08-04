function [allPics,allRelativeCtrs] = cropROIs(mName,expDate,taskName,NPlanes,...
        imageType, padding)

baseDir = load_paper_dirs;

%baseDir = 'C:\...' %change to your working directory which holds the OpenData and OpenCode folders

dataDir = fullfile(baseDir, 'OpenData', 'PrecomputedData');

if nargin < 7
    padding = 10
    if nargin < 6
        imageType = 'normmean'
    end
end

if NPlanes > 1
    validPlanes = [1:NPlanes]+1;
else
    validPlanes     = 1;
end
NValidPlanes    = length(validPlanes);
for pl = 1:NValidPlanes
    fDataFname = fullfile(dataDir, sprintf('F_%s_%s_plane%d_proc.mat', mName, expDate, validPlanes(pl)));

    load(fDataFname);
    roiStat = dat.stat;
    switch imageType
        case 'normmean'
            meanImg = normalize_image(dat.ops.mimg(dat.ops.yrange,dat.ops.xrange));
        case 'normstd'
            meanImg = normalize_image(dat.ops.sdmov);
        case 'mean'
            meanImg = dat.ops.mimg(dat.ops.yrange,dat.ops.xrange);
        case 'std'
            meanImg = dat.ops.sdmov;
    end

    centroids_xy = s2p_rois2centroids(dat); 
    [roiImgs,relativeROICentroids] = cropCellsMimg(meanImg, roiStat,padding) ;

    cellImgs{pl}            = roiImgs(logical([dat.stat.iscell]));
    relativeCentroids{pl}   = relativeROICentroids(logical([dat.stat.iscell]),:);

end

allPics         = horzcat(cellImgs{:});
allRelativeCtrs = cat(1,relativeCentroids{:});

%max projection instead?
