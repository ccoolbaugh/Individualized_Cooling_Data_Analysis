%% ShiverTimes Function
%
% Purpose: This code reads the tGUI shiver event data to log the start/end
% times of each self-reported shiver. The shiver duration is calculated and
% it is labeled with a '1' for a spontaneous shiver (< 15 s) or '2' for a
% continuous shiver (> 15 s). Shiver on/off times, durations, and types are
% formatted into a Matlab table. 
%
% Inputs: tGUI shiver data, tGUI datetime information
%
% Outputs: ShiverData (Matlab Table)

% Authors: Emily Bush and Crystal Coolbaugh
% Date: October 10, 2017
% Copyright 2017 Emily Bush, Crystal Coolbaugh

function [ShiverData] = ShiverTimes(shiver, tGUI_DateTime)

%% Identify Shivering Indices
SIdxOn = find(diff(shiver)==1);
SIdxOff = find(diff(shiver)==-1);
ind = 1;

if length(SIdxOn)>=2 && length(SIdxOff)>=2
    % Invert On/Off if phase began with 'Shiver' in 'on' position
    if SIdxOff(1) < SIdxOn(1)
        Start = SIdxOff;
        End = SIdxOn;
        SIdxOn = Start;
        SIdxOff = End;
    end
    
    % Add final time value if 'Shiver' left in 'on' position
    if length(SIdxOff) < length(SIdxOn)
        SIdxOff(end+1) = length(shiver);
    end
    
    % Log shiver timestamps for on/off
    ShivOn = timeofday(datetime(tGUI_DateTime(SIdxOn),'Format','HH:mm:ss'));
    ShivOff = timeofday(datetime(tGUI_DateTime(SIdxOff),'Format','HH:mm:ss'));
    
    % Calculate shiver duration
    for n = 1:length(SIdxOn)
        ShivDur(ind,1) = seconds(tGUI_DateTime(SIdxOff(n,1))-tGUI_DateTime(SIdxOn(n,1)));

        % Determine Shiver Type (spontaneous < 15s; continuous >= 15s)
        if ShivDur(ind,1) < 15
            ShivType(ind,1) = 1;
        else
            ShivType(ind,1) = 2;
        end
        ind = ind+1;
    end
else
    ShivOn = 0;
    ShivOff = 0;
    ShivDur = 0;
    ShivType = 0;
end

%% Format Shiver Array for Export
ShiverData = table(ShivOn, ShivOff, ShivDur, ShivType, ...
    'VariableNames', {'On', 'Off', 'Duration', 'Type'});

end

