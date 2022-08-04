function [roiImgs,relativeCentroids] = cropCellsMimg(meanImg, roiStat,padding) 
%this should take IN ROIs from Suite2p, get their coordinates - e.g. from
%min, max dat.stat(iCell).xpix, ypix etc. with padding 
%or area around med, get npix, and take square (doesn't work really)

%can take input of CellsOfInterestIdxs 

if nargin < 3
    padding = 10
end

NROIs 	= length(roiStat); 
roiImgs = cell(1,NROIs); %each entry is the image for that roi
%later expand to have rows for same cell, different days?? 

roiRectCoords = NaN(4,NROIs); %xmin, xmax, ymin, ymax??? 

%%
for iROI = 1:NROIs
	xmin = max(1, min(roiStat(iROI).xpix) - padding); 
	xmax = min(size(meanImg,2), max(roiStat(iROI).xpix) + padding); 
	ymin = max(1, min(roiStat(iROI).ypix) - padding); 
	ymax = min(size(meanImg,1), max(roiStat(iROI).ypix) + padding); 

	xmedRelative(iROI) = round(mean(roiStat(iROI).xpix)) - xmin+1; %works more or less!!
	ymedRelative(iROI) = round(mean(roiStat(iROI).ypix)) - ymin+1; %off by one pixel maybe?

	roiRectCoords(iROI,1:4) = round([xmin xmax ymin ymax]); 
	roiImgs{iROI} = meanImg(roiRectCoords(iROI, 3):roiRectCoords(iROI, 4),...
        roiRectCoords(iROI, 1):roiRectCoords(iROI,2)); 
end


relativeCentroids = [xmedRelative(:),ymedRelative(:)];
