function varargout = GUI(varargin)
% GUI MATLAB code for GUI.fig
%      GUI, by itself, creates a new GUI or raises the existing
%      singleton*.
%
%      H = GUI returns the handle to a new GUI or the handle to
%      the existing singleton*.
%
%      GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI.M with the given input arguments.
%
%      GUI('Property','Value',...) creates a new GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI

% Last Modified by GUIDE v2.5 22-May-2019 22:07:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_OutputFcn, ...
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


% --- Executes just before GUI is made visible.
function GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI (see VARARGIN)

% Choose default command line output for GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Shepp.
function Shepp_Callback(hObject, eventdata, handles)
% hObject    handle to Shepp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global P
P = phantom(256);%样本图片
imshow(P,[],'parent',handles.axes1);
set(handles.axes1,'YTick', []);  
set(handles.axes1,'XTick', []);  


% --- Executes on button press in Other.
function Other_Callback(hObject, eventdata, handles)
% hObject    handle to Other (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global P
[filename,filepath]=uigetfile('*.*','请选择文件');%选择其他文件
P = imread(strcat(filepath,filename));%读取图片文件
P = im2double(rgb2gray(P));
imshow(P,[],'parent',handles.axes1);
set(handles.axes1,'YTick', []);  
set(handles.axes1,'XTick', []);  



function ProjectionNum_Callback(hObject, eventdata, handles)
% hObject    handle to ProjectionNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of ProjectionNum as text
%        str2double(get(hObject,'String')) returns contents of ProjectionNum as a double



% --- Executes during object creation, after setting all properties.
function ProjectionNum_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ProjectionNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in Projection.
function Projection_Callback(hObject, eventdata, handles)
% hObject    handle to Projection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%进行投影
global P
global proj
global h
global w
global theta
global anglenum

anglenum=str2num(get(handles.ProjectionNum,'string'));%投影角度数
[h,w] = (size(P));

step=180/anglenum;%角度步长
theta = step:step:180;  
  
% radon 变换
proj = projection(P,theta,handles);  




% --- Executes on button press in Filtering.
function Filtering_Callback(hObject, eventdata, handles)
% hObject    handle to Filtering (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%进行滤波
global proj
global width
global proj_ifft
global anglenum

width = 2^nextpow2(size(proj,1));
proj_fft = fft(proj, width);  

val = get(handles.popupmenu1,'value'); %选择滤波器
switch val
    case 1%矩形窗
        filter = rectwin(width);
    case 2%RL滤波器
     	filter = triang(width);
    case 3%SL滤波器
    	filter = triang(width);
        for i = 1:(width/2)
            filter(i) = filter(i)*sinc(i/width/2);
            filter(width+1-i) = filter(width-i)*sinc(i/width/2);
        end
end
%滤波
proj_filtered = zeros(width,anglenum);
for i = 1:anglenum
 	proj_filtered(:,i) = proj_fft(:,i).*filter;  
end  
  
%傅里叶逆变换
proj_ifft = real(ifft(proj_filtered)); 
%显示滤波结果
imshow(proj_ifft(1:size(proj,1),:),[],'parent',handles.axes3); 
set(handles.axes3,'XTick', []);  
set(handles.axes3,'YTick', []);  


% --- Executes on button press in Reconstruction.
function Reconstruction_Callback(hObject, eventdata, handles)
% hObject    handle to Reconstruction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% 图像重建，反投影
global h
global w
global anglenum
global theta
global proj
global proj_ifft
global fbp_final

%进行iradon变换
fbp = zeros(h,w);

for i = 1:anglenum
  	for x = 1:h
        for y = 1:w
          	t = -(x-h/2)*sind(theta(i))+(y-w/2)*cosd(theta(i));  
          	fbp(x,y)=fbp(x,y)+...
                (floor(t)+1-t)*proj_ifft(floor(t)+round(size(proj,1)/2),i)+...
                (t-floor(t))*proj_ifft(floor(t)+1+round(size(proj,1)/2),i);%线性插值
        end
    end
    if mod(i,5) == 0 %图像显示
        imshow(fbp/anglenum,[],'parent',handles.axes4);  
        set(handles.axes4,'YTick', []);  
        set(handles.axes4,'XTick', []);  
        pause(0.001);
    end
end

imshow(fbp/anglenum,[],'parent',handles.axes4);
set(handles.axes4,'YTick', []);  
set(handles.axes4,'XTick', []);

fbp_final = fbp/anglenum;



function output = projection(img,angle,handles)
%投影函数
[h, w] = size(img);

[~,angle2] = size(angle);
proj_size = [ceil(sqrt(h*h+w*w)/2)*2+1, angle2];%图片对角线的长度,示例图为285

proj = zeros(proj_size);%投影 对角线长度*角度数

for n = 1:proj_size(2)%角度数
    for i = -(proj_size(1)-1)/2:(proj_size(1)-1)/2%对角线的长度
        counter = 0;
        for j =  -(proj_size(1)-1)/2:(proj_size(1)-1)/2
            %通过i,j找到对应的坐标点
            x = i*sind(angle(n))+j*cosd(angle(n))+h/2;
            y = -i*cosd(angle(n))+j*sind(angle(n))+w/2;
            if (x<h)&&(x>1)&&(y<w)&&(y>1)%确定该位置在图像内
                counter = counter + img(floor(x),floor(y));
            end
        end
        proj((proj_size(1)+1)/2-i,n)=counter;
    end
    if mod(n,5) == 0
        imshow(proj,[],'parent',handles.axes2); 
        set(handles.axes2,'XTick', []);  
        set(handles.axes2,'YTick', []); 
        pause(0.001);
    end
end

output = proj;



% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Eval.
function Eval_Callback(hObject, eventdata, handles)
% hObject    handle to Eval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global P
global fbp_final

compare = abs(im2double(P)-im2double(fbp_final));

%归一化均方距离判据
d = sqrt(sum(sum(compare.^2))/sum(sum((im2double(P)-mean(mean(im2double(P)))).^2)));
%归一化平均绝对距离判据
r = sum(sum(abs(compare)))/sum(sum(im2double(P)));
set(handles.d,'string',num2str(d));
set(handles.r,'string',num2str(r));

axes(handles.axes5);     
s = surf(compare,'FaceAlpha',0.5);
view(-45,70);
s.EdgeColor = 'none';
