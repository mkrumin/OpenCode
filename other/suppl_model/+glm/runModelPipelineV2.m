%% provided for reference
%% uses deconvolved spikes
%% options:
    % linear model with free predictors 
    % glm with gaussian predictors
    % glm with free predictors

function allRes = runModelPipelineV2(mName,expDate,taskName,NPlanes, ...
                    whichModel, whichTaskName, modelType, ops)

    if exist('ops', 'var')
        ops = glm.loadDefaultOps(whichModel,ops);
    else
        ops = glm.loadDefaultOps(whichModel);
    end

    tskIdx = find(strcmp(taskName, whichTaskName));

    randomPlIdx = 1;

    session = loadSingleSession(mName,expDate,expNumStr,tskIdx,taskName{tskIdx},NPlanes+1);
    if ~isfield(session.et,'move') & ismember(session.taskName, {'sw', 'stm'})
        [~,~,~,session.et.move] = getWheelTL(session.TL, true);
    end

    ops.data.originalFs = round(1/mean(diff(session.fFT{randomPlIdx})));        
    if isfield(ops, 'upsampFactor')
        ops.data.Fs     = ops.data.originalFs*ops.upsampFactor;        
    end

    [fPlanes,ops] = glm.getDataForModel(session, ops)

    for pl = 1:NPlanes
        eventTimes{pl} = glm.getEvents(session,ops,pl);
        NEvents     = length(eventTimes{pl});
        [predictors{pl},cumulWinSamps] = glm.constructPredictors(eventTimes{pl},pl, ops);
        foldID{pl} = glm.splitChunks(ops.data.NFrames{pl}, ops.NCVFolds);
        switch modelType
        case 'linear'
            res{pl} = glm.runLinearModel(fPlanes{pl},predictors{pl},foldID{pl}, cumulWinSamps);
        case 'glm'
            addpath('glmnet_matlab')
            res{pl} = glm.runGLMNetv0(fPlanes{pl},predictors{pl},foldID{pl});
        end
        cvErr{pl} = res{pl}.cvErr(:);

        Xall{pl} = predictors{pl}\fPlanes{pl}';
        for ev = 1:NEvents
            fitKernels{ev}{pl} = Xall{pl}(cumulWinSamps(ev)+1:cumulWinSamps(ev+1),:);
        end

        predSignals{pl} = res{pl}.allPredSignals;
        resid{pl}       = fPlanes{pl}-predSignals{pl};

    end

    allRes.plRes = res;
    for ev = 1:NEvents
        allRes.fitKernels{ev} = horzcat(fitKernels{ev}{:});
    end
    allRes.cvErr        = vertcat(cvErr{:});
    allRes.fData        = fPlanes;
    allRes.predictors   = predictors;
    allRes.predSignals  = predSignals;
    allRes.resid        = resid;

    ops.pred.modelName          = glm.getModelName(ops.pred.names);

    allRes.ops                 = ops;
    allRes.ops.data.predictors = predictors;
    allRes.ops.data.foldID     = foldID;

    allRes.ops.cumulNLags      = cumulWinSamps;

    allRes.whenRun             = now;

end
