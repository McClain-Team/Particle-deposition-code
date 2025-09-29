function[angle] = determineConeAngle(fullFileName,thresh,PLOT_STEPS)
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
%% for small angles, check if
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

if PLOT_STEPS
    figure
    
    t = tiledlayout(4,1,'TileSpacing','Compact');
    nexttile % tile 1
    imshow(heatcrop)
    testendid = strfind(fullFileName,"\");
    testid = fullFileName(testendid(end)+1:end);
    %testid = replace(fullFileName(testendid(end)+1:end),'_','.');
    title(testid,'Interpreter', 'none') % say voltage and material
    nexttile % tile 2
    imshow(BW)
    title("Threshold = "+num2str(thresh,'%d')+" ("+num2str(thresh/2.5)+"%)")
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
    title("Angle = "+num2str(angle,'%.2f'))
    %title(baseFileName+" - Angle = "+num2str(angle,'%.2f'),'Interpreter', 'none')
    
    %         if SAVE_FIGS
    %             saveas(gcf,(figoutpath+"\T"+num2str(threshold)+"\"+baseFileName));
    %         end
    
    
end
