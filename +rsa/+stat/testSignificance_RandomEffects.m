% This function computes random effects statistics for RoI RDMs in fixed time window

% IZ 11-12
function testSignificance_RandomEffects(RDMs, Models, userOptions)

import rsa.*
import rsa.fig.*
import rsa.fmri.*
import rsa.rdm.*
import rsa.sim.*
import rsa.spm.*
import rsa.stat.*
import rsa.util.*

returnHere = pwd;

%% Set defaults and check options struct
if ~isfield(userOptions, 'analysisName'), error('testSignificance:NoAnalysisName', 'analysisName must be set. See help'); end%if
if ~isfield(userOptions, 'rootPath'), error('testSignificance:NoRootPath', 'rootPath must be set. See help'); end%if
userOptions = setIfUnset(userOptions, 'significanceTestPermutations', 10000);
userOptions = setIfUnset(userOptions, 'distanceMeasure', 'Spearman');


StatisticsFileName =  [userOptions.analysisName '-random_effects-p'];

% Options for the prompt
promptOptions.functionCaller = 'testSignificance_RandomEffects';
promptOptions.defaultResponse = 'S';
promptOptions.checkFiles(1).address = fullfile(userOptions.rootPath, 'Statistics', [StatisticsFileName '.csv']);

% Do the prompt
overwriteFlag = overwritePrompt(userOptions, promptOptions);

if overwriteFlag % If files may be (over)written:
    
    fprintf('Performing random effects analysis... ');
    modelNumber=userOptions.modelNumber;
    modelRDM = Models(modelNumber).RDM;
    modelRDM_vec = vectorizeRDM(modelRDM);
    
    if userOptions.sensorLevelAnalysis
        nMasks = 1;
        disp('in sensor space!');
        maskNames = userOptions.MEGSensor_maskSpec.maskName;
    else
        nMasks = numel(userOptions.maskNames);
        disp('in source space!');
        maskNames = userOptions.maskNames;
    end
    
    for mask=1:nMasks
        for subject=1:numel(userOptions.subjectNames)
            [r(subject) p_sub] = corr(vectorizeRDM(RDMs(mask,subject).RDM)',modelRDM_vec','type',userOptions.RDMCorrelationType,'rows','pairwise');
        end
        [h,p(1,mask),ci,stats] = ttest(r,0);
        disp([' | Mask: ' maskNames{mask} ' | p: ' num2str(p(1,mask))]);
    end
    
    fprintf('Saving p values...')
    xlswrite(fullfile(userOptions.rootPath,'Statistics',StatisticsFileName), squeeze(p));
    disp('Done!');
else
    disp('Permutation already performed.');    
end
end
