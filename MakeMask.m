function [contourmask, PixelSpacing, SliceThickness] = MakeMask(indir, ROI_name_full, num_slices_PTV, epsilon)

%% Load MRI
[I, PixelSpacing, SliceThickness, ImagePositionPatient, ImageOrientationPatient, ImgSize] = load_VR_MRI(indir);
ImgSize = double(ImgSize);
NumSlices = size(I,3);
Imask =zeros(size(I));
I_z_ind = ImagePositionPatient(:,3);    % z indices of all slices
I_x_or = ImagePositionPatient(1,1);     % x origin of the image
I_y_or = ImagePositionPatient(1,2);     % y origin of the image
ImagePositionPatient = ImagePositionPatient(end,:);


%% Load structure file
dd=dir([indir '\RTS*.dcm']);
dinfo=dicominfo([indir '\' dd.name]);

%% Get structure parameters
[ROIidx, roi_name_int, PTV_min_z, PTV_max_z] = StructureExamine (indir, ROI_name_full);
PTV_min_z = PTV_min_z - num_slices_PTV*SliceThickness - epsilon;
PTV_max_z = PTV_max_z + num_slices_PTV*SliceThickness + epsilon;

%% Get the contour data
numContours = numel(fieldnames(eval(['dinfo.ROIContourSequence.Item_' num2str(ROIidx) '.ContourSequence'])));
zcoors=[];
item_no=[];
for i = 1:numContours
    tempContour=eval(['dinfo.ROIContourSequence.Item_' num2str(ROIidx) '.ContourSequence.Item_' num2str(i) '.ContourData']);
    tempContour=reshape(tempContour, 3, length(tempContour)/3);
    
    zcoor=mean(tempContour(3, :)); % The zcoordinate of this coordinate, which corresponds to an image slice
    
    % Truncate by PTV slices
    if zcoor >=PTV_min_z & zcoor <=PTV_max_z
        zcoors=[zcoors zcoor];
        item_no = [item_no i];
    end
end

%% Sort the slices according to Z-coordinates
[sortedzcoors, tmpidx] = sort(zcoors);

%% Find unique Z-coordinate, which can differ by epsilon
uniquezcoors = sortedzcoors(1);
for i = sortedzcoors(2:end)
    % If this coordinate differs from the last element by epsilon then
    % add to the queue of uniquezcoors
    if i-uniquezcoors(end) > epsilon
        uniquezcoors = [uniquezcoors i];
    end
end

%% Make meshgrids according to these coordinate systems
[xgrid, ygrid] = meshgrid([0:ImgSize(2)-1]*PixelSpacing(1)+ImagePositionPatient(1),...
    [0:ImgSize(1)-1]*PixelSpacing(2)+ImagePositionPatient(2));

%% Initialize the mask variable
contourmask = zeros(size(I));

%% Create volumetric mask for this organ
for i = tmpidx
    ind = item_no(i);
    
    %Retrieve the contour sorted by the z coordinates
    tempContour=eval(['dinfo.ROIContourSequence.Item_' num2str(ROIidx) '.ContourSequence.Item_' num2str(ind) '.ContourData']);
    tempContour=reshape(tempContour, 3, length(tempContour)/3);
    
    %Locate the slice corresponding to this contour
    z_up = zcoors(i) - epsilon;
    z_down = zcoors(i) + epsilon;
    sliceidx = find(I_z_ind>z_up & I_z_ind<z_down);
    
    if isempty(sliceidx)
        disp(['Error: cannot find a slice for this coordinate: ' num2str(zcoors(i))]);
    end
    
    % Input for inpoly
    testpts = [reshape(xgrid, prod(ImgSize), 1),...
        reshape(ygrid, prod(ImgSize), 1)];
    
    % Create the binary mask slice
    insideContour = inpoly(testpts, tempContour(1:2,:)');
    insideContour = reshape(insideContour, ImgSize(1), ImgSize(2));
    
    % Concatenate the result to the contourmask using the OR function
    contourmask(:,:,sliceidx) = contourmask(:,:,sliceidx) | insideContour;
    
end

disp(size(I))
disp(PixelSpacing)
disp(SliceThickness)

%% Convert to uint8
contourmask = uint8(contourmask);