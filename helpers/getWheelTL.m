%function [vel,pos,t,detectedMoves] = getWheelTL(TL, detectMoves, movesParams)
%wrttein for extracting wheel data (i.e. position,velocity...) from TL rotary encoder
%this is useful for validating signals wheel times and for wheel experiments that don't use signals.

function [vel,pos,t,detectedMoves] = getWheelTL(TL, detectMoves, movesParams)
    if nargin < 3
        movesParams = [];

        if nargin < 2
            detectMoves = 0; %to save time; findWheelMoves takes the longest to run
        end
    end

    rawPos = double(typecast(uint32(TL.rawDAQData(:,...
        strcmp({TL.hw.inputs.name}, 'rotaryEncoder'))), 'int32')); %correct for over/underflow
    rawTimes = TL.rawDAQTimestamps;

    %get "actual" position - from wheelAnalysis repo
    Fs = 1000; 
    t = rawTimes(1):1/Fs:rawTimes(end); %make samples evenly spaced
    pos = interp1(rawTimes, rawPos, t, 'linear');
    wheelRadius = 31; % mm (burgess wheel) (measured by Chris)
    wheelRadius = 150; % mm (running wheel) (guess!)
    rotaryEncoderResolution = 360*4; % num of ticks for one revolution (factor of 4 according to CB)
    pos = pos./(rotaryEncoderResolution)*2*pi*wheelRadius; % convert to mm

    %get velocity
    smoothSize = 0.01; %taken from e.g. plotWheel.m in wheelAnalysis repo
    vel = wheel.computeVelocity2(pos,smoothSize,Fs); %smooth size = 50

    if nargin > 1 && detectMoves == 1
        movesParams = [];
        [detectedMoves.moveOnsets detectedMoves.moveOffsets] = ...
            wheel.findWheelMoves3(pos, rawTimes, Fs, movesParams);
        if isempty(detectedMoves.moveOnsets)
            movesParams.posThresh = (max(pos)-min(pos))/2;
            [detectedMoves.moveOnsets detectedMoves.moveOffsets] = ...
                wheel.findWheelMoves3(pos, rawTimes, Fs, movesParams);
            if isempty(detectedMoves.moveOnsets)
                error('error in finding wheel movements')
            end
        end
    else
        detectedMoves = {'set detectMoves flag to 1'}; 
    end


%then e.g. plotWheel(t,pos,detectedMoves)
