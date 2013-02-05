%Load annotation (25um) data  ABA format to mat.
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

path2data = '../Data_ABA_format/Annotation';
path2res = '../Data_mat_format';

%Hardcoded variables
volsize = [528 320 456];


%% ANO = 3-D matrix of annotation labels
fprintf('\nLoading annotation data')
fid = fopen(fullfile(path2data,'annotation.raw'), 'r', 'l' );
ANO = fread( fid, prod(volsize), 'uint16' );
fclose( fid );
ANO = reshape(ANO,volsize);


%% Parse annotation LUT file -
fid = fopen(fullfile(path2data,'annotation_LUT.txt'), 'r', 'l' );
D = textscan(fid,'%d %s %s %d %d %d %s %s','Headerlines',1,'Delimiter','\t');
fclose(fid);
% the colums of D (i.e. its header) are:
%id	name	acronym	parent_structure_id	depth	graph_order	structure_id_path	color_hex_triplet

%build structure
headersNames = {'id';'name';'acronym';'parent_structure_id';'depth';'graph_order';'structure_id_path';'color_hex_triplet'};
nHeadersNames = size(headersNames,1);
for iFIELD = 1 : nHeadersNames;
    metadata.(headersNames{iFIELD}) = D{iFIELD};
end

clear D

%% build colormap - the ABA colors are stored as HEX triplets, parse to RGB space

maxID = max(metadata.id);
nRegs = size(metadata.id,1);
ABAcolormap = ones(nRegs+1,3); %add one to keep index 0 as white
%note color code for id 643 was erroneous and changed to it's parent
%structure

% do a 1 by 1 check as some strings are longer than 6 characters (use next
% correct value instead
for iREG = 1 : nRegs
    hexTriplet = metadata.color_hex_triplet{iREG};
    if numel(hexTriplet) == 6
        ABAcolormap(metadata.id(iREG)+1,:) = [hex2dec(hexTriplet(1:2)) hex2dec(hexTriplet(2:4))  hex2dec(hexTriplet(5:6)) ]./255;
    end
    %there are values larger than 1 so this should be truncated.
    ABAcolormap(ABAcolormap>1)=1;
    %TO DO - more robust conversion
end

%% walk through coronal and saggital annotations
figure
subplot(1,2,1)
for iPLANE = 1 : volsize(1);
    imagesc(squeeze(ANO(iPLANE,:,:)));colormap(ABAcolormap);set(gca,'clim',[0 maxID]);
  title(num2str(iPLANE))
    axis off
    axis image
      drawnow;
end

subplot(1,2,2)
for iPLANE = 1 : volsize(3);
    imagesc(squeeze(ANO(:,:,iPLANE)));colormap(ABAcolormap);set(gca,'clim',[0 maxID]);
  title(num2str(iPLANE))
    axis off
    axis image
      drawnow;
end


