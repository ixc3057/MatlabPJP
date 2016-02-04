clear, clc, close all, format compact

%% Inputs
% Patient number
patient_number = 5;
% Fraction numbers to compare to each other
fraction_number = 1;
% Number of slices above and below PTV to truncate
num_slices_PTV = 5;

% Structure of interest
ROI_name = 'DUODENUM';
ROI_name_full = [ROI_name, '_FX', num2str(fraction_number)];
%ROI_name = 'Skin';
%ROI_name_full = ROI_name;

epsilon = 1e-7;

indir = ['C:\Users\ichen\Documents\anon_data\Patient_0', num2str(patient_number) '\Abdomen_SB_Fx', num2str(fraction_number),'_Delivery']

%% Load MRI file
% [I, PixelSpacing, SliceThickness, ImagePositionPatient, ImageOrientationPatient, ImgSize] = load_VR_MRI(indir);
[I, PixelSpacing, SliceThickness, ImagePositionPatient, ImageOrientationPatient, ImgSize] = load_VR_MRI(indir);
I_z_ind = ImagePositionPatient(:,3);    % z indices of all slices
ImagePositionPatient = ImagePositionPatient(end,:);
ImgSize = double(ImgSize);
NumSlices = size(I,3);
Imask =zeros(size(I));

dd=dir([indir '\RTS*.dcm']);
dinfo=dicominfo([indir '\' dd.name]);

[ROIidx, roi_name_int, PTV_min_z, PTV_max_z] = StructureExamine (indir, ROI_name_full);


PTV_min_z = PTV_min_z - num_slices_PTV*SliceThickness;
PTV_max_z = PTV_max_z + num_slices_PTV*SliceThickness;


% % Get the structure names from the dicom file
% numROIs = numel(fieldnames(dinfo.StructureSetROISequence));  % Number of contours
% 
% ROIidx = -1;
% for i=1:numROIs
%     roi_names{i,1}= eval(['dinfo.StructureSetROISequence.Item_' num2str(i) '.ROIName']);
%     roi_name_str = cell2mat(roi_names(i));
%     
%     % If this is the structure of interest, return item #
%     if strcmp(cell2mat(roi_names(i,1)), ROI_name_full)
%         ROIidx = i;
%     end
% end
% 
% if ROIidx == -1
%     disp(['Error, cannot find structure.']);
%     return
% end

% Get the contour data
numContours = numel(fieldnames(eval(['dinfo.ROIContourSequence.Item_' num2str(ROIidx) '.ContourSequence'])));
zcoors=[];
for i = 1:numContours
    tempContour=eval(['dinfo.ROIContourSequence.Item_' num2str(ROIidx) '.ContourSequence.Item_' num2str(i) '.ContourData']);
    tempContour=reshape(tempContour, 3, length(tempContour)/3);
    
    zcoor=mean(tempContour(3, :)); % The zcoordinate of this coordinate, which corresponds to an image slice
    if zcoor >=(PTV_min_z-epsilon) & zcoor <=(PTV_max_z+epsilon)
        zcoors=[zcoors zcoor];
    end
end

% Sort the slices according to Z-coordinates
[sortedzcoors, tmpidx] = sort(zcoors); 

% Find unique Z-coordinate, which can differ by epsilon
uniquezcoors = sortedzcoors(1);
for i = sortedzcoors(2:end)
    % If this coordinate differs from the last element by epsilon then
    % add to the queue of uniquezcoors
    if i-uniquezcoors(end) > epsilon
        uniquezcoors = [uniquezcoors i];
    end
end

% Make meshgrids according to these coordinate systems
[xgrid, ygrid] = meshgrid([0:ImgSize(2)-1]*PixelSpacing(1)+ImagePositionPatient(1),...
                          [0:ImgSize(1)-1]*PixelSpacing(2)+ImagePositionPatient(2));
contourmask = zeros([size(xgrid),length(uniquezcoors)]);

% Create volumetric mask for this organ
for i = tmpidx
    %Retrieve the contour sorted by the z coordinates
    tempContour=eval(['dinfo.ROIContourSequence.Item_' num2str(ROIidx) '.ContourSequence.Item_' num2str(i) '.ContourData']); 
    tempContour=reshape(tempContour, 3, length(tempContour)/3);
    
    %Locate the slice corresponding to this contour
    sliceidx = find((zcoors(i)-SliceThickness/2 < uniquezcoors) & (zcoors(i)+SliceThickness/2 > uniquezcoors));
    
    if isempty(sliceidx)
        disp(['Error: cannot find a slice for this coordinate: ' num2str(zcoors(i))]);
    end
    
    % Test whether coordinates are inside the polygon
    %insideContour = inpolygon(xgrid, ygrid,... 
    %                          tempContour(1, :),tempContour(2, :));
    %imagesc(insideContour); title([num2str(zcoor), '; Slice ', num2str(i)]);
    %pause;
    
    testpts = [reshape(xgrid, prod(ImgSize), 1),...
               reshape(ygrid, prod(ImgSize), 1)];
       
    insideContour = inpoly(testpts, tempContour(1:2,:)');
    insideContour = reshape(insideContour, ImgSize(1), ImgSize(2));
    
    % Concatenate the result to the contourmask using the OR function
    contourmask(:,:,sliceidx) = contourmask(:,:,sliceidx) | insideContour;
    
    %     figure(gcf);
    %     imagesc(squeeze(contourmask(:,:,i))); title(['Z=', num2str(zcoors(i)), 'mm, Slice: ', num2str(sliceidx)]);
    %     colormap(gray);
    %     pause;
end 

%% Assume that Z-coordinate of slice = sliceidx * SliceThickness - ImagePosition(3)
for i = 1:size(contourmask,3)
    figure(gcf);
    subplot(1,2,1);
    imagesc(squeeze(contourmask(:,:,i))); title(['Slice: ', num2str(i)]); axis equal; 
    subplot(1,2,2);
    sliceidx = NumSlices-round((ImagePositionPatient(3)-uniquezcoors(i))/SliceThickness);
    imagesc(double(squeeze(I(:,:,sliceidx))).*squeeze(contourmask(:,:,i))*30+...
            double(squeeze(I(:,:,sliceidx))).*squeeze(~contourmask(:,:,i))*10); title(['Slice: ', num2str(sliceidx)]); axis equal;
    colormap(gray);
    pause;
end