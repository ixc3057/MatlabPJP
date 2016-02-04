% --- Executes when selected cell(s) is changed in uitable_roi.
function uitable_roi_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to uitable_roi (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)

%Last Modified by Yonggang Lu, WashU, 14-Jan-2016


index= eventdata.Indices;
roi_no=index(1,1);


user_data= get(handles.figure1,'UserData');
user_data.roi_no=roi_no;
dinfo=user_data.dinfo;
set(handles.figure1,'UserData',user_data);

sliceno=handles.sliceno;
position=handles.position;

PixelSpacing=handles.PixelSpacing;
ImagePositionPatient=handles.ImagePositionPatient;
ImageOrientationPatient=handles.ImageOrientationPatient;

for i=1:numel(fieldnames(eval(['dinfo.ROIContourSequence.Item_' num2str(roi_no) '.ContourSequence'])))
    contour=eval(['dinfo.ROIContourSequence.Item_' num2str(roi_no) '.ContourSequence.Item_' num2str(i) '.ContourData']);
    locations(i)=contour(3);
end

slice_index=find(abs(locations-position)>-0.001&abs(locations-position)<0.001);
    
if ~isempty(slice_index)
        for i=1:length(slice_index)
            ContourData=eval(['dinfo.ROIContourSequence.Item_' num2str(roi_no) '.ContourSequence.Item_' num2str(slice_index(i)) '.ContourData']);
            PixelSpacing=handles.PixelSpacing;
            ImagePositionPatient=handles.ImagePositionPatient;
            ImageOrientationPatient=handles.ImageOrientationPatient;
            for j=1:length(ContourData)/3
                contour(j,1)=round((ContourData((j-1)*3+1)-ImagePositionPatient(1)*ImageOrientationPatient(1))/PixelSpacing(1));
                contour(j,2)=round((ContourData((j-1)*3+2)-ImagePositionPatient(2)*ImageOrientationPatient(5))/PixelSpacing(2));
            end
            index=find(contour(:,2)==0);
            contour(index,:)=[];
            color=eval(['dinfo.ROIContourSequence.Item_' num2str(roi_no) '.ROIDisplayColor']);
            color=color/max(color(:));
            hold on;plot(contour(:,1),contour(:,2),'Color',color);
            clear contour;
        end
 end
handles.contour=contour;
guidata(hObject, handles);
