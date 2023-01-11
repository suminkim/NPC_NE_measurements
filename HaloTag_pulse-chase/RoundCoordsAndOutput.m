%% Round_up_coord_Output
% Take .mat outputs from SIM_NPC_Analysis_SK2.m, Obtains coordinates for
% each peak. For any peak that has adjacent maxima (2 pixels side by side),
% the centroid is taken and rounded using floor function. The single peaks
% are then outputted and made into a .tif and saved. 

%% Folders to analyze %

clear all

clear all

FOLDERS = {
%     
     '0608_10_WT/DIV4'
     '0608_10_WT/DIV6'
     '0608_10_WT/DIV8'
     '0608_10_WT/DIV10'

    '0610_1_WT/DIV4'
     '0610_1_WT/DIV6'
     '0610_1_WT/DIV8'
     '0610_1_WT/DIV10'
    
     '0610_9_WT/DIV4'
     '0610_9_WT/DIV6'
     '0610_9_WT/DIV8'
     '0610_9_WT/DIV10'
     
     '1022_1_KO/DIV4'
     '1022_1_KO/DIV6'
     '1022_1_KO/DIV8'
     '1022_1_KO/DIV10'

   '0610_4_KO/DIV4'
     '0610_4_KO/DIV6'
     '0610_4_KO/DIV8'
    '0610_4_KO/DIV10'
    
   '0610_8_KO/DIV4'
     '0610_8_KO/DIV6'
     '0610_8_KO/DIV8'
    '0610_8_KO/DIV10'
};

iopath = '/Users/suminkim/Dropbox (University of Michigan)/Dropbox_Imaging/SIM/HaloTag_DIV4-10_PulseChase/';
cd(iopath);


%% Loop through each folder, grab the Prop to get coordinates for each

chs = {'Nup153','JFX554','JF646','JF646_Unique'};

for k = 1:numel(FOLDERS)
    FOLDER = [FOLDERS{k}];
    
    mkdir(FOLDER, 'RoundedCoords'); 
    Outfolder = [iopath,FOLDER,'/RoundedCoords/'];  
    
    for channel = 1:numel(chs)
        
        ch = [chs{channel}];
        
        % skip JF646 / JF646_Unique if DIV4 since there are no folders for
        % these
        if contains(FOLDER,'DIV4') == 1 && contains(ch,'646') == 1
            continue
        end
        
        ch_folder = [iopath, FOLDER, '/',ch,'_Output/']; 
        fnames = dir([ch_folder '*.tif.mat']);

        for i = 1:length(fnames)
            % Open each .mat file 
            file = fnames(i).name; % current file being processed
            ch_mat = open([ch_folder, file]);

            % Get coordinates from Prop and use floor function to get single
            % coordinates for any peaks that are adjacent to each other
            coords = getCentroids(ch_mat.Prop);
            rounded = floor(coords);
            
            % Change filename to include "new" if JF646 to differentiate
            % from regular JF646 channel
            if contains(ch,'Unique') == 1
                file = strrep(file,'JF646','JF646_new');
            end
            
            % Make image of the rounded coords and save
            ch_img = make_coords_img(rounded,2048);
            ch_imgname = strrep(file,'.tif.mat','_coords.tif');
            tiffwrite2(ch_img,Outfolder,ch_imgname,8,1); % normalize if saving logicals for IJ
   
            %Save the centroid -- not rounded -- coordinates as .mat files
            ch_filename = [Outfolder, strrep(file,'.tif.mat','_coords.mat')];
            save(ch_filename,'coords');
        end
    end
end


%%

%% To get the coordinates from the centroids (Prop)
function coords = getCentroids(Prop)
    for j = 1:length(Prop)
        x_centroid(j) = Prop(j).Centroid(1);
        y_centroid(j) = Prop(j).Centroid(2);
        coords = [x_centroid',y_centroid'];
        
    end
end
%% Make coordinates into an image. Takes coords (a double of x and y values) and dimension of image
% Returns an image of the coordinates in dim x dim size

function img = make_coords_img(coords,dim)
    img = zeros(dim, dim);  
    
    for j = 1:length(coords)
        x = coords(j,1);
        y = coords(j,2);
        img(y,x) = 1;
    end
end