%% Directory setup

clear all

cd(pwd)
addpath(genpath(pwd))


%% Experiment 1 analyses and figures

% Run only once (results are automatically stored)
Exp1_apply_cone_method
Exp1_apply_CP_test
Exp1_actual_adjustment_angle_estimation % includes Supplementary Figure 3-1 & 3-2

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
