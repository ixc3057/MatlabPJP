clear, clc, close all, format compact

%% Inputs
% Patient number
patient_number = 5;
% Fraction numbers to compare to each other
fraction_number = 1;

% Structure of interest
ROI_name = 'DUODENUM';
ROI_name_full = [ROI_name, '_FX', num2str(fraction_number)];
%ROI_name_full = ROI_name;

indir = ['C:\Users\Ishita\Documents\MATLAB\Patient_0', num2str(patient_number) '\Abdomen_SB_Fx', num2str(fraction_number),'_Delivery']

%% Load MRI file
[I, PixelSpacing, SliceThickness, ImagePositionPatient, ImageOrientationPatient, ImgSize] = load_VR_MRI(indir);
ImgSize = double(ImgSize);

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

if ROIidx == -1
    disp(['Error, cannot find structure.']);
    return
end

% Get the contour data
numContours = numel(fieldnames(eval(['dinfo.ROIContourSequence.Item_' num2str(ROIidx) '.ContourSequence'])));
zcoors=[];
for i = 1:numContours
    tempContour=eval(['dinfo.ROIContourSequence.Item_' num2str(ROIidx) '.ContourSequence.Item_' num2str(i) '.ContourData']);
    tempContour=reshape(tempContour, 3, length(tempContour)/3);
    
    zcoor=mean(tempContour(3, :)); % The zcoordinate of this coordinate, which corresponds to an image slice
    zcoors=[zcoors zcoor];
end

% Sort the slices according to Z-coordinates
[sortedzcoors, tmpidx] = sort(zcoors); 

% Find unique Z-coordinate, which can differ by epsilon
uniquezcoors = sortedzcoors(1);
for i = sortedzcoors(2:end)
    % If the this coordinate differs from the last element by epsilon then
    % add to the queue of uniquezcoors
    if i-uniquezcoors(end) > 1e-7
        uniquezcoors = [uniquezcoors i];
    end
end

% Make meshgrids according to these coordinate systems
[xgrid, ygrid] = meshgrid([0:ImgSize(1)-1]*PixelSpacing(1)+ImagePositionPatient(1),...
                          [0:ImgSize(2)-1]*PixelSpacing(2)+ImagePositionPatient(2));
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
    insideContour = reshape(insideContour, ImgSize(2), ImgSize(1));
    
    % Concatenate the result to the contourmask using the OR function
    contourmask(:,:,sliceidx) = contourmask(:,:,sliceidx) | insideContour;
    figure(gcf);
    imagesc(squeeze(contourmask(:,:,sliceidx))); title(['Z=', num2str(zcoors(i)), 'mm, Slice: ', num2str(sliceidx)]);
    colormap(gray);
    pause;
end  