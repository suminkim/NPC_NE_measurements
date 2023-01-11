%%% Erodes mask by 15px to exclude regions of the nucleus that curves and
%%% keep NE plane that is flat
%%% Otsu thresholding on images, then overlays corresponding eroded masks ->
%%% output .tif of the thresholded and overlayed image
%%% Saves info on eroded and original ROI area, circularity of the original ROI 

%%% All images are in folder named 'TIFs_forAnalysis' and masks are in 'Masks'
%%
% Read files to analyze %
clear all

FOLDERS = {
%     
    '0608_10_WT/DIV4'
     '0608_10_WT/DIV6'
     '0608_10_WT/DIV8'
     '0608_10_WT/DIV10'

%     '0610_1_WT/DIV4'
%      '0610_1_WT/DIV6'
%      '0610_1_WT/DIV8'
%      '0610_1_WT/DIV10'
%     
%     '0610_9_WT/DIV4'
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
%%

iopath = '/Users/suminkim/Dropbox (University of Michigan)/Dropbox_Imaging/SIM/HaloTag_DIV4-10_PulseChase/';
cd(iopath);

% Erode mask by 15 pixels if needed
se = strel('disk',15);

%edges = [0:10:150];

%% Separate main flow from the processing steps for better readability and reuse.. %%
% Repeat this loop for all channels - manually change channel ID

ch = 'Nup153';  % Manually change this and run for each channel name

for k = 1:numel(FOLDERS)
    FOLDER = [FOLDERS{k}];
    fnames = dir([FOLDER '/TIFs_forAnalysis/*' ch '.tif']);  
    maskfiles = dir([FOLDER '/Masks/*.tif']);
    mkdir([FOLDER, '/',ch,'_Overlayed']); 
    
    Readfolder = [iopath, FOLDER,'/TIFs_forAnalysis/'];
    Maskfolder = [iopath, FOLDER,'/Masks/'];
    Outfolder = [iopath,FOLDER,'/',ch,'_Overlayed'];
    
    ROIarea_eroded = zeros(length(maskfiles),0);
    ROI_original = zeros(length(maskfiles),0);
    CircMeasurements = zeros(length(maskfiles),0);
    filenames = strings;
    
    count = 1;
    
    for i = 1:length(fnames)
        
        originalImg = tiffreader2(fnames(i).name,Readfolder);
        % Get 16bit value of Otsu thresholding to threshold image
        % Create mask of thresholded image and overlay mask onto image
        threshvalue = multithresh(originalImg);
        threshmask = originalImg > threshvalue;
        threshimg = originalImg.*threshmask;
    
        % Get string of filename and delete channel name -- for example delete '_Nup153.tif'
        imagename = strrep(fnames(i).name,['_',ch,'.tif'],'');
        
        % Use imagename to read mask image
        maskname = strcat(imagename,'-Mask.tif');
        maskimage = tiffreader2(maskname, Maskfolder);
        L = bwlabel(maskimage);  % get each cell
	
            for j = 1:max(L(:))
                mask = L == j;
                
                % Get circularity and  area of original mask before erosion
                Prop = regionprops(mask,'Circularity','Area');
                CircMeasurements(count) = getfield(Prop,'Circularity');
                ROI_original(count) = getfield(Prop,'Area');
               
                % erode mask to get rid of NE edges
                mask = imerode(mask, se);
            
                % Get area of eroded ROI in pixelunits
                ROI = mask > 0;
                ROIarea_eroded(count) = sum(ROI(:));
            
                % Get filename of img to an array
                overlayfilename = strcat(imagename, '-',ch,'-',string(j),'.tif');
                filenames(count) = char(overlayfilename);
    
                % Overlay mask
                img = threshimg;
                img(mask==0) = 0;
                tiffwrite2(img,Outfolder,char(overlayfilename),8,1);

                count = count+1;  
            end 
    end

%%
    
%% This section should only be run for one channel, comment out for other channels
divname = FOLDER(11:end); %only extract DIV info

outputfile = [filenames',ROIarea_eroded'];
outputfilename = [iopath, FOLDER, '/',divname,' NPC ROI_eroded areas.csv'];
cell2csv(outputfilename,outputfile);

outputfile = [filenames',CircMeasurements'];
outputfile(:,3)=ROI_original;
outputfilename = [iopath, FOLDER, '/',divname,' CircularityAreaMeasurements.csv'];
cell2csv(outputfilename,outputfile);

%%save .mat file
foldername = [iopath, FOLDER,'/',divname,'.mat'];
save(foldername,'filenames','ROIarea_eroded','CircMeasurements','ROI_original');
end