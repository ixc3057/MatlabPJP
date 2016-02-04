% --------------------------------------------------------------------
function file_save_Callback(hObject, eventdata, handles)
% hObject    handle to file_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

I=handles.I;

dir=uigetdir(pwd,'Select save .mat folder');
filename=[dir,'\luimage.mat'];
save(filename,'I');
msgbox('Saved');
