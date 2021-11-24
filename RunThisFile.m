%% Directory setup

clear all

if isunix % Mac/Windows uses slash/backslash for file paths.
    s = '/';
elseif ispc
    s = '\';
end

curr_dir = matlab.desktop.editor.getActiveFilename;
tmp_ind = strfind(curr_dir,s);
curr_dir = curr_dir(1:tmp_ind(end));
cd(curr_dir);

if ~exist('figures','dir')
    mkdir('figures')
end

addpath(genpath(pwd))

data_dir = [curr_dir 'data' s];
fig_dir = [curr_dir 'figures' s];



%% Data merging
% To comply with Github's file size restrictions, the data for Experiment 1
% had to be split in two parts, which are merged here.

if ~exist([data_dir 'Exp1_data_full.mat'],'file')
    load([data_dir 'Exp1_data1.mat']);
    load([data_dir 'Exp1_data2.mat']);
    
    trial_data = vertcat(trial_data1,trial_data2);
    hand_data  = vertcat(hand_data1,hand_data2);
    
    save([data_dir 'Exp1_data_full.mat'],'trial_data','hand_data');
else
    load([data_dir 'Exp1_data_full.mat']);
end


%% Experiment 1 analyses and figures

% Only needs to be run once (results will be stored).
% If certain variables are missing in trial_data (table from
% Exp1_data_full.mat), try deleting the cone and CP data .mat files and rerun them again. 
if ~exist([data_dir 'Exp1_cone_data.mat'],'file')
    Exp1_apply_cone_method
end

if ~exist([data_dir 'Exp1_CP_data.mat'],'file')
    Exp1_apply_CP_test
end


% Includes Supplementary Figures 3-1 & 3-2; estimated actual adjustment
% angles already included in Exp1_data.mat (i.e. only needs to be run for
% the figure)
Exp1_actual_adjustment_angle_estimation

% Run each time
Exp1_Figure1D
Exp1_Figure2
Exp1_Figure3
Exp1_poc_proportion_inbound_analyses % includes Figure 4 ABC and Supplementary Figure 1-1
Exp1_poc_location_analyses % includes Figure 4 DEF
Exp1_poc_change_across_extra_criteria_analyses % includes Supplementary Figure 1-2



%% Experiment 2 analyses and figures

load([data_dir 'Exp2_data.mat']);

% Run once
if ~exist([data_dir 'Exp2_cone_data.mat'],'file')
    Exp2_apply_cone_method
end

if ~exist([data_dir 'Exp2_CP_data.mat'],'file')
    Exp2_apply_CP_test
end

% Run each time
Exp2_analyses % includes Figure 5
