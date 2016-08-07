clear, clc, close all, format compact
% View image and distanc map with an overlay of contours

%% Inputs
% Patient number
patient_number = 1;
% Fraction numbers to compare to each other
fraction_number_init = 1;
fraction_number = fraction_number_init;
fraction_number2 = 5;
fxnums = 25;
slice_num = 65;

% Number of slices above and below PTV to truncate
num_slices_PTV = 5;

% Structure of interest
ROI_name = 'DUODENUM';

% Precision error
epsilon = 1e-6;

% File locations
base_dir = 'C:\Users\ichen\Documents\data-anon-matlab\Patient_0';
results_dir = 'Analysis';

% Names
ROI_name_full = [ROI_name, '_FX', num2str(fraction_number)];
ROI_name_full2 = [ROI_name, '_FX', num2str(fraction_number2)];

% %% Load MRI file for first fraction
% for iter = 1:fxnums
%     
%     fraction_number = iter;
%     indir = [base_dir, num2str(patient_number) '\Abdomen_SB_Fx', num2str(fraction_number),'_Delivery']
%     
%     [I, PixelSpacing, SliceThickness, ImagePositionPatient, ImageOrientationPatient, ImgSize] = load_VR_MRI(indir);
%     I = flipdim(I,3);
%     ImgSize = double(ImgSize);
%     NumSlices = size(I,3);
%     Imask =zeros(size(I));
%     I_z_ind = ImagePositionPatient(:,3);    % z indices of all slices
%     I_x_or = ImagePositionPatient(1,1);     % x origin of the image
%     I_y_or = ImagePositionPatient(1,2);     % y origin of the image
%     
%     II(:,:,iter) = I(:,:,slice_num);
%     
%     ImagePositionPatient = ImagePositionPatient(end,:);
% end

%% Load MRI file for first fraction
 
fraction_number = 1;
indir = [base_dir, num2str(patient_number) '\Abdomen_SB_Fx', num2str(fraction_number),'_Delivery']
    
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

%% 1st fx ROI
% Get boundary for 1st fx binary
BoundaryBW1 = bwboundaries(contourmask1(:,:,slice_num),'noholes');
% Get points
BoundaryPoints1 = [];
for ii = 1:length(BoundaryBW1)
    BoundaryPoints1 = [BoundaryPoints1; BoundaryBW1{ii}];
end



%% Load binary of PTV
fnameout =  [base_dir, num2str(patient_number), '\', results_dir,'\', 'CTV_mask.raw'];
fid = fopen(fnameout,'r');
PTV_mask = fread(fid,'uint8');
PTV_mask = reshape(PTV_mask, size(I));
PTV_mask = flipdim(PTV_mask,3);
fclose(fid);

%% PTV
% Get boundary for PTV
BoundPTV = bwboundaries(PTV_mask(:,:,slice_num),'noholes');
% Get points
BoundaryPointsPTV = [];
for ii = 1:length(BoundPTV)
    BoundaryPointsPTV = [BoundaryPointsPTV; BoundPTV{ii}];
end

%% Display
contourmask3 = contourmask1;
fname_anim_vid = [base_dir, num2str(patient_number), '\Animation\animation_pt_', num2str(patient_number), '_', ROI_name, '2.mp4' ];
outputVideo = VideoWriter(fname_anim_vid);
outputVideo.FrameRate = 5;
open(outputVideo)
for iter = 1:fxnums
    
    % Display image slice
    h=figure(1);
    %     imagesc(II(:,:,iter), [10 300])
    imagesc(I(:,:,slice_num), [10 300])
    axis equal; axis tight; axis off
    colormap(gray)
    title(['Fx #', num2str(iter)],'FontSize',20)
    hold on
    set(h,'Position',[151   146   964   784])
    
    
    % Display 1st fx
    if ~isempty(BoundaryPoints1)
        plot(BoundaryPoints1(:,2),BoundaryPoints1(:,1),'b.','LineWidth',1,'MarkerSize',5)
    end
    
    
    % Display PTV
    if ~isempty(BoundaryPointsPTV)
        plot(BoundaryPointsPTV(:,2),BoundaryPointsPTV(:,1),'g.','LineWidth',1,'MarkerSize',5)
    end
    
    % 2nd fx ROI
    ROI_name_full2 = [ROI_name, '_FX', num2str(iter)];
    fnameout = [base_dir, num2str(patient_number), '\', results_dir,'\', ROI_name_full2, '_mask.raw'];
    fid = fopen(fnameout,'r');
    contourmask2 = fread(fid,'uint8');
    contourmask2 = reshape(contourmask2, size(I));
    contourmask2 = flipdim(contourmask2,3);
    fclose(fid);
    
    contourmask3 = or(contourmask3, contourmask2);
    
    %% 1st fx, ROI union
    % Get boundary for 1st fx binary
    BoundaryBW2 = bwboundaries(contourmask3(:,:,slice_num),'noholes');
    % Get points
    BoundaryPoints2 = [];
    for ii = 1:length(BoundaryBW2)
        BoundaryPoints2 = [BoundaryPoints2; BoundaryBW2{ii}];
    end
    % Display 1st fx
    if ~isempty(BoundaryPoints2)
        plot(BoundaryPoints2(:,2),BoundaryPoints2(:,1),'r.','LineWidth',1,'MarkerSize',5)
    end
    
    %     fname_anim = [base_dir, num2str(patient_number), '\Animation\frame_', num2str(iter)];
    %     saveas(h,fname_anim, 'png');
    
    frame = getframe(h);
    writeVideo(outputVideo,frame);
    
    hold off
    set(h,'Position',[151   146   964   784])
    pause(0.1)
    %     pause
end

close(outputVideo)
