function [ops,whichIdxs] = loadDefaultOps(whichPredictors, ops)

    %% set options

    % default ops
    ops.doSave          = true;
    ops.reg.lambda      = 0.1; %.05; %options: 0.01, 0.05, 0.1, 1, or 1 
    ops.NCVFolds        = 11; 
    ops.activityType    = 'deconv';

    ops.doConv          = true;
    ops.convSize        = 0.5; %filter by gauss win of 0.5 second
    ops.upsampFactor    = getOr(ops,'upsampFactor', 1); %none if 1


    % specify predictors
    pred.evNames    = {'trialOn','trialOnL', 'trialOnR', ...
                        'pdFlipL', 'pdFlipR', ...
                        'pdFlipLowL', 'pdFlipLowR', ...
                        'pdFlipMedL', 'pdFlipMedR', ...
                        'pdFlipHighL', 'pdFlipHighR', ...
                            'intDelayEnd','intDelayEndL','intDelayEndR',...
                            'anyMove', 'firstMove', 'firstMoveL', 'firstMoveR',...
                            'reward', 'correct', 'wrong', 'licks', ...
                        'trialEndChooseL', 'trialEndChooseR'};

    pred.evWin      = {[-0.05 0.5], [-0.05 0.5],[-0.05 0.5],...
                        [-0.05 0.5],[-0.05 0.5],...
                        [-0.05 0.5],[-0.05 0.5],...
                        [-0.05 0.5],[-0.05 0.5],...
                        [-0.05 0.5],[-0.05 0.5],...
                        [-0.25 0.75], [-0.25 0.75],[-0.25 0.75],...
                        [-0.15 0.4],[-0.15 0.4],[-0.15 0.4],[-0.15 0.4], ...
                        [-0.1 0.4],[-0.1 0.4],[-0.1 0.4],[-0.1 0.4], ...
                        [-0.4 0.1], [-0.4 0.1]};

    pred.contNames  = {'rewardThis', 'noRewardThis', 'rewardLast', 'noRewardLast', ...
                        'moveCurrent', 'moveCurrentL', 'moveCurrentR', ...
                            'ITI', 'runCurrent', 'stopCurrent',...
                                'velocity', 'accel', ...
                                    'velocityAbs', 'velocityPos', 'velocityNeg', ...
                                        'rotVel', 'rotVelPos', 'rotVelNeg', ...
                                            'accelPos', 'accelNeg', ...
                                                'azimuth', 'azimuthL', 'azimuthR', ...
                                                    'pupilArea', 'pupilX', 'pupilY', ...
                                                        '1stpc', 'face', 'whisk', ...
                                                            'zInd', 'thInd', ...
                                                                'piezo'};

    [pred.lags{~contains(pred.contNames, 'Ind')}] = deal([-0.5 -0.25 0 0.25 0.5]); %shift cont preds 
    [pred.lags{contains(pred.contNames, 'Ind')}]  = deal([0]); %don't shift indicator vectors at all
    pred.names      = horzcat(pred.evNames,pred.contNames);
    pred.win        = horzcat(pred.evWin, pred.lags);
    pred.type       = cell(size(pred.names));
    pred.doScale    = zeros(size(pred.names));
    pred.doScale(ismember(pred.names, {'stimL', 'stimR', 'stimNZ'})) = 1;

    [pred.type{1:length(pred.evNames)}]         = deal('step');
    [pred.type{length(pred.evNames)+1:end}]     = deal('cont');
    [pred.type{contains(pred.names, 'Ind')}]    = deal('indicator'); 

    assert(isequal(length(pred.names), length(pred.win)), 'something went wrong');

    assert(numel(intersect(pred.names,whichPredictors))==numel(whichPredictors), ...
        'are you sure the predictor name is correct? at least one predictor not found')

    whichIdxs           = ismember(pred.names, whichPredictors);
    ops.pred.names      = pred.names(whichIdxs);
    ops.pred.win        = pred.win(whichIdxs);
    ops.pred.type       = pred.type(whichIdxs);
    ops.pred.doScale    = getOr(ops.pred, 'doScale', pred.doScale(whichIdxs));

    ops.pred.modelName  = join(ops.pred.names, '_');

    if nargout >= 2
        whichIdxs = sprintf('%d', whichIdxs);
    end

end
