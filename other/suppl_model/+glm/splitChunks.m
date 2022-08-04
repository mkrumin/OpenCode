%splitChunks(NFrames, NChunks, doSaveGLM, mName, expDate, whichTaskName)
%divide NFrames into NBins, of which split into NChunks, and concatenate every nth chunk as a fold
%will look like a sawtooth 
function foldID = splitChunks(NFrames, NChunks)

    if nargin <2
        NChunks = 11;
        fprintf('using 11 folds..')
    end

    foldID = NaN(1,NFrames);

    NBin = 10;
    y = quantile(1:NFrames,NBin-1);
    [counts,~, Id] = histcounts(1:NFrames, [-inf; y(:); inf]);           

    for bn = 1:NBin
        y2 = quantile(1:counts(bn),NChunks-1);
        [~,~, Id2] = histcounts(1:counts(bn), ...
            [-inf; y2(:); inf]);           
        theseInds = find(Id==bn);
        for fld = 1:NChunks
            foldID(theseInds(Id2==fld)) = fld;
        end
    end

    assert(numel(unique(foldID))==max(foldID) & max(foldID)==NChunks, 'something went wrong')

end
