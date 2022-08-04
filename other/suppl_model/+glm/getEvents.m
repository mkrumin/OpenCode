function [allEvents,ops] = getEvents(session, ops, whichPlaneIdx)
    if ~isfield(ops, 'doFilt')
        doFilt = false;
    else
        doFilt = ops.doFilt;
    end
    NPlanes = length(session.fFT);
    if nargin < 3
        if NPlanes == 1
            whichPlaneIdx = 1;
        else
            whichPlaneIdx = 2;
        end
    end

    NEvents = numel(ops.pred.names);

    NTrials = session.NTrials;

    for ev = 1:NEvents
        eventName   = ops.pred.names{ev};
        try
            thisEvent = eta.getEventTimes(session, eventName);
            if ops.pred.doScale(ev) == true
                [~,thisEventIdxs] = eta.getEventTimes(session, eventName);
                ops.pred.scale{ev} = abs(session.ev.contrastValues(1:session.NTrials));
                ops.pred.scale{ev} = ops.pred.scale{ev}(thisEventIdxs);
                ops.pred.scale{ev} = ops.pred.scale{ev}./max(ops.pred.scale{ev}); %normalize to be max 1
            end
        catch ME
           if strcmp(ME.identifier, 'getEvents:noSuchVariable')
               switch eventName
                   case 'velocityAbs'
                       vel = session.vel{whichPlaneIdx};
                       vel(isnan(vel)) = 0;
                       thisEvent = abs(vel);
                   case 'rotVel'
                       vel = session.rotvel{whichPlaneIdx};
                       vel(isnan(vel)) = 0;
                       thisEvent = abs(vel);
                   case 'rotVelPos'
                       vel = session.rotvel{whichPlaneIdx};
                       vel(isnan(vel)) = 0;
                       if doFilt
                           filtSize = round(ops.data.Fs/2);
                           vel = filtfilt(ones(filtSize,1)/filtSize,1, double(vel));
                       end
                       thisEvent = vel;
                       thisEvent(thisEvent < 0) = 0;
                   case 'rotVelNeg'
                       vel = session.rotvel{whichPlaneIdx};
                       vel(isnan(vel)) = 0;
                       if doFilt
                           filtSize = round(ops.data.Fs/2);
                           vel = filtfilt(ones(filtSize,1)/filtSize,1, double(vel));
                       end
                       thisEvent = vel;
                       thisEvent(thisEvent > 0) = 0;
                       thisEvent = abs(thisEvent);
                   case 'velocity'
                       vel = session.vel{whichPlaneIdx};
                       vel(isnan(vel)) = 0;
                       thisEvent = vel;
                   case 'accel'
                       vel = session.vel{whichPlaneIdx};
                       vel(isnan(vel)) = 0;
                       thisEvent = [0; diff(vel(:))];
                   case 'accelPos'
                       vel = session.vel{whichPlaneIdx};
                       vel(isnan(vel)) = 0;
                       thisEvent = [0; diff(vel(:))];
                       thisEvent(thisEvent < 0) = 0;
                   case 'accelNeg'
                       vel = session.vel{whichPlaneIdx};
                       vel(isnan(vel)) = 0;
                       thisEvent = [0; diff(vel(:))];
                       thisEvent(thisEvent > 0) = 0;
                       thisEvent = abs(thisEvent);
                   case 'velocityPos'
                       vel = session.vel{whichPlaneIdx};
                       vel(isnan(vel)) = 0;
                       if doFilt
                           filtSize = round(ops.data.Fs/2);
                           vel = filtfilt(ones(filtSize,1)/filtSize,1, double(vel));
                       end
                       thisEvent = vel;
                       thisEvent(thisEvent < 0) = 0;
                   case 'velocityNeg'
                       vel = session.vel{whichPlaneIdx};
                       vel(isnan(vel)) = 0;
                       if doFilt
                           filtSize = round(ops.data.Fs/2);
                           vel = filtfilt(ones(filtSize,1)/filtSize,1, double(vel));
                       end
                       thisEvent = vel;
                       thisEvent(thisEvent > 0) = 0;
                       thisEvent = abs(thisEvent);
                   case 'reward'  %prev: rewardThis, changed 2021-04-01 - why?
                       rewThisTrial = session.ev.feedbackValues;
                       thisEvent = glm.getTrialPredictors(session, find(rewThisTrial));
                       thisEvent = thisEvent{whichPlaneIdx};
                   case 'noRewardThis' 
                       rewThisTrial = session.ev.feedbackValues;
                       thisEvent = glm.getTrialPredictors(session, find(~rewThisTrial));
                       thisEvent = thisEvent{whichPlaneIdx};
                   case 'rewardLast' 
                       rewLastTrial    = logical([0 session.ev.feedbackValues(1:end-1)]); %yep
                       thisEvent       = glm.getTrialPredictors(session, find(rewLastTrial));
                       thisEvent       = thisEvent{whichPlaneIdx};
                   case 'noRewardLast' 
                       rewLastTrial = logical([0 session.ev.feedbackValues(1:end-1)]); %yep
                       thisEvent = glm.getTrialPredictors(session, find(~rewLastTrial));
                       thisEvent = thisEvent{whichPlaneIdx};
                   case 'moveCurrent'
                       vel = session.vel{whichPlaneIdx};
                       thisEvent = zeros(size(vel));
                       thisEvent(vel > 0 | vel < 0) = 1;
                   case 'azimuth' %does this need to be signed azimuth?
                       validAz         = getAzimuth(session); %the "out of trial" indices are NaNs
                       thisEvent       = validAz{whichPlaneIdx};
                       thisEvent(isnan(thisEvent)) = 0; %maybe?? 0 azimuth should contribute nothing
                   case 'zPos' 
                       warning('this is invalid, should not use z as intensity. basis function instead?')
                       [~,thisEvent] = getZTh(session); 
                       thisEvent(isnan(thisEvent)) = 0; %may be already 0
                   case 'theta' 
                       warning('this is invalid, should not use z as intensity. basis function instead?')
                       thPos        = getZTh(session); 
                       thisEvent(isnan(thisEvent)) = 0; %may be already 0
                   case 'pupilArea'
                       try
                           interpArea      = getPupil(session, doFilt);
                           thisEvent       = interpArea{1}{whichPlaneIdx};
                           thisEvent(isnan(thisEvent)) = nanmedian(thisEvent); %maybe??
                       catch
                           [~,~,interpArea]    = getFaceMovie(session, doFilt);
                           thisEvent           = interpArea{1}{whichPlaneIdx};
                       end
                       if isempty(interpArea)
                           error('are you sure pupil data has been processed?')
                       end
                   case 'pupilX'
                       [~,interpX]     = getPupil(session, doFilt);
                       if isempty(interpX)
                           error('are you sure pupil data has been processed?')
                       end
                       thisEvent       = interpX{1}{whichPlaneIdx};
                       thisEvent(isnan(thisEvent)) = nanmedian(thisEvent); %maybe??
                   case 'pupilY'
                       [~,~,interpY]   = getPupil(session, doFilt);
                       if isempty(interpY)
                           error('are you sure pupil data has been processed?')
                       end
                       thisEvent       = interpY{1}{whichPlaneIdx};
                       thisEvent(isnan(thisEvent)) = nanmedian(thisEvent); %maybe??
                   case 'face' %FaceMap (SVD of whole movie) 1st pc
                       interpFaceFirstPC   = getFaceMovie(session, doFilt);
                       thisEvent           = interpFaceFirstPC{whichPlaneIdx}; %fixed aug 2021
                   case 'whisk' %FaceMap whisker pad ROI 1st pc
                       [~,interpWhiskTotal]    = getFaceMovie(session, doFilt);
                       thisEvent               = interpWhiskTotal{whichPlaneIdx}; %fixed aug 2021
                   case 'piezo' %raw piezo 
                       filtSize = 20;
                       licks    = session.TL.rawDAQData(:,...
                                    strcmp({session.TL.hw.inputs.name},'piezoLickDetector'));
                       tt       = session.TL.rawDAQTimestamps;

                        %% filter licks - can be improved
                       filtLicks = filtfilt(ones(filtSize,1)/filtSize, 1, licks); %a bit arbitrary atm 

                       thisEvent = interp1(tt, filtLicks, session.fFT{whichPlaneIdx}, 'nearest');
                   case 'faceRR' 
                       %TODO: reduced rank regression on the face
                   case '1stpc' %1st pc
                       warning('do not use 1st pc, it will obviously capture a lot of variance by definition..')
                   case 'zInd'
                       thisEvent = glm.getTMEvents(session, ops,whichPlaneIdx, eventName);
                   case 'thInd'
                       thisEvent = glm.getTMEvents(session, ops,whichPlaneIdx, eventName);
                   otherwise
                       error(sprintf('"%s" event is not defined', eventName))
               end
           else
               error(sprintf('"%s" event is not defined', eventName))
           end
        end

        if strcmp(ops.pred.type{ev}, 'step') | strcmp(ops.pred.type{ev}, 'cont')
            if(any(isnan(thisEvent)))
                warning(sprintf('%d NaNs found for %s\n', sum(isnan(thisEvent)), eventName))
            end
            thisEvent = thisEvent(~isnan(thisEvent));
        elseif ~any(size(thisEvent)==1) %a matrix, not a vector (indicator)
            try
                assert(max(size(thisEvent))==max(size(ops.data.origFT{1})), 'event matrix wrong size')
            catch
                assert(max(size(thisEvent))==max(size(ops.data.origFT{2})), 'event matrix wrong size')
            end
             %idk? changed 2021-04-01 - idk what's diff between fft and orig fft
            assert(~any(isnan(thisEvent(:))), 'NaNs found in event matrix')
        elseif iscell(thisEvent)
            assert(~any(isnan(vertcat(thisEvent{:}))))
        else
            warning('not clear what this event %s is, be careful?', eventName)
        end
        if isempty(thisEvent)
            warning('%s is empty for this session, removing..', eventName)
        end
        eventTimes{ev} = thisEvent;
    end

    notEmptyIdxs    = ~cellfun(@isempty, eventTimes);
    eventTimes      = eventTimes(notEmptyIdxs);
    ops.pred.names  = ops.pred.names(notEmptyIdxs);
    ops.pred.win    = ops.pred.win(notEmptyIdxs);
    ops.pred.type   = ops.pred.type(notEmptyIdxs);
    %%idk if this then breaks the below

    ii = cell2mat(cellfun(@iscell, eventTimes, 'uni', 0));
    if any(ii)
        allEvents = {};
        allWin    = {};

        newWin = cell(1,NEvents);
        for ev = 1:NEvents
            if ismember(ev, find(ii))
                newWin{ev} = repmat(ops.pred.win(ev), 1, length(eventTimes{ii}));
            else
                newWin{ev} = ops.pred.win{ev};
            end
        end

        for ev = 1:sum(ii)
            allEvents       = horzcat(allEvents, eventTimes{ii}, eventTimes(~ii));
            allWin          = horzcat(allWin, newWin{ii}, newWin(~ii));
        end

        %try
            warning('hack') %assumes that all the level predictors are at the start I guess
            allType = cell(size(allWin));
            allType(numel(allType)-numel(ops.pred.type)+1:end) = ops.pred.type;
            [allType{cell2mat(cellfun(@isempty,allType, 'uni', 0))}] = deal('step');
            ops.pred.win    = allWin;
            ops.pred.type   = allType;
        %end
    else
        allEvents = eventTimes;
    end

end
