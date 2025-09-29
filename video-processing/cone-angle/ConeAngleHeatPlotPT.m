%% Initialization and setup
% clc
% clear
close all
tic

% This script processess previously generated "long exposure" images of
% powder deposition to identify flow cone angle and create an excel sheet
% with the resultant data.

% set up which type of images to collect
filename = 'S*-BW.png';
threshold = 0;
filename = 'S*-H.png'; % to do fewer tests, change S*... to S2*... for ex 
threshold = 0;
% filename = 'S1-3_1V-H.png';

% outputName = "ImageConeAngleAnalysis.xlsx";
% sheetName = 'G-ThrX'; % UPDATE THIS for each iteration with different settings (threshold mainly)

DO_PLOTTING = true; % for just bad ones, or other intermediate plotting
PLOT_ALL = true; % figure of start image to edges and line fit
WRITE_TABLE = false;
NO_COLS = 10; % testname, angle, intersection x and y, badflag, size of final left and right groups, etc
FINAL_PLOTTING = true;
SAVE_FIGS = false;

folderpath = "C:\PURDUE\Year 5 (Graduate)\Research\Experiments\High Speed Camera\IPS Cone Flow Image Processing\AllDataLongEx\";
filepattern = fullfile(folderpath, filename);
filelist = dir(filepattern);
no_tests = length(filelist);
figoutpath = "C:\PURDUE\Year 5 (Graduate)\Research\Experiments\High Speed Camera\IPS Cone Flow Image Processing\ConeAngleFigs";


% Output data initialization
Voltages = [1, 1.3, 1.6, 1.9, 2.2, 2.5, 2.8, 3.1, 3.4];
AngleData = zeros(15,9);
badlist = [];
% other outputs from this...?
    % saving images... velocity (lots of separate, extra work), parabola
    % attempts, 

    
DetailedStats = string(zeros(no_tests, NO_COLS));
    
%     for threshold = [32, 40, 60, 80, 100]
%         close all
%% test looping
for trial = 1:no_tests
%for trial = 92 % testing specific cases. Uncomment this and comment the above line
    %% test data reading
    % access item from directory list
    baseFileName = filelist(trial).name;
    fullFileName = fullfile(filelist(trial).folder, baseFileName);
    %fprintf(1, 'Now reading %s\n', fullFileName); % debug/tracking
    greyIm = imread(fullFileName);
    greyIm = imrotate(greyIm,90);
    
    %% cone angle image preparation
    % Binarize to filter areas that only had one or two particle passes
    
    threshBin = greyIm > threshold;
    binEdge = edge(threshBin); % go from binary envelope to edges to curve fit
    % cleanBinEdge = bwareaopen(binEdge,50); % clean specks from the edge image
    % ^ doesn't seem needed, instead do some other filtering later....
    cleanBinEdge = binEdge; % testing use of no filter
    
    
    %cropBin = cleanBinEdge(181:1180,:); % crop the nozzle tip and bottom with light issues
    cropBin = cleanBinEdge(181:280,:); % crop to 1mm (just below the tip) to fit lines on flow
    
%     if DO_PLOTTING
%         figure(trial)
%         imshow(cropBin)
%     end
    
    % clean up noise/edges from within the envelope
    leftEdge = zeros(size(cropBin),'logical');
    rightEdge = zeros(size(cropBin),'logical');
    rows = length(cropBin(:,1));
    for row = 1:rows
        whites = find(cropBin(row,:) == 1); % identify indexes of white pixels in row
        % create a new image of only the left and right bound
        if ~isempty(whites) % prevent error if row had no pixels
            leftEdge(row, whites(1)) = 1;
            rightEdge(row, whites(end)) = 1;
        end
    end
    
    % for wide angles, check columns that didn't get filled to try and
    % create a continuous streak
    % start in center and work out
    cols = (length(cropBin(1,:)));
    for col = 1:cols/2
        % start from the center and work out, will omit center col for odd # of cols
        Lcol = floor(cols/2) - col + 1;
        Rcol = ceil(cols/2) + col;
        % act when columns of edge images are all black
        if all(leftEdge(:,Lcol)==0)
            firstpxL = find(cropBin(:,Lcol),1); % get index of topmost pixel from image before edge extraction
            % make sure a pixel was found (shortcircuit out if empty), then
            % check a 3x3 area of the edge image to find a neighbor and add
            % the identified pixel to the edge (avoiding adding floaters)
                % errors out if firstpx is first or last of column due to
            % indexing beyond range... easiest is to take max b/n 1 and
            % firstpx-1, min for top of range...
            if ~isempty(firstpxL) && any(leftEdge(max([1 firstpxL-1]):min([firstpxL+1 rows]),Lcol-1:Lcol+1),'all')
                leftEdge(firstpxL,Lcol) = 1;
            end
        end
        if all(rightEdge(:,Rcol)==0) % repeat steps for right side
            firstpxR = find(cropBin(:,Rcol),1);
            if ~isempty(firstpxR) && any(rightEdge(max([1 firstpxR-1]):min([firstpxR+1 rows]),Rcol-1:Rcol+1),'all')
                rightEdge(firstpxR,Rcol) = 1;
            end
        end
    end % end of column fill loop
    
    
    % Clean up edges. bwareaopen not as easy bc minimum size needed varies.
    % manually implemented the alg to find the largest continuous track
    
    CCL = bwconncomp(leftEdge);
    SL = regionprops(CCL, 'Area');
    LL = labelmatrix(CCL);
    cleanLeftEdge = ismember(LL, find([SL.Area] == max([SL.Area])));
    
    CCR = bwconncomp(rightEdge);
    SR = regionprops(CCR, 'Area');
    LR = labelmatrix(CCR);
    cleanRightEdge = ismember(LR, find([SR.Area] == max([SR.Area])));
    
    
    LRim = cleanLeftEdge+cleanRightEdge; % create a image with both sides
    
%     if DO_PLOTTING
%         figure(trial)
%         imshowpair(binEdge,LRim, 'montage')
%     end
    
    %% cone angle extraction
    % fit line to edges based on white pixel coordinates
    [yl,xl] = find(cleanLeftEdge == 1); 
    [yr,xr] = find(cleanRightEdge == 1);
    lineL = polyfit(xl,yl,1); % 1st index = slope
    lineR = polyfit(xr,yr,1);

    xf = 1:length(greyIm(1,:)); % 1 point per pixel
    ylf = polyval(lineL, xf);
    yrf = polyval(lineR, xf);
    
    
    
%     if DO_PLOTTING
%         figure(trial+100)
%         hold on
%         plot(xl, yl, 'b.', xr, yr, 'b.', xf, ylf, 'r-', xf, yrf, 'g-');
%         set(gca,'YDir','normal')
%     end
   
    % calculate angle based on fit slopes
    % difference between angles from 0 of 2 slopes = cone angle
    angle = rad2deg((atan2(-lineL(1),-1)) - (atan2(lineR(1),1)));
    % left edge *should* always be negative... light/blowing may cause 
    % issues tho could do if statements to prevent errors...
    % just go with it for now tho, investigate weird numbers later
    
    %% intersection point check flag
    % check if the lines intersect at a reasonable point as a output
    % quality verifier.
    % could check x and y together or separate...
    % x needs extra tolerance for tip location
    % y should intersect above the edge of the image at least
    xint = (lineR(2)-lineL(2))/(lineL(1)-lineR(1)); % (b2-b1)/(m1-m2)
    yint = lineR(1)*xint + lineR(2); % y = mx + b, can use either m and b set
    xtol = .25; % enter fraction of central image to consider "safe"/reasonable
    xmid = length(LRim(1,:))/2;
    xlower = xmid * (1-xtol);
    xupper = xmid * (1+xtol);
    
    % could also check length of edge groups as verifier... i.e. need 20 or
    % more pix in each edge to be "good"
    if (yint<0) && (xlower<xint) && (xint<xupper) % check both x and y together now
        badflag = false;
    else
        badflag = true;
    end
    
    %% Act on badflag
    if PLOT_ALL || (DO_PLOTTING && badflag)
       figure('units','normalized','outerposition',[0 0 .5 1])
       %imshow(cropBin)
%        imshow(LRim)
%        hold on
%        plot(xf, ylf, 'r-', xf, yrf, 'g-')
%        title(baseFileName,'Interpreter', 'none')
        
        % use tilelayout instead of subplot
        
        if ~contains(filename,'H')
            t = tiledlayout(5,1,'TileSpacing','Compact');
        else
            t = tiledlayout(6,1,'TileSpacing','Compact');  
        end
      
        nexttile % tile 1
        imshow(greyIm(181:280,:))
        hold on
        plot(xf, ylf, 'r-', xf, yrf, 'g-')
        title(baseFileName+" - Angle = "+num2str(angle,'%.2f'),'Interpreter', 'none')
        % if greyscale heatmap, show binarized threshold
        if contains(filename,'H')
            nexttile % tile 2 if grey
            imshow(threshBin(181:280,:))
            hold on
            plot(xf, ylf, 'r-', xf, yrf, 'g-')
            title('Binarized Greyscale Heatmap, Threshold: '+string(threshold)) 
        end
        nexttile % tile 2
        imshow(cropBin)
        title('Edge detection')
        nexttile % tile 3
        imshow(leftEdge)
        title('Left edge extraction before cleaning to smallest group')
        nexttile % tile 4
        imshow(rightEdge)
        title('Right edge extraction before cleaning to smallest group')
        nexttile % tile 5
        imshow(LRim)
        hold on
        plot(xf, ylf, 'r-', xf, yrf, 'g-')
        title('Combined and cleaned edges plus curve fits')
 
        if SAVE_FIGS
            saveas(gcf,(figoutpath+"\T"+num2str(threshold)+"\"+baseFileName));
        end
    end
    
    if badflag
        badlist = [badlist; string(baseFileName)]; % create column vec of bad test names
    end
    
    %% saving data to non-loop variables
    % find row and column to populate within angle table
    % row = test set
    testSet = baseFileName(2:3); % 2nd and 3rd character fo S1 thru S11
    % need to pull proper number by testing third character
    % discards the original 3rd character if it is non-numeric
    if isnan(str2double(testSet))
        % could be proper and test to make sure the name is right
        testSet = testSet(1);
    end
    testSet = str2double(testSet); % convert data type so we can index
    % column = voltage
    vind = strfind(baseFileName, 'V');
    testV = replace(baseFileName(vind-3:vind-1),'_','.');
    testCol = find(Voltages == str2double(testV));
    
    % save data out
    AngleData(testSet,testCol) = angle;
    
    %% Single table for saving broad range of parameters
    
    % testname, angle, intersection x and y, badflag, size of final left and right groups, etc
    
    DetailedStats(trial,1) = string(baseFileName);
    DetailedStats(trial,2) = string(angle);
    DetailedStats(trial,3) = string(badflag); % 1 means test was "bad"
    DetailedStats(trial,4) = string(xint);
    DetailedStats(trial,5) = string(yint);
    DetailedStats(trial,6) = string(max([SL.Area])); % size of left edge group
    DetailedStats(trial,7) = string(max([SR.Area])); % size of right edge group
    %DetailedStats(trial,8) = string();
    %DetailedStats(trial,9) = string();
    %DetailedStats(trial,10) = string();
    
end

%     end
%% table saving
colNames = {'Test Name','Angle', 'Bad?', 'X intercept', 'Y intercept',...
    'Left edge size', 'Right edge size'}; %,'manual check', 'unused', 'unused2'}; % can add more
% need to build table with a series of vectors for column naming to work i guess
DS1 = DetailedStats(:,1);
DS2 = double(DetailedStats(:,2));
DS3 = DetailedStats(:,3);
DS4 = double(DetailedStats(:,4));
DS5 = double(DetailedStats(:,5));
DS6 = int16(double(DetailedStats(:,6)));
DS7 = int16(double(DetailedStats(:,7)));
% DS8 = DetailedStats(:,8);
% DS9 = DetailedStats(:,9);
% DS10 = DetailedStats(:,10);

DetailedStatsT = table(DS1, DS2, DS3, DS4, DS5, DS6, DS7,'VariableNames',colNames);

if WRITE_TABLE % could have just used writematrix but nbd
writetable(DetailedStatsT,outputName,'Sheet',sheetName);
writematrix(AngleData,outputName,'Sheet',sheetName+"Xtra",'Range','B2');
writetable(table(badlist),outputName,'Sheet',sheetName+"Xtra",'Range','M1');
end

%% plot voltage vs angle for each set... look at outliers manually...
if FINAL_PLOTTING
figure(200)
hold on
for series = [1,7,9,10,11] % static length for now
plot(Voltages,AngleData(series,1:9),'--x')
end
title('Cone angle by material')
xlabel('Voltage')
ylabel('Cone angle')
legend('150 Glass','150 Sugar','53 Glass','13 Glass', 'PA12','location', 'best')
ylim([0 180])
saveas(gcf,(figoutpath+"\T"+num2str(threshold)+"\AngleByMaterial.png"));

figure(201)
hold on
for series = [1,6,7,8] % static length for now
plot(Voltages,AngleData(series,1:9),'--x')
end
title('Cone angle by tip type, with 150-212 glass or sugar')
xlabel('Voltage')
ylabel('Cone angle')
legend('glass + plastic tip','glass + metal tip','sugar + plastic tip','sugar + metal tip','location', 'best')
ylim([0 180])
saveas(gcf,(figoutpath+"\T"+num2str(threshold)+"\AngleByTip.png"));

figure(202)
hold on
for series = [1,2,3,4,5] % static length for now
plot(Voltages,AngleData(series,1:9),'--x')
end
title('Cone angle by test params, all with 150-212um Glass')
xlabel('Voltage')
ylabel('Cone angle')
legend('baseline config','arm extended','motor parallel with arm','motor normal to syringe', 'vertical motor','location', 'best')
ylim([0 180])
saveas(gcf,(figoutpath+"\T"+num2str(threshold)+"\AngleByMotorPlacement.png"));
end


%% done
% improvements:
    % do the open area cleanup on small edges
    % improve atan2 to account for angles. make sure 180 and 0 reflect
    % appropriate options... (could try vector approach?)
    % check intercept of lines as flag
    
    % CURRENT ISSUE: imshowpair(cropBin,leftEdge,'montage')
    % shows that one pixel per row can create separate groups which get
    % filtered out for group size stuff
    % idea: somehow use the connected group identification to identify the
    % left edge group from an unfiltered image...
    % idea 2: not sure how to run the above well... instead look for
    % vertical pixels in empty columns?
    
toc