clear, clc, close all, format compact
% View image and distanc map with an overlay of contours

%% Inputs
% Patient number
patient_number = 5;
% Fraction numbers to compare to each other
fraction_number_init = 2;
fraction_number = fraction_number_init;
fraction_number2 = 1;
fxnums = 25;

% Number of slices above and below PTV to truncate
num_slices_PTV = 5;

% Structure of interest
ROI_name = 'SMALLBOWEL';

% Precision error
epsilon = 1e-6;

% File locations
base_dir = 'C:\Users\ichen\Documents\data-anon-matlab\Patient_0';
results_dir = 'Analysis2';

% Names
indir = [base_dir, num2str(patient_number) '\Abdomen_SB_Fx', num2str(fraction_number),'_Delivery']
ROI_name_full = [ROI_name, '_FX', num2str(fraction_number)];
ROI_name_full2 = [ROI_name, '_FX', num2str(fraction_number2)];

%% Load MRI file for first fraction
[I, PixelSpacing, SliceThickness, ImagePositionPatient, ImageOrientationPatient, ImgSize] = load_VR_MRI(indir);
I = flipdim(I,3);
ImgSize = double(ImgSize);
NumSlices = size(I,3);
Imask =zeros(size(I));
I_z_ind = ImagePositionPatient(:,3);    % z indices of all slices
I_x_or = ImagePositionPatient(1,1);     % x origin of the image
I_y_or = ImagePositionPatient(1,2);     % y origin of the image

ImagePositionPatient = ImagePositionPatient(end,:);

%% Load binaries
% Load first binary for first fx
fnameout =  [base_dir, num2str(patient_number), '\', results_dir,'\', ROI_name_full, '_mask.raw'];
fid = fopen(fnameout,'r');
contourmask1 = fread(fid,'uint8');
contourmask1 = reshape(contourmask1, size(I));
contourmask1 = flipdim(contourmask1,3);
fclose(fid);

% Load binary of another fx
% fnameout =  [base_dir, num2str(patient_number), '\', results_dir,'\', ROI_name, '_mask_union.raw'];
fnameout =  [base_dir, num2str(patient_number), '\', results_dir,'\', ROI_name_full2, '_mask.raw'];
fid = fopen(fnameout,'r');
contourmask2 = fread(fid,'uint8');
contourmask2 = reshape(contourmask2, size(I));
contourmask2 = flipdim(contourmask2,3);
fclose(fid);

% Load binary of PTV
fnameout =  [base_dir, num2str(patient_number), '\', results_dir,'\', 'PTV_mask.raw'];
fid = fopen(fnameout,'r');
PTV_mask = fread(fid,'uint8');
PTV_mask = reshape(PTV_mask, size(I));
PTV_mask = flipdim(PTV_mask,3);
fclose(fid);

%% Load distance map for baseline Fx
fnameout =  [base_dir, num2str(patient_number), '\', results_dir,'\', ROI_name_full, '_Dmap.raw'];
fid = fopen(fnameout,'r');
Dmap_Fx1 = fread(fid,'double');
Dmap_Fx1 = reshape(Dmap_Fx1, size(I));
Dmap_Fx1 = flipdim(Dmap_Fx1,3);
fclose(fid);

%% Display
h=figure(1)
for iter = 50:120
    
    % Display image slice
    figure(1);
    subplot(1,2,1)
    imagesc(I(:,:,iter), [10 300])
    axis equal; axis tight; axis off
    colormap(gray)
    title(['Slice #', num2str(iter)])
    hold on
    
    %% 1st fx
    % Get boundary for 1st fx binary
    BoundaryBW1 = bwboundaries(contourmask1(:,:,iter),'noholes');
    % Get points
    BoundaryPoints1 = [];
    for ii = 1:length(BoundaryBW1)
        BoundaryPoints1 = [BoundaryPoints1; BoundaryBW1{ii}];
    end
    % Display 1st fx
    if ~isempty(BoundaryPoints1)
        plot(BoundaryPoints1(:,2),BoundaryPoints1(:,1),'b.','LineWidth',1,'MarkerSize',5)
    end
    
    %% PTV
    % Get boundary for PTV
    BoundPTV = bwboundaries(PTV_mask(:,:,iter),'noholes');
    % Get points
    BoundaryPointsPTV = [];
    for ii = 1:length(BoundPTV)
        BoundaryPointsPTV = [BoundaryPointsPTV; BoundPTV{ii}];
    end
    % Display PTV
    if ~isempty(BoundaryPointsPTV)
        plot(BoundaryPointsPTV(:,2),BoundaryPointsPTV(:,1),'g.','LineWidth',1,'MarkerSize',5)
    end

    %% 2nd Fx
    % Get boundary for 2nd fx binary
    BoundaryBW2 = bwboundaries(contourmask2(:,:,iter),'noholes');
    % Get points
    BoundaryPoints2 = [];
    for ii = 1:length(BoundaryBW2)
        BoundaryPoints2 = [BoundaryPoints2; BoundaryBW2{ii}];
    end
    % Display 2nd fx
    if ~isempty(BoundaryPoints2)
        plot(BoundaryPoints2(:,2),BoundaryPoints2(:,1),'r.','LineWidth',1,'MarkerSize',5)
    end

    hold off
    freezeColors
    
    %% Display distance map
    subplot(1,2,2)
    imagesc(Dmap_Fx1(:,:,iter),[0 50])
    axis equal; axis tight; axis off
    colormap(jet)
    hold on
    % Display baseline boundary
    if ~isempty(BoundaryPoints1)
        plot(BoundaryPoints1(:,2),BoundaryPoints1(:,1),'k.','LineWidth',1,'MarkerSize',5)
    end
    % Display 2nd Fx
    if ~isempty(BoundaryPoints2)
        plot(BoundaryPoints2(:,2),BoundaryPoints2(:,1),'k.','LineWidth',1,'MarkerSize',1)
    end
    % Display PTV
    if ~isempty(BoundaryPointsPTV)
        plot(BoundaryPointsPTV(1:3:end,2),BoundaryPointsPTV(1:3:end,1),'k*','LineWidth',1,'MarkerSize',2)
    end
    
    colorbar
    hold off
    set(h,'Position',[37 490 1225 433])
    %     pause(0.1)
    pause
end

