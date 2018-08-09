%% iButton Temperature File Import Function
%
% Purpose: This code imports an iButton temperature log file. The
% log file is in a comma-separated-value (.csv) format. The function
% imports a data array containing the iButton temperature. Note, this
% function was modified from the default code auto-generated with the
% Matlab Import Data tool.
%
% Input: iButton .csv log file
% Outputs: iButton temperature data

% Author: Crystal Coolbaugh
% Date: May 10, 2018
% Copyright 2018 Crystal Coolbaugh

%% Import iButton Temperature Data

function [iTemp] = iButtonFileImport(filename, startRow, endRow)

%% Initialize variables.
delimiter = {',','°'};
if nargin<=2
    startRow = 27;
    endRow = inf;
end

%% Format string for each line of text:
%   column2: text (%q)
formatSpec = '%*q%f%*s%*s%*s%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to format string.
dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', delimiter, 'HeaderLines', startRow(1)-1, 'ReturnOnError', false);

%% Close the text file.
fclose(fileID);

%% Create output variable
iTemp=[dataArray{1:end-1}];

end

