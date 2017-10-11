%% tGUI File Import Function
%
% Purpose: This code imports a tGUI log file. The log file is a
% comma-separated-value (.csv) format. The function imports a data array
% containing the tGUI level (perception of cooling), time (s), and shiver
% event indicator. The date-time stamp information in the filename is used 
% to create a date-time string (yyyy-mm-dd hh:mm:ss) format.  Note, this 
% function was modified from the default code auto-generated with the 
% Matlab Import Data tool. 
%
% Inputs: tGUI .csv log file
%
% Outputs: tGUI level, tGUI time (s), shiver, tGUI_DateTime,
% tGUI_DateString, tGUIFileName
%
% Note: Extraction of the correct date from the file name assumes a file
% name of the format: YYYYMMDD_S###_####_tGUI-.csv

% Authors: Emily Bush and Crystal Coolbaugh
% Date: October 10, 2017
% Copyright 2017 Emily Bush, Crystal Coolbaugh

%% Import tGUI Data

function [level, s, shiver, tGUIDate, tGUI_DateTime, tGUIFileName] = tGUIFileImport
%% Initialize variables.
[tGUIFileName, pathname] = uigetfile('*.csv','Select the tGUI Data File.');
filename = horzcat(pathname,tGUIFileName);
delimiter = ',';
startRow = 2;

clear tokens matches
expression_time = '(\d{8}_\d{6}).csv';
expression = '(\d{8})_(S\d{1,5})_([^_]*)_([^_]*)';

%% Format string for each line of text:
%   column1: double (%f)
%	column2: double (%f)
%   column3: double (%f)
formatSpec = '%f%f%f%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to format string.
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false);

%% Close the text file.
fclose(fileID);

%% Allocate imported array to column variable names
s = dataArray{:, 1};
level = dataArray{:, 2};
shiver = dataArray{:, 3};

%% Create datetime variables

[tokens_time,matches_time] = regexp(tGUIFileName,expression_time,'tokens','match');
tGUIstart=tokens_time{1}{1};
tGUIstart = datetime(tGUIstart, 'InputFormat', 'yyyyMMdd_HHmmss');

[tokens,matches] = regexp(tGUIFileName,expression,'tokens','match');
tGUIDate=tokens{1}{1};
tGUIDate = datetime(tGUIDate, 'InputFormat', 'yyyyMMdd');

% Convert seconds to date-time format
for n=1:length(level)
    tGUI_DateTime(n,1)=tGUIstart+seconds(s(n));
end

%% Clear temporary variables
clearvars filename delimiter startRow formatSpec fileID dataArray ans;

end