%% PCP_Session_Summary 

% Purpose: This code imports a blanketrol data log file, a tGUI data log
% file, and a skin temperature (three temperature probes) data log file 
% recorded during a perception based cooling protocol (PCP). Data from 
% these log files are summarized and plotted.
%
% Inputs: Blanketrol Log File (csv), *tGUI Log File (csv), Skin Temp Log
% File (csv), Phase Time Table (.mat)
%
% *tGUI Log File created with the open source Thermoesthesia GUI available
% on GitHub. [https://github.com/welcheb/Thermoesthesia_GUI]
%
% Outputs: PCPDataSummary Matlab Structure (.mat)
%
% Figures: Water/Set Temp Time Series Plot, Perception of Cooling and
% Shivers Time Series Plot, Skin Temperature Time Series Plot (note:
% figures are not saved by default)
%
% Requirments: B3FileImport, LCFileImport, tGUIFileImport, PhaseIDSync,
% PhaseSummary, ShiverTimes, ExtractPhaseTimes

% Authors: Emily Bush and Crystal Coolbaugh
% Date: October 10, 2017
% Copyright 2017 Emily Bush, Crystal Coolbaugh 


%% Format Workspace
clear 
clc
close all
format compact

%% Choose Data Types for Analysis
% User selects data types (Blanketrol (B3), tGUI, and/or Skin Temp (LabChart) (LC)) for
% analysis. A single or multiple data types can be chosen.

DataTypes = {'Blanketrol', 'tGUI', 'SkinTemp'};

%Create List Diaglog Menu
%Selection = DataType String Selected
%Value = 0 if no selection, 1 if selection
[Selection, Value] = listdlg('PromptString', ...
    'Select the Data Types for Analysis:', 'SelectionMode','multiple',...
    'ListString',DataTypes,'ListSize', [250 200]);

%% Define RegEx Expressions

expression = '(\d{8})_(S\d{1,5})_([^_]*)_([^_]*)';

%% Define Thermoneutral Phase
% User defines the phase number associated with thermoneutral
TNPrompt = 'Enter Phase Number for Thermoneutral:';
TNTitle = 'Thermoneutral Phase Number';
TNLines = 1;
TNDefault = {'1'};
TNInput = inputdlg(TNPrompt,TNTitle,TNLines,TNDefault);
TNPhase = str2num(TNInput{:});


%% Import, Format Time, and Identify Experimental Phases

for i = 1:length(Selection)
    DataAnalysis = DataTypes{Selection(i)};
    
    switch DataAnalysis
        case 'Blanketrol'
            %% Import Blanketrol (B3) Data Log (*.csv)
            [SetTemp, Time, WaterTemp, B3Date, B3_DateTime, B3FileName] = B3FileImport;
            
            % Identify Subject # and Session Type from FileName
            [B3tokens,B3matches] = regexp(B3FileName,expression,'tokens','match');
            SubID=B3tokens{1}{2};
            SessionType=B3tokens{1}{3};

            %% Extract Phase Start Times
            [B3PhaseTimes] = ExtractPhaseTimes(SubID);         
            PhaseStartTime = B3PhaseTimes(:,1);
            PhaseStopTime = B3PhaseTimes(:,2);
            PhaseNum = length(PhaseStartTime);
            
            %% Identify Experimental Phases / Sync to End of TN Phase
            [B3PhaseLabel, B3PhaseInd, B3PhaseStart, B3PhaseStop, ...
                B3t_0, B3t_base, B3TimeTN] = PhaseIDSync(PhaseNum, ...
                PhaseStartTime, PhaseStopTime, TNPhase, B3Date, B3_DateTime);
            
            %% Experimental Phase Summary
            % Set Temperature
            [SetTempSum] = PhaseSummary(B3PhaseLabel, B3PhaseInd, SetTemp, B3TimeTN, 0);
            % Water Temperature
            [WaterTempSum] = PhaseSummary(B3PhaseLabel, B3PhaseInd, WaterTemp, B3TimeTN, 1);
            
            % Merge Set / Water Temperature
            B3Sum = join(SetTempSum, WaterTempSum);
            
            % Add to Structure
            PCPDataSummary.B3=B3Sum;
            
            %% Plot Set / Water Temperature
            % Plot Properties
            fig = figure();
            fig.Color = 'white';
            
            % Create Phase Lines for Plot
            % Water Temperature
            for n = 1:length(B3PhaseInd)
                for j = 1:35
                    TempPhaseLineX(j,n) = minutes(B3TimeTN(B3PhaseInd(n,1)));
                    TempPhaseLineY(j,n) = j;
                end
            end
            
            % Truncate Time and Variables to Baseline -> End of Data
            B3TimeTrim = B3TimeTN(B3PhaseInd(1,1):B3PhaseInd(end,2));
            SetTempTrim = SetTemp(B3PhaseInd(1,1):B3PhaseInd(end,2));
            WaterTempTrim = WaterTemp(B3PhaseInd(1,1):B3PhaseInd(end,2));
            
            % Plot Set / Water Temperature
            plot(minutes(B3TimeTrim),SetTempTrim, 'Color', ...
                [(255/255) (182/255) (108/255)], 'LineWidth', 4', ...
                'DisplayName', 'Set'); hold on;
            plot(minutes(B3TimeTrim), WaterTempTrim, 'Color', ...
                [(40/255) (145/255) (178/255)], 'LineWidth', 4, ...
                'DisplayName','H20');
            s = sprintf('Water | Set Temp %cC', char(176));
            legend('Set', 'Water', 'Location', 'Best');
            
            plot(TempPhaseLineX, TempPhaseLineY, '--','LineWidth', 1, ...
                'Color', [0.55 0.55 0.55]); hold off;
            ylabel(s); ylim([0 35]);
            title([SubID ' ' SessionType])
            
            % Axis Properties
            ax1 = gca;
            ax1.YTick=[0 5 15 25 35];
            ax1.Box = 'off';
            ax1.LineWidth = 1;
            ax1.FontSize = 14;
            ax1.XLabel.String = 'Time (min)';
            ax1.XLabel.FontSize = 14;
            

        case 'tGUI'
            %% Import tGUI Log (*.csv)
            [level, s, shiver, tGUIDate, tGUI_DateTime, tGUIFileName] = tGUIFileImport;
           
            % Identify Subject # and Session Type from FileName
            [tGUItokens,tGUImatches] = regexp(tGUIFileName,expression,'tokens','match');
            SubID=tGUItokens{1}{2};
            SessionType=tGUItokens{1}{3};
            
            %% Extract Phase Start Times 
            [tGUIPhaseTimes] = ExtractPhaseTimes(SubID);
            PhaseStartTime = tGUIPhaseTimes(:,1);
            PhaseStopTime = tGUIPhaseTimes(:,2);
            PhaseNum = length(PhaseStartTime);
            
            %% Identify Experimental Phases / Sync to End of TN Phase
            [tGUIPhaseLabel, tGUIPhaseInd, tGUIPhaseStart, tGUIPhaseStop, ...
                tGUIt_0, tGUIt_base, tGUITimeTN] = PhaseIDSync(PhaseNum, ...
                PhaseStartTime, PhaseStopTime, TNPhase, tGUIDate, tGUI_DateTime);
            
            %% Summarize Shivering Times 
            [ShiverData] = ShiverTimes(shiver, tGUI_DateTime);
            
            %% Experimental Phase Summary
            % Perception of Cold (level)
            [levelSum] = PhaseSummary(tGUIPhaseLabel, tGUIPhaseInd, ...
                level, tGUITimeTN,1);
            
            % Add to Structure
            PCPDataSummary.ColdPercept=levelSum;
            
            %% Plot tGUI Level / Shiver
            % Plot Properties
            fig = figure();
            fig.Color = 'white';
            
            % Create Phase Lines for Plot
            % tGUI Level
            for n = 1:length(tGUIPhaseInd)
                for j = 1:55
                    tGUIPhaseLineX(j,n) = minutes(tGUITimeTN(tGUIPhaseInd(n,1)));
                    tGUIPhaseLineY(j,n) = j;
                end
            end
            
            % Truncate Time and Variables to Baseline -> End of Data
            tGUITimeTrim = tGUITimeTN(tGUIPhaseInd(1,1):tGUIPhaseInd(end,2));
            levelTrim = level(tGUIPhaseInd(1,1):tGUIPhaseInd(end,2));
            shiverTrim = shiver(tGUIPhaseInd(1,1):tGUIPhaseInd(end,2));
            
            % Plot Perception of Cold / Shiver Status
            plot(minutes(tGUITimeTrim),levelTrim, 'LineWidth', 4, ...
                'Color', [(255/255) (101/255) (92/255)],'DisplayName', 'tGUI'); hold on;
            plot(minutes(tGUITimeTrim(shiverTrim==1)), shiverTrim(shiverTrim==1)*51,'.', ...
                'Color', [0.45    0.45   0.45], 'LineWidth', 2, ...
                'MarkerSize', 10,'DisplayName', 'Shiver');
            legend('Perception', 'Shiver', 'Location', 'Best'); ylim([0 55]);
            plot(tGUIPhaseLineX, tGUIPhaseLineY, '--','LineWidth', 1, ...
                'Color', [0.55 0.55 0.55]); hold off;
            title([SubID ' ' SessionType])
            
            % Axis Properties
            ax2 = gca;
            ax2.Box = 'off';
            ax2.LineWidth = 1;
            ax2.FontSize = 14;
            ax2.XLabel.String = 'Time (min)';
            ax2.XLabel.FontSize = 14;
            ax2.YTick=[0 10 20 30 40 50];
            ax2.YTickLabel={'V.Cold', 'Cold', 'S.Cold', 'Cool', 'S.Cool', 'Neutral'};
            
          
        case 'SkinTemp'
            %% Import Skin Temp (LabChart) Log (*.csv)
            [ClavTemp, ArmTemp, FingTemp, LCDate, LC_DateTime, LCFileName] = LCFileImport;
            
            % Identify Subject # and Session Type from FileName
            [LCtokens,B3matches] = regexp(LCFileName,expression,'tokens','match');
            SubID=LCtokens{1}{2};
            SessionType=LCtokens{1}{3};

             %% Extract Phase Start Times
            [LCPhaseTimes] = ExtractPhaseTimes(SubID);
            PhaseStartTime = LCPhaseTimes(:,1);
            PhaseStopTime = LCPhaseTimes(:,2);
            PhaseNum = length(PhaseStartTime);
            
            %% Identify Experimental Phases / Sync to End of TN Phase
            [LCPhaseLabel, LCPhaseInd, LCPhaseStart, LCPhaseStop, ...
                LCt_0, LCt_base, LCTimeTN] = PhaseIDSync(PhaseNum, ...
                PhaseStartTime,PhaseStopTime,TNPhase, LCDate, LC_DateTime);
            
            %% Experimental Phase Summary
            % Clavicle Temperature
            [ClavSum] = PhaseSummary(LCPhaseLabel,LCPhaseInd, ClavTemp, ...
                LCTimeTN, 1);
            % Arm Temperature
            [ArmSum] = PhaseSummary(LCPhaseLabel,LCPhaseInd, ArmTemp, ...
                LCTimeTN, 1);
            % Finger Temperature
            [FingSum] = PhaseSummary(LCPhaseLabel,LCPhaseInd, FingTemp, ...
                LCTimeTN, 1);
            % Vasoconstriction Gradient (Arm-Finger)
            [VCSum] = PhaseSummary(LCPhaseLabel,LCPhaseInd, ...
                (ArmTemp-FingTemp), LCTimeTN, 1);
            
            % Add to Structure
            PCPDataSummary.ClavTemp=ClavSum;
            PCPDataSummary.ArmTemp=ArmSum;
            PCPDataSummary.FingTemp=FingSum;
            PCPDataSummary.VCTemp=VCSum;
            
            %% Plot Skin Temperatures
            % Plot Properties
            fig = figure();
            fig.Color = 'white';
            
            % Create Phase Lines for Plot
            % Skin Temperature
            for n = 1:length(LCPhaseInd)
                for j = 1:40
                    SkinPhaseLineX(j,n) = minutes(LCTimeTN(LCPhaseInd(n,1)));
                    SkinPhaseLineY(j,n) = j;
                end
            end
            
            % Truncate Time and Variables to Baseline -> End of Data
            LCTimeTrim = LCTimeTN(LCPhaseInd(1,1):LCPhaseInd(end,2));
            ClavTrim = ClavTemp(LCPhaseInd(1,1):LCPhaseInd(end,2));
            ArmTrim = ArmTemp(LCPhaseInd(1,1):LCPhaseInd(end,2));
            FingTrim = FingTemp(LCPhaseInd(1,1):LCPhaseInd(end,2));
            
            % Plot Skin Temperature
            % Clavicle Color: 152 36 204
            % Arm Color: 255 194 71
            % Finger Color: 101 255 182
            plot(minutes(LCTimeTrim),ClavTrim, ...
                'Color',[0.5961    0.1412    0.8],...
                'LineWidth', 4, 'DisplayName', 'Clavicle'); hold on;
            plot(minutes(LCTimeTN(LCPhaseInd(1,1):LCPhaseInd(end,2))),...
                ArmTemp(LCPhaseInd(1,1):LCPhaseInd(end,2)),...
                'Color', [1    0.7608    0.2784], ...
                'LineWidth', 4, 'DisplayName', 'Arm'); hold on;
            plot(minutes(LCTimeTN(LCPhaseInd(1,1):LCPhaseInd(end,2))),...
                FingTemp(LCPhaseInd(1,1):LCPhaseInd(end,2)),...
                'Color', [0.3961    1.0    0.7137], ...
                'LineWidth', 4, 'DisplayName', 'Finger'); hold on;
            legend('Clavicle', 'Arm', 'Finger','Location', 'SouthWest');
            plot(SkinPhaseLineX, SkinPhaseLineY, '--','LineWidth', 1, ...
                'Color', [0.55 0.55 0.55]); hold off;
            s2 = sprintf('Skin Temp %cC', char(176));
            ylabel(s2); ylim([15 40]);
            title([SubID ' ' SessionType])
            
            % Axis Properties
            ax3 = gca;
            ax3.Box = 'off';
            ax3.LineWidth = 1;
            ax3.FontSize = 14;
            ax3.XLabel.String = 'Time (min)';
            ax3.XLabel.FontSize = 14;
        
            
        otherwise
            warning('Unexpected data type selected. No analysis performed')
    end
end

%% Save Session

% Close Figures before Saving
FigClose = menu('Close Figures before Saving Matlab Session?', 'Yes', 'No');
if FigClose == 1
    close all
end

% Save entire workspace to ...\Processed\S###_MatlabSession
SessionSave=horzcat(SubID,'_',SessionType,'_MatlabSession');
save(SessionSave)








