function [] = ConeAnglePlotterFnc(filename, outplottitle, SAVE_FIGS)
%filename="S11-*-H.png";,outplottitle="Coarse SL Tapered 20Ga";,SAVE_FIGS=0;
% function-ized version of ConeAngleHeatV2 to make calling each material
% easier

% Attempting to implement this example's process instead of my own approach
% https://www.mathworks.com/help/images/measuring-angle-of-intersection.html
%% setup

% heatmap = imread("C:\PURDUE\Year 5 (Graduate)\Research\Experiments\High Speed Camera\IPS Cone Flow Image Processing\AllDataLongExV2\S2-3_1V-BW.png");
% heatmap = imread("C:\PURDUE\Year 5 (Graduate)\Research\Experiments\High Speed Camera\IPS Cone Flow Image Processing\AllDataLongExV2\S2-1_6V-BW.png");
heatmap = imread("C:\PURDUE\Year 5 (Graduate)\Research\Experiments\High Speed Camera\IPS Cone Flow Image Processing\AllDataLongExV2\S2-1_6V-H.png");


% (FNC PARAMETER) filename = 'S2*-H.png'; % to do fewer tests, change S*... to S2*... for ex
threshes = [255 225 200 175 150 125 100]; % 250+ = white, 25 = 10% of particle traj passed there
threshes = 250:-1:200; % stop at 200 bc analysis breaks down beyond that
% threshes = 225; % single case test for out plots 

% shorter debug, comment out to full run
%filename = 'S2-2*-H.png'; % 2.2V, 2.5V, 2.8V
%threshes = [255 225 200 175 150];

FIT_PLOTS = 0; % update for all or bad or none
RES_PLOTS = 1;

% (FNC PARAMETER) outplottitle = 'Set 2 cone angle variance analysis';
figoutpath = "C:\PURDUE\Year 5 (Graduate)\Research\Experiments\High Speed Camera\IPS Cone Flow Image Processing\ConeAngleFigs"; % output folder

folderpath = "C:\PURDUE\Year 5 (Graduate)\Research\Experiments\High Speed Camera\IPS Cone Flow Image Processing\AllDataLongExv2\"; %input im location
filepattern = fullfile(folderpath, filename);
filelist = dir(filepattern);
no_files = length(filelist);
no_thresh = length(threshes);
no_runs = no_files*no_thresh;


angletable = zeros(no_files,no_thresh); % initialize out table
% each row of table is one image (one material x voltage condition)

plotcolors = [
    "1_0", "#fa6beb"; "1_3", "#f31a1a"; "1_6", "#ff8f20"; ...
    "1_9", "#FFD133"; "2_2", "#75FF33"; "2_5", "#00BCD4"; ...
    "2_8", "#00796B"; "3_1", "#003DA5"; "3_4", "#7B1FA2"; ...
    ];

for i = 1:no_runs
    file = idivide(i-1, uint16(no_thresh)) + 1; % row
    current_thresh_ind = i - ((file-1)*no_thresh); % col
    
    
    baseFileName = filelist(file).name;
    fullFileName = fullfile(filelist(file).folder, baseFileName);
    %fprintf(1, 'Now reading %s\n', fullFileName); % debug/tracking
    
    % change 0 to 1 at end for intermediate plots for debugging
    angletable(file,current_thresh_ind) = determineConeAngle(fullFileName,threshes(current_thresh_ind),0);
end


%% output plotting
if RES_PLOTS
    figure % do one test per material condition (diff voltage curves on plot
    hold on
    for trial = 1:no_files
        x = [100 90 80 70 60]; % depends on thresholds, corresponds to % of particles included, divide by 2.5 to convert
        x = 100 - (threshes/2.5);
        baseFileName = filelist(trial).name; % reusing same var name...
        vind = strfind(baseFileName, 'V');
        testV = replace(baseFileName(vind-3:vind),'_','.');
        plotcolor = plotcolors(find(plotcolors==baseFileName(vind-3:vind-1)),2);
        plot(x,angletable(trial,:),'-','DisplayName',testV,'Color',plotcolor) % add formatting...
        
        Vlist(trial) = str2double(testV(1:3));
    end
    title(outplottitle);
    xlabel('Filter Threshold (> %)')
    ylabel('Cone Angle (^o)')
    legend('location','best')
end

if SAVE_FIGS
    saveas(gcf,(figoutpath+"\"+outplottitle+".png"));
end

figure(1)
% plot 90% angles onto fig 1, x = voltage, y = angle (one column of
% angletable)
desCol = find(threshes == 225);
plot(Vlist,angletable(:,desCol),'--x') 




