%% Directory setup

clear all

cd(pwd)
addpath(genpath(pwd))


%% Experiment 1 analyses and figures

% Only needs to be run once (results will be stored).
% Results that are needed for the scripts below are already stored in
% Exp1_data.mat.
Exp1_apply_cone_method
Exp1_apply_CP_test

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

% Run once
Exp2_apply_cone_method
Exp2_apply_CP_test

% Run each time
Exp2_analyses % includes Figure 5
