% Load DICOM structure files
% 
%
%
% (C) Ishita Chen, 1/21/2016


clear, clc, close all, format compact

%% Inputs
% Patient number
patient_number = 5;
% Fraction numbers to compare to each other
fraction_number_1 = 1;
fraction_number_2 = 15;
% Structure of interest
roi_of_interest_name = 'STOMACH'
roi_of_interest_01 = [roi_of_interest_name, '_FX', num2str(fraction_number_1)];
roi_of_interest_02 = [roi_of_interest_name, '_FX', num2str(fraction_number_2)];
% Downsampling factor
DSfactor1 = 10;
DSfactor2 = 10;
% Number of slices above and below PTV to truncate
num_slices1 = 5;
num_slices2 = 5;

indir1 = ['C:\Users\Ishita\Documents\MATLAB\Patient_0', num2str(patient_number) '\Abdomen_SB_Fx', num2str(fraction_number_1),'_Delivery']
indir2 = ['C:\Users\Ishita\Documents\MATLAB\Patient_0', num2str(patient_number) '\Abdomen_SB_Fx', num2str(fraction_number_2),'_Delivery']

%% Load MRI file
[I1, PixelSpacing1, SliceThickness1, ImagePositionPatient1, ImageOrientationPatient1, ImgSize1] = load_VR_MRI(indir1);
[I2, PixelSpacing2, SliceThickness2, ImagePositionPatient2, ImageOrientationPatient2, ImgSize2] = load_VR_MRI(indir2);

%% Examine first structure file
% Read dicom file
[roi_no1, roi_name1, PTV_min_z1, PTV_max_z1] = StructureExamine (indir1, roi_of_interest_01);

disp(['roi_num: ', num2str(roi_no1)])
disp(['roi_name: ', roi_name1])


%% Load the point data
[seg_contour1, seg_contour_downsample1, NumberPoints1, NumberPointsDS1] = load_VR_struct(indir1, roi_no1, DSfactor1, PTV_min_z1, PTV_max_z1, SliceThickness1, num_slices1);
disp(['Number of points struture #1: ', num2str(NumberPointsDS1)])

%% Examine second structure file
% Read dicom file
[roi_no2, roi_name2, PTV_min_z2, PTV_max_z2] = StructureExamine (indir2, roi_of_interest_02);

disp(['roi_num: ', num2str(roi_no2)])
disp(['roi_name: ', roi_name2])

%% Load the point data
[seg_contour2, seg_contour_downsample2, NumberPoints2, NumberPointsDS2] = load_VR_struct(indir2, roi_no2, DSfactor2, PTV_min_z2, PTV_max_z2, SliceThickness2, num_slices2);
disp(['Number of points struture #2: ', num2str(NumberPointsDS2)])

% Easy variable names for plotting
x1 = seg_contour_downsample1(:,1);
y1 = seg_contour_downsample1(:,2);
z1 = seg_contour_downsample1(:,3);
x2 = seg_contour_downsample2(:,1);
y2 = seg_contour_downsample2(:,2);
z2 = seg_contour_downsample2(:,3);


% tri1 = delaunay(x1,y1);
% tri2 = delaunay(x2,y2);
% 
% figure(1)
% h = trisurf(tri1, x1, y1, z1);
% axis vis3d
% l = light('Position',[-50 -15 29])
% set(gca,'CameraPosition',[208 -50 7687])
% lighting phong
% shading interp

M = [x1 y1 z1]';    % Reference data
D = [x2 y2 z2]';    % Target data

% Run ICP (fast kDtree matching and extrapolation)
[Ricp Ticp ER t matchIDX] = icp(M, D, 30, 'Matching', 'kDtree', 'Extrapolation', true);
disp(['Size of match indices: ', num2str(length(matchIDX))])

M_crrsp_pts = M(:,matchIDX);
rms_dist = rms_error(D,M_crrsp_pts);
disp(['RMS untransformed distance: ', num2str(rms_dist)])

% Transform data-matrix using ICP result
Dicp = Ricp * D + repmat(Ticp, 1, NumberPointsDS2);

% Plot model points blue and transformed points red
figure(2)
subplot(2,2,1);
plot3(M(1,:),M(2,:),M(3,:),'b.',D(1,:),D(2,:),D(3,:),'r.');
axis equal;
xlabel('x'); ylabel('y'); zlabel('z');
title('Red: z=sin(x)*cos(y), blue: transformed point cloud');

% Plot the results
subplot(2,2,2);
plot3(M(1,:),M(2,:),M(3,:),'b.',Dicp(1,:),Dicp(2,:),Dicp(3,:),'r.');
axis equal;
xlabel('x'); ylabel('y'); zlabel('z');
title('ICP result');

% Plot RMS curve
subplot(2,2,[3 4]);
plot(0:30,ER,'--x');
xlabel('iteration#');
ylabel('d_{RMS}');
legend('kDtree matching and extrapolation');
title(['Total elapsed time: ' num2str(t(end),2) ' s']);

% suptitle(['PATIENT #0', num2str(patient_number), ', Fx #', num2str(fraction_number_2), ', ', roi_of_interest_name])

matchIDXd = matchIDX(1:10:end);
ds_id = 1:10:length(x2);
u1 = x2(ds_id)-x1(matchIDXd);
v1 = y2(ds_id)-y1(matchIDXd);
w1 = z2(ds_id)-z1(matchIDXd);

h=figure(1)
set(h,'Position',[91, 163, 1038, 754])
hold on
grid on
plot3(x1,y1,z1,'LineStyle','none','Marker','.','MarkerEdgeColor','blue','MarkerSize',5)
plot3(x2,y2,z2,'LineStyle','none','Marker','.','MarkerEdgeColor','red','MarkerSize',5)
% plot3([x1(matchIDXd)'; x2(ds_id)'], [y1(matchIDXd)'; y2(ds_id)'], [z1(matchIDXd)'; z2(ds_id)'], '-k')
quiver3(x1(matchIDXd), y1(matchIDXd), z1(matchIDXd), u1, v1, w1,0,'linewidth',2)
xlabel('X'), ylabel('Y'), zlabel('Z')
title(['PATIENT #0', num2str(patient_number), ', Fx #', num2str(fraction_number_2), ', ', roi_of_interest_name])
axis equal
hold off

% OptionZ.FrameRate=15;OptionZ.Duration=5.5;OptionZ.Periodic=true;
% filename1 = ['../Data/Patient_0',num2str(patient_number),'_Fx_',num2str(fraction_number_2),'_',roi_of_interest_name,'_quiver'];
% CaptureFigVid([-20,10;-110,10;-190,80;-290,10;-380,10], filename1,OptionZ)

% h=figure(3)
% set(h,'Position',[91, 163, 1038, 754])
% plot3(M(1,:),M(2,:),M(3,:),'b.',Dicp(1,:),Dicp(2,:),Dicp(3,:),'r.');
% axis equal;
% xlabel('x'); ylabel('y'); zlabel('z');
% title(['Original point cloud']);
% 
% OptionZ.FrameRate=15;OptionZ.Duration=5.5;OptionZ.Periodic=true;
% filename2 = ['Patient_0',num2str(patient_number),'_Fx_',num2str(fraction_number_2),'_',roi_of_interest_name,'_orig_pt_clouds'];
% CaptureFigVid([-20,10;-110,10;-190,80;-290,10;-380,10], filename2,OptionZ)
% 
% h=figure(4)
% set(h,'Position',[91, 163, 1038, 754])
% plot3(M(1,:),M(2,:),M(3,:),'b.',Dicp(1,:),Dicp(2,:),Dicp(3,:),'r.');
% axis equal;
% xlabel('x'); ylabel('y'); zlabel('z');
% title(['ICP; Blue: Fx1, Red: Fx', num2str(fraction_number_2)]);
% 
% OptionZ.FrameRate=15;OptionZ.Duration=5.5;OptionZ.Periodic=true;
% filename3 = ['Patient_0',num2str(patient_number),'_Fx_',num2str(fraction_number_2),'_',roi_of_interest_name,'_ICP'];
% CaptureFigVid([-20,10;-110,10;-190,80;-290,10;-380,10], filename3,OptionZ)

% h=figure(5)
% set(h,'Position',[19, 432, 1234, 448])
% subplot(1,2,1)
% plot3(M(1,:),M(2,:),M(3,:),'b.',D(1,:),D(2,:),D(3,:),'r.');
% axis equal;
% xlabel('x'); ylabel('y'); zlabel('z');
% title(['Original point cloud']);
% subplot(1,2,2)
% plot3(M(1,:),M(2,:),M(3,:),'b.',Dicp(1,:),Dicp(2,:),Dicp(3,:),'r.');
% axis equal;
% xlabel('x'); ylabel('y'); zlabel('z');
% title(['ICP; Blue: Fx1, Red: Fx', num2str(fraction_number_2)]);
% OptionZ.FrameRate=15;OptionZ.Duration=5.5;OptionZ.Periodic=true;
% filename4 = ['../Data/Patient_0',num2str(patient_number),'_Fx_',num2str(fraction_number_2),'_',roi_of_interest_name,'_orig_ICP'];
% CaptureFigVid2([-20,10;-110,10;-190,80;-290,10;-380,10], filename4,OptionZ)