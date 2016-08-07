clear, clc, close all, format compact

%% Inputs
% Patient number
patient_number = 10;
% Fraction numbers to compare to each other
fraction_number_init = 1;
fraction_number = fraction_number_init;
fxnums = 15;
% Number of slices above and below PTV to truncate
num_slices_PTV = 5;

% Structure of interest
% ROI_name = 'STOMACH';
% ROI_name = 'DUODENUM';
% ROI_name = 'SMALLBOWEL';
% ROI_name = 'LARGEBOWEL';
ROI_name = {4,1};
ROI_name{1} = 'STOMACH';
ROI_name{2} = 'DUODENUM';
ROI_name{3} = 'SMALLBOWEL';
ROI_name{4} = 'LARGEBOWEL';

% Precision error
epsilon = 1e-4;

base_dir = 'C:\Users\ichen\Documents\data_anon\Patient_';
results_dir = 'Analysis';

indir = [base_dir, sprintf('%02d',patient_number) '\Abdomen_SB_Fx', num2str(fraction_number),'_Delivery']


%% Load MRI file for first fraction
[I, PixelSpacing, SliceThickness, ImagePositionPatient, ImageOrientationPatient, ImgSize] = load_VR_MRI(indir);
ImgSize = double(ImgSize);
NumSlices = size(I,3);
Imask =zeros(size(I));
I_z_ind = ImagePositionPatient(:,3);    % z indices of all slices
I_x_or = ImagePositionPatient(1,1);     % x origin of the image
I_y_or = ImagePositionPatient(1,2);     % y origin of the image

ImagePositionPatient = ImagePositionPatient(end,:);

% Load the mask for PTV
fnameout =  [base_dir, sprintf('%02d',patient_number), '\Analysis\PTV_mask.raw'];
fid = fopen(fnameout,'r');
PTV_mask = fread(fid,'uint8');
PTV_mask = reshape(PTV_mask, size(I));
fclose(fid);

% Load distance map for PTV
fnameout =  [base_dir, sprintf('%02d',patient_number), '\Analysis\PTV_Dmap.raw'];
fid = fopen(fnameout,'r');
Dmap_PTV = fread(fid,'double');
Dmap_PTV = reshape(Dmap_PTV, size(I));
fclose(fid);

for iter = 1:length(ROI_name)
    
    fraction_number = fraction_number_init;
    %% Make mask of first fraction
    ROI_name_full = [ROI_name{iter}, '_FX', num2str(fraction_number)];
    disp(ROI_name_full);
    
    
    % Load binary mask for first fraction
    fnameout =  [base_dir, sprintf('%02d',patient_number), '\', results_dir,'\', ROI_name_full, '_mask.raw'];
    fid = fopen(fnameout,'r');
    contourmask1 = fread(fid,'uint8');
    contourmask1 = reshape(contourmask1, size(I));
    fclose(fid);
    
    % Load distance map for first fraction
    fnameout =  [base_dir, sprintf('%02d',patient_number), '\', results_dir,'\', ROI_name_full, '_Dmap.raw'];
    fid = fopen(fnameout,'r');
    Dmap_Fx1 = fread(fid,'double');
    Dmap_Fx1 = reshape(Dmap_Fx1, size(I));
    fclose(fid);
    
    
    
    Dmap_Fx1_contour = [];
    Dmap_PTV_contour = [];
    
    fx_num_iter = 1:fxnums;
    fx_num_iter = setdiff(fx_num_iter,fraction_number_init);
    for ii = fx_num_iter
        fraction_number = ii;
        ROI_name_full = [ROI_name{iter}, '_FX', num2str(fraction_number)];
        
        % Load new fraction
        fnameout =  [base_dir, sprintf('%02d',patient_number), '\', results_dir,'\', ROI_name_full, '_mask.raw'];
        fid = fopen(fnameout,'r');
        contourmask2 = fread(fid,'uint8');
        contourmask2 = reshape(contourmask2, size(I));
        fclose(fid);
        
        [Dmap_Fx1_tmp, Dmap_PTV_tmp] = WriteDistanceMapArray(contourmask1, contourmask2, Dmap_Fx1, Dmap_PTV, epsilon);
        
        % Concatenate
        Dmap_Fx1_contour = [Dmap_Fx1_contour; Dmap_Fx1_tmp];
        Dmap_PTV_contour = [Dmap_PTV_contour; Dmap_PTV_tmp];
        
        disp(ROI_name_full);
    end
    
    % Compute the distance map for union image
    disp('Computing distance map for union')
    fnameout =  [base_dir, sprintf('%02d',patient_number), '\', results_dir,'\', ROI_name{iter}, '_mask_union.raw'];
    fid = fopen(fnameout,'r');
    contourmask2 = fread(fid,'uint8');
    contourmask2 = reshape(contourmask2, size(I));
    fclose(fid);
    
    [Dmap_Fx1_union, Dmap_PTV_union] = WriteDistanceMapArray(contourmask1, contourmask2, Dmap_Fx1, Dmap_PTV, epsilon);
    
    
    % Write the concatenated distance maps
    fnameout =  [base_dir, sprintf('%02d',patient_number), '\', results_dir,'\', ROI_name{iter}, '_Fx1_Dmap_linear_array.raw'];
    fid = fopen(fnameout,'w');
    cnt=fwrite(fid,Dmap_Fx1_contour,'double');
    fclose(fid);
    
    
    fnameout =  [base_dir, sprintf('%02d',patient_number), '\', results_dir,'\', ROI_name{iter}, '_PTV_Dmap_linear_array.raw'];
    fid = fopen(fnameout,'w');
    cnt=fwrite(fid,Dmap_PTV_contour,'double');
    fclose(fid);
    
    % Write distance maps of union
    fnameout =  [base_dir, sprintf('%02d',patient_number), '\', results_dir,'\', ROI_name{iter}, '_Fx1_union_Dmap_linear_array.raw'];
    fid = fopen(fnameout,'w');
    cnt=fwrite(fid,Dmap_Fx1_union,'double');
    fclose(fid);
    
    
    fnameout =  [base_dir, sprintf('%02d',patient_number), '\', results_dir,'\', ROI_name{iter}, '_PTV_union_Dmap_linear_array.raw'];
    fid = fopen(fnameout,'w');
    cnt=fwrite(fid,Dmap_PTV_union,'double');
    fclose(fid);
end