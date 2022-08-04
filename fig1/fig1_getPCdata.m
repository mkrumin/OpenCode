function [cc,pp,nn] = getPCdata(session)

NTrials = session.NTrials;
if strcmp(session.taskName, 'tm')

    contrast = [];
    outcome = '';
    behavior = '';
    finished = [];
    random = [];
    
    rightChoices = []; 
    
    allTrials   = session.tmaze.SESSION.allTrials;
    EXP         = session.tmaze.EXP;
    for tr = 1:NTrials
        contrast(tr) = allTrials(tr).info.contrast;
        side = -1+2*isequal(allTrials(tr).info.stimulus, 'RIGHT'); %add sign of which side (+ve R, -ve L) 
        contrast(tr) = contrast(tr) * side;

        outcome(tr) = allTrials(tr).info.outcome(1);
        behavior(tr) = outcome(tr);

        if outcome(tr) == 'C'
            behavior(tr) = allTrials(tr).info.stimulus(1);
        elseif outcome(tr) == 'W'
            behavior(tr) = char('R'+'L'-allTrials(tr).info.stimulus(1));
        end
        
        if isequal(EXP.stimType, 'BAITED')
            random(tr) = tr == 1 || outcome(tr-1)~='W';
        else
            random(tr) = true; %assuming 'RANDOM'
        end

        finished(tr) = ismember(behavior(tr), {'R', 'L'});
    end

    cc = unique(contrast);
    pp = nan(size(cc));
    nn = nan(size(cc));
    for iCC=1:length(cc)
        indices = (contrast == cc(iCC)) & finished & random;
        nn(iCC) = sum(indices);
        pp(iCC) = sum(behavior(indices)=='R')/sum(indices);
        
        rightChoices(iCC) = sum(behavior(indices)=='R'); 
    end

elseif strcmp(session.taskName, 'sw')
    block = session.block;

    cc = unique(block.events.contrastValues);
    pp = NaN(size(cc));
    nn = NaN(size(cc));
    for cont = 1:length(cc)
         contIdxs = block.events.contrastValues==cc(cont);
         contIdxs = contIdxs(1:length(block.events.responseValues));
         nn(cont) = sum(contIdxs); 
         try
            pp(cont) = sum(block.events.responseValues(contIdxs) == 1)/sum(contIdxs);  
         catch
             if nn(cont) == 0 %if no trials presented at this contrast
                 pp(cont) = 0;
             end
         end 
    end
end

if all(cc <= 1) %translate proportions to percentages
    cc = cc*100;
end

if any(abs(cc)>50) %only include contrasts up to 50%
    pp = pp(abs(cc)<=50);
    nn = nn(abs(cc)<=50);
    cc = cc(abs(cc)<=50);
end

