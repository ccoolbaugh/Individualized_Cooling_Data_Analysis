%% Blanketrol III File Import Function
%
% Purpose: This code imports a Blanketrol III water-circulating blanket log
% file. The log file is a comma-separated-value (.csv) format. The function
% imports a data array containing the log time (hh:mm:ss), water
% temperature, and set-point temperature. The date stamp information in the
% filename is imported to create a date-time string. Note, this function
% was modified from the default code auto-generated with the Matlab Import
% Data tool. 
%
% Inputs: BIII .csv log file
%
% Note: Extraction of the correct date from the file name assumes a file
% name of the format: YYYYMMDD_S###_SessionType_B3.csv
%
% Outputs: Set Temp, Time, WaterTemp, BIII Date/Time, BIII Filename 

% Authors: Emily Bush and Crystal Coolbaugh
% Date: October 10, 2017
% Copyright 2017 Emily Bush, Crystal Coolbaugh

%% Import Blanketrol III Data

function [SetTemp, Time, WaterTemp, B3Date, B3_DateTime, B3FileName] = B3FileImport
%% Initialize variables.

% B3FileName=findBATfile(SubNum,SessionType,'B3',RawPath);
% filename = horzcat(RawPath,B3FileName);

[B3FileName, pathname] = uigetfile('*.csv','Select the B3 Data File.');
filename = horzcat(pathname,B3FileName);
clear tokens matches
expression = '(\d{8})_(S\d{1,5})_([^_]*)_([^_]*)';

delimiter = ',';
startRow = 2;

%% Format string for each line of text:
%   column2: datetimes (%{HH:mm:ss}D)
%	column5: double (%f)
%   column7: double (%f)
formatSpec = '%*q%{HH:mm:ss}D%*q%*q%f%*q%f%*s%*s%*s%*s%*s%*s%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to format string.
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'EmptyValue' ,NaN,'HeaderLines' ,startRow-1, 'ReturnOnError', false);

%% Close the text file.
fclose(fileID);

%% Create output variable
B3File = table(dataArray{1:end-1}, 'VariableNames', {'Time','WaterTemp','SetPoint'});

WaterTemp=table2array(B3File(:,2));
SetTemp=table2array(B3File(:,3));
Time=table2array(B3File(:,1));

%% Create datetime variables
[tokens,matches] = regexp(B3FileName,expression,'tokens','match');
B3Date=tokens{1}{1};
B3Date=datetime(B3Date, 'InputFormat','yyyyMMdd');

% B3Date = datetime(B3FileName(1:8),'InputFormat','yyyyMMdd');

for n=1:length(Time)
    B3_DateTime(n,1)=B3Date+timeofday(Time(n));
end

%% Clear temporary variables
clearvars filename delimiter formatSpec fileID dataArray ans;

end
