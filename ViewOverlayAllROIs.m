clear, clc, close all, format compact
% View image and distanc map with an overlay of contours

%% Inputs
% Patient number
patient_number = 10;
% Fraction numbers to compare to each other
fraction_number_init = 1;
fraction_number = fraction_number_init;
fraction_number2 = 5;
fxnums = 15;

% Number of slices above and below PTV to truncate
num_slices_PTV = 5;

% Structure of interest
ROI_name = 'STOMACH';

% Precision error
epsilon = 1e-6;

% File locations
base_dir = 'C:\Users\ichen\Documents\data_anon\Patient_';
results_dir = 'Analysis';

% Names
indir = [base_dir, sprintf('%02d',patient_number) '\Abdomen_SB_Fx', num2str(fraction_number),'_Delivery']
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
fnameout =  [base_dir, sprintf('%02d',patient_number), '\', results_dir,'\', ROI_name_full, '_mask.raw'];
fid = fopen(fnameout,'r');
contourmask1 = fread(fid,'uint8');
contourmask1 = reshape(contourmask1, size(I));
contourmask1 = flipdim(contourmask1,3);
fclose(fid);

% Structure of interest
ROI_name = 'DUODENUM';
ROI_name_full = [ROI_name, '_FX', num2str(fraction_number)];
% Load first binary for first fx
fnameout =  [base_dir, sprintf('%02d',patient_number), '\', results_dir,'\', ROI_name_full, '_mask.raw'];
fid = fopen(fnameout,'r');
contourmask2 = fread(fid,'uint8');
contourmask2 = reshape(contourmask2, size(I));
contourmask2 = flipdim(contourmask2,3);
fclose(fid);

% Structure of interest
ROI_name = 'SMALLBOWEL';
ROI_name_full = [ROI_name, '_FX', num2str(fraction_number)];
% Load first binary for first fx
fnameout =  [base_dir, sprintf('%02d',patient_number), '\', results_dir,'\', ROI_name_full, '_mask.raw'];
fid = fopen(fnameout,'r');
contourmask3 = fread(fid,'uint8');
contourmask3 = reshape(contourmask3, size(I));
contourmask3 = flipdim(contourmask3,3);
fclose(fid);

% Structure of interest
ROI_name = 'LARGEBOWEL';
ROI_name_full = [ROI_name, '_FX', num2str(fraction_number)];
% Load first binary for first fx
fnameout =  [base_dir, sprintf('%02d',patient_number), '\', results_dir,'\', ROI_name_full, '_mask.raw'];
fid = fopen(fnameout,'r');
contourmask4 = fread(fid,'uint8');
contourmask4 = reshape(contourmask4, size(I));
contourmask4 = flipdim(contourmask4,3);
fclose(fid);

% Load binary of PTV
fnameout =  [base_dir, sprintf('%02d',patient_number), '\', results_dir,'\', 'PTV_mask.raw'];
fid = fopen(fnameout,'r');
PTV_mask = fread(fid,'uint8');
PTV_mask = reshape(PTV_mask, size(I));
PTV_mask = flipdim(PTV_mask,3);
fclose(fid);

%% Display
h=figure(1)
for iter = 45:90
        
    % Display image slice
    figure(1);
    imagesc(I(:,:,iter), [10 300])
    axis equal; axis tight; axis off
    colormap(gray)
    title(['Slice #', num2str(iter)],'FontSize',20)
    hold on
    
    %% 1st fx, stomach
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
    
    %% 1st fx, duodenum
    % Get boundary for 1st fx binary
    BoundaryBW2 = bwboundaries(contourmask2(:,:,iter),'noholes');
    % Get points
    BoundaryPoints2 = [];
    for ii = 1:length(BoundaryBW2)
        BoundaryPoints2 = [BoundaryPoints2; BoundaryBW2{ii}];
    end
    % Display 1st fx
    if ~isempty(BoundaryPoints2)
        plot(BoundaryPoints2(:,2),BoundaryPoints2(:,1),'r.','LineWidth',1,'MarkerSize',5)
    end
    
    %% 1st fx, small intestine
    % Get boundary for 1st fx binary
    BoundaryBW3 = bwboundaries(contourmask3(:,:,iter),'noholes');
    % Get points
    BoundaryPoints3 = [];
    for ii = 1:length(BoundaryBW3)
        BoundaryPoints3 = [BoundaryPoints3; BoundaryBW3{ii}];
    end
    % Display 1st fx
    if ~isempty(BoundaryPoints3)
        plot(BoundaryPoints3(:,2),BoundaryPoints3(:,1),'y.','LineWidth',1,'MarkerSize',5)
    end
    
    %% 1st fx, colon
    % Get boundary for 1st fx binary
    BoundaryBW4 = bwboundaries(contourmask4(:,:,iter),'noholes');
    % Get points
    BoundaryPoints4 = [];
    for ii = 1:length(BoundaryBW4)
        BoundaryPoints4 = [BoundaryPoints4; BoundaryBW4{ii}];
    end
    % Display 1st fx
    if ~isempty(BoundaryPoints4)
        plot(BoundaryPoints4(:,2),BoundaryPoints4(:,1),'m.','LineWidth',1,'MarkerSize',5)
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

    hold off
    set(h,'Position',[151   146   964   784])
    %     pause(0.1)
    pause
end