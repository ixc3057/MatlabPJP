function [seg_contour, seg_contour_downsample, NumberPointsTrunc, NumberPointsDS] = load_VR_struct (indir, roi_no, DS_factor, PTV_min_z, PTV_max_z, SliceThickness, num_slices)
% Function to load the structure from the dicom file and output points and
% decimated points
%
%
%
% (C) Ishita Chen, 1/25/2016

dd=dir([indir '\RTS*.dcm']);
dinfo=dicominfo([indir '\' dd.name]);

NumberPoints = 0;
seg_contour = [];

for i = 1:numel(fieldnames(eval(['dinfo.ROIContourSequence.Item_' num2str(roi_no) '.ContourSequence'])))
    % seg_contour = eval(['dinfo.ROIContourSequence.Item_' num2str(roi_no) '.ContourSequence.Item_' num2str(i) '.ContourData']);
    % locations(i)=seg_contour(3);
    % disp(eval(['dinfo.ROIContourSequence.Item_' num2str(roi_no) '.ContourSequence.Item_' num2str(i)]))
    NumberPoints = NumberPoints + eval(['dinfo.ROIContourSequence.Item_' num2str(roi_no) '.ContourSequence.Item_' num2str(i) '.NumberOfContourPoints']);
    seg_contour = [ seg_contour; eval(['dinfo.ROIContourSequence.Item_' num2str(roi_no) '.ContourSequence.Item_' num2str(i) '.ContourData']) ];
end

% disp([ 'Number of points: ', num2str(NumberPoints) ])
% disp('Size of contour data: ')
% disp(size(seg_contour))
% disp(seg_contour(1:9))

seg_contour = reshape(seg_contour,3,[])';
seg_contour = truncate_points(seg_contour, PTV_min_z, PTV_max_z, SliceThickness, num_slices);
NumberPointsTrunc = size(seg_contour,1);
% disp('Size of contour data: ')
% disp(size(seg_contour))
% disp(seg_contour(1:3,:))

% Downsample points
point_ind = [1:NumberPointsTrunc]';
point_ind_d = downsample(point_ind,DS_factor);
seg_contour_downsample = seg_contour(point_ind_d,:);
NumberPointsDS = length(point_ind_d);
% disp('Size of downsampled contour data: ')
% disp(size(seg_contour_downsample))
% disp(seg_contour_downsample(1:3,:))