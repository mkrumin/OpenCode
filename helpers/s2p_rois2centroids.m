%written by Henry Dalgleish
function [centroids_xy,rois] = s2p_rois2centroids(dat,varargin)

s2p_iscell = find([dat.stat(:).iscell]);
for v = 1:numel(varargin)
    if strcmpi(varargin{v},'all')
        s2p_iscell = 1:numel([dat.stat(:).iscell]);
    end
end

centroids_xy = zeros(numel(s2p_iscell),2);
rois = cell(numel(s2p_iscell),1);
for r = 1:numel(s2p_iscell)
    centroids_xy(r,:) = mean([dat.ops.xrange(dat.stat(s2p_iscell(r)).xpix)' ...
                            dat.ops.yrange(dat.stat(s2p_iscell(r)).ypix)'],1);
    rois{r} = sub2ind(size(dat.ops.mimg1),...
                dat.ops.yrange(dat.stat(s2p_iscell(r)).ypix)',...
                    dat.ops.xrange(dat.stat(s2p_iscell(r)).xpix)');
end
centroids_xy = round(centroids_xy);

end

