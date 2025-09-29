% cone angle sensitivity plot maker

% generate one figure with 80%, 90%, 100% threshold curve fits on a single
% test heatmap

% create an example for sugar or coarse SL and one for PA12/fine? use
% higher voltages

close all
SAVE_FIGS = 0;
SAVE_CON = 1;
saveFolder = "C:\PURDUE\Year 5 (Graduate)\Research\Experiments\High Speed Camera\IPS Cone Flow Image Processing\ConeAngleFigs\";


%% list of files crudely prepared for iteration
file(1) = "C:\PURDUE\Year 5 (Graduate)\Research\Experiments\High Speed Camera\IPS Cone Flow Image Processing\AllDataLongExV2\S1-1_3V-H.png";
test(1) = "Coarse SL at 1.3V";

file(2) = "C:\PURDUE\Year 5 (Graduate)\Research\Experiments\High Speed Camera\IPS Cone Flow Image Processing\AllDataLongExV2\S1-3_1V-H.png";
test(2) = "Coarse SL at 3.1V";

file(3) = "C:\PURDUE\Year 5 (Graduate)\Research\Experiments\High Speed Camera\IPS Cone Flow Image Processing\AllDataLongExV2\S7-1_3V-H.png";
test(3) = "Sugar at 1.3V";

file(4) = "C:\PURDUE\Year 5 (Graduate)\Research\Experiments\High Speed Camera\IPS Cone Flow Image Processing\AllDataLongExV2\S7-3_1V-H.png";
test(4) = "Sugar at 3.1V";

file(5) = "C:\PURDUE\Year 5 (Graduate)\Research\Experiments\High Speed Camera\IPS Cone Flow Image Processing\AllDataLongExV2\S11-1_3V-H.png";
test(5) = "PA12 at 1.3V";

file(6) = "C:\PURDUE\Year 5 (Graduate)\Research\Experiments\High Speed Camera\IPS Cone Flow Image Processing\AllDataLongExV2\S11-3_1V-H.png";
test(6) = "PA12 at 3.1V";


%%
plotcolors = ["#f31a1a" "#ff8f20" "#FFD133" "#75FF33" "#01BCD4" "#7B1FA2"]; %rainbow

for i = 1:length(file)
    
    angles = [-1 -1 -1]; % for three calls
    [angles(3), h1] = determineConeAngle(file(i),250,plotcolors(1),1,i); % 100% LOCAL VERSION OF dCA
    [angles(2), h2] = determineConeAngle(file(i),225,plotcolors(2),0,i); % 90%
    [angles(1), h3] = determineConeAngle(file(i),200,plotcolors(3),0,i); % 80%
    
    f = figure(i);
    legend([h1,h2,h3],'Location','northwest')
    title(test(i))
    %f.Position = [100 100 720 460];
    if SAVE_FIGS
        saveas(gcf,(saveFolder+test(i)+" ThreshSensitivity.png"))
    end
    
    %% secondary analysis, contour map
    contours = 250:-25:125; % thresh values corresponding to 100,
    refim = imrotate(imread(file(i)),90);
    [x, y] = size(refim);
    cmR = uint8(zeros(x,y));
    cmG = uint8(zeros(x,y));
    cmB = uint8(zeros(x,y));
    
    for c = 1:length(contours)
        color = char(plotcolors(c));
        cmR(refim<contours(c)) = hex2dec(color(2:3));
        cmG(refim<contours(c)) = hex2dec(color(4:5));
        cmB(refim<contours(c)) = hex2dec(color(6:7));
        
    end
    conmap = cat(3,cmR,cmG,cmB);
    conmap(~conmap) = 255; % convert black pixels to white
    figure(i+20)
    hold on
    imshow(conmap)
    if SAVE_CON
        saveas(gcf,(saveFolder+test(i)+" Contour.png"))
    end
    
end




%% FUNCTIONs
% pasting on modified version for cone angle calc to do special plotting
function[angle,handle] = determineConeAngle(fullFileName,thresh,color,firstCall,i)
% fullFileName = "C:\PURDUE\Year 5 (Graduate)\Research\Experiments\High Speed Camera\IPS Cone Flow Image Processing\AllDataLongExv2\S1-3_4V-H.png";
% thresh = 225;
% PLOT_STEPS = 1;


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
BW = heatcrop < thresh;% simple thresholding (logic based binarization)

% left edge startpoint
row1 = 10;
col1 = find(BW(row1,:), 1);
% right beam startpoint
row2 = 10;
col2 = find(BW(row2,:), 1,'last');

%%
boundary1 = bwtraceboundary(BW,[row1, col1],"W",8,60,"counterclockwise"); %trace left
boundary2 = bwtraceboundary(BW,[row2, col2],"E",8,60); %trace right, default search is CW from start (NE)

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
%% test to verify/correct small/large angle direction
if ~(30<angle && angle<150) % if small or close to 180, verify that proper angle was measured (trust it normally?
    % use slope of left edge to test verticallity,
    if abs(ab1(1)) > 1 % slope > 1 means vert, angle should be small
        if angle > 150
            angle = 180 - angle;
        end % no else bc other case is angle already small
    else % horiz, angle should be close to 180
        if angle < 30
            angle = 180 - angle;
        end
    end
end

intersection = [1 ,-ab1(1); 1, -ab2(1)] \ [ab1(2); ab2(2)];
intersection = intersection + [offsetY; offsetX]; % y then x in col
badflag = intersection(1)>offsetY; % opens facing down

figure(i)
if firstCall
    imshow(heatmap(1:420,:))% show the top third of the image
end
hold on
%plot(boundary1(:,2),boundary1(:,1),"g"); % extracted border
%plot(boundary2(:,2),boundary2(:,1),"g");
%lineName = string(thresh/2.5) + "% Angle = " + string(angle) + "^o";
lineName = "> "+string(100 - thresh/2.5)+"% filter, Angle = " + string(angle) + "^o";
handle = plot(boundary1(:,2),offsetY+fit1,'Color',color,'DisplayName', lineName,'lineWidth',1.6);
plot(boundary2(:,2),offsetY+fit2,'Color',color,'lineWidth',1.6);


end