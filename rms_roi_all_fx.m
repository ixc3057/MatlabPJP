% Plot the RMS distance across all fractions for ROIs of interest
% 
%
%
% (C) Ishita Chen, 1/26/2016

clear, clc, close all, format compact

% Inputs
patient_number = 5;
num_fx = 25
root_dir = 'C:\Users\ichen\Documents\anon_data\Patient_0';
indir1 = [root_dir, num2str(patient_number), '\Abdomen_SB_Fx1_Delivery'];
roi_of_interest_name = cell(4,1); 
roi_of_interest_name{1} = 'STOMACH';
roi_of_interest_name{2} = 'DUODENUM';
roi_of_interest_name{3} = 'SMALLBOWEL';
roi_of_interest_name{4} = 'LARGEBOWEL';

% Downsampling factor
DSfactor1 = 10;
DSfactor2 = 10;

% Number of slices above and below PTV to truncate
num_slices1 = 5;
num_slices2 = 5;

iter = 0;

rms_dist = zeros(4,num_fx-1);

for ii = 1:4
    
    roi_of_interest_01 = [roi_of_interest_name{ii}, '_FX1'];
        
    % Load first MRI file
    [I1, PixelSpacing1, SliceThickness1, ImagePositionPatient1, ImageOrientationPatient1] = load_VR_MRI(indir1);
    
    % Examine first structure file
    [roi_no1, roi_name1, PTV_min_z1, PTV_max_z1] = StructureExamine (indir1, roi_of_interest_01);
    
    % Load the first point data
    [seg_contour1, seg_contour_downsample1, NumberPoints1, NumberPointsDS1] = load_VR_struct(indir1, roi_no1, DSfactor1, PTV_min_z1, PTV_max_z1, SliceThickness1, num_slices1);
    
    for jj = 2:num_fx
        
        roi_of_interest_02 = [roi_of_interest_name{ii}, '_FX', num2str(jj)];
        
        % Set file directory
        indir2 = [root_dir, num2str(patient_number), '\Abdomen_SB_Fx', num2str(jj),'_Delivery'];
        
        % Load second MRI file
        [I2, PixelSpacing2, SliceThickness2, ImagePositionPatient2, ImageOrientationPatient2] = load_VR_MRI(indir2);
        
        % Examine second structure file
        [roi_no2, roi_name2, PTV_min_z2, PTV_max_z2] = StructureExamine (indir2, roi_of_interest_02);
        
        % Load the point data
        [seg_contour2, seg_contour_downsample2, NumberPoints2, NumberPointsDS2] = load_VR_struct(indir2, roi_no2, DSfactor2, PTV_min_z2, PTV_max_z2, SliceThickness2, num_slices2);
        
        % Easy variable names for plotting
        x1 = seg_contour_downsample1(:,1);
        y1 = seg_contour_downsample1(:,2);
        z1 = seg_contour_downsample1(:,3);
        x2 = seg_contour_downsample2(:,1);
        y2 = seg_contour_downsample2(:,2);
        z2 = seg_contour_downsample2(:,3);
        
        M = [x1 y1 z1]';    % Reference data
        D = [x2 y2 z2]';    % Target data
        
        % Run ICP (fast kDtree matching and extrapolation)
        [Ricp Ticp ER t matchIDX] = icp(M, D, 30, 'Matching', 'kDtree', 'Extrapolation', true);
        
        M_crrsp_pts = M(:,matchIDX);
        rms_dist(ii,jj-1) = rms_error(D,M_crrsp_pts);
        iter = iter + 1;
        disp(['iter: ', num2str(iter), '; ', roi_of_interest_01, ', Fx #', num2str(jj)])
    end
    
end

h=figure(1)
set(h,'Position',[107, 174, 1091, 751])
% Plot the results
subplot(2,2,1);
plot(2:num_fx,rms_dist(1,:),'--x');
xlabel('fx#');
ylabel('d_{RMS}');
title([roi_of_interest_name{1}]);

subplot(2,2,2);
plot(2:num_fx,rms_dist(2,:),'--x');
xlabel('fx#');
ylabel('d_{RMS}');
title([roi_of_interest_name{2}]);

subplot(2,2,3);
plot(2:num_fx,rms_dist(3,:),'--x');
xlabel('fx#');
ylabel('d_{RMS}');
title([roi_of_interest_name{3}]);

subplot(2,2,4);
plot(2:num_fx,rms_dist(4,:),'--x');
xlabel('fx#');
ylabel('d_{RMS}');
title([roi_of_interest_name{4}]);

suptitle(['PATIENT #0', num2str(patient_number)])