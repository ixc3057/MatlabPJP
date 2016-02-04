% Check metadata to ensure dicom properly anonymized
%
%
%
% (C) Ishita Chen, 1/25/2016

clear, clc, close all, format compact

indir = 'C:\Users\ichen\Documents\anon_data\Patient_01\Abdomen_SB_Fx1_Delivery'
dd=dir([indir '\MR*.dcm']);
file_in=[indir '\' dd(1).name];
CTinfo=dicominfo(file_in)
disp(['CTinfo.Filename: ', CTinfo.Filename])
disp(['FileMetaInformationVersion: '])
disp(CTinfo.FileMetaInformationVersion)
disp(['CTinfo.MediaStorageSOPInstanceUID: ', CTinfo.MediaStorageSOPInstanceUID])
disp(['CTinfo.SOPInstanceUID: ', CTinfo.SOPInstanceUID])
disp(['CTinfo.ReferringPhysicianName: '])
disp(CTinfo.ReferringPhysicianName)
disp(['CTinfo.PatientName: '])
disp(CTinfo.PatientName)
disp(['CTinfo.StudyInstanceUID: ', CTinfo.StudyInstanceUID])
disp(['CTinfo.SeriesInstanceUID: ', CTinfo.SeriesInstanceUID])
disp('CTinfo.ImagePositionPatient: ')
disp(CTinfo.ImagePositionPatient)
disp('CTinfo.ImageOrientationPatient: ')
disp(CTinfo.ImageOrientationPatient)
disp(['CTinfo.FrameOfReferenceUID: ', CTinfo.FrameOfReferenceUID])
disp('CTinfo.PixelSpacing: ')
disp(CTinfo.PixelSpacing)