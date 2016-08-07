clear, clc, close all, format compact
% View image and distanc map with an overlay of contours

%% Inputs
% Patient number
patient_number = 7;
% Fraction numbers to compare to each other
fraction_number_init = 2;
fraction_number = fraction_number_init;
fraction_number2 = 5;
fxnums = 25;

% Number of slices above and below PTV to truncate
num_slices_PTV = 5;

% Structure of interest
ROI_name = 'STOMACH';

% Precision error
epsilon = 1e-6;

% File locations
base_dir = 'C:\Users\ichen\Documents\data_anon\Patient_';
results_dir = 'Analysis';

% Names
indir = [base_dir, sprintf('%02d',patient_number) '\Abdomen_SB_Fx', num2str(fraction_number),'_Delivery']
ROI_name_full = [ROI_name, '_FX', num2str(fraction_number)];
ROI_name_full2 = [ROI_name, '_FX', num2str(fraction_number2)];

%% Load MRI file for first fraction
[I, PixelSpacing, SliceThickness, ImagePositionPatient, ImageOrientationPatient, ImgSize] = load_VR_MRI(indir);
I = flipdim(I,3);
ImgSize = double(ImgSize);
NumSlices = size(I,3);
Imask =zeros(size(I));
I_z_ind = ImagePositionPatient(:,3);    % z indices of all slices
I_x_or = ImagePositionPatient(1,1);     % x origin of the image
I_y_or = ImagePositionPatient(1,2);     % y origin of the image

ImagePositionPatient = ImagePositionPatient(end,:);

%% Display
h=figure(1)
% set(h,'Position',[12         422        1249         942])
% set(h,'Position',[151   181   939   731])
for iter = 2:2:288
    
    % Display image slice
    figure(1);
%     subplot(2,2,1)
    imagesc(I(:,:,iter), [10 350])
    axis equal; axis tight; axis off
    colormap(gray)
    title(['Slice #', num2str(iter)],'FontSize',20)
    pause(0.1)
end