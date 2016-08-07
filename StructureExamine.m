function [roi_num_int, roi_name_int, PTV_min_z, PTV_max_z] = StructureExamine (indir, roi_of_interest, PTV_name)

dd=dir([indir '\RTS*.dcm']);
dinfo=dicominfo([indir '\' dd.name]);
roi_num= numel(fieldnames(dinfo.StructureSetROISequence));  % Number of contours
roi_names=cell(roi_num,1);  % Empty array to contain names of the segmented structures
seg_contour_PTV = [];

% Get the structure names from the dicom file
for i=1:roi_num
    roi_names{i,1}= eval(['dinfo.StructureSetROISequence.Item_' num2str(i) '.ROIName']);
    roi_name_str = cell2mat(roi_names(i));
    % If this is the structure of interest, return item #
    if strcmp(cell2mat(roi_names(i,1)), roi_of_interest)
        roi_num_int = i;
        roi_name_int = roi_names{i,1};
    end
    % If this is PTV, load points
    if strcmp(cell2mat(roi_names(i,1)), PTV_name)
    % if regexp(roi_name_str, regexptranslate('wildcard', 'PTV*'))
        for ii = 1:numel(fieldnames(eval(['dinfo.ROIContourSequence.Item_' num2str(i) '.ContourSequence'])))
            seg_contour_PTV = [ seg_contour_PTV; eval(['dinfo.ROIContourSequence.Item_' num2str(i) '.ContourSequence.Item_' num2str(ii) '.ContourData']) ];
        end
    end
end

% Get upper and lower z-range of PTV
seg_contour_PTV = reshape(seg_contour_PTV,3,[])';
seg_contour_PTV_z = seg_contour_PTV(:,3);
PTV_min_z = min(seg_contour_PTV_z);
PTV_max_z = max(seg_contour_PTV_z);