function [fPlanes,ops] = loadData(session,ops);

    NPlanes = length(session.fFT);
    for pl = 1:NPlanes
        fFT = session.fFT{pl}; 
        fMat = session.spData{pl};

        % these will do nothing if ops.upsampFactor is 1
        t = fFT(1):1/ops.data.Fs:fFT(end); %make samples evenly spaced
        ops.data.fFT{pl}        = interp1(session.fFT{pl}, session.fFT{pl}, t, 'linear');
        ops.data.origFT{pl}     = session.fFT{pl};
        ops.data.NFrames{pl}    = length(ops.data.fFT{pl}); %needs to be the new upsampled version!!

        for ci = 1:size(fMat,1)
            fPlanes{pl}(ci,:) = interp1(session.fFT{pl}, fMat(ci,:), t, 'linear');
        end

        if ops.doConv
            convGauss   = gausswin(round(ops.data.Fs*ops.convSize)); %default = 0.5s width
            convGauss   = convGauss./sum(convGauss); %normalise
            fPlanes{pl} = conv2(1, convGauss, fPlanes{pl}, 'same');
        end
    end

end
