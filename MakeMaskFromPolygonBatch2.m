% Make binary mask of all fractions, and create distance maps of first
% fraction and PTV
% 
% 
% (C) Ishita Chen, 2/5/16

clear, clc, close all, format compact

%% Inputs
% Patient number
patient_number = 10;
% Starting fraction number
fraction_number_init = 1;
fraction_number = fraction_number_init;
% Total number of fractions
fxnums = 15;
% Number of slices above and below PTV to truncate
num_slices_PTV = 5;

% PTV name
PTV_name = 'PTV';

% Structure of interest
% ROI_name = 'STOMACH';
% ROI_name = 'DUODENUM';
% ROI_name = 'SMALLBOWEL';
% ROI_name = 'LARGEBOWEL';
% Structure of interest
ROI_name = {4,1};
ROI_name{1} = 'STOMACH';
ROI_name{2} = 'DUODENUM';
ROI_name{3} = 'SMALLBOWEL';
ROI_name{4} = 'LARGEBOWEL';
% ROI_name = {1,1};
% % ROI_name{1} = 'STOMACH';
% ROI_name{2} = 'DUODENUM';
% % ROI_name{3} = 'SMALLBOWEL';
% % ROI_name{4} = 'LARGEBOWEL';

%ROI_name_full = ROI_name;

% Precision error
epsilon = 1e-4;

base_dir = 'C:\Users\ichen\Documents\data_anon\Patient_';
results_dir = 'Analysis';

results_dir_name = [base_dir, sprintf('%02d',patient_number), '\', results_dir];
if ~exist(results_dir_name,'dir')
    mkdir(results_dir_name)
end

%% Make mask of PTV or GTV
indir = [base_dir, sprintf('%02d',patient_number) '\Abdomen_SB_Fx', num2str(fraction_number),'_Delivery']
ROI_name_full = PTV_name;
[contourmaskPTV, PixelSpacing, SliceThickness] = MakeMask(indir, ROI_name_full, num_slices_PTV, epsilon, PTV_name);
% Write the file
fnameout =  [base_dir, sprintf('%02d',patient_number), '\', results_dir,'\PTV_mask.raw'];
fid = fopen(fnameout,'w');
cnt=fwrite(fid,contourmaskPTV,'uint8');
fclose(fid);

%% Create distance map of PTV
% Create distance map
aspectRatio = [PixelSpacing; SliceThickness]';
DmapFx1 = bwdistsc(contourmaskPTV, aspectRatio);
% Write the file
fnameout =  [base_dir, sprintf('%02d',patient_number), '\', results_dir,'\PTV_Dmap.raw'];
fid = fopen(fnameout,'w');
cnt=fwrite(fid,DmapFx1,'double');
fclose(fid);

for iter = 1:length(ROI_name)
    fraction_number = fraction_number_init;
    %% Make mask of first fraction
    ROI_name_full = [ROI_name{iter}, '_FX', num2str(fraction_number)];
    disp(ROI_name_full);
    indir = [base_dir, sprintf('%02d',patient_number) '\Abdomen_SB_Fx', num2str(fraction_number),'_Delivery']
    [contourmask1, PixelSpacing, SliceThickness] = MakeMask(indir, ROI_name_full, num_slices_PTV, epsilon, PTV_name);
    % Write the file
    fnameout =  [base_dir, sprintf('%02d',patient_number), '\', results_dir,'\', ROI_name_full, '_mask.raw'];
    fid = fopen(fnameout,'w');
    cnt=fwrite(fid,contourmask1,'uint8');
    fclose(fid);
    
    %% Create distance map of first fraction
    % Create distance map
    aspectRatio = [PixelSpacing; SliceThickness]';
    DmapFx1 = bwdistsc(contourmask1, aspectRatio);
    % Write the file
    fnameout =  [base_dir, sprintf('%02d',patient_number), '\', results_dir,'\', ROI_name_full, '_Dmap.raw'];
    fid = fopen(fnameout,'w');
    cnt=fwrite(fid,DmapFx1,'double');
    fclose(fid);
    
    % Save binary masks of all other fractions
    contourmask2 = zeros(size(contourmask1));
    fx_num_iter = 1:fxnums;
    fx_num_iter = setdiff(fx_num_iter,fraction_number_init);
    for ii = fx_num_iter
        
        fraction_number = ii;
        
        disp(ROI_name_full);
        indir = [base_dir, sprintf('%02d',patient_number) '\Abdomen_SB_Fx', num2str(fraction_number),'_Delivery']
        ROI_name_full = [ROI_name{iter}, '_FX', num2str(fraction_number)];
        
        % Create mask of this fraction
        [contourmask2tmp, PixelSpacing, SliceThickness] = MakeMask(indir, ROI_name_full, num_slices_PTV, epsilon, PTV_name);
        % Write the file
        fnameout =  [base_dir, sprintf('%02d',patient_number), '\', results_dir,'\', ROI_name_full, '_mask.raw'];
        fid = fopen(fnameout,'w');
        cnt=fwrite(fid,contourmask2tmp,'uint8');
        fclose(fid);
        
        % Create a union of all fx
        contourmask2 = or(contourmask2, contourmask2tmp);
        
        disp(ii)
    end
    
    % Write the binary mask of the union
    fnameout =  [base_dir, sprintf('%02d',patient_number), '\', results_dir,'\', ROI_name{iter}, '_mask_union.raw'];
    fid = fopen(fnameout,'w');
    cnt=fwrite(fid,contourmask2,'uint8');
    fclose(fid);
end