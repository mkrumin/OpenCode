%written by Andy Peters and modified by JL

function signals_events = AP_alignsignals(TL, block)
signals_events = block.events;

reward_t_block = block.outputs.rewardTimes(block.outputs.rewardValues > 0);
        
timeline_reward_idx = strcmp({TL.hw.inputs.name}, 'rewardCommand');
reward_thresh = max(TL.rawDAQData(:,timeline_reward_idx))/2;
reward_trace = TL.rawDAQData(:,timeline_reward_idx) > reward_thresh;
reward_t_timeline = TL.rawDAQTimestamps(find(reward_trace(2:end) & ~reward_trace(1:end-1))+1);

if length(reward_t_block) == length(reward_t_timeline)
    block_fieldnames = fieldnames(block.events);
    block_values_idx = cellfun(@(x) ~isempty(x),strfind(block_fieldnames,'Values'));
    block_times_idx = cellfun(@(x) ~isempty(x),strfind(block_fieldnames,'Times'));
    for curr_times = find(block_times_idx)'
        if isempty(signals_events.(block_fieldnames{curr_times}))
            % skip if empty
            continue
        end
        signals_events.(block_fieldnames{curr_times}) = ...
            AP_clock_fix(block.events.(block_fieldnames{curr_times}),reward_t_block,reward_t_timeline);
    end
    signals_events.rewardTimes = ...
            AP_clock_fix(block.outputs.rewardTimes,reward_t_block,reward_t_timeline);      

    signals_events.wheelTimes = ...
            AP_clock_fix(block.inputs.wheelTimes,reward_t_block,reward_t_timeline);      
else
    warning('NOT ALIGNING SIGNALS TO TIMELINE - REWARD MISMATCH')
end

function t_new = AP_clock_fix(t,source_sync,target_sync)
% t_new = AP_clock_fix(t,source_sync,target_sync)
 
% Converts time from one clock to another
% t - times
% source_sync - synchronization corresponding to t
% target_sync - synchronization corresponding to desired t
% NOTE: source/target syncs can be n timepoints, only uses first and last

% t_offset = source_sync(1) - target_sync(1);

% t_drift = 1 - (target_sync(end) - target_sync(1))/(source_sync(end) - source_sync(1));
% t_new = t - t_offset - (t - target_sync(1)).*t_drift;

if length(source_sync) ~= length(target_sync)
   error('Different numbers of sync pulses - cannot align')
end

t_new = interp1(source_sync,target_sync,t, 'linear', 'extrap');
