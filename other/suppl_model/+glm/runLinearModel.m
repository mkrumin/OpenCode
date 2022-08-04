%this is now used, in favour of the poisson GLM
function [res,errFlag] = runLinearModel(fMat, predictors, foldID, cumulWinSamps)

    cvEvalFunc = @(pred, actual)1- var(pred-actual)./var(actual);

    %% find optimal lambda - iterate over some possibilities
    lambdaList = [0.01 0.05 0.1 0.5 1];
    for itr = 1:length(lambdaList)
        [cvErr,allPred] = runRegression(fMat, predictors,foldID, lambdaList(itr)); 
        allCVErr(:,itr) = mean(cvErr,2);
    end

    [~,iLD] = min(allCVErr,[],2);
    [~,iBestLD] = max(histcounts(iLD));
    bestLambda = lambdaList(iBestLD);

    % remember to z-score predictors

    [finalCVErr, allPredSignals, devFrac,errFlag] = runRegression(fMat, predictors, foldID, bestLambda);

    res.cvErr           = nanmean(finalCVErr,2);
    res.allDevs         = nanmean(devFrac,2);
    res.allPredSignals  = allPredSignals;
    res.allF            = fMat;

    res.bestLambda      = bestLambda; 

function [cvErr,allPred, devFrac,errFlag] = runRegression(fMat,predictors, foldID, ld)
    errFlag = [];

    NCVFolds    = max(foldID);

    assert(all(predictors(:,end)==1), 'intercept term possibly not included?')

    %%add regularization rows
    if ld > 0
        NFrames = size(predictors,1);
        NPred   = size(predictors,2)-1; %minus intercept
        predictors(NFrames+1:NFrames+NPred, 1:end-1) = ...
                    diag(ld*ones(1,NPred));
    end

    for fld = 1:NCVFolds
        testInds    = foldID==fld;
        trainInds   = foldID~=fld;
        if any(sum(predictors(trainInds,:))==0) %rank deficient i.e happens to be no event in this fold
            warning('this fold is rank deficient, using pseudo-inv..')
            X2  = pinv(predictors(trainInds,:))*fMat(:,trainInds)'; 
            predictedSignals = (predictors(testInds,:)*X2);

            [~,whichPredSparse] = intersect(cumulWinSamps,find(sum(predictors(trainInds,:))==0)-1);
            %flag which predictor caused the problem
            errFlag = [errFlag,whichPredSparse];
        else
            X                   = predictors(trainInds,:)\fMat(:,trainInds)'; %kernels change with every iter
            predictedSignals    = (predictors(testInds,:)*X);
        end

        fTest = fMat(:,testInds)';

        cvErr(:,fld) = cvEvalFunc(predictedSignals, fTest);
        fldPred{fld} = predictedSignals';

        NCells = size(fTest,2);
        for ci = 1:NCells 
            fldDevFrac{fld}(ci) = getDeviance(fMat(ci, testInds), predictedSignals(:,ci), ...
                nanmean(fMat(ci,trainInds)), 'gaussian');
        end
    end

    for fld = 1:NCVFolds
        testInds            = foldID==fld;
        allPred(:,testInds) = fldPred{fld};
        devFrac(:,fld)      = fldDevFrac{fld};
    end
    
end

end


