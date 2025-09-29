% 50% sugar and nylon mix analysis to attempt to determine size
% characteristics of each sugar type

% clc;
clear;
%close all;
tic 

%choose a vid to look at 
filename = 'C:\PURDUE\Year 5 (Graduate)\Research\Experiments\Bryan Segregation\TIF vids\Single sugar + PA\50% 90-150 sugar, 50% nylon, 0s v2.tif';
%filename = 'C:\PURDUE\Year 5 (Graduate)\Research\Experiments\Bryan Segregation\TIF vids\Single sugar + PA\50% 150-212 sugar, 50% nylon, 0s v3.tif';
filename = 'C:\PURDUE\Year 5 (Graduate)\Research\Experiments\Bryan Segregation\TIF vids\5 wt% 3 to 1 sugar mix v4\full 0s v4.tif';
filename = 'C:\PURDUE\Year 5 (Graduate)\Research\Experiments\Bryan Segregation\TIF vids\T11_1_9V-646frame.tif';
% (my videos aren't rotated on import, bryan's are...)

% var initialization
area = 0;
PartAreas = table();
EDias = table();
filter = table();
particleTotal = 0;
eulerFilter = 0;
solidFilter = 0;
diaFilter = 0;
totalFiltered = 0;


tifInfo = imfinfo(filename); % determine number of frames --> 
tifLength = numel(tifInfo); % 776 instead of 1000 (due to TIF size limit?) (seems to be all vids?)

n = 20; % how often to count particles
%i = 1; % debug w/o loop
for i = 1:n:tifLength % run thru images, consider every nth frame
    imBase = imread(filename,i); %calls up file to be analyzed
    imBase = imrotate(imBase,90); % USE FOR MY VIDEOS, NOT BRYANS
    imGray = im2gray(imBase); %converts image to gray scale
    imBiner = imcomplement(imbinarize(imGray));%binarizes image, white particles
    % 1280 px tall, want 5/8 to 7/8?
    imCropped = imcrop(imBiner,[0 720 720 319]); % reduce area for counting, x1 y1 width, height
    
    % identify groups of white pixels (particles),
    CC = bwconncomp(imCropped);%funciton that determines whether a particle is present
    NumParticles = CC.NumObjects;
    stats = regionprops('table',CC,'Area','Circularity','EquivDiameter', 'Solidity','EulerNumber','MinFeretProperties','MaxFeretProperties');
    % area = stats.Area;
    % figure
    % imshow(imCropped)
    % figure
    % imshow(imBase)
    
    

    % shape based filtering (to remove static groups and partial overlapped groups)
    [particlesInFrame, ~] = size(stats);
    particleTotal = particleTotal + particlesInFrame;
    cleanupSel = stats.EulerNumber==1 & stats.Solidity>0.7 & stats.EquivDiameter<35; % could use circ too
    eulerFilter = eulerFilter + nnz(stats.EulerNumber==0);
    solidFilter = solidFilter + nnz(stats.Solidity<=0.7);
    diaFilter = diaFilter + nnz(stats.EquivDiameter>=35);
    
    % check how many get caught by each filter? (some count for multiple)
    % or could plot distributions of total parameters... (can't easily tie
    % to particles from assorted frames as visualization aid...)

    % not sure if better way to make new CC than new im with sel and redo bwconncomp
    imClean = cc2bw(CC,ObjectsToKeep=cleanupSel);
    cleanCC = bwconncomp(imClean); 
    cleanStats = regionprops('table',cleanCC,'Area','Circularity','EquivDiameter', 'Solidity','EulerNumber','MinFeretProperties','MaxFeretProperties');    
    
    [particlesAfterFilter, ~] = size(cleanStats);
    totalFiltered = totalFiltered + (particlesInFrame - particlesAfterFilter); % 

    tabArea = array2table(cleanStats.Area);%converts the array that contains the areas into an 
    PartAreas = [PartAreas; tabArea];
    EDias = [EDias; array2table(cleanStats.EquivDiameter)];
    filter = [filter; array2table(cleanStats.Circularity)];
    
    % manual pixel counting for size:
        % 30px seems like max single size of reason, but give extra margin
        % to be generous... full remove dia > 35? (for 150) 
        % 90 seems to go up to 20 ish in its vid
        % shape filtering deals with groups
   % sel = ;%
        
    % just target sugar + nylon, "bimodal" confidence is too low


end

areas = table2array(PartAreas);
dias = table2array(EDias);
filterStat = table2array(filter);

if i > 1
framesRead = length(1:n:tifLength);



figure
histogram(filterStat,unique(filterStat))
title('Particle circ Distribution')
xlabel('Particle circ')
ylabel('Pre-filter Number of particles over ' + string(framesRead) + ' Frames')

% filter artiacts found in most frames (dust on sensor) from bulk list (not all bc overlapping on occasion.
% (plot overall area histogram, should see a few spikes)
[cnt,bin] = hist(filterStat,unique(filterStat));
[~,idx] = sort(-cnt);
 % filter anything that had a circularity show up at least 30% of the time, should be stuck dust
 badFilters = bin(idx(cnt(idx) > framesRead * .3));
goodMap = ~ismember(filterStat,badFilters); 
areas = areas(goodMap);
dias = dias(goodMap);
filteredStat = filterStat(goodMap);


figure
histogram(filteredStat,unique(filteredStat))
title('Particle circ Distribution - fixed')
xlabel('Particle circ')
ylabel('Number of particles over ' + string(framesRead) + ' Frames')




%%
areaEdges = [0:1000];
figure
histogram(areas,areaEdges)
title('Particle Area Distribution')
xlabel('Particle Area (um)')
ylabel('Number of particles over ' + string(framesRead) + ' Frames')


% based on 90-150 0s v2, to fall 1/4 of image (specific bottom crop
    % region) it takes this many frames:
        % 90-150 S , 30.15 frames, .0094s, 3.2mm, .34m/s
        % nylon    , 41.2
        % 150-212 S, 29.1
        % nylon    , 41.2

% emperical correction factor based on average particle speed to
        % undo the effects of seeing some particles multiple times. Based
        % on # of frames between each sample. 
        sugarOversample = 1.5; % for n = 20
        nylonOversample = 2;   % ^
        % apply based on NUMBER OF PARTICLES in calculations
end

% Number dist
figure
edges = [0 1:3:149 150];
%PartDistro = histogram(table2array(EDias)*10,edges,'Normalization','probability'); %Creates the histogram of the probability for particle size
PartDistro = histogram(table2array(EDias)*10,edges,'Normalization','pdf'); %Creates the histogram of the probability for particle size
hold on
title('Particle Size Distribution')
xlabel('Particle Size (um)')
ylabel('Proability of Particle Size')
hold off



% PartDistro = histogram(Distro,'Normalization','probability')%Creates the histogram of the probability for particle size
% hold on
% title('Corrected Particle Size Distribution (double counting comp)')
% xlabel('Particle Size (um)')
% ylabel('Proability of Particle Size')
% hold off


% if a size showed up in every frame, remove that from the data

toc


% IMPROVEMENTS
% use/report number of filtered particles
% create report images that color-code sample frames to show which
    % particles were identified as which material