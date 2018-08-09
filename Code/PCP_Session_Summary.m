%% PCP_Session_Summary 

% Purpose: This code imports a blanketrol data log file, a tGUI data log
% file, and skin temperature data (multiple iButton log files)
% recorded during a perception based cooling protocol (PCP). Data from 
% these log files are summarized and plotted.
%
% Inputs: Blanketrol Log File (csv), *tGUI Log File (csv), Skin Temp Log
% Files (csv), Phase Time Table (mat), iButton Start Time Table (mat)
%
% *tGUI Log File created with the open source Thermoesthesia GUI available
% on GitHub. [https://github.com/welcheb/Thermoesthesia_GUI]
%
% *iButton Sensors: 18 iButton sensors were used in the example data. The
% code assumes the iButton sensors were programmed to start at the same
% time of day and at a sample rate of 1 sample/minute. Refer to the GitHub 
% Data Dictionary for more information about the iButton sensors. 
%
% Outputs: PCPDataSummary Matlab Structure (.mat)
%
% Figures: Water/Set Temp Time Series Plot, Perception of Cooling and
% Shivers Time Series Plot, Skin Temperature Time Series Plot (note:
% figures are not saved by default)
%
% Requirments: B3FileImport, iButtonFileImport, tGUIFileImport, PhaseIDSync,
% PhaseSummary, ShiverTimes, ExtractPhaseTimes, ExtractiButtonStartTime
%
% *ExtractPhaseTimes - modify this function to import the version of the
% PhaseTable depending on the example data used (i.e. S0000 vs. S0001 for
% versions v0 and v1 respectively).
%
% Authors: Emily Bush and Crystal Coolbaugh
% Date: October 10, 2017
% Copyright 2017 Emily Bush, Crystal Coolbaugh 
%
% Versions: 
%   - v0.0.0 - Imports skin temperature data from LabChart format
%   - v1.0.0 - Imports skin temperature data from iButton sensors
%
% History: 
%   - 20180510 (CLC) - Updated skin temperature measurements and log files
%   to use iButton temperature files. This version is no longer compatible
%   with temperature data collected with LabChart. Use version 0.#.# for
%   LabChart compatability.


%% Format Workspace
clear 
clc
close all
format compact

%% Choose Data Types for Analysis
% User selects data types (Blanketrol (B3), tGUI, and/or Skin Temp (iButton) for
% analysis. A single or multiple data types can be chosen.

DataTypes = {'Blanketrol', 'tGUI', 'SkinTemp'};

%Create List Diaglog Menu
%Selection = DataType String Selected
%Value = 0 if no selection, 1 if selection
[Selection, Value] = listdlg('PromptString', ...
    'Select the Data Types for Analysis:', 'SelectionMode','multiple',...
    'ListString',DataTypes,'ListSize', [250 200]);

%% Define RegEx Expressions

%Requires FileNames with the Following Format:
% YYYYMMDD_S####_SessionID_EquipID ...

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
            disp('Select the Blanketrol File to Import')
            [SetTemp, Time, WaterTemp, B3Date, B3_DateTime, B3FileName] = B3FileImport;
            
            % Identify Subject # and Session Type from FileName
            [B3tokens,B3matches] = regexp(B3FileName,expression,'tokens','match');
            SubID=B3tokens{1}{2};
            SessionType=B3tokens{1}{3};

            %% Extract Phase Start Times
            disp('Select the folder directory containing the PhaseTables.mat file')
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
            PCPData.Summary.B3=B3Sum;
            
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
            p1 = plot(minutes(B3TimeTrim),SetTempTrim, 'Color', ...
                [(255/255) (182/255) (108/255)], 'LineWidth', 4', ...
                'DisplayName', 'Set'); hold on;
            p2 = plot(minutes(B3TimeTrim), WaterTempTrim, 'Color', ...
                [(40/255) (145/255) (178/255)], 'LineWidth', 4, ...
                'DisplayName','H20');
            s = sprintf('Water | Set Temp %cC', char(176));            
            p3 = plot(TempPhaseLineX, TempPhaseLineY, '--','LineWidth', 1, ...
                'Color', [0.55 0.55 0.55]); hold off;
            ylabel(s); ylim([0 35]);
            title('Blanketrol Data')
            legend([p1, p2], {'Set', 'Water'}, 'Location', 'SouthWest');legend('boxoff');
            
            
            % Axis Properties
            ax1 = gca;
            ax1.YTick=[0 5 15 25 35];
            ax1.Box = 'off';
            ax1.LineWidth = 1;
            ax1.FontSize = 14;
            ax1.XLabel.String = 'Time (min)';
            ax1.XLabel.FontSize = 14;
            

            %% Add B3 Data to Structure
            PCPData.B3Time = B3TimeTrim;
            PCPData.Water = WaterTempTrim;
            PCPData.Set = SetTempTrim;
            
        case 'tGUI'
            %% Import tGUI Log (*.csv)
            disp('Select the tGUI Log File')
            [level, s, shiver, tGUIDate, tGUI_DateTime, tGUIFileName] = tGUIFileImport;
           
            % Identify Subject # and Session Type from FileName
            [tGUItokens,tGUImatches] = regexp(tGUIFileName,expression,'tokens','match');
            SubID=tGUItokens{1}{2};
            SessionType=tGUItokens{1}{3};
            
            %% Extract Phase Start Times 
            disp('Select the folder directory containing the PhaseTables.mat file')
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
            PCPData.Summary.ColdPercept=levelSum;
            
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
            p4 = plot(minutes(tGUITimeTrim),levelTrim, 'LineWidth', 4, ...
                'Color', [(255/255) (101/255) (92/255)],'DisplayName', 'tGUI'); hold on;
            p5 = plot(minutes(tGUITimeTrim(shiverTrim==1)), shiverTrim(shiverTrim==1)*51,'.', ...
                'Color', [0.45    0.45   0.45], 'LineWidth', 2, ...
                'MarkerSize', 10,'DisplayName', 'Shiver');ylim([0 55]);
            p6 = plot(tGUIPhaseLineX, tGUIPhaseLineY, '--','LineWidth', 1, ...
                'Color', [0.55 0.55 0.55]); hold off;
            legend([p4 p5],{'Perception', 'Shiver'}, 'Location', 'SouthWest'); legend('boxoff');            
            title('tGUI Data')
            
            % Axis Properties
            ax2 = gca;
            ax2.Box = 'off';
            ax2.LineWidth = 1;
            ax2.FontSize = 14;
            ax2.XLabel.String = 'Time (min)';
            ax2.XLabel.FontSize = 14;
            ax2.YTick=[0 10 20 30 40 50];
            ax2.YTickLabel={'V.Cold', 'Cold', 'S.Cold', 'Cool', 'S.Cool', 'Neutral'};
                    

             %% Add tGUI Data to Structure
            PCPData.tGUITime = tGUITimeTrim;
            PCPData.level = levelTrim;
            PCPData.shiver = shiverTrim;
            
        case 'SkinTemp'
            %% User Selects iButton Skin Temperature Log Files (*.csv)
            disp('Select the iButton Files (i##). Hold the Shift Key to Select All of the Files.')
            [iButtonFiles, iButtonPath] = uigetfile('*.csv',...
                'Select iButton Files (Hold Shift Key to Select Multiple Files)', ...
                'MultiSelect', 'on');
            
            % Identify Subject #, Session Type from FileName
            [STtokens,B3matches] = regexp(iButtonFiles{1},expression,'tokens','match');
            SubID=STtokens{1}{2};
            SessionType=STtokens{1}{3};
            
            %% Import iButton Start Time & Session Date
            disp('Select the folder directory containing the iButtonStartTime.mat file')
            iButtonStart=ExtractiButtonStartTime(SubID);
            
            %Extract iButton Date from Filename
            iButtonFileName=iButtonFiles{1};
            iButtonDate=datetime(iButtonFileName(1:8),'InputFormat','yyyyMMdd');
          
            %% Extract Phase Start Times
            disp('Select the folder directory containing the PhaseTables.mat file')
            [PhaseTimes] = ExtractPhaseTimes(SubID);
            PhaseStartTime = PhaseTimes(:,1);
            PhaseStopTime = PhaseTimes(:,2);
            PhaseNum = length(PhaseStartTime);
            
            %% Import iButton Temperature Data
            % Saves iButton Temperature Data for each sensor to a separate
            % numeric array in the structure iButtonData
            iButtonData = struct('Temp',[]);
            
            for n = 1:length(iButtonFiles)
                filename = horzcat(iButtonPath,iButtonFiles{1,n});
                iButtonData(n).Temp = iButtonFileImport(filename);
                
                %Create iButton Time Vector
                %Set First Value to iButton Start
                %Add Time in 1 minute increments (iButton sample rate)
                for m=1:length(iButtonData(n).Temp)
                    if m==1
                        iButtonData(n).Time(m,1) = iButtonDate+timeofday(iButtonStart);
                    else
                        iButtonData(n).Time(m,1) = iButtonData(n).Time((m-1),1)+minutes(1);
                    end
                end
                
                %Identify Experimental Phases / Sync to End of TN Phase
                [iButtonData(n).PhaseLabel,iButtonData(n).PhaseInd, iButtonData(n).PhaseStart, iButtonData(n).PhaseStop, ...
                    iButtonData(n).t_0, iButtonData(n).t_base, iButtonData(n).TimeTN] = PhaseIDSync(PhaseNum, ...
                    PhaseStartTime,PhaseStopTime,TNPhase,iButtonDate,iButtonData(n).Time);
                
                % Trim iButton Data from TN to End of Experimental Phases
                iButtonData(n).TempTN = iButtonData(n).Temp(iButtonData(n).t_0:iButtonData(n).PhaseInd(end,2));
            
            end
            
            % Create Common Time Vector (TN Synced) for all iButton Sensors
            iButtonTime = iButtonData(1).TimeTN(iButtonData(n).t_0:iButtonData(1).PhaseInd(end,2));
            
            % Update Phase Index Positions for Trimmed Data Set
            iButtonPhases = iButtonData(1).PhaseInd(:,:) - iButtonData(1).PhaseInd(1,1);
            % Correct Zero Index in First Row - Prevents Error when Calling
            % Zeroth Position in Time Array
            iButtonPhases(1,1) = 1;
            iButtonPhases(1,2) = 2;
            
            %% Calculate Skin Temperature Equations
            
            % Mean Body Temperature: 14 ISO 9886-2004
            %(Forehead*0.07)+(Neck*0.07)+(Right Scapula*0.07)+
            %(Left Chest*0.07)+(Right Deltoid*0.07)+(Left Elbow*0.07)+
            %(Right Abdomen*0.07)+(Left Hand*0.07)+(Left Lumbar *0.07)+
            %(Right Thigh*0.07)+(Left Hamstring*0.07)+(Right Shinbone*0.07)+
            %(Left Gastrocnemius*0.07)+(Right Instep*0.07)
            
            MnBodyTemp = 0; %pre-allocate array for mean body temp
            for iButton = 1:14
                MnBodyTemp = MnBodyTemp + iButtonData(i).TempTN*0.07;
            end
            
            % Body Temperature Gradient: Boon et al. 2014
            %(Left Hand+Right Instep)/2-(Right Thigh*0.383)+
            %(Right Clavicular*0.293)+(Right Abdomen*0.324)
            GrdBodyTemp = (iButtonData(8).TempTN + iButtonData(14).TempTN)/2 - ...
                ((iButtonData(10).TempTN*0.383)+(iButtonData(15).TempTN*0.293)+(iButtonData(7).TempTN*0.324));
                
            % Peripheral Vasoconstriction:
            % (Left Forearm - Left Middle Finger)
            VCTemp = iButtonData(17).TempTN - iButtonData(18).TempTN;
            
            % Supraclavicular Temperature Gradient: Lee et al. 2011
            %(Right Supraclavicular(S) - Right Chest (RC))
            GrdClavTemp = iButtonData(15).TempTN - iButtonData(16).TempTN;
                   
            
            %% Experimental Phase Summary
            % Mean Body Temperature
            [MnBodyTempSum] = PhaseSummary(iButtonData(1).PhaseLabel, ...
                iButtonPhases, MnBodyTemp, iButtonTime, 1);
                        
            % Body Temperature Gradient
            [GrdBodyTempSum] = PhaseSummary(iButtonData(1).PhaseLabel, ...
                iButtonPhases, GrdBodyTemp, iButtonTime, 1);
            
            % Peripheral Vasoconstriction
            [VCTempSum] = PhaseSummary(iButtonData(1).PhaseLabel, ...
                iButtonPhases, VCTemp, iButtonTime, 1);

            % Supraclavicular Temperature Gradient
            [GrdClavTempSum] = PhaseSummary(iButtonData(1).PhaseLabel, ...
                iButtonPhases, GrdClavTemp, iButtonTime, 1);
                       
            % Add to Structure
            PCPData.Summary.MnBodyTemp=MnBodyTempSum;
            PCPData.Summary.GrdBodyTemp=GrdBodyTempSum;
            PCPData.Summary.VCTemp=VCTempSum;
            PCPData.Summary.GrdClavTemp=GrdClavTempSum;
            
            %% Plot Skin Temperatures
            fig = figure();
            
            % Create Phase Lines for Plot
            % Skin Temperature
            for n = 1:length(iButtonPhases)
                idx = -10;
                for j = 1:50
                    SkinPhaseLineX(j,n) = minutes(iButtonTime(iButtonPhases(n,1)));
                    SkinPhaseLineY(j,n) = idx;
                    idx = idx + 1;
                end
            end
                      
            % Plot Skin Temperature
            % Mean Body Temp Color: 23 190 207
            % Gradient Body Temp Color: 188 189 34
            % Vasoconstriction Color: 127 127 127
            % Clavicle Gradient Color: 227 119 194
            
            ax(1) = subplot(2,2,1,'Color','w');           
            plot(minutes(iButtonTime), MnBodyTemp, ...
                'Color',[23/255 190/255 207/255],...
                'LineWidth', 3, 'DisplayName', 'Mean');
            title('Mean Body Temperature');hold on;
            plot(SkinPhaseLineX, SkinPhaseLineY, '--', 'LineWidth', 1, ...
                'Color', [0.55 0.55 0.55]); ylim([10 35]);xlim([-10 70]);  
            ax(1).YTick=[20 25 30 35 40]; hold off;
            
            ax(2) = subplot(2,2,2,'Color','w'); 
            plot(minutes(iButtonTime), GrdBodyTemp, ...
                'Color', [188/255 189/255 34/255], ...
                'LineWidth', 3, 'DisplayName', 'Gradient');
            title('Body Temperature Gradient');hold on;
            plot(SkinPhaseLineX, SkinPhaseLineY, '--', 'LineWidth', 1, ...
                'Color', [0.55 0.55 0.55]); ylim([-8 4]);
            ax(2).YTick = [-6 -4 -2 0]; hold off;
            
            ax(3) = subplot(2,2,3,'Color','w'); 
            plot(minutes(iButtonTime), VCTemp,...
                'Color', [127/255 127/255 127/255], ...
                'LineWidth', 3, 'DisplayName', 'Vasoconstriction'); 
            title('Vasoconstriction');hold on;
            plot(SkinPhaseLineX, SkinPhaseLineY, '--', 'LineWidth', 1, ...
                'Color', [0.55 0.55 0.55]);ylim([-5 15]); 
            ax(3).YTick=[-5 0 5 10 15];hold off;    
                
            ax(4) = subplot(2,2,4,'Color','w'); 
            plot(minutes(iButtonTime), GrdClavTemp, ...
                'Color', [227/255 119/255 194/255], ...
                'LineWidth', 3, 'DisplayName', 'Clavicle');
            title('Clavicle Temperature Gradient'); hold on;
            plot(SkinPhaseLineX, SkinPhaseLineY, '--', 'LineWidth', 1, ...
                'Color', [0.55 0.55 0.55]); ylim([-2 8]);
            ax(4).YTick=[-5 0 5]; hold off;
                       
            %Link X Axes
            linkaxes(ax(:),'x');
            
            % Y Axis Label
            s2 = sprintf('Temperature %cC', char(176));
            
            %Set Axis Properties
            for j = 1:4
                ax(j).Box = 'off';
                ax(j).LineWidth = 1;
                ax(j).FontSize = 14;
                ax(j).XTick=[-10 0 10 20 30 40 50 60 70];
                ax(j).XLabel.String = 'Time (min)';
                ax(j).XLabel.FontSize = 14;
                ax(j).YLabel.String = s2;
            end
            
            fig.Color = 'white';
            
            %% Add SkinTemp Data to Structure
            PCPData.STTime = iButtonTime;
            PCPData.MnTemp = MnBodyTemp;
            PCPData.GrTemp = GrdBodyTemp;
            PCPData.VCTemp = VCTemp;
            PCPData.ClTemp = GrdClavTemp;
            
        otherwise
            warning('Unexpected data type selected. No analysis performed')
    end
end

%% Save Session

% Close Figures before Saving
FigClose = menu('Close Figures before Saving Matlab Session?', 'Yes', 'No');
if FigClose == 1
    clc
    close all
end

% Save entire MATLAB workspace to ...S###_MatlabSession
SessionSave=horzcat(SubID,'_','MatlabSession');
save(SessionSave)













