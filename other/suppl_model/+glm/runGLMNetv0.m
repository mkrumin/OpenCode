function res = runGLMNetv0(fMat, predictors, foldID)
    if nargin < 4
        opts.alpha  = 0.01;
    end

    cvEvalFunc = @(pred, actual)1- var(pred-actual)./var(actual);
    cvEvalFunc = @(pred, actual)1- var(pred-actual)./var(actual);
    assert(numel(unique(foldID))==max(foldID), 'something went wrong')

    NCVFolds = max(foldID);
        
    glmnetOps = glmnetSet(opts);
    %options: alpha = 0.1, lambda default

    [NCells, NFrames] = size(fMat);

    for fld = 1:NCVFolds
        testInds    = foldID==fld;
        trainInds   = foldID~=fld;
        devFrac     = NaN(NCells,1);

        for ci = 1:NCells
            fCell           = fMat(ci,:);

            %tic; 

            if false
                gf = glmnet(predictors(trainInds,:),fCell(trainInds)',...
                    'gaussian',glmnetOps)
            else
                %% predictors exclude bias, and add it as an "offset"
                % lasso glm
                [B,FitInfo] = lassoglm(predictors(trainInds,1:end-1),fCell(trainInds)', ...
                    'normal','Lambda', 0.5, 'alpha', 0.5, 'offset', predictors(trainInds,end));

                B0          = FitInfo.Intercept;
                coeff{ci}   = [B0; B]; %first column is bias

                predTest    = glmval(coeff{ci},predictors(testInds,1:end-1), 'identity');

                allPredTest{ci} = predTest;

                %devFrac(ci) = FitI
            end
            %toc

            %should be same length as predictor plus one for the bias term

        end

        %just pick one
        assert(size(predictors,2)==length(coeff{randi(NCells)}))

        allPredSignals(:,testInds) = horzcat(allPredTest{:})';

        cvErr(:,fld) = cvEvalFunc(allPredSignals(:,testInds)', fMat(:,testInds)');

        allCoeff{fld} = coeff; %idk
    end

    allCoefMat  = cell2mat(cat(3,allCoeff{:}));

    res.allPredSignals  = allPredSignals;
    res.allF            = fMat;
    res.allCoefMat      = allCoefMat;
    res.cvErr           = nanmean(cvErr, 2);
end
