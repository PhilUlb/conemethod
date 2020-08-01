# conemethod

The cone method is a data analysis tool to estimate the timepoint of commitment to a spatial target in single movement trajectories. Its rationale and implementation are fully described in Ulbrich & Gail (2020): DOI will be provided once the preprint has been unlocked on bioRxiv

The code and data provided here can be used to recreate all figures and analyses described in Ulbrich & Gail (2020), using Matlab (tested with Matlab 2015b). Note that the figures produced by this code are "rough", i.e. while all data is plotted correctly as shown in Ulbrich & Gail (2020) they have undergone substantial postprocessing in terms of axis labels, subplot positioning etc. The figures require the gramm toolbox (https://doi.org/10.21105/joss.00568; https://github.com/piermorel/gramm).

By running "main_script.m", the cone method and all other analyses described in Ulbrich & Gail (2020) are automatically executed. The cone method itself is applied using the function "cone_wrapper.m", located in the folder "cone_method". This folder contains all code necessary to run the cone method. Examples of how the data needs to be formatted for the cone method to be applied can be found in "Exp1_apply_cone_method.m" and "Exp2_apply_cone_method.m".
