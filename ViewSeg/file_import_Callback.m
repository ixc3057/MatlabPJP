% --------------------------------------------------------------------
function file_import_Callback(hObject, eventdata, handles)
% hObject    handle to file_import (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%Last Modified by Yonggang Lu,WashU, 14-Jan-2016


indir=uigetdir(pwd,'Select input dicom folder');% 
dd=dir([indir '\MR*.dcm']);
pos=[];
I=[];
for i=1:length(dd)   
    info=dicominfo([indir '\' dd(i).name]);
    pos=[pos; info.ImagePositionPatient'.*[info.ImageOrientationPatient(1),info.ImageOrientationPatient(5) 1] ];
    I= cat(3,I, dicomread([indir '\' dd(i).name]));
end

[pos,index]=sortrows(pos,3);
I=I(:,:,index);
[rows,cols,slices]=size(I);


dd=dir([indir '\RTS*.dcm']);

dinfo=dicominfo([indir '\' dd(1).name]);
roi_num= numel(fieldnames(dinfo.StructureSetROISequence));
roi_names=cell(roi_num,1);
numbers=cell(1,roi_num);
for i=1:roi_num
    numbers{1,i}=num2str(i);
    roi_names{i,1}= eval(['dinfo.StructureSetROISequence.Item_' num2str(i) '.ROIName']);
end


user_data.dinfo=dinfo;
user_data.roi_no=1;
set(handles.figure1,'UserData',user_data);

axes(handles.axes1);
cla;

imagesc(I(:,:,1));
colormap(gray);
axis off;


handles.I=I;
handles.pos=pos;
handles.rows=rows;
handles.cols=cols;
handles.slices=slices;
handles.sliceno=1;
handles.position=handles.pos(1,3);
handles.PixelSpacing=info.PixelSpacing;
handles.ImagePositionPatient=info.ImagePositionPatient;
handles.ImageOrientationPatient=info.ImageOrientationPatient;

set(handles.slider_sliceend,'String',num2str(slices));
set(handles.slider_sliceno,'String',num2str(1));set(handles.uitable_roi, 'Data',roi_names,'ColumnName',{'ROI name'},'RowName',numbers);

guidata(hObject, handles);









