%% Phase Summary Function
%
% Purpose: This code summarizes information from a data log file (e.g. B3,
% tGUI, or SkinTemp) according to the phases of the perception-based
% cooling protocol (PCP) session. Phase start and stop times must be
% previously imported from a phase time log table. The phase label, index
% positions (start/stop), variable of interest, time, and data type (single
% value per phase or continuous values) are imported. A summary table
% containing the phase duration, max, min, mean, standard deviation,
% change, rate of change, and phase start/stop times is output. 
%
% Inputs: PhaseLabel (number of current phase), PhaseIndices (array
% positions for the start/end of the phase), Variable (data array of
% interest), time (array time values), DataType (0 = single value or 1 =
% continuous value)
%
% Outputs: VariableSummary (Matlab Table)
%
% Requires: Phase Start/Stop Indices, Phase Label

% Authors: Emily Bush and Crystal Coolbaugh
% Date: October 10, 2017
% Copyright 2017 Emily Bush, Crystal Coolbaugh

function [VariableSummary] = PhaseSummary(PhaseLabel,PhaseIndices,Variable,Time,DataType)

%% Summarize Variable Statistics per Experimental Phase
if DataType == 0  % Single Value per Phase (e.g. Set Temperature)
    % Assign value at end of phase
    for i = 1:length(PhaseIndices)
        VarValue(i,1) = Variable(PhaseIndices(i,2));
    end

    % Format Variable Summary Table for Export
    VarNames = {'Phase', 'Value'};
    VariableSummary = table(PhaseLabel, VarValue,'VariableNames', VarNames);

elseif DataType == 1
    for i = 1:length(PhaseIndices)
        % Phase Duration - input in duration format
        PhaseDur(i,1) = minutes(Time(PhaseIndices(i,2)) - Time(PhaseIndices(i,1)));
        
        % Variable Max
        VarMax(i,1) = max(Variable(PhaseIndices(i,1):PhaseIndices(i,2)));
        
        % Variable Min
        VarMin(i,1) = min(Variable(PhaseIndices(i,1):PhaseIndices(i,2)));
        
        % Variable Mean
        VarMean(i,1) = mean(Variable(PhaseIndices(i,1):PhaseIndices(i,2)));
        
        % Variable Standard Deviation
        VarSD(i,1) = std(Variable(PhaseIndices(i,1):PhaseIndices(i,2)));
        
        % Variable Delta
        VarDelta(i,1) = Variable(PhaseIndices(i,2)) - Variable(PhaseIndices(i,1));
        
        % Variable Rate - Delta / Duration
        VarRate(i,1) = VarDelta(i,1) / PhaseDur (i,1);
        
        % Phase Start 
        VarStart(i,1) = PhaseIndices(i,1);
        
        % Phase Stop
        VarStop(i,1) = PhaseIndices(i,2);
    end
    
    %% Format Variable Summary Table for Export
    VarNames = {'Phase','Time', 'Max', 'Min', 'Mean', 'SD', 'Delta', 'Rate', 'StartInd', 'StopInd'};
    VariableSummary = table(PhaseLabel, PhaseDur, VarMax, VarMin, VarMean, ...
        VarSD, VarDelta, VarRate, VarStart, VarStop, 'VariableNames', VarNames);
end

end




