clear, clc, close all, format compact

%% Inputs
% Patient number
patient_number = 5;
% Fraction numbers to compare to each other
fraction_number = 1;
fxnums = 25;
% Number of slices above and below PTV to truncate
num_slices_PTV = 5;

% Structure of interest
ROI_name = 'LARGEBOWEL';

%ROI_name = 'Skin';
%ROI_name_full = ROI_name;

epsilon = 1e-3;

indir = ['C:\Users\ichen\Documents\data-anon-matlab\Patient_0', num2str(patient_number) '\Abdomen_SB_Fx', num2str(fraction_number),'_Delivery']
ROI_name_full = [ROI_name, '_FX', num2str(fraction_number)];

%% Load MRI file for first fraction
[I, PixelSpacing, SliceThickness, ImagePositionPatient, ImageOrientationPatient, ImgSize] = load_VR_MRI(indir);
ImgSize = double(ImgSize);
NumSlices = size(I,3);
Imask =zeros(size(I));
I_z_ind = ImagePositionPatient(:,3);    % z indices of all slices
I_x_or = ImagePositionPatient(1,1);     % x origin of the image
I_y_or = ImagePositionPatient(1,2);     % y origin of the image

ImagePositionPatient = ImagePositionPatient(end,:);

% Load binary mask for first fraction
fnameout =  ['C:\Users\ichen\Documents\data-anon-matlab\Patient_0', num2str(patient_number), '\Analysis\', ROI_name_full, '_mask.raw'];
fid = fopen(fnameout,'r');
contourmask1 = fread(fid,'uint8');
contourmask1 = reshape(contourmask1, size(I));
fclose(fid);

% Load distance map for first fraction
fnameout =  ['C:\Users\ichen\Documents\data-anon-matlab\Patient_0', num2str(patient_number), '\Analysis\', ROI_name_full, '_Dmap.raw'];
fid = fopen(fnameout,'r');
Dmap_Fx1 = fread(fid,'double');
Dmap_Fx1 = reshape(Dmap_Fx1, size(I));
fclose(fid);

% Load the mask for PTV
fnameout =  ['C:\Users\ichen\Documents\data-anon-matlab\Patient_0', num2str(patient_number), '\Analysis\PTV_mask.raw'];
fid = fopen(fnameout,'r');
PTV_mask = fread(fid,'uint8');
PTV_mask = reshape(PTV_mask, size(I));
fclose(fid);

% Load distance map for PTV
fnameout =  ['C:\Users\ichen\Documents\data-anon-matlab\Patient_0', num2str(patient_number), '\Analysis\PTV_Dmap.raw'];
fid = fopen(fnameout,'r');
Dmap_PTV = fread(fid,'double');
Dmap_PTV = reshape(Dmap_PTV, size(I));
fclose(fid);

Dmap_Fx1_contour = [];
Dmap_PTV_contour = [];

for iter = 2:fxnums
    fraction_number = iter;
    ROI_name_full = [ROI_name, '_FX', num2str(fraction_number)];
    
    % Load new fraction
    fnameout =  ['C:\Users\ichen\Documents\data-anon-matlab\Patient_0', num2str(patient_number), '\Analysis\', ROI_name_full, '_mask.raw'];
    fid = fopen(fnameout,'r');
    contourmask2 = fread(fid,'uint8');
    contourmask2 = reshape(contourmask2, size(I));
    fclose(fid);
    
    % Create difference of new fraction mask and first fraction
    union_sub = and(~contourmask1, contourmask2);

    %     % Plot images
    %     h = figure(1);
    %     % for ii = 1:size(I,3)
    %     for ii = 40:100
    %         subplot(2,2,1)
    %         imagesc(contourmask1(:,:,ii), [0 1])
    %         axis equal; axis tight;
    %         colormap(gray)
    %         title(['Fx #', num2str(fraction_number), ' Slice #', num2str(ii)])
    %         subplot(2,2,2)
    %         imagesc(contourmask2(:,:,ii), [0 1])
    %         axis equal; axis tight;
    %         colormap(gray)
    %         title(['Fx #', num2str(fraction_number), ' Slice #', num2str(ii)])
    %         subplot(2,2,3)
    %         imagesc(union_sub(:,:,ii), [0 1])
    %         axis equal; axis tight;
    %         colormap(gray)
    %         title(['Subtr, Slice #', num2str(ii)])
    %         pause(0.01)
    %         subplot(2,2,4)
    %         imagesc(PTV_mask(:,:,ii), [0 1])
    %         axis equal; axis tight;
    %         colormap(gray)
    %         title(['PTV, Slice #', num2str(ii)])
    %         set(h,'Position',[67 141 1151 790])
    %         pause
    %     end
    
    %     % Plot distance maps
    %     h = figure(2);
    %     % for ii = 1:size(I,3)
    %     for ii = 40:100
    %         subplot(1,2,1)
    %         imagesc(Dmap_Fx1(:,:,ii), [0 150])
    %         colormap(jet)
    %         axis equal; axis tight;
    %         title(['Fx1 Dmap, Slice #', num2str(ii)])
    %         subplot(1,2,2)
    %         imagesc(Dmap_PTV(:,:,ii), [0 150])
    %         colormap(jet)
    %         axis equal; axis tight;
    %         title(['PTV Dmap, Slice #', num2str(ii)])
    %         colorbar
    %         set(h,'Position',[64 239 1130 681]);
    %         pause(0.01)
    %
    %     end
    %     pause
    
    % Create linear array of non-zero elements of distance map of
    % subtracted image wrt Fx1 and PTV
    % Multiply distance map to binary mask
    Dmap_Fx1_tmp = Dmap_Fx1 .* union_sub;
    Dmap_PTV_tmp = Dmap_PTV .* union_sub;
    % Linearize arrays
    union_sub_flat = union_sub(:);
    Dmap_Fx1_tmp_flat = Dmap_Fx1_tmp(:);
    Dmap_PTV_tmp_flat = Dmap_PTV_tmp(:);
    % Separate non-zero elements of mask
    [non_zero_ind] = find(union_sub_flat>0+epsilon);
    Dmap_Fx1_tmp_flat = Dmap_Fx1_tmp_flat(non_zero_ind);
    Dmap_PTV_tmp_flat = Dmap_PTV_tmp_flat(non_zero_ind);
    % Concatenate
    Dmap_Fx1_contour = [Dmap_Fx1_contour; Dmap_Fx1_tmp_flat];
    Dmap_PTV_contour = [Dmap_PTV_contour; Dmap_PTV_tmp_flat];
    
    disp(iter)
    %     DmapFlat = Dmap(:);
    %     DmaphistInd = find(DmapFlat>3);
    %     Dmaphist = DmapFlat(DmaphistInd);
    %     figure(3)
    %     bar(hist(Dmaphist,[3:3:60]) ./ sum(hist(Dmaphist,[3:3:60]))*100)
    %     xlabel('Distance (mm)')
    %     ylabel('% Pixels')
    %     title('Patient #5, Duodenum')
end

% Write the concatenated distance maps
fnameout =  ['C:\Users\ichen\Documents\data-anon-matlab\Patient_0', num2str(patient_number), '\Analysis\', ROI_name, '_Fx1_Dmap_linear_array.raw'];
fid = fopen(fnameout,'w');
cnt=fwrite(fid,Dmap_Fx1_contour,'double');
fclose(fid);


fnameout =  ['C:\Users\ichen\Documents\data-anon-matlab\Patient_0', num2str(patient_number), '\Analysis\', ROI_name, '_PTV_Dmap_linear_array.raw'];
fid = fopen(fnameout,'w');
cnt=fwrite(fid,Dmap_PTV_contour,'double');
fclose(fid);