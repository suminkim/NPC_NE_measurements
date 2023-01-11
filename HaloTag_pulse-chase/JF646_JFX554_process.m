% Find JF646 puncta that do NOT overlay with JFX554: Identifying "new"
% pores
% Inputs are peak .tifs for "query" and overlayed/thresholded .tifs for
% "search"
%%
%%
% Read files to analyze %

clear all

FOLDERS = {
%   Comment out DIV4 folders since they do not have JF646 channel

%%%     '0608_10_WT/DIV4'
     '0608_10_WT/DIV6'
     '0608_10_WT/DIV8'
     '0608_10_WT/DIV10'

%%%     '0610_1_WT/DIV4'
%      '0610_1_WT/DIV6'
%      '0610_1_WT/DIV8'
%      '0610_1_WT/DIV10'
    
%%%    '0610_9_WT/DIV4'
%      '0610_9_WT/DIV6'
%      '0610_9_WT/DIV8'
%      '0610_9_WT/DIV10'
     
%%%   '1022_1_KO/DIV4'
   %  '1022_1_KO/DIV6'
%      '1022_1_KO/DIV8'
%      '1022_1_KO/DIV10'

%%%    '0610_4_KO/DIV4'
%      '0610_4_KO/DIV6'
%      '0610_4_KO/DIV8'
%     '0610_4_KO/DIV10'
    
%%%    '0610_8_KO/DIV4'
%      '0610_8_KO/DIV6'
%      '0610_8_KO/DIV8'
%     '0610_8_KO/DIV10'
};

iopath = '/Users/suminkim/Dropbox (University of Michigan)/Dropbox_Imaging/SIM/HaloTag_DIV4-10_PulseChase/';
cd(iopath);

%% Channel set up
query = 'JF646'; %for each coordinate of query channel, will search through the search channel
search = 'JFX554';

%% Loop
for k = 1:numel(FOLDERS)
    FOLDER = [FOLDERS{k}];

    query_folder = [iopath, FOLDER, '/',query,'_Output/'];
    search_folder = [iopath, FOLDER, '/',search,'_Overlayed/']; 

    query_fnames = dir([query_folder '/*', query,'*.tif']);
    search_fnames = dir([search_folder '/*',search,'*.tif']);
    
    NPCnumber = [];
    filenames = strings;
    Outfolder = [iopath,FOLDER,'/',query, '_Unique_Output'];

    %%
    % Separate main flow from the processing steps for better readability and reuse..
    % Repeat for each channel ID

    for i = 1:length(query_fnames)
        % Open each query coordinate .tif file and open the matching search overlayed .tif file
        query_name = query_fnames(i).name; % current file being processed
        query_img = tiffreader2(query_name,query_folder); % open the .tif file of coordinates
        search_name = regexprep(query_name,{query, ''},{search,''}); % replace strings to get search channel overlay file names
        search_img = tiffreader2(search_name,search_folder); % open the .tif file for search channel
        
        % Run "find_unique_puncta" function
        [unique_peaks, no_coloc_num] = find_unique_puncta(query_img, search_img);
        
        % Append number of peaks to a list
        NPCnumber(i) = no_coloc_num; 

        % Get filename of img to an array
        filename = query_fnames(i).name;
        filenames(i) = string(filename);

        % Write output file of peak locations for visualization
        tiffwrite2(unique_peaks,Outfolder,query_fnames(i).name,8,1); % normalize if saving logicals for IJ

        % Get coordinates of all peaks in centroids to avoid overlap and save
        % in .mat
        L = bwlabel(unique_peaks);  %to count one spot with multiple maxima values as one peak
        Prop = regionprops(L,'Centroid','Area');
        arrayname = [filename,'.mat'];
        arrayout = [Outfolder,'/',arrayname]; 
        save(arrayout,'unique_peaks','Prop');

    end

%----Make an array of filenames, NPC number
divname = FOLDER(11:end);
outputfile = [filenames',NPCnumber'];
outputfilename = [FOLDER, '/',divname,' ',query,'_Unique_Counts.csv'];
cell2csv(outputfilename,outputfile);

mat_filename = strrep(outputfilename,'.csv','.mat');
save(mat_filename,'filenames','NPCnumber');

end

%% Find unique JF646 puncta with query_img (image of the peaks) and search_img (image that was thresholded/masked)

function [unique_peaks, no_coloc_num] = find_unique_puncta(query_img, search_img)
        % Get total number of coordinates in query and append to
        % totalcount
        L = bwlabel(query_img);  %to count one spot with multiple maxima values as one peak
        totalnum = max(L(:)); %get number of peaks
        
        % Make overlayed image of search channel into a reverse mask - only
        % values of 0 are counted (i.e. areas where there is no signal from
        % this channel). Then mask the query coordinate image to get
        % coordinates that do not colocalize
        mask = search_img == 0;
        unique_peaks = query_img.*mask;
        
        % Count # coordinates that do not colocalize
        L = bwlabel(unique_peaks);  %to count one spot with multiple maxima values as one peak
        no_coloc_num = max(L(:)); %get number of peaks
        
end