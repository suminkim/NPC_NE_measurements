%% CombineData.m
% Process outputs from previous steps to calculate NPC density (puncta
% density) and combine all data into one file.
%% First section to combine timepoints within each biological replicate
% Second section to combine all data

% Output first .csv file for Circularity, ROI areas etc. (parameters)

% Output second .csv file of density for each channel and eroded ROI area

%% Folders to analyze %

clear all

clear all

FOLDERS = {
%     
   '0608_10_WT/'

   '0610_1_WT/'
    
   '0610_9_WT/'
     
   '1022_1_KO/'

   '0610_4_KO/'
   
   '0610_8_KO/'
};

iopath = '/Users/suminkim/Dropbox (University of Michigan)/Dropbox_Imaging/SIM/HaloTag_DIV4-10_PulseChase/';
cd(iopath);

%% FIRST SECTION: 
% Loop through each folder and combine data for that replicate across all
% timepoints

chs = {'Nup153','JFX554','JF646','JF646_Unique'};
tpoints = {'DIV4','DIV6','DIV8','DIV10'};

% Loop through each folder and consolidate all info
for k = 1:numel(FOLDERS)
    FOLDER = [FOLDERS{k}];
    
    % Set up output: output will be in each parent folder:
    density_array = []; % save all DIV and channel densities here
    % DIV (tpoint) / filename / ROIarea (original in um^2) / ROI area (eroded in um^2) / circularity / Ch (Nup153,
    % JFX554, JF646, JF646_Unique) -> 7 columns (except DIV4 doesn't have
    % JF646 / JF646_Unique)
    
    params_array = [];  % 5 columns
    % DIV (tpoint) / filename / circularity / ROI_orig_um^2 / ROI_eroded_um^2
    
    for tpoint = 1:numel(tpoints)
        t = [tpoints{tpoint}];
        density_subarray = []; % will append this to density_array
        params_subarray = []; % will append this to params_array
        
        % Load the .mat file of this folder that contains the following
        % info: 'filenames','ROIarea_eroded','CircMeasurements','ROI_original'
        paramfile = [FOLDER,t,'/',t,'.mat'];
        params = open((paramfile));
    
        roi_filenames = params.filenames;
        [sorted_filenames,sortidx] = sort(roi_filenames); %To get sort index for the filenames and apply this index to other variables 
        
        % Make array of # of analyzed cells for div column
        divarray = zeros(1, length(sorted_filenames))+str2num(t(4:end));
    
        % save variables using the sort index from above
        circularity = params.CircMeasurements(sortidx);
        ROI_orig = params.ROI_original(sortidx);
        ROI_eroded = params.ROIarea_eroded(sortidx);
        ROI_orig_um = ROI_orig*0.0009; % original ROI areas in um^2 units
        ROI_eroded_um = ROI_eroded*0.0009; % eroded ROI areas in um^2 units
        
        % combine DIV, filename, circularity, and um^2 areas:
        params_subarray = [divarray', sorted_filenames', circularity', ROI_orig_um', ROI_eroded_um'];
        params_array = vertcat(params_array,params_subarray); % add to output array
        
        % Load the .mat files that contain puncta counts for each channel
        % and save the counts arrays as separate variables
        % Match up filenames to the parameters array by sorting it for
        % consistency with the order of the ROI area
        
        densityfile = []; % array to save ch densities as we loop through each channel
        fileids = []; % save DIV and sorted filenames from first channel
        
        for channel = 1:numel(chs)
            ch = [chs{channel}];
            
            % conditional because no 646 channel for DIV4: 
            % pass this and continue to next channel. Will fill in "NaN" to
            % empty channels later.
            if contains(t,'4') == 1 && contains(ch,'646') == 1
                continue
            end
          
            
            ch_file = open([iopath, FOLDER,t,'/',t,' ',ch,'_Counts.mat']);
            ch_filenames = ch_file.filenames;

            % Sort these filenames as well and get sorted indices to make
            % sure these match up in order with ROI area order and are in a
            % consistent order between channels
            [sorted_ch_filenames,ch_sortidx] = sort(ch_filenames);
            ch_counts = ch_file.NPCnumber(ch_sortidx);

            % Take density calculations by dividing ch_counts by
            % ROI_eroded_um
            ch_density = ch_counts./ROI_eroded_um;
           
            if channel == 1 % For first channel ('Nup153')
                fileids = sorted_ch_filenames; % get filenames from Nup153 channel
            end 
            
            densityfile = [densityfile, ch_density']; %append ch_density to densities array
        end  % ends channel loop
        
        if size(densityfile,2) == 2
            densityfile = horzcat(densityfile,NaN(length(densityfile),2));
        end
        
        
        density_subarray = [divarray',fileids', ROI_orig_um', ROI_eroded_um', circularity', densityfile];
        density_array = vertcat(density_array,density_subarray);

    
    % Save the data in .mat -- params_array and density_array separately
    params_outfilename = [iopath, FOLDER, 'Parameters.mat'];
    save(params_outfilename,'params_array');
    density_outfilename = [iopath, FOLDER, 'Densities.mat'];
    save(density_outfilename,'density_array');
       
    % Save the data in .csv 
    params_outfilename_csv = strrep(params_outfilename,'.mat','.csv');
    writematrix(params_array,params_outfilename_csv);
    density_outfilename_csv = strrep(density_outfilename,'.mat','.csv');
    writematrix(density_array,density_outfilename_csv);
    
    end  % ends tpoints loop
    
end % ends folders loop

%% SECOND SECTION -- Combine all replicates for density data

WTs= {'0608_10_WT/','0610_1_WT/','0610_9_WT/'};
KOs = {'0610_4_KO/','0610_8_KO/','1022_1_KO/'};

WTout = [];
KOout = [];

for rep = 1:numel(WTs)
    %params = open([iopath, WTs(rep),'Parameters.mat']);
    densityfile = open([iopath, WTs{rep}, 'Densities.mat']);
    density_array = densityfile.density_array;
    reparray = zeros(length(density_array(:,1)),1)+rep; % make array of matching length as densities and add replicate #
    WTout = vertcat(WTout,[reparray,density_array]); 
    WTgeno = zeros(length(WTout(:,1)),1); % WT genotype denoted as 0
end

for rep = 1:numel(KOs)
    %params = open([iopath, KOs(rep),'Parameters.mat']);
    densityfile = open([iopath, KOs{rep}, 'Densities.mat']);
    density_array = densityfile.density_array;
    reparray = zeros(length(density_array(:,1)),1)+rep; % make array of matching length as densities and add replicate #
    KOout = vertcat(KOout,[reparray,density_array]); 
    KOgeno = zeros(length(KOout(:,1)),1)+1; % KO genotype denoted as 1
end

Alldata = vertcat([WTout,WTgeno],[KOout,KOgeno]);

header = {'Replicate','DIV','Filename','ROI_orig','ROI_eroded','Circularity','Nup153','JFX554','JF646','JF646_unique','Genotype'};

% Save the combined data in .mat
outfilename = [iopath, 'CombinedData.mat'];
output = [header;Alldata];
save(outfilename,'output');


% COMBINE ALL DIV AND REPLICATE DATA
outfilename_csv = [iopath,'CombinedData.csv'];
writematrix(output, outfilename_csv);


%%
%%%
