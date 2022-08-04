function [allCentroids, allROIPixels, plCentroids, plPixels] = getROILocations(mName,expDate,expNumStr, forceRerun)
if nargin < 4
    forceRerun = false;
end

baseDir = load_paper_dirs;
%baseDir = 'C:\...' %change to your working directory which holds the OpenData and OpenCode folders

ROILocsFname = fullfile(baseDir, 'OpenData', 'PrecomputedData', ...
                sprintf('%s_%s_roilocs.mat', mName, expDate));

if ~exist(ROILocsFname, 'file') | forceRerun
    load(fullfile(baseDir, 'OpenData', 'PrecomputedData', sprintf('regops_%s_%s.mat', mName,expDate)))
    NPlanes = length(ops1);
    validPlanes 	= 2:NPlanes;
    NValidPlanes 	= length(validPlanes);
    for pl = 1:NValidPlanes 
        error('') % provided for reference, requires "dat" output from suite2p so will not run
        load(fullfile(localDataDir, sprintf('%s\\%s\\%s\\F_%s_%s_plane%d_proc.mat', mName, expDate, ...
            expNumStr, mName, expDate, validPlanes(pl))), 'dat')
        [centroids_xy{pl},rois{pl}] = s2p_rois2centroids(dat); 
    end

    allROIPixels 	= vertcat(rois{:}); 
    allCentroids 	= vertcat(centroids_xy{:});

    plCentroids 	= centroids_xy;
    plPixels 	    = rois;

    save(ROILocsFname, 'allROIPixels', 'allCentroids', 'plCentroids', 'plPixels')
else
    load(ROILocsFname)
end

