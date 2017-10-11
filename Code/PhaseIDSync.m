%% Phase ID Sync Function
%
% Purpose: This code uses the number of phases in the perception-based
% cooling protocol, the phase start/stop times from the session log, and
% the number of the thermoneutral phase to locate the index positions
% associated with each phase start/stop in the data time array. The index
% position associated with the end of the thermoneutral phase is also
% identified to sync all of the data arrays to the same time format. Time
% is synchronized such that the end of thermoneutral equals time zero. 
%
% Inputs: PhaseNum (number of phases), PhaseStartTime & PhaseStopTime 
% (phase start/stop time from log file), TNPhase (number of the
% thermoneutral phase), DataDate (date of the session), Data_DateTime (time
% data for the log file). 
%
% Outputs: PhaseLabel (string of phase numbers), PhaseInd (start/stop index
% values), PhaseStart/PhaseStop (start/stop times of each phase), t_0
% (index position to sync time to zero), t_base (index position to mark
% start of baseline [final minute of thermoneutral phase]), TimeTN (time
% array synced to end of thermoneutral)

% Authors: Emily Bush and Crystal Coolbaugh
% Date: October 10, 2017
% Copyright 2017 Emily Bush, Crystal Coolbaugh

function [PhaseLabel, PhaseInd, PhaseStart, PhaseStop, t_0, t_base, TimeTN] = PhaseIDSync(PhaseNum, PhaseStartTime, PhaseStopTime, TNPhase, DataDate, Data_DateTime)

%% Identify Index Positions of Start / End of Experimental Phases
%Set Phase Count Index
ind = 1;
PhaseLabel = zeros(PhaseNum,1);
PhaseInd = zeros(PhaseNum,2);

%Adjust First Phase Start Time if Data Started after Experiment Start
if timeofday(PhaseStartTime(1)) < timeofday(Data_DateTime(1))
    PhaseLabel(ind,1) = ind;
    PhaseInd(ind,1) = 1;
    ind = ind + 1;
end

%Identify Start Index of Experimental Phase in Selected Data Array
for i = 2:length(Data_DateTime)
    tlower = Data_DateTime(i-1);
    tupper = Data_DateTime(i);
    RedCapTime = DataDate + timeofday(PhaseStartTime(ind,1));
    tFind = isbetween(RedCapTime, tlower, tupper);
    
    if tFind == 1
        PhaseLabel(ind,1) = ind;
        PhaseInd(ind,1) = i-1;
        ind = ind + 1;
        if ind > length(PhaseStartTime)
            break
        end
    end
end


%Add End Index of Experimental Phases
for i = 2:PhaseNum
    PhaseInd(i-1,2) = PhaseInd(i,1) - 1;
end

%Identify Final Index for End of Experiment
%Use Final Data Point if Stop Time not included in Data_DateTime
if timeofday(PhaseStopTime(end)) > timeofday(Data_DateTime(end))
    PhaseInd(PhaseNum,2) = length(Data_DateTime);
end

%Search DateTime data for Stop Time
for j = PhaseInd(PhaseNum,1):length(Data_DateTime)
    tlower = Data_DateTime(j-1);
    tupper = Data_DateTime(j);
    RedCapEnd = DataDate + timeofday(PhaseStopTime(end));
    tFind = isbetween(RedCapEnd, tlower, tupper);
    
    if tFind == 1
        PhaseInd(PhaseNum,2) = j-1;
    end
end

%Save Start/End Times for each Phase
PhaseStart = Data_DateTime(PhaseInd(:,1));
PhaseStop = Data_DateTime(PhaseInd(:,2));

%% Create Time Array Synced to End of ThermoNeutral Phase
% Note: User must define the phase number associated with the thermoneutral
% experimental phase. 

%Define Index of End of Thermoneutral
t_0 = PhaseInd(TNPhase,2);

%Create New Time Array Synced to t = 0 @ end of TN phase
TimeTN = Data_DateTime - Data_DateTime(t_0);

%Identify Start of Baseline (final 60s of TN Phase)
BaseLine = intersect(find(TimeTN <= duration(0,-1,0)),find(TimeTN >= duration(0,-2,0)));

%Save Index Position for Start of Baseline Phase
t_base = BaseLine(end);

%Assign Baseline Index to Phase Indices Variable
PhaseInd(TNPhase,1) = t_base;

%Remove Extra Phases if Thermoneutral is not Phase 1
for i = 1:length(PhaseNum)
    if i < TNPhase
        PhaseInd(i,:) = [];
        PhaseLabel(i) = [];
        PhaseStart(i) = [];
        PhaseStop(i) = [];
    end
end         

end


    