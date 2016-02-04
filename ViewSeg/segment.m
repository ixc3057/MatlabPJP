function varargout = segment(varargin)
% SEGMENT_NEMU MATLAB code for segment_nemu.fig
%      SEGMENT_NEMU, by itself, creates a new SEGMENT_NEMU or raises the existing
%      singleton*.
%
%      H = SEGMENT_NEMU returns the handle to a new SEGMENT_NEMU or the handle to
%      the existing singleton*.
%
%      SEGMENT_NEMU('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SEGMENT_NEMU.M with the given input arguments.
%
%      SEGMENT_NEMU('Property','Value',...) creates a new SEGMENT_NEMU or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before segment_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to segment_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help segment_nemu

% Last Modified by Yonggang Lu,WashU, 14-Jan-2016

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;

gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @segment_OpeningFcn, ...
                   'gui_OutputFcn',  @segment_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before segment_nemu is made visible.
function segment_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to segment_nemu (see VARARGIN)

% Choose default command line output for segment_nemu

axis off;
handles.output = hObject;


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes segment_nemu wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = segment_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --------------------------------------------------------------------
function file_exit_Callback(hObject, eventdata, handles)
% hObject    handle to file_exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(handles.figure1);

% --------------------------------------------------------------------
function segment_nemu_Callback(hObject, eventdata, handles)
% hObject    handle to segment_nemu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function file_menu_Callback(hObject, eventdata, handles)
% hObject    handle to file_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)





% --- Executes during object creation, after setting all properties.
function image_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to image_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
