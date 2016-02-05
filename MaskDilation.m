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

fnameout =  ['C:\Users\Ishita\Documents\MATLAB\Patient_0', num2str(patient_number), '\', ROI_name_full, '_mask.raw'];

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

fnameout =  ['C:\Users\Ishita\Documents\MATLAB\Patient_0', num2str(patient_number), '\', ROI_name, '_mask_union.raw'];

fid = fopen(fnameout,'r');
contourmask2 = fread(fid);
contourmask2 = reshape(contourmask2, size(I));
fclose(fid);

union_sub = and(~contourmask1, contourmask2);


aspectRatio = [PixelSpacing; SliceThickness]';
Dmap = bwdistsc(contourmask1, aspectRatio);
Dmap = Dmap .* union_sub;
% Dmap=bwdistsc(contourmask1);

figure(1)
% for ii = 1:size(I,3)
for ii = 40:100
    subplot(1,3,1)
    imagesc(contourmask1(:,:,ii), [0 1])
    axis equal
    colormap(gray)
    title(['Mask1, Slice #', num2str(ii)])
    subplot(1,3,2)
    imagesc(contourmask2(:,:,ii), [0 1])
    axis equal
    colormap(gray)
    title(['Union, Slice #', num2str(ii)])
    subplot(1,3,3)
    imagesc(union_sub(:,:,ii), [0 1])
    axis equal
    colormap(gray)
    title(['Subtr, Slice #', num2str(ii)])
    pause(0.01)
end

figure(2)
for ii = 1:size(I,3)
    title(['Slice #', num2str(ii)])
    imagesc(Dmap(:,:,ii), [0 100])
    colormap(jet)
    axis equal
    title(['Slice #', num2str(ii)])
    colorbar
    pause(0.1)
    
end

