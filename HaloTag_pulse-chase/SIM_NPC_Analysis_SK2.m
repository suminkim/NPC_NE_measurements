% Analysis of SIM Images for Position and Number of NPCs (puncta peaks)
% Uses output from 'Overlaymask_outputtiff.m'
% Output: # of NPCs (unique peaks) for each nucleus and peaks as .tif (one
% nucleus per image)
%%
% Read files to analyze %

clear all

FOLDERS = {
%     
%    '0608_10_WT/DIV4'
     '0608_10_WT/DIV6'
     '0608_10_WT/DIV8'
     '0608_10_WT/DIV10'
% 
%      '0610_1_WT/DIV4'
%      '0610_1_WT/DIV6'
%      '0610_1_WT/DIV8'
%      '0610_1_WT/DIV10'
% %     
%      '0610_9_WT/DIV4'
%      '0610_9_WT/DIV6'
%      '0610_9_WT/DIV8'
%      '0610_9_WT/DIV10'
     
%     '1022_1_KO/DIV4'
%      '1022_1_KO/DIV6'
%      '1022_1_KO/DIV8'
%      '1022_1_KO/DIV10'
% 
%     '0610_4_KO/DIV4'
%      '0610_4_KO/DIV6'
%      '0610_4_KO/DIV8'
%      '0610_4_KO/DIV10'
%     
%     '0610_8_KO/DIV4'
%      '0610_8_KO/DIV6'
%      '0610_8_KO/DIV8'
%      '0610_8_KO/DIV10'
};

iopath = '/Users/suminkim/Dropbox (University of Michigan)/Dropbox_Imaging/SIM/HaloTag_DIV4-10_PulseChase/';
cd(iopath);

%% Set channel name:
ch = 'JF646';

%% Loop
for k = 1:numel(FOLDERS)
    FOLDER = [FOLDERS{k}];
    fnames = dir([FOLDER '/',ch,'_Overlayed/*.tif']);  %% change for Nup153 vs JFX554
    mkdir(FOLDER, [ch,'_Output']);   %% change for Nup153 vs JFX554
    
    Readfolder = [iopath, FOLDER,'/',ch,'_Overlayed/'];
    Outfolder = [iopath,FOLDER,'/',ch, '_Output'];


NPCnumber = [];
filenames = strings;

%%
% Separate main flow from the processing steps for better readability and reuse..
% Repeat for each channel ID

for i = 1:length(fnames)
  
    % Import .tif file
    % Want to open and process only one image at a time to save memory
    img = tiffreader2(fnames(i).name,Readfolder); 

    % Gets peak numbers from image. 
    fpeaks = procimg(img);
    fpeaks(fpeaks==255) = 0;   %get rid of saturated artifacts
    L = bwlabel(fpeaks);  %to count one spot with multiple maxima values as one peak
    num = max(L(:)); %get number of peaks
    % Append number of peaks to a list
    NPCnumber(i) = num; 
    
    % Get filename of img to an array
    filename = fnames(i).name;
    filenames(i) = string(filename);
    
    % Write output file of peak locations for visualization
    tiffwrite2(fpeaks,Outfolder,fnames(i).name,8,1); % normalize if saving logicals for IJ
    
    % Get coordinates of all peaks in centroids to avoid overlap and save
    % in .mat
    Prop = regionprops(L,'Centroid','Area');
    arrayname = [filename,'.mat'];
    arrayout = [Outfolder,'/',arrayname]; 
    save(arrayout,'fpeaks','Prop');
    
end

%----Make an array of filenames, NPC number
divname = FOLDER(11:end);
outputfile = [filenames',NPCnumber'];
outputfilename = [FOLDER, '/',divname,' ',ch,'_Counts.csv'];
cell2csv(outputfilename,outputfile);

mat_filename = strrep(outputfilename,'.csv','.mat');
save(mat_filename,'filenames','NPCnumber');

end

%% Define function for identifying peaks
function fpeaks = procimg(img) 

    global iopath;
    global outpath;
    
    % --- Finds peaks
    % CHANGE PEAK HEIGHT AS NEEDED BASED IMAGE INTENSITY OR NORMALIZE INTENSITY
    
    peaks = imextendedmax(img,0.5,8);  % peaks is a logical.
    peaknums = sum(peaks(:));
    
    % ---Applies interior mask to the peaks
    % Masking before finding peaks created edge artifacts.
    fpeaks = peaks.*img;

end





