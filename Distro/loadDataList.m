%Parse gene expression energey from ABA format to mat.
%
%   Directory tree should be orgnized as follow:
%
%   $root/Data_ABA_format/GeneExpressionData - folder containing gene
%   expression data in separated folders for each gene. The folder is named
%   after the id (number) of the gene. Each folder contains the following
%   files: data_set.xml	energy.mhd	energy.raw. See the API documentation
%   for further details.
%
%   $root/Data_ABA_format/Annotation - folder containg brain region
%   annotation data. Folder conains the following files:
%   annotation_LUT.csv	annotation.raw and annotation_LUT.csv
%
%   $root/Distro - folder containing code
%
%   -Data_mat_format (output will be stored here)
%
clc

path2data = '../Data_ABA_format/GeneExpressionData';
path2res = '../Data_mat_format';

doParseSaggitalData = 0;
doParseCoronalData = 1;
doKeepInMemSaggitalData = 1;
doKeepInMemCoronalData = 1;

% hardcoded defs
% 200 micron volume size
sizeGrid = [67 41 58];% [sagital,height, cronal]
numberOfVoxels = prod(sizeGrid);


%% load metadata
[imageId, geneNames, section] = textread('ImageSeriesInfo.csv','%s %s %s','delimiter',',');
metaData = [imageId, geneNames, section];
numberOfImages = size(metaData,1);

%% Sagital
if doParseSaggitalData
    
    
    onlySectionImages = strcmp('sagittal', metaData(:,3));
    outputMatFile = fullfile(path2res,'mouseSagitalBrainMatrix.mat');
    
    metaData = metaData(onlySectionImages,:);
    
    
    expressionEnergyAllGenesCoronal= nan(numberOfImages, numberOfVoxels );
    genesWithErrors = {};
    
    fprintf('Saggital data. Working on gene')
    for iGENE =1:numberOfImages
        nchars = fprintf(' %d/out of %d',iGENE,numberOfImages);
        try
            filePath = fullfile( path2data,metaData{iGENE,1}, 'energy.raw');
            fid = fopen(filePath, 'r', 'l' );
            ENERGY = fread( fid, numberOfVoxels, 'float' );
            fclose( fid );
            expressionEnergyAllGenesCoronal(iGENE,:) = ENERGY;
        catch e
            genesWithErrors = [genesWithErrors ; metaData{iGENE,1}];
        end
        fprintf(repmat('\b',1,nchars));
    end
    
    fprintf ('\nSaving data');
    save(outputMatFile,'expressionEnergyAllGenesSaggital', 'metaData','sizeGrid','-v7.3');
    
    nErrors = size(genesWithErrors,1);
    if nErrors
        fprintf('\nThere are %d errors. Saving list with errors',nErrors);
        save (fullfile(path2res,'genesWithErrorsSagital.mat'),'expressionEnergyAllGenesSaggital');
    end
    %viewGeneOnGrid(expressionEnergyAllGenesSaggital(100,:), sizeGrid, 15);
    
    %cleanup
    if ~doKeepInMemSaggitalData
        clear expressionEnergyAllGenesSaggital
    end
    
end %processing saggital data

%% Coronal 
if doParseCoronalData
    
    
    onlySectionImages = strcmp('coronal', metaData(:,3));
    outputMatFile = fullfile(path2res,'mouseCoronalBrainMatrix.mat');
    
    metaData = metaData(onlySectionImages,:);
    numberOfImages = size(metaData,1);
    
    expressionEnergyAllGenesCoronal= nan(numberOfImages, numberOfVoxels );
    genesWithErrors = {};
    
    fprintf('Coronal data. Working on gene')
    for iGENE =1:numberOfImages
        nchars = fprintf(' %d/out of %d',iGENE,numberOfImages);
        try
            filePath = fullfile( path2data,metaData{iGENE,1}, 'energy.raw');
            fid = fopen(filePath, 'r', 'l' );
            ENERGY = fread( fid, numberOfVoxels, 'float' );
            fclose( fid );
            expressionEnergyAllGenesCoronal(iGENE,:) = ENERGY;
        catch e
            genesWithErrors = [genesWithErrors ; metaData{iGENE,1}];
        end
        fprintf(repmat('\b',1,nchars));
    end
    
    fprintf ('\nSaving data');
    save(outputMatFile,'expressionEnergyAllGenesCoronal', 'metaData','sizeGrid','-v7.3');
    
    nErrors = size(genesWithErrors,1);
    if nErrors
        fprintf('\nThere are %d errors. Saving list with errors',nErrors);
        save (fullfile(path2res,'genesWithErrorsCoronal.mat'),'expressionEnergyAllGenesCoronal');
    end
    %viewGeneOnGrid(expressionEnergyAllGenesSaggital(100,:), sizeGrid, 15);
    
    %cleanup
    if ~doKeepInMemCoronalData
        clear expressionEnergyAllGenesSaggital
    end
    
end %processing saggital data