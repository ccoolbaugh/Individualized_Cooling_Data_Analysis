%% Labchart File Import Function
%
% Purpose: This code imports a skin temp log file. The log file is in a
% comma-separated-value (.csv) format and contains skin temperature data. 
% The function imports a data array containing the sensor data and a log 
% time stamp. The date time stamp information in the filename is imported 
% to create a datetime variable. Note, this function
% was modified from the default code auto-generated with the Matlab Import
% Data tool. 
%
% File Log Note: Labchart Version 8 DataPad software was used to create the
% example skin temperature log file. Other software programs should be
% compatible if they adhere to a similar .csv file format. 
%
% Inputs: Skin Temperature .csv log file (log time stamps 'Sel Start' and
% 'Sel End' should be read as the time of day HH:MM:SS format).
%
% Outputs: Clavicle, Arm, and Finger Skin Temperatures, Date/Time, FileName
%
% Note: Extraction of the correct date from the file name assumes a file
% name of the format: YYYYMMDD_S###_SessionType_SkinTemp.csv

% Authors: Emily Bush and Crystal Coolbaugh
% Date: October 10, 2017
% Copyright 2017 Emily Bush, Crystal Coolbaugh

%% Import Skin Temperature (Labchart) Data

function[ClavTemp, ArmTemp, FingTemp, LCDate, LC_DateTime, LCFileName] = LCFileImport
%% Initialize variables.
[LCFileName, pathname] = uigetfile('*.csv','Select the Skin Temp Data File.');
filename = horzcat(pathname,LCFileName);

clear tokens matches
expression = '(\d{8})_(S\d{1,5})_([^_]*)_([^_]*)';


delimiter = ',';

%% Read columns of data as strings:
formatSpec = '%s%s%s%s%s%s%s%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to format string.
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);

%% Close the text file.
fclose(fileID);

%% Convert the contents of columns containing numeric strings to numbers.
% Replace non-numeric strings with NaN.
raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
for col=1:length(dataArray)-1
    raw(1:length(dataArray{col}),col) = dataArray{col};
end
numericData = NaN(size(dataArray{1},1),size(dataArray,2));

for col=[1,2,3,4,5]
    % Converts strings in the input cell array to numbers. Replaced non-numeric
    % strings with NaN.
    rawData = dataArray{col};
    for row=1:size(rawData, 1);
        % Create a regular expression to detect and remove non-numeric prefixes and
        % suffixes.
        regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\,]*)+[\.]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\,]*)*[\.]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
        try
            result = regexp(rawData{row}, regexstr, 'names');
            numbers = result.numbers;
            
            % Detected commas in non-thousand locations.
            invalidThousandsSeparator = false;
            if any(numbers==',');
                thousandsRegExp = '^\d+?(\,\d{3})*\.{0,1}\d*$';
                if isempty(regexp(thousandsRegExp, ',', 'once'));
                    numbers = NaN;
                    invalidThousandsSeparator = true;
                end
            end
            % Convert numeric strings to numbers.
            if ~invalidThousandsSeparator;
                numbers = textscan(strrep(numbers, ',', ''), '%f');
                numericData(row, col) = numbers{1};
                raw{row, col} = numbers{1};
            end
        catch me
        end
    end
end

%% Split data into numeric and cell columns.
rawNumericColumns = raw(:, [1,2,3,4,5]);
rawCellColumns = raw(:, [6,7]);


%% Exclude rows with non-numeric cells
I = ~all(cellfun(@(x) (isnumeric(x) || islogical(x)) && ~isnan(x),rawNumericColumns),2); % Find rows with non-numeric cells
rawNumericColumns(I,:) = [];
rawCellColumns(I,:) = [];

%% Allocate imported array to column variable names
ClavTemp = cell2mat(rawNumericColumns(:,3));
ArmTemp = cell2mat(rawNumericColumns(:,4));
FingTemp = cell2mat(rawNumericColumns(:,5));

SelEnd = rawCellColumns(:,2);

%% Convert LCTime -> Get Date String of HH:mm:ss of LCTime -> Convert HH:mm:ss Date String to Date String Time -> LC Date Time w/ Date

[tokens,matches] = regexp(LCFileName,expression,'tokens','match');
LCDate=tokens{1}{1};
LCDate=datetime(LCDate,'InputFormat', 'yyyyMMdd');


% LCDate = datetime(LCFileName(1:8),'InputFormat', 'yyyyMMdd');

for n=1:length(SelEnd)
    LC_DateString(n,1) = datetime(datestr(SelEnd(n)),'Format', 'HH:mm:ss'); %Convert string to HH:mm:ss format
    LC_DateTime(n,1) = LCDate+timeofday(LC_DateString(n,1));  %Include date with timestamp
end

%% Clear temporary variables
clearvars filename delimiter formatSpec fileID dataArray raw col numericData rawData row regexstr result numbers invalidThousandsSeparator thousandsRegExp me rawNumericColumns rawCellColumns I J K;

end