%% Extract iButton Start Times
%
% Purpose: This codes loads a MATLAB table containing the subject # and the
% start time of the iButton temperature files. The code assumes the same
% start time is entered for all iButton temperature sensors. The user must
% select the directory containing the MATLAB table to load the information.
% iButton start times are stored and used to create a time vector. 
%
% Input: iButtonStartTime.mat
%
% Output: iButtonStart value

% Author: Crystal Coolbaugh
% Date: May 10, 2018
% Copyright 2018 Crystal Coolbaugh

function iButtonStart=ExtractiButtonStartTime(SubID)

% Add folder containing the iButtonStartTime.mat file to the Matlab path
tidy_path=uigetdir(pwd, 'Select Example-Data Folder');
addpath(tidy_path);

% Load iButtonStartTimeTable Information
load('iButtonStart')

% in line function searches through SubjectID column in iButtonStart Table and identifies
% row containg phase time information that matches with the inputed SubID
cellfind = @(string)(@(cell_contents)(strcmp(string,cell_contents)));
logical_cells = cellfun(cellfind(SubID),iButtonStart.SubjectID);
subrow=find(logical_cells,1,'first');

% create array containing only datetime data for individual subject
iButtonStart=table2array(iButtonStart(subrow,3));

end