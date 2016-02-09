% Make binary mask of all fractions, and create distance maps of first
% fraction and PTV
% 
% 
% (C) Ishita Chen, 2/5/16

clear, clc, close all, format compact

%% Inputs
% Patient number
patient_number = 5;
% Starting fraction number
fraction_number = 1;
% Total number of fractions
fxnums = 25;
% Number of slices above and below PTV to truncate
num_slices_PTV = 5;

% Structure of interest
ROI_name = 'STOMACH';
ROI_name_full = [ROI_name, '_FX', num2str(fraction_number)];
%ROI_name_full = ROI_name;

% Precision error
epsilon = 1e-3;

base_dir = 'C:\Users\Ishita\Documents\data\Patient_0';

%% Make mask of first fraction
indir = [base_dir, num2str(patient_number) '\Abdomen_SB_Fx', num2str(fraction_number),'_Delivery']
[contourmask1, PixelSpacing, SliceThickness] = MakeMask(indir, ROI_name_full, num_slices_PTV, epsilon);
% Write the file
fnameout =  [base_dir, num2str(patient_number), '\Analysis\', ROI_name_full, '_mask.raw'];
fid = fopen(fnameout,'w');
cnt=fwrite(fid,contourmask1,'uint8');
fclose(fid);

%% Create distance map of first fraction
% Create distance map
aspectRatio = [PixelSpacing; SliceThickness]';
DmapFx1 = bwdistsc(contourmask1, aspectRatio);
% Write the file
fnameout =  [base_dir, num2str(patient_number), '\Analysis\', ROI_name_full, '_Dmap.raw'];
fid = fopen(fnameout,'w');
cnt=fwrite(fid,DmapFx1,'double');
fclose(fid);

%% Make mask of first fraction
indir = [base_dir, num2str(patient_number) '\Abdomen_SB_Fx', num2str(fraction_number),'_Delivery']
ROI_name_full = 'PTV';
[contourmaskPTV, PixelSpacing, SliceThickness] = MakeMask(indir, ROI_name_full, num_slices_PTV, epsilon);
% Write the file
fnameout =  [base_dir, num2str(patient_number), '\Analysis\', ROI_name_full, '_mask.raw'];
fid = fopen(fnameout,'w');
cnt=fwrite(fid,contourmaskPTV,'uint8');
fclose(fid);

%% Create distance map of first fraction
% Create distance map
aspectRatio = [PixelSpacing; SliceThickness]';
DmapFx1 = bwdistsc(contourmaskPTV, aspectRatio);
% Write the file
fnameout =  [base_dir, num2str(patient_number), '\Analysis\', ROI_name_full, '_Dmap.raw'];
fid = fopen(fnameout,'w');
cnt=fwrite(fid,DmapFx1,'double');
fclose(fid);

% Save binary masks of all other fractions
contourmask2 = zeros(size(contourmask1));
for ii = 2:fxnums
    
    fraction_number = ii;
    
    indir = [base_dir, num2str(patient_number) '\Abdomen_SB_Fx', num2str(fraction_number),'_Delivery']
    ROI_name_full = [ROI_name, '_FX', num2str(fraction_number)];
    
    % Create mask of this fraction
    [contourmask2tmp, PixelSpacing, SliceThickness] = MakeMask(indir, ROI_name_full, num_slices_PTV, epsilon);
    % Write the file
    fnameout =  [base_dir, num2str(patient_number), '\Analysis\', ROI_name_full, '_mask.raw'];
    fid = fopen(fnameout,'w');
    cnt=fwrite(fid,contourmask2tmp,'uint8');
    fclose(fid);
    
    % Create a union of all fx
    contourmask2 = or(contourmask2, contourmask2tmp);
 
    disp(ii)
end

% Write the binary mask of the union
fnameout =  [base_dir, num2str(patient_number), '\Analysis\', ROI_name, '_mask_union.raw'];
fid = fopen(fnameout,'w');
cnt=fwrite(fid,contourmask2,'uint8');
fclose(fid);