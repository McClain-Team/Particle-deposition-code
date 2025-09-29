function[angle, badflag] = determineConeAngleHoriz(fullFileName,thresh,PLOT_STEPS)
% fullFileName = "C:\PURDUE\Year 5 (Graduate)\Research\Experiments\High Speed Camera\IPS Cone Flow Image Processing\AllDataLongExv2\S1-3_4V-H.png";
% thresh = 225;
% PLOT_STEPS = 1;


% THIS VERSION OF THE FUCNTION DOESNT ROTATE IMAGES ON IMPORT, seeing if it
% affects linear fits for angle measurement


heatmap = imread(fullFileName);
    
    heatcrop = heatmap(:,1001:1100); % crop to 1mm (just below the tip) to fit lines on flow
    offsetX = 180; % (no x crop)
    offsetY = 0;
    
    %%
    % BW = heatcrop;
    
    
    
    
    %%
    % BINARIZE GREY IMAGE, want white on black (using binary to start with testing method)
    % I = im2gray(cropRGB);
    % BW = imbinarize(I);
    % BW = ~BW;
    % imshow(BW)
    BW = heatcrop < thresh;% simple thresholding (logic based binarization)
    
  
    dim = size(BW);
    
    % Top edge startpoint
    col1 = 91;
    row1 = find(BW(:,col1), 1);
    % Bottom beam startpoint
    col2 = 91;
    row2 = find(BW(:,col2), 1,'last');
    
    %%
    boundary1 = bwtraceboundary(BW,[row1, col1],"N",8,60,"counterclockwise"); %trace left
    boundary2 = bwtraceboundary(BW,[row2, col2],"S",8,60); %trace right, default search is CW from start (NE)
    
    
    
    
    
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
    angle = acos(dp/(length1*length2))*180/pi;
    
    
    intersection = [1 ,-ab1(1); 1, -ab2(1)] \ [ab1(2); ab2(2)];
    intersection = intersection + [offsetY; offsetX]; % y then x in col
    badflag = intersection(1)>offsetY; % opens facing down
    
    if PLOT_STEPS
        figure
      
        t = tiledlayout(1,4,'TileSpacing','Compact');
    nexttile % tile 1
    imshow(heatcrop)
    testendid = strfind(fullFileName,"\");
    testid = fullFileName(testendid(end)+1:end);
    title(testid,'Interpreter', 'none') % say voltage and material
    nexttile % tile 2
    imshow(BW)
    title("Threshold = "+num2str(thresh),'%d')
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
    