% create compound images based on single frame extracted from segregation
% video


filename = "C:\PURDUE\Year 5 (Graduate)\Research\Experiments\Bryan Segregation\TIF vids\0s v4 sample frame 5wt%.png";


%compImg = uint8(zeros(720,1280,3)); % create composite image to show filtering effects



    imBase = imread(filename); %calls up file to be analyzed
    %imBase = imrotate(imBase,90); % USE FOR MY VIDEOS, NOT BRYANS
    imGray = im2gray(imBase); %converts image to gray scale
    imBiner = imcomplement(imbinarize(imGray));%binarizes image, white particles
    % 1280 px tall, want 5/8 to 7/8?
    %imCropped = imcrop(imBiner,[0 720 720 319]); % reduce area for counting, x1 y1 width, height
    imCropped = imBiner; % dont crop for this one

    % identify groups of white pixels (particles),
    CC = bwconncomp(imCropped);%funciton that determines whether a particle is present
    NumParticles = CC.NumObjects;
    stats = regionprops('table',CC,'Area','Circularity','EquivDiameter', 'Solidity','EulerNumber','MinFeretProperties','MaxFeretProperties');
   
    % shape based filtering (to remove static groups and partial overlapped groups)
    [particlesInFrame, ~] = size(stats);
    particleTotal =particlesInFrame;
    cleanupSel = stats.EulerNumber==1 & stats.Solidity>0.7 & stats.EquivDiameter<35; % could use circ too
    eulerFilter = nnz(stats.EulerNumber==0);
    solidFilter = nnz(stats.Solidity<=0.7);
    diaFilter = nnz(stats.EquivDiameter>=35);

    
    
    % not sure if better way to make new CC than new im with sel and redo bwconncomp
    imClean = cc2bw(CC,ObjectsToKeep=cleanupSel);
    cleanCC = bwconncomp(imClean); 
    cleanStats = regionprops('table',cleanCC,'Area','Circularity','EquivDiameter', 'Solidity','EulerNumber','MinFeretProperties','MaxFeretProperties');    
    
    PASel = cleanStats.EquivDiameter<8.5; % <85 micron size means nylon
    SugarSel = cleanStats.EquivDiameter>=8.5; % sugar is just compliment for now

    imPA = cc2bw(cleanCC, ObjectsToKeep=PASel);
    imSugar = cc2bw(cleanCC, ObjectsToKeep=SugarSel);

    imshow(imPA)
    figure
    imshow(imSugar)
%% merge images into RGB map, color shows details

imFiltered = imBiner ~= imClean; % difference = filtered regions

cmR = uint8(imSugar + imPA)*255;
cmG = uint8(imFiltered + imPA)*255;
cmB = uint8(imFiltered + imSugar)*255;

compImg = (cat(3,cmR,cmG,cmB)); % keep filtered areas white

imshow(compImg)

% add colored bars to show filter region
compImg(718:720,:,:) = 255;
compImg(1040:1042,:,:) = 255;
compImg(718:1042,1:3,:) = 255;
compImg(718:1042,718:720,:) = 255;

figure
imshow(compImg)

% not easy to just flip BW invert colors, instead
figure
imshow(imcomplement(compImg))

% % flip BW
% 
% Bmap = ()
% Wmap = 
% 
% 
% compImg2 = compImg;
% compImg2(compImg == 0)
% %[0 720 720 319]