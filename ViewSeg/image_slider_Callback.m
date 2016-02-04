% --- Executes on slider movement.
function image_slider_Callback(hObject, eventdata, handles)
% hObject    handle to image_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% Last Modified by Yonggang Lu,WashU, 14-Jan-2016


I=handles.I;
slices=handles.slices;
sliceno=round(get(hObject,'Value')*slices);
position=handles.pos(sliceno,3);
handles.position=position;
handles.sliceno=sliceno;

set(handles.slider_sliceno, 'String',num2str(sliceno));
imagesc(I(:,:,sliceno));
axis off;

if ~isempty(get(handles.figure1,'UserData'))
    user_data=get(handles.figure1,'UserData');
    roi_no=user_data.roi_no;
    dinfo=user_data.dinfo;
   
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
            handles.contour=contour;
            clear contour;
        end
    end
end

guidata(hObject, handles);