clear, clc, close all, format compact

%% Inputs
% Patient number
patient_number = 10;
% Fraction numbers to compare to each other
fraction_number = 13;
% Number of slices above and below PTV to truncate
num_slices_PTV = 5;

% Structure of interest
ROI_name = 'DUODENUM';
ROI_name_full = [ROI_name, '_FX', num2str(fraction_number)];
%ROI_name = 'Skin';
%ROI_name_full = ROI_name;

epsilon = 1e-3;

indir = ['C:\Users\ichen\Documents\data_anon\Patient_', sprintf('%02d',patient_number) '\Abdomen_SB_Fx', num2str(fraction_number),'_Delivery']

%% Load MRI file
[I, PixelSpacing, SliceThickness, ImagePositionPatient, ImageOrientationPatient, ImgSize] = load_VR_MRI(indir);
ImgSize = double(ImgSize);
NumSlices = size(I,3);
Imask =zeros(size(I));
I_z_ind = ImagePositionPatient(:,3);    % z indices of all slices
I_x_or = ImagePositionPatient(1,1);     % x origin of the image
I_y_or = ImagePositionPatient(1,2);     % y origin of the image

ImagePositionPatient = ImagePositionPatient(end,:);

dd=dir([indir '\RTS*.dcm']);
dinfo=dicominfo([indir '\' dd.name]);


% Get the structure names from the dicom file
numROIs = numel(fieldnames(dinfo.StructureSetROISequence));  % Number of contours
ROIidx = -1;
for i=1:numROIs
    roi_names{i,1}= eval(['dinfo.StructureSetROISequence.Item_' num2str(i) '.ROIName']);
    roi_name_str = cell2mat(roi_names(i));
    
    % If this is the structure of interest, return item #
    if strcmp(cell2mat(roi_names(i,1)), ROI_name_full)
        ROIidx = i;
    end
end
disp(roi_names)

if ROIidx == -1
    disp(['Error, cannot find structure.']);
    return
end
