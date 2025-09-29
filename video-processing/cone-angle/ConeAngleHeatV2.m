% Attempting to implement this example's process instead of my own approach
% https://www.mathworks.com/help/images/measuring-angle-of-intersection.html
%% setup
clear
close all
clc
tic

% heatmap = imread("C:\PURDUE\Year 5 (Graduate)\Research\Experiments\High Speed Camera\IPS Cone Flow Image Processing\AllDataLongExV2\S2-3_1V-BW.png");
% heatmap = imread("C:\PURDUE\Year 5 (Graduate)\Research\Experiments\High Speed Camera\IPS Cone Flow Image Processing\AllDataLongExV2\S2-1_6V-BW.png");
heatmap = imread("C:\PURDUE\Year 5 (Graduate)\Research\Experiments\High Speed Camera\IPS Cone Flow Image Processing\AllDataLongExV2\S2-1_6V-H.png");


filename = 'S2*-H.png'; % to do fewer tests, change S*... to S2*... for ex
threshes = [255 225 200 175 150 125 100]; % 250+ = white, 25 = 10% of particle traj passed there
threshes = 250:-1:200; % stop at 200 bc analysis breaks down beyond that
% shorter debug, comment out to full run
%filename = 'S2-2*-H.png'; % 2.2V, 2.5V, 2.8V
%threshes = [255 225 200 175 150];



FIT_PLOTS = 0; % update for all or bad or none
RES_PLOTS = 1;

outplottitle = 'Set 2 cone angle variance analysis';
figoutpath = "C:\PURDUE\Year 5 (Graduate)\Research\Experiments\High Speed Camera\IPS Cone Flow Image Processing\ConeAngleFigs"; % output folder

folderpath = "C:\PURDUE\Year 5 (Graduate)\Research\Experiments\High Speed Camera\IPS Cone Flow Image Processing\AllDataLongExv2\"; %input im location
filepattern = fullfile(folderpath, filename);
filelist = dir(filepattern);
no_files = length(filelist);
no_thresh = length(threshes);
no_runs = no_files*no_thresh;


angletable = zeros(no_files,no_thresh); % initialize out table
% each row of table is one image (one material x voltage condition)

for i = 1:no_runs
    file = idivide(i-1, uint16(no_thresh)) + 1; % row
    current_thresh_ind = i - ((file-1)*no_thresh); % col
    
    
    baseFileName = filelist(file).name;
    fullFileName = fullfile(filelist(file).folder, baseFileName);
    %fprintf(1, 'Now reading %s\n', fullFileName); % debug/tracking
    heatmap = imrotate(imread(fullFileName),90);
    
    heatcrop = heatmap(181:280,:); % crop to 1mm (just below the tip) to fit lines on flow
    offsetX = 0; % (no x crop)
    offsetY = 180;
    
    % BW = heatcrop;
    
    
    
    
    %%
    % BINARIZE GREY IMAGE, want white on black (using binary to start with testing method)
    % I = im2gray(cropRGB);
    % BW = imbinarize(I);
    % BW = ~BW;
    % imshow(BW)
    BW = heatcrop < threshes(current_thresh_ind);% simple thresholding (logic based binarization)
    
    
    
    dim = size(BW);
    
    % left edge startpoint
    row1 = 10;
    col1 = find(BW(row1,:), 1);
    % right beam startpoint
    row2 = 10;
    col2 = find(BW(row2,:), 1,'last');
    
    %%
    boundary1 = bwtraceboundary(BW,[row1, col1],"W",8,60,"counterclockwise"); %trace left
    boundary2 = bwtraceboundary(BW,[row2, col2],"E",8,60); %trace right, default search is CW from start (NE)
    
    
    
    
    
    % Apply offsets in order to draw in the original image
    %plot(offsetX+boundary1(:,2),offsetY+boundary1(:,1),"g");
    %plot(offsetX+boundary2(:,2),offsetY+boundary2(:,1),"g");
    
    %% fit line, turn into vector
    ab1 = polyfit(boundary1(:,2),boundary1(:,1),1);
    ab2 = polyfit(boundary2(:,2),boundary2(:,1),1);
    vect1 = [1 ab1(1)]; % Create a vector based on the line equation
    vect2 = [1 ab2(1)];
    fit1 = polyval(ab1,boundary1(:,2));
    fit2 = polyval(ab2,boundary2(:,2));
    
    
    dp = dot(vect1, vect2);
    length1 = sqrt(sum(vect1.^2));
    length2 = sqrt(sum(vect2.^2));
    angle = 180-acos(dp/(length1*length2))*180/pi;
    
    angletable(file,current_thresh_ind) = angle;
    
    if FIT_PLOTS
    figure('units','normalized','outerposition',[0 0 .5 1])
    t = tiledlayout(4,1,'TileSpacing','Compact');
    nexttile % tile 1
    imshow(heatcrop)
        nexttile % tile 2
    imshow(BW)
    title("Threshold = "+num2str(threshes(current_thresh_ind),'%d'))
    nexttile % tile 3, no offsets bc plotting crop
    imshow(heatcrop)
    hold on
    plot(boundary1(:,2),boundary1(:,1),"g");
    plot(boundary2(:,2),boundary2(:,1),"g");
    nexttile % tile 4
    imshow(heatcrop)
    hold on
    plot(boundary1(:,2),boundary1(:,1),"g"); % extracted border
    plot(boundary2(:,2),boundary2(:,1),"g");
    plot(boundary1(:,2),fit1,'r'); 
    plot(boundary2(:,2),fit2,'r');
    title(baseFileName+" - Angle = "+num2str(angle,'%.2f'),'Interpreter', 'none')
    end
    %% intersection (for plotting)
    % maybe use intersection to determine small or large angle?...
    intersection = [1 ,-ab1(1); 1, -ab2(1)] \ [ab1(2); ab2(2)];
    intersection = intersection + [offsetY; offsetX];
end


%% output plotting
if RES_PLOTS
figure % do one test per material condition (diff voltage curves on plot
hold on
for trial = 1:no_files
    x = [100 90 80 70 60]; % depends on thresholds, corresponds to % of particles included, divide by 2.5 to convert
    x = threshes/2.5;
    baseFileName = filelist(trial).name; % reusing same var name...
    vind = strfind(baseFileName, 'V');
    testV = replace(baseFileName(vind-3:vind),'_','.');
    plot(x,angletable(trial,:),'-','DisplayName',testV) % add formatting...
    
    
end
title(outplottitle);
xlabel('Particles Included (%)')
ylabel('Cone Angle (deg)')
legend('location','best')
end

toc