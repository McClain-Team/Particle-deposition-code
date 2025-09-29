% function to isolate job of looking at video. for now, return bare
% essentials. Maybe add returning of stats such as how much is filtered per video
% later


% comment fnc line and end, uncomment below to debug as non-function
%filename = "C:\PURDUE\Year 5 (Graduate)\Research\Experiments\Bryan Segregation\TIF vids\5 wt% 3 to 1 sugar mix v4\full 0s v4.tif"; 

function [pctPA, pctOther, uncompPA, PAVolFrac, PAMassFrac, badPct] = mixSegregationPA(filename)
% analyzeVideo - This function takes in a video clip (of particles
    % flowing) and processes it to identify the relative portions of nylon
    % 
    % 
    % Inputs:
    %   filepath - string, the full path to the video file.
    %
    % Outputs:
    %   pctPA - scalar(0-1), the relative fraction of particles in this
    %   video classified as PA (
    %   pctOther - scalar, the average brightness (intensity) of all frames.


    % BELOW IS COPIED FROM SingleSugarAnalysis.m
    
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
compImg = uint8(zeros(720,1280,3)); % create output image showing proce


tifInfo = imfinfo(filename); % determine number of frames --> 
tifLength = numel(tifInfo); % 776 instead of 1000 (due to TIF size limit?) (seems to be all vids?)

n = 20; % how often to count particles
%i = 1; % debug w/o loop
for i = 1:n:tifLength % run thru images, consider every nth frame
    imBase = imread(filename,i); %calls up file to be analyzed
    %imBase = imrotate(imBase,90); % USE FOR MY VIDEOS, NOT BRYANS
    imGray = im2gray(imBase); %converts image to gray scale
    imBiner = imcomplement(imbinarize(imGray));%binarizes image, white particles
    % 1280 px tall, want 5/8 to 7/8?
    imCropped = imcrop(imBiner,[0 720 720 319]); % reduce area for counting, x1 y1 width, height
    
    % identify groups of white pixels (particles),
    CC = bwconncomp(imCropped);%funciton that determines whether a particle is present
    NumParticles = CC.NumObjects;
    stats = regionprops('table',CC,'Area','Circularity','EquivDiameter', 'Solidity','EulerNumber','MinFeretProperties','MaxFeretProperties');
   
    % shape based filtering (to remove static groups and partial overlapped groups)
    [particlesInFrame, ~] = size(stats);
    particleTotal = particleTotal + particlesInFrame;
    cleanupSel = stats.EulerNumber==1 & stats.Solidity>0.7 & stats.EquivDiameter<35; % could use circ too
    eulerFilter = eulerFilter + nnz(stats.EulerNumber==0);
    solidFilter = solidFilter + nnz(stats.Solidity<=0.7);
    diaFilter = diaFilter + nnz(stats.EquivDiameter>=35);
    
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
end

framesRead = length(1:n:tifLength); % " = i" would be valid since this is after the loop.
areas = table2array(PartAreas);
dias = table2array(EDias);
filterStat = table2array(filter);

%% filter artiacts found in most frames (dust on sensor) from bulk list (not all bc overlapping on occasion.
% (plot overall area histogram, should see a few spikes)
[cnt,bin] = hist(filterStat,unique(filterStat));
[~,idx] = sort(-cnt);
 % filter anything that had a circularity show up at least 30% of the time,
 % should be stuck dust, circularity is a pretty unique/complex parameter
 badFilters = bin(idx(cnt(idx) > framesRead * .3));
goodMap = ~ismember(filterStat,badFilters); 
areas = areas(goodMap);
dias = dias(goodMap);
filteredStat = filterStat(goodMap);


% NEW PARTS OF CODE
% for v1, do simple check of area equiv dia < 85um means PA, based on d95
% from analyzing dispensing test of pure PA at 1.9V. sugar shouldn't be 
% smaller due to sieving. seems ok for first pass at least
% flaws with method: cant account for particles clinging together/to sugar,
% which is especially problematic if charge develops over the duration of a
% test, meaning PA gets missed more.

totParticles = length(dias);
PAmap = dias<8.5; % binary output, in pixels, not um

numPA = nnz(PAmap);
numOtherMtl = totParticles - numPA;

% adjust numbers to attempt and account for diff fall speeds/double
% counting, emperically determined and tracked in excel sheet.
sugarOversample = 1.5; % for n = 20 (every nth frame analyzed for particles)
PAOversample = 2;   % ^

compPA = numPA / PAOversample;
compOther = numOtherMtl / sugarOversample;
compCount = compPA + compOther; % fractions will add to 100%, could try and accound for data tossed out...

% calculate final material fractions (could base on pre-filtered groups...
% wouldn't add to 100%, not necessarily bad thing tho if more accurate
pctPA = compPA/compCount;
pctOther = compOther/compCount;
uncompPA = numPA/totParticles;

%% currently working by num basis. convert to vol/mass basis!
% approximate particles as spheres
estMass = 4/3 * pi() * ((dias/1000)/2).^3; % first estimate sphere vol, d/1000 converts to cm, cm^3
PATotVol = sum(estMass(PAmap)) / PAOversample; % generate vol stats and apply compensation. 
otherTotVol = sum(estMass(~PAmap)) / sugarOversample;
PAVolFrac = PATotVol / (PATotVol + otherTotVol);

estMass(~PAmap) = estMass(~PAmap)*1.6; % correct for sugar density = 1.6 g/cm^3 (unit = g)
% PA density = 1 g/cm^3 so it doesn't need to change
PATotMass = sum(estMass(PAmap)) / PAOversample; % apply compensation. should be linear still..? (technically some effect from particle distribution being lost
otherTotMass = sum(estMass(~PAmap)) / PAOversample;
PAMassFrac = PATotMass / (PATotMass + otherTotMass);
badPct = totalFiltered/(totParticles+totalFiltered);
end