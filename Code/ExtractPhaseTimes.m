%% Extract Phase Times Function
%
% Purpose: This code loads a Matlab table containing the subject # and the
% start/stop time of each phase of the perception-based cooling protocol.
% The user must select the directory containing the Matlab table to load
% the information. Phase times are stored for future analyses. 
%
% Input: PhaseTable.mat 
%
% Output: SessionPhaseTimes array

% Authors: Emily Bush and Crystal Coolbaugh
% Date: October 10, 2017
% Copyright 2017 Emily Bush, Crystal Coolbaugh

function [SessionPhaseTimes]=ExtractPhaseTimes(SubID)

% Add folder containing the PhaseTable.mat file to the Matlab path
tidy_path=uigetdir(pwd, 'Select Example-Data Folder');
addpath(tidy_path);

% Load PhaseTable Information
load('PhaseTable')

% In line function searches through SubjectID column in Phase Table and identifies
% row containg phase time information that matches with the SubID
cellfind = @(string)(@(cell_contents)(strcmp(string,cell_contents)));
logical_cells = cellfun(cellfind(SubID),PhaseTable.SubjectID);
subrow=find(logical_cells,1,'first');

% create array containing only datetime data for individual subject
% determine the number of phases by identifying first column containing NaT
pcparray=table2array(PhaseTable(subrow,3:width(PhaseTable)));
lastphasetime=find(isnat(pcparray),1,'first');

% create matrix containing start and stop times for each phase
SessionPhaseTimes=[pcparray(1:2:lastphasetime-1)' pcparray(2:2:lastphasetime)'];
end