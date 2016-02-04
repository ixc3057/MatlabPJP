function [I, PixelSpacing, SliceThickness, ImagePositionPatient, ImageOrientationPatient, ImgSize] = load_VR_MRI(indir);
% Function to load the ViewRay MRI file
%
%
%
% (C) Ishita Chen, 1/25/2016

% Read dicom file
dd=dir([indir '\MR*.dcm']);
pos=[];
I=[];
for i=1:length(dd)   
    imginfo=dicominfo([indir '\' dd(i).name]);
    pos=[pos; imginfo.ImagePositionPatient'.*[imginfo.ImageOrientationPatient(1),imginfo.ImageOrientationPatient(5) 1] ];
    I= cat(3,I, dicomread([indir '\' dd(i).name]));
end

% Sort slices along z-axis position
[pos,index]=sortrows(pos,3);
I=I(:,:,index);
[rows,cols,slices]=size(I);

% Get MRI image parameters
PixelSpacing=imginfo.PixelSpacing;
SliceThickness = imginfo.SliceThickness;
% ImagePositionPatient=imginfo.ImagePositionPatient;
ImagePositionPatient=pos;
ImageOrientationPatient=imginfo.ImageOrientationPatient;
ImgSize = [imginfo.Rows imginfo.Columns];