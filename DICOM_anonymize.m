% Load, anonymize and save DICOM files
% 
%
%
% (C) Ishita Chen, 1/21/2016

clear, clc, close all, format compact

% Change values before each run
%   Patient ID# and path in indir = ['C:\Users\ichen\Documents\data\11150340\Abdomen_SB_Fx',num2str(ii),'_Delivery\PlanningData'];
%   Patient_## in line outdir = ['C:\Users\ichen\Documents\anon_data\Patient_01']
%   'for ii' variable

% Sets paths
for ii=13:13  % change to number of files
    disp(ii)
    indir = ['C:\Users\ichen\Documents\data\12160058\ABDOMEN_SB_Fx',num2str(ii),'_Delivery\PlanningData'];
    outdir = ['C:\Users\ichen\Documents\data_anon\Patient_10'];
    outdirname = ['Abdomen_SB_Fx',num2str(ii),'_Delivery'];
    % mkdir(outdir,outdirname);
    outdir = [outdir,'\',outdirname];
    if ~exist(outdir,'dir')
        mkdir(outdir)
    end
    disp_message = ['Writing data to ',outdir];
    disp(disp_message)
    
    % Anonymize MR files
    disp('Anonymizing MR...')
    dd=dir([indir '\MR*.dcm']);
    for i=1:length(dd)
        file_in=[indir '\' dd(i).name];
        %info_in=dicominfo(file_in);
        file_out=[outdir '\' dd(i).name];
        dicomanon(file_in, file_out);
        %info_out=dicominfo(file_out);
    end
    
    % Anonymize CT files
    disp('Anonymizing CT...')
    dd=dir([indir '\CT*.dcm']);
    for i=1:length(dd)
        file_in=[indir '\' dd(i).name];
        %info_in=dicominfo(file_in);
        file_out=[outdir '\' dd(i).name];
        dicomanon(file_in, file_out);
        %info_out=dicominfo(file_out);
    end
        
    % Anonymize structures
    disp('Anonymizing structures...')
    dd=dir([indir '\RTS*.dcm']);
    file_in=[indir '\' dd.name];
    %info_in=dicominfo(file_in);
    file_out=[outdir '\' dd.name];
    dicomanon(file_in, file_out);
    %info_out=dicominfo(file_out);
end