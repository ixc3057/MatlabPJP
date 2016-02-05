clear, clc, close all, format compact

%% Inputs
% Patient number
patient_number = 5;
% Fraction numbers to compare to each other
fraction_number = 4;
% Number of slices above and below PTV to truncate
num_slices_PTV = 5;

% Structure of interest
ROI_name = 'DUODENUM';
ROI_name_full = [ROI_name, '_FX', num2str(fraction_number)];
%ROI_name = 'Skin';
%ROI_name_full = ROI_name;

epsilon = 1e-3;

indir = ['C:\Users\Ishita\Documents\MATLAB\Patient_0', num2str(patient_number) '\Abdomen_SB_Fx', num2str(fraction_number),'_Delivery']

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

[ROIidx, roi_name_int, PTV_min_z, PTV_max_z] = StructureExamine (indir, ROI_name_full);


PTV_min_z = PTV_min_z - num_slices_PTV*SliceThickness - epsilon;
PTV_max_z = PTV_max_z + num_slices_PTV*SliceThickness + epsilon;


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
item_no=[];
for i = 1:numContours
    tempContour=eval(['dinfo.ROIContourSequence.Item_' num2str(ROIidx) '.ContourSequence.Item_' num2str(i) '.ContourData']);
    tempContour=reshape(tempContour, 3, length(tempContour)/3);
    
    zcoor=mean(tempContour(3, :)); % The zcoordinate of this coordinate, which corresponds to an image slice
    if zcoor >=PTV_min_z & zcoor <=PTV_max_z
        zcoors=[zcoors zcoor];
        item_no = [item_no i];
    end
end
h=figure(1);
subplot(1,3,1)
plot(zcoors,'*')
title('zcoors')
axis square

% Sort the slices according to Z-coordinates
[sortedzcoors, tmpidx] = sort(zcoors); 
subplot(1,3,2)
plot(sortedzcoors,'*')
title('Sorted')
axis square

% Find unique Z-coordinate, which can differ by epsilon
uniquezcoors = sortedzcoors(1);
for i = sortedzcoors(2:end)
    % If this coordinate differs from the last element by epsilon then
    % add to the queue of uniquezcoors
    if i-uniquezcoors(end) > epsilon
        uniquezcoors = [uniquezcoors i];
    end
end
subplot(1,3,3)
plot(uniquezcoors,'*')
title('Unique')
axis square
set(h,'Position', [57 524 1185 378])

% Make meshgrids according to these coordinate systems
% [xgrid, ygrid] = meshgrid([0:ImgSize(1)-1]*PixelSpacing(1)+I_x_or,...
%                           [0:ImgSize(2)-1]*PixelSpacing(2)+I_y_or);
[xgrid, ygrid] = meshgrid([0:ImgSize(2)-1]*PixelSpacing(1)+ImagePositionPatient(1),...
                          [0:ImgSize(1)-1]*PixelSpacing(2)+ImagePositionPatient(2));
% xgrid = xgrid';
% ygrid = ygrid';
contourmask = zeros(size(I));
contourmask_non_conc = zeros([ImgSize length(tmpidx)]); %Non concatenated mask

% Create volumetric mask for this organ
for i = tmpidx
    ind = item_no(i);
    %Retrieve the contour sorted by the z coordinates
    tempContour=eval(['dinfo.ROIContourSequence.Item_' num2str(ROIidx) '.ContourSequence.Item_' num2str(ind) '.ContourData']); 
    tempContour=reshape(tempContour, 3, length(tempContour)/3);
    
    %Locate the slice corresponding to this contour
    % sliceidx = find((zcoors(i)-SliceThickness/2 < uniquezcoors) & (zcoors(i)+SliceThickness/2 > uniquezcoors));
    z_up = zcoors(i) - epsilon;
    z_down = zcoors(i) + epsilon;
    sliceidx = find(I_z_ind>z_up & I_z_ind<z_down);
    
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
    
    contourPoints = zeros(length(tempContour),2);
    contourPoints(:,1)=round((tempContour(1,:)-I_x_or*ImageOrientationPatient(1))/PixelSpacing(1))+1;
    contourPoints(:,2)=round((tempContour(2,:)-I_y_or*ImageOrientationPatient(5))/PixelSpacing(2))+1;
    
    figure(2)
    subplot(1,2,1)
    imagesc(I(:,:,sliceidx), [10 300])
    axis equal
    colormap(gray)
    hold on;plot(contourPoints(:,1),contourPoints(:,2));
    hold off
    subplot(1,2,2)
    imagesc(insideContour)
    axis equal
    colormap(gray)
    hold on;plot(contourPoints(:,1),contourPoints(:,2));
    hold off
    pause(0.1)
    
    % Place the mask slice in noncocatenated file
    contourmask_non_conc(:,:,i) = insideContour;
    
    % Concatenate the result to the contourmask using the OR function
    contourmask(:,:,sliceidx) = contourmask(:,:,sliceidx) | insideContour;
    
    %     figure(gcf);
    %     imagesc(squeeze(contourmask(:,:,i))); title(['Z=', num2str(zcoors(i)), 'mm, Slice: ', num2str(sliceidx)]);
    %     colormap(gray);
    %     pause;
end


% Display entire image w points and mask to verify
for i = 1:size(I,3)
    figure(3)
    imagesc(contourmask(:,:,i), [0 1])
    title(['Slice #', num2str(i)])
    colormap(gray)
    pause(0.05)
end

% %% Assume that Z-coordinate of slice = sliceidx * SliceThickness - ImagePosition(3)
% for i = 1:size(contourmask,3)
%     figure(gcf);
%     subplot(1,2,1);
%     imagesc(squeeze(contourmask(:,:,i))); title(['Slice: ', num2str(i)]); axis equal; 
%     subplot(1,2,2);
%     sliceidx = NumSlices-round((ImagePositionPatient(3)-uniquezcoors(i))/SliceThickness);
%     imagesc(double(squeeze(I(:,:,sliceidx))).*squeeze(contourmask(:,:,i))*30+...
%             double(squeeze(I(:,:,sliceidx))).*squeeze(~contourmask(:,:,i))*10); title(['Slice: ', num2str(sliceidx)]); axis equal;
%     colormap(gray);
%     pause;
% end