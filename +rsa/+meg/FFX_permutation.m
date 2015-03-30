% This function permutes between subjects to simulate a null distribution of
% maximum stats.

% Based on RFX script by Su Li
% Isma Zulfiqar 11/2012 Updated IZ 04/13 updated FJ 03/14

function FFX_permutation (model, combinedMasks, userOptions)

import rsa.*
import rsa.fig.*
import rsa.meg.*
import rsa.rdm.*
import rsa.sim.*
import rsa.spm.*
import rsa.stat.*
import rsa.util.*

returnHere = pwd; % We'll come back here later
nSubjects = numel(userOptions.subjectNames);
modelName = spacesToUnderscores(model.name);
if userOptions.partial_correlation
    modelName = [modelName, '_partialCorr'];
end

MapsFilename = ['perm-', userOptions.significanceTestPermutations, '_', modelName, '_r_map'];

usingMasks = ~isempty(userOptions.maskNames);

promptOptions.functionCaller = 'FFX_permutation';
promptOptions.defaultResponse = 'S';
promptOptions.checkFiles(1).address = fullfile(userOptions.rootPath, 'Maps', modelName, [MapsFilename, '-lh.stc']);
promptOptions.checkFiles(2).address = fullfile(userOptions.rootPath, 'Maps', modelName, [MapsFilename, '-rh.stc']);

overwriteFlag = overwritePrompt(userOptions, promptOptions);

if overwriteFlag
    disp('Permuting (FFX) ...');

    %%  computing average subject RDMs
    for chirality = 1:2
        switch chirality
            case 1
                chi = 'L';
            case 2
                chi = 'R';
        end % switch: chilarity
        
        % Get combined mask for this side
        maskThisHemi = combinedMasks([combinedMasks.chi] == chi);
        nVertices = length(maskThisHemi.vertices);
        
        fprintf(['Computing Average Subject RDMs for ' (chi) ' hemisphere...']);
        
        MapsFilename = 'averaged_searchlightRDMs_masked_';

        promptOptions.functionCaller = 'FFX_permutation';
        promptOptions.defaultResponse = 'S';
        promptOptions.checkFiles(1).address = fullfile(userOptions.rootPath, 'RDMs', [MapsFilename, 'lh.mat']);
        promptOptions.checkFiles(2).address = fullfile(userOptions.rootPath, 'RDMs', [MapsFilename, 'rh.mat']);

        overwriteFlag = overwritePrompt(userOptions, promptOptions);
        
        if overwriteFlag
        % computes nanmean
            for subjectNumber = 1:nSubjects
                filepath = ['searchlightRDMs_'];
                if usingMasks
                    filepath = [filepath 'masked_'];
                end
                subjectRDMsFile = fullfile(userOptions.rootPath, 'RDMs', [filepath  userOptions.subjectNames{subjectNumber} '-' lower(chi) 'h']);
                subjectRDMs = directLoad(subjectRDMsFile, 'subjectRDMs');

                for v=1:nVertices % vertices
                    nTimePoints = length(fieldnames(subjectRDMs.searchlightRDMs.(['v_' num2str(masksThisHemi.vertices(v))])));
                    for t=1:nTimePoints % time points
                        averageSubjectRDMs.(chi).(['v_' num2str(masksThisHemi.vertices(v))]).([...
                            't_' num2str(t)]).RDM(subjectNumber,:) = single(vectorizeRDM...
                            (subjectRDMs.searchlightRDMs.(['v_' num2str(masksThisHemi.vertices(v))]).([...
                            't_' num2str(t)]).RDM));

                        if subjectNumber == nSubjects
                            averageSubjectRDMs.(chi).(['v_' num2str(masksThisHemi.vertices(v))]).([...
                                't_' num2str(t)]).RDM = single(nanmean(averageSubjectRDMs.(chi).([...
                                'v_' num2str(masksThisHemi.vertices(v))]).(['t_' num2str(t)]).RDM,1));
                        end
                    end % timepoints
                end % vertices
                fprintf('.');
                clear subjectRDMs;
            end % subjects
            save('-v7.3',fullfile(userOptions.rootPath,'RDMs',['averaged_' filepath  lower(chi) 'h']), 'averageSubjectRDMs');
            disp(' Done!');
        else 
            filepath = ['searchlightRDMs_'];
            if usingMasks
                filepath = [filepath 'masked_'];
            end
            averageSubjectRDMs = directLoad(promptOptions.checkFiles(chirality).address, 'averageSubjectRDMs');
            nTimePoints = length(fieldnames(averageSubjectRDMs.(chi).(['v_' num2str(masksThisHemi.vertices(1))])));
        end
        
        % preparing models
        modelRDMs_utv = vectorizeRDMs(model);
        modelRDMs_utv = modelRDMs_utv.RDM;
                
        % observed correlation
        temp = zeros(userOptions.targetResolution, nTimePoints);
        fprintf('Computing observed correlation...');
        for i = 1:nVertices
            vertex = masksThisHemi.vertices(i);
            rdms = averageSubjectRDMs.(chi).(['v_' num2str(vertex)]);
            parfor t = 1:nTimePoints
                rdm = rdms.(['t_' num2str(t)]).RDM;
                r = corr(vectorizeRDM(rdm)', modelRDMs_utv', 'type', ...
                    userOptions.RDMCorrelationType, 'rows', 'pairwise');
                temp(vertex, t) = r;
            end
        end
        observed_r = squeeze(temp);
        disp(' Done!');
        
        % saving file to stc format
        observed_Vol.(chi) = userOptions.STCmetaData;
        observed_Vol.(chi).data = observed_r;
        
        outputFilename = fullfile(userOptions.rootPath, 'Maps', modelName, ...
            [userOptions.analysisName '_rMesh_' modelName '_allSubjects']);
        if usingMasks
            outputFilename = [outputFilename '_masked'];
        end
        mkdir(fullfile(userOptions.rootPath, 'Maps'),modelName);
        mne_write_stc_file1([outputFilename, '-', lower(chi), 'h.stc'], observed_Vol.(chi));
        
        clear averageSubjectRDMs;% rather than storing both simultaneously in ram, load them independently
        clear temp rdms rdm observed_r; 
    end % chirality
    
    %% permuting for generating different models and computing correlation
    
    numberOfPermutation = userOptions.significanceTestPermutations;
    max_r_value = zeros(1,numberOfPermutation);
    

    
    fprintf('Permuting...');
    parfor perm = 1:numberOfPermutation
    simulated_Vol_lh = userOptions.STCmetaData;
    simulated_Vol_lh.data = zeros(userOptions.targetResolution, nTimePoints);
    simulated_Vol_rh = userOptions.STCmetaData;
    simulated_Vol_rh.data = zeros(userOptions.targetResolution, nTimePoints);
        if mod(perm, floor(numberOfPermutation/20)) == 0, fprintf('\b.'); end%if
        %disp(['perm' num2str(perm)]);
        
        % preparing models
        modelRDMs = randomizeSimMat(model.RDM);
        modelRDMs_utv = squeeze(unwrapRDMs(vectorizeRDMs(modelRDMs)));
        
        offset = 0;
        
         for chirality = 1:2
            switch chirality
                case 1
                    chi = 'L';
                case 2
                    chi = 'R';
            end % switch: chilarity
            
            % compute corr with averageSubjectsRDM
			% TODO: What variable name is this loading?
			% TODO: We shouldn;t ever use bare load()s,
			% TODO: as it's super hard to track data flow.
            load(fullfile(userOptions.rootPath,'RDMs',['averaged_' filepath  lower(chi) 'h']));
            
            simulated_r = zeros(userOptions.targetResolution*2, nTimePoints);
            for i = 1:length(masksThisHemi.vertices)
                vertex = masksThisHemi.vertices(i);
                temp = zeros(1,nTimePoints);
                rdms = averageSubjectRDMs.(chi).(['v_' num2str(vertex)]);
                parfor t = 1:nTimePoints
                    rdm = rdms.(['t_' num2str(t)]).RDM;
                    r = corr(vectorizeRDM(rdm)', modelRDMs_utv', 'type', ...
                        userOptions.RDMCorrelationType, 'rows', 'pairwise');
                    temp(t) = r;
                end % for t
                simulated_r(vertex + offset,:) = temp;
                
            end % for vertex
           offset = userOptions.targetResolution; 
           
           clear averageSubjectRDMs temp rdms;
           fprintf('.');
        end % chirality
        
        outputFilename = fullfile(userOptions.rootPath, 'Maps', modelName, ['perm-' num2str(perm) '_' modelName '_r_map']);
        
        simulated_Vol_lh.data = simulated_r(1:userOptions.targetResolution,:);
        mne_write_stc_file1([outputFilename,'-lh.stc'], simulated_Vol_lh);
        offset = userOptions.targetResolution;
        
        simulated_Vol_rh.data = simulated_r(userOptions.targetResolution + 1:userOptions.targetResolution*2,:);
        mne_write_stc_file1([outputFilename,'-rh.stc'], simulated_Vol_rh);
   
        max_r_value(perm) = max(max(simulated_r));
        
        clear simulated_r;
        
    end % for perm
    disp(' Done!');
    
    percent = 0.05; % Update IZ 03/13
    r_distribution = sort(max_r_value);
    
    vertex_level_threshold = r_distribution(ceil(size(r_distribution,2)*(1-percent)));
    
    disp('Writng results corrected for both hemispheres using permutation but without using clustering method...');
    
    gotoDir(userOptions.rootPath, 'Results');
    outputFileName_sig = fullfile(userOptions.rootPath, 'Results', [userOptions.analysisName, '_', modelName '_significant_vertex_ffx']);
    if usingMasks
        outputFileName_sig = [outputFileName_sig '_masked'];
    end
    observed_Vol.L.data(observed_Vol.L.data<vertex_level_threshold) = 0;
    observed_Vol.R.data(observed_Vol.R.data<vertex_level_threshold) = 0;
    
    mne_write_stc_file1([outputFileName_sig, '-lh.stc'], observed_Vol.L);
    mne_write_stc_file1([outputFileName_sig, '-rh.stc'], observed_Vol.R);
    
else
    fprintf('Already done permutation, Skip...');
end

cd(returnHere); % And go back to where you started
