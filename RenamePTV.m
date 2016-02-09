% Load DICOM structure files
% 
%
%
% (C) Ishita Chen, 1/29/2016

clear, clc, close all, format compact

% Inputs
% Patient number
patient_number = 3;
% Fraction numbers to compare to each other
fraction_number_N = 25;

roi_of_interest = 'PTV_4500';

roi_name_int = {};

for fraction_number_1 = 1:fraction_number_N
    disp(fraction_number_1)
    indir1 = ['C:\Users\Ishita\Documents\data\Patient_0', num2str(patient_number) '\Abdomen_SB_Fx', num2str(fraction_number_1),'_Delivery']
    
    dd=dir([indir1 '\RTS*.dcm']);
    file_in = ([indir1 '\' dd.name]);
    %     file_in = [indir1,'\test.dcm'];
    dinfo=dicominfo(file_in);
    file_out = file_in;
    %     file_out = [indir1,'\test.dcm'];
    roi_num= numel(fieldnames(dinfo.StructureSetROISequence));  % Number of contours
    roi_names=cell(roi_num,1);  % Empty array to contain names of the segmented structures
    
    % Get the structure names from the dicom file
    item_no = []
    iter = 0;
    
    for i=1:roi_num
        roi_names{i,1}= eval(['dinfo.StructureSetROISequence.Item_' num2str(i) '.ROIName']);
        roi_name_str = cell2mat(roi_names(i));
        if regexp(roi_name_str, regexptranslate('wildcard', 'PTV*'))
            if strcmp(roi_name_str, roi_of_interest)
                PTV_item_no = i;
            end
            iter = iter + 1;
            roi_name_int{iter,1} = roi_name_str;
            item_no = [item_no; i];
        end
    end
    
    
    disp(roi_names)
    disp(item_no)
    disp(roi_name_int)
    disp(PTV_item_no)
    
    PTV_info = dinfo;
    PTV_info.StructureSetROISequence.Item_15.ROIName = 'PTV';
    dicomanon(file_in, file_out, 'update', PTV_info);
end