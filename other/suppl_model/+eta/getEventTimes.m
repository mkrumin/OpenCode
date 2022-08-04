
function [evTimes,evIdxs] = getEventTimes(session, eventType)
    if contains(eventType, 'pdFlip');
        try
            pdFlip = getStimWindowUpdate(session);
        catch
            forceIfNotEnough = true;
            pdFlip = getTrialTimes(session.TL,session.block, forceIfNotEnough);
        end
        assert(isequal(numel(pdFlip),session.NTrials))
        allCtrs = (session.ev.contrastValues(1:session.NTrials));
        switch eventType
        case 'pdFlip'
            evIdxs = ones(size(pdFlip));
        case 'pdFlipL'
            evIdxs = (sign(allCtrs)==-1);
        case 'pdFlipR'
            evIdxs = (sign(allCtrs)==1);
        case 'pdFlipLowL'
            evIdxs = ismember(allCtrs, [0.06]);
        case 'pdFlipLowR'
            evIdxs = ismember(allCtrs, [-0.06]);
        case 'pdFlipMedL'
            evIdxs = ismember(allCtrs, [-0.12 -0.25]);
        case 'pdFlipMedR'
            evIdxs = ismember(allCtrs, [0.12 0.25]);
        case 'pdFlipHighL'
            evIdxs = ismember(allCtrs, [-0.5]);
        case 'pdFlipHighR'
            evIdxs = ismember(allCtrs, [0.5]);
        end
        evTimes = pdFlip(evIdxs);
    else
        switch eventType
        case 'trialOn'
            try
                alignedEvents = AP_alignsignals(session.TL, session.block); 
                evTimes = alignedEvents.stimulusOnTimes(1:session.NTrials);
            catch
                evTimes = session.et.trialOn(1:session.NTrials);
            end
        case 'trialOnL'
            allCtrs = (session.ev.contrastValues(1:session.NTrials));
            try
                alignedEvents = AP_alignsignals(session.TL, session.block); 
                evTimes = alignedEvents.stimulusOnTimes(1:session.NTrials);
            catch
                evTimes = session.et.trialOn(1:session.NTrials);
            end
            evIdxs = (sign(allCtrs)==-1);
            evTimes = evTimes(evIdxs);
        case 'trialOnR'
            allCtrs = (session.ev.contrastValues(1:session.NTrials));
            try
                alignedEvents = AP_alignsignals(session.TL, session.block); 
                evTimes = alignedEvents.stimulusOnTimes(1:session.NTrials);
            catch
                evTimes = session.et.trialOn(1:session.NTrials);
            end
            evIdxs = (sign(allCtrs)==1);
            evTimes = evTimes(evIdxs);
        case 'trialEndChooseL'
            evIdxs  = (session.ev.responseValues(1:session.NTrials)==-1);
            evTimes = session.et.trialOff(1:session.NTrials);
            evTimes = evTimes(evIdxs);
        case 'trialEndChooseR'
            evIdxs  = (session.ev.responseValues(1:session.NTrials)==1);
            evTimes = session.et.trialOff(1:session.NTrials);
            evTimes = evTimes(evIdxs);
        case 'reward'
            evTimes = session.et.reward;
        case 'correct'
            alignedEvents   = AP_alignsignals(session.TL, session.block); 
            evTimes         = alignedEvents.feedbackTimes(session.ev.feedbackValues==1);
        case 'wrong'
            alignedEvents   = AP_alignsignals(session.TL, session.block); 
            evTimes         = alignedEvents.feedbackTimes(session.ev.feedbackValues==0 & ...;
                                session.ev.responseValues~=0);
        case 'intDelayEnd'
            try
                intDelayDur     = session.block.paramsValues(1).interactiveDelay;
            catch
                intDelayDur     = 0.2;
            end
            trialOn         = session.et.trialOn;
            evTimes         = trialOn+intDelayDur;
        case 'intDelayEndL'
            intDelayDur     = session.block.paramsValues(1).interactiveDelay;
            evIdxs = (sign(session.ev.contrastValues(1:session.NTrials))==-1);
            evTimes         = session.et.trialOn(evIdxs)+intDelayDur;
        case 'intDelayEndR'
            intDelayDur     = session.block.paramsValues(1).interactiveDelay;
            evIdxs = (sign(session.ev.contrastValues(1:session.NTrials))==1);
            evTimes         = session.et.trialOn(evIdxs)+intDelayDur;
        case 'anyMove'
            evTimes         = session.et.move.moveOnsets;
        case 'firstMove'
            firstMove       = getFirstMove(session);
            evTimes         = firstMove(~isnan(firstMove));
        case 'firstMoveL'
            firstMove       = getFirstMove(session);
            evIdxs          = (session.ev.responseValues(1:session.NTrials)==-1);
            evTimes         = firstMove(evIdxs);
            evTimes         = evTimes(~isnan(evTimes));
        case 'firstMoveR'
            firstMove       = getFirstMove(session);
            evIdxs          = (session.ev.responseValues(1:session.NTrials)==1);
            evTimes         = firstMove(evIdxs);
            evTimes         = evTimes(~isnan(evTimes));
        case 'licks' %depends on quality of pd trace
            alignedEvents   = AP_alignsignals(session.TL, session.block); 
            feedback        = alignedEvents.feedbackTimes;
            lck             = NaN(size(feedback));
            for fb = 1:length(feedback)
                if alignedEvents.feedbackValues(fb)==1 %rewarded
                    thisLck = session.et.licks(find(abs(session.et.licks-feedback(fb))<0.3,1, 'first'));
                    if ~isempty(thisLck)
                        lck(fb) = thisLck;
                    else
                        lck(fb) = NaN;
                    end
                else
                    lck(fb) = NaN;
                end
            end
            evTimes = lck;
        otherwise
            ME = MException('getEvents:noSuchVariable', sprintf('variable %s not found', eventType));
            throw(ME)
        end
    end

    if numel(evTimes) < 10;
        warning(sprintf('fewer than 10 examples of %s, do you really want to use this?', eventType))
    elseif numel(evTimes) < 50;
        fprintf('%d examples of %s, do you really want to use this?\n', numel(evTimes),eventType)
    end

end
