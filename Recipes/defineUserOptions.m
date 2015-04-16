function userOptions = defineUserOptions()
% TODO: We should maintain a policy of setting these values here, and never
% TODO: modifying them again.  If other data needs to be passed around, it
% TODO: shouldn't be in this struct.
%
%  defineUserOptions is a nullary function which initialises a struct
%  containing the preferences and details for a particular project.
%  It should be edited to taste before a project is run, and a new
%  one created for each substantially different project (though the
%  options struct will be saved each time the project is run under
%  a new name, so all will not be lost if you don't do this).
%
%  For a guide to how to fill out the fields in this file, consult
%  the documentation folder (particularly the userOptions_guide.m)
%
%  Cai Wingfield 2009-11, 2015-03
%  Li Su updated 2-2012
%  Fawad updated 12-2013, 10-2014
%  Jana updated 10-2014
%__________________________________________________________________________
% Copyright (C) 2009 Medical Research Council

%%%%%%%%%%%%%%%%%%%%%
%% Project details %%
%%%%%%%%%%%%%%%%%%%%%

% This name identifies a collection of files which all belong to the same run of a project.
userOptions.analysisName = 'yourProjectName';

% This is the root directory of the project.
userOptions.rootPath = 'pathToRootDirectoryOfProject';

% The path leading to where the scans are stored (not including subject-specific identifiers).
% "[[subjectName]]" should be used as a placeholder to denote an entry in userOptions.subjectNames
% "[[betaIdentifier]]" should be used as a placeholder to denote an output of betaCorrespondence.m if SPM is not being used; or an arbitrary filename if SPM is being used.
userOptions.betaPath = 'pathToYourSingleConditionResponses';% e.g. /imaging/mb01/lexpro/multivariate/ffx_simple/[[subjectName]]/[[betaIdentifier]]

%%%%%%%%%%%%%%%%%%%
%% Email Options %%
%%%%%%%%%%%%%%%%%%%

% Set to true to be informed when a script finishes.
userOptions.recieveEmail = true;
% Put your address to make 
userOptions.mailto = 'cw417@cam.ac.uk';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Parallel Computing toolbox %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% To run parallel locally set run_in_parallel *and*
% run_in_parallel_in_cluster to false. 
% To run on CBU adaptive queue set run_in_parallel_in_cluster to true. 
% Do NOT set this true for fixed effect analysis (searchlight and
% permutation.
userOptions.run_in_parallel = true;
userOptions.run_in_parallel_in_cluster= true;
% Sometimes the performance will drop if there are large number of tiny
% jobs due to the communication and setting-up overhead.
userOptions.jobSize = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Adaptive Computing Cluster Queueing OPTIONS %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set true to delete jobs from the queue otherwise set to false.
% If you do not want to delete all jobs but only sepecific one do not set
% this variable to true.
userOptions.flush_Queue = false; 
% Used only when using CBU cluster.
% i.e. when run_in_parallel_in_cluster = true;
userOptions.wallTime = '12:00:00';
% Cluster machines requested.
userOptions.nodesReq = 8;
% Processors requested per processor machine.
userOptions.proPNode = 1;
% The product of nodesReq and proPNode should be greater or equal to the
% number of workers requested.
userOptions.nWorkers = 8;
% In gigabytes, to be distributed amongst all nodes.
userOptions.memReq = 400;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Modality-agnostic analysis options %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% The path to a stereotypical mask data file is stored (not including subject-specific identifiers).
% "[[subjectName]]" should be used as a placeholder to denote an entry in userOptions.subjectNames
% "[[maskName]]" should be used as a placeholder to denote an entry in userOptions.maskNames
userOptions.maskPath = 'pathToWhereYourMasksAreStored';%'/imaging/mb01/lexpro/multivariate/ffx_simple/[[subjectName]]/[[maskName]].img';

% The list of mask filenames (minus .hdr extension) to be used.
% For MEG, names should be in pairs, such as maskName-lh,
% maskName-rh.
% Leave empty to do whole-brain analysis.
%
% For MEG sensor-level analysis, only the use of a single mask is
% supported.
userOptions.maskNames = { ...
    'mask-lh', 'mask-rh'...
};

% The type of pattern to look at.
% Options are:
%     Correlate over space ('spatial')
%     Correlate over time ('temporal')
%     Correlate over space and time ('spatiotemporal')
% For fMRI, the available options are 'spatial'.
% For MEG, the all options are available.
userOptions.searchlightPatterns = 'spatiotemporal';

%%%%%%%%%%%%%%%%%%%%%%%%
%% EXPERIMENTAL SETUP %%
%%%%%%%%%%%%%%%%%%%%%%%%

% The list of subjects to be included in the study.
userOptions.subjectNames = { ...
	'subject1','subject2',...
};% eg CBUXXXXX

% The default colour label for RDMs corresponding to RoI masks (as opposed to models).
userOptions.RoIColor = [0 0 1];
userOptions.ModelColor = [0 1 0];

% Should information about the experimental design be automatically
% acquired from SPM metadata?
% If this option is set to true, the entries in userOptions.conditionLabels
% MUST correspond to the names of the conditions as specified in SPM.
userOptions.getSPMData = false;

%% %% %% %% %%
%% fMRI  %% Use these next three options if you're working in fMRI native space:
%% %% %% %% %%

% What is the path to the anatomical (structural) fMRI scans for each subject?
% "[[subjectName]]" should be used to denote an entry in userOptions.subjectNames
userOptions.structuralsPath = 'pathToWhereYourSubject''s structuralImagesAreStored ';% e.g. /imaging/mb01/lexpro/[[subjectName]]/structurals/

% What are the dimensions (in mm) of the voxels in the scans?
userOptions.voxelSize = [3 3 3.75];

% What radius of searchlight should be used (mm)?
userOptions.searchlightRadius = 15;

%% %% %% %% %%
%%  MEG  %% Use these next four options if you're working in MEG:
%% %% %% %% %%

% The average surface files
userOptions.averageSurfaceFile = '/imaging/cw03/decom2/subjects/average/surf/lh.inflated';

% The width of the sliding window (ms)
userOptions.temporalSearchlightWidth = 20; %20;

% The timestep for sliding window (ms)
userOptions.temporalSearchlightTimestep = 10;

% The overall window of interest for searchlight (ms)
userOptions.temporalSearchlightLimits = [-200 800];

% Temporal downsampling
% E.g., a value of 10 here means only taking each 10th point in time.
userOptions.temporalDownsampleRate = 1;

% Time windows are specified for each region.
%
% There should be one entry for each entry in userOptions.maskNames, and
% they will be treated as corresponding pairs.
% For example, if there are entries 'mask-a' and 'mask-b' in
% userOptions.maskNames, and there are entries [0 100] and [-100 200] in
% userOptions.maskTimeWindows, then [0 100] will go with 'mask-a', and
% [-100 200] will go with 'mask-b'.
%
% For searchlight analysis, these values will be ignored and
% userOptions.temporalSearchlightLimits will be used instead.
userOptions.maskTimeWindows = {
    [0 500], [0 500] ...
};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% MEG SENSOR-LEVEL ANALYSIS %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% remove/add sensors in your mask by setting them true/false
userOptions.MEGSensor_maskSpec.MEGSensors.Gradiometers = true;
userOptions.MEGSensor_maskSpec.MEGSensors.Magnetometers = true;
% for each mag and grad: create above mentioned mask by putting sensor
% numbers in arrays put any values, such as [90 98 100 1 4];
userOptions.MEGSensor_maskSpec.MEGSensorSites = (1:102);

userOptions.MEGSensor_maskSpec.MEGSensors.EEG = false;
userOptions.MEGSensor_maskSpec.EEGSensorSites = (1:70);

% The window to be used as baseline.
userOptions.MEGSensor_maskSpec.baselineWindow = [-100, -50];

% time window for RoI analysis
userOptions.MEGSensor_maskSpec.timeWindow = [-200 100];

% The radius of the sensor searchlight (in adjacent sensors, excluding the centre: 0 => 1 sensor, 1 => ~9)
userOptions.sensorSearchlightRadius = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% MEG SOURCE-LEVEL ANALYSIS %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% The radius of the source-space searchlight (in mm)
userOptions.sourceSearchlightRadius = 20;

% Spatial downsampling.
% Set the target number of vertices per hemisphere.
userOptions.targetResolution = 10242;

% TODO: Explain this
% 5mm is the smallest distance between two adjacent vertex in 10242 resolution.
% 10mm is the smallest distance between two adjacent vertex in 2562 resolution.
userOptions.minDist = 5; %mm

%%%%%%%%%%%%%%%%%%%%%%%%%%
%% First-order analysis %%
%%%%%%%%%%%%%%%%%%%%%%%%%%

% Text lables which may be attached to the conditions for MDS plots.
[userOptions.conditionLabels{1:92}] = deal(' ');
% TODO: this is confusing
% userOptions.alternativeConditionLabels = { ...
% 	' ', ...
% 	' ', ...
% 	' ', ...
% 	' ', ...
% 	' ' ...
% 	};
% userOptions.useAlternativeConditionLabels = false;

% What colours should be given to the conditions?
userOptions.conditionColours = [repmat([1 0 0], 48,1); repmat([0 0 1], 44,1)];

% Which distance measure to use when calculating first-order RDMs.
userOptions.distance = 'Correlation';

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Second-order analysis %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Which model RDM to test? (This number corresponds to the order in
% variable Models, which is specified in ModelRDMs.m)
% TODO: This should be in the recipe, not here.

userOptions.partial_correlation = false;
% all models listed here will be partialed out from the original model
userOptions.partial_modelNumber = {5,7};

% Which similarity-measure is used for the second-order comparison.
userOptions.RDMCorrelationType = 'Kendall_taua';

% How many permutations should be used to test the significance of the
% fits?  (10,000 highly recommended.)
userOptions.significanceTestPermutations = 10000;

% Bootstrap options
userOptions.nResamplings = 1000;
userOptions.resampleSubjects = true;
userOptions.resampleConditions = false;

userOptions.fisher = true;

% Group statistics options: random effect ('RFX') or fixed effect ('FFX')
% TODO: requires a lot more explanation
userOptions.groupStats = 'RFX';

% Clustering analysis: primary cluster-forming threshold in terms of the
% top x% for all vertexes across space and time.
% It means that primary threshold is set to p<x ,one tailed for positive
% clusters. This doesnot need to be adjusted according to the degree of
% freedom of data. If the requirement is to select top ONLY x% of all data, set
% this value to nan.
% If not using tmaps for RFX, this value only will define the primary threshold.
% DoF does not help compute threshold for that case.
userOptions.primaryThreshold = 0.05;

% Should RDMs' entries be rank transformed into [0,1] before they're displayed?
userOptions.rankTransform = true;

%%%%%%%%%%%%%%%%%%%%
%% Figure options %%
%%%%%%%%%%%%%%%%%%%%

% Should rubber bands be shown on the MDS plot?
userOptions.rubberbands = true;

% What criterion shoud be minimised in MDS display?
userOptions.criterion = 'metricstress';

% What is the colourscheme for the RDMs?
userOptions.colourScheme = jet(128); 

% Set any of the following to true to delete files saved as work-in-progress
% throughout the analysis. This will save space.
userOptions.deleteTMaps_Dir = false;
userOptions.deleteImageData_Dir = false;
userOptions.deletePerm = true;

% How should figures be outputted?
userOptions.displayFigures = true;
userOptions.saveFiguresPDF = false;
userOptions.saveFiguresFig = false;
userOptions.saveFiguresPS = false;
% Which dots per inch resolution do we output?
userOptions.dpi = 300;
% Remove whitespace from PDF/PS files?
% Bad if you just want to print the figures since they'll
% no longer be A4 size, good if you want to put the figure
% in a manuscript or presentation.
userOptions.tightInset = false;

%%%%%%%%%%%%%%%%%%%%%%%%%
%% Interaction options %%
%%%%%%%%%%%%%%%%%%%%%%%%%

% TODO: Need a better solution to this. Enum?
% This can be used to force a reply to each propt about overwriting files.
% It can be useful when running unsupervised, or in parallel, where the
% prompt may not even be seen.
% Set to 'a', 'r', 's'; or use '' to not force a reply.
userOptions.forcePromptReply = '';

% Present user with graphical feedback?
userOptions.dialogueBox = false;

end%function
