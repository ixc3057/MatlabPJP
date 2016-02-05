clear, clc, close all, format compact

%% Inputs
% Patient number
patient_number = 5;
% Fraction numbers to compare to each other
fraction_number = 1;
fxnums = 25;
% Number of slices above and below PTV to truncate
num_slices_PTV = 5;

% Structure of interest
ROI_name = 'DUODENUM';

%ROI_name = 'Skin';
%ROI_name_full = ROI_name;

epsilon = 1e-3;

indir = ['C:\Users\Ishita\Documents\MATLAB\Patient_0', num2str(patient_number) '\Abdomen_SB_Fx', num2str(fraction_number),'_Delivery']
ROI_name_full = [ROI_name, '_FX', num2str(fraction_number)];

fnameout =  ['C:\Users\Ishita\Documents\MATLAB\Patient_0', num2str(patient_number), '\Analysis\', ROI_name_full, '_mask.raw'];

%% Load MRI file
[I, PixelSpacing, SliceThickness, ImagePositionPatient, ImageOrientationPatient, ImgSize] = load_VR_MRI(indir);
ImgSize = double(ImgSize);
NumSlices = size(I,3);
Imask =zeros(size(I));
I_z_ind = ImagePositionPatient(:,3);    % z indices of all slices
I_x_or = ImagePositionPatient(1,1);     % x origin of the image
I_y_or = ImagePositionPatient(1,2);     % y origin of the image

ImagePositionPatient = ImagePositionPatient(end,:);

fnameout =  ['C:\Users\Ishita\Documents\MATLAB\Patient_0', num2str(patient_number), '\', ROI_name_full, '_mask.raw'];

fid = fopen(fnameout,'r');
contourmask1 = fread(fid);
contourmask1 = reshape(contourmask1, size(I));
fclose(fid);

contourmask2 = zeros(size(contourmask1));

for ii = 2:fxnums
    
    fraction_number = ii;
    
    indir = ['C:\Users\Ishita\Documents\MATLAB\Patient_0', num2str(patient_number) '\Abdomen_SB_Fx', num2str(fraction_number),'_Delivery']
    ROI_name_full = [ROI_name, '_FX', num2str(fraction_number)];
    
    fnameout =  ['C:\Users\Ishita\Documents\MATLAB\Patient_0', num2str(patient_number), '\', ROI_name_full, '_mask.raw'];

    fid = fopen(fnameout,'r');
    contourmask2tmp = fread(fid);
    contourmask2tmp = reshape(contourmask2tmp, size(I));
    
    contourmask2 = or(contourmask2, contourmask2tmp);
end

figure(1)
for ii = 1:size(I,3)
    subplot(1,2,1)
    imagesc(contourmask1(:,:,ii), [0 1])
    axis equal
    colormap(gray)
    title(['Slice #', num2str(ii)])
    subplot(1,2,2)
    imagesc(contourmask2(:,:,ii), [0 1])
    axis equal
    colormap(gray)
    title(['Slice #', num2str(ii)])
    pause(0.1)
end

%% Write the file
fnameout =  ['C:\Users\Ishita\Documents\MATLAB\Patient_0', num2str(patient_number), '\', ROI_name, '_mask_union.raw'];
fid = fopen(fnameout,'w');
cnt=fwrite(fid,contourmask2,'uint8');
fclose(fid);