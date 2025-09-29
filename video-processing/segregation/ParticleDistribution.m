clc;
clear;
close all;
tic % time to process a single vid is ~6s with no intermediate plotting

filename ='C:\Users\Bryan\Desktop\HE3P\Powder Segregation\90-150(23.75)+150-212(71.3),Poly(5) full syringe\Test1\full 345s v5.tif'; %name of file that needs to be analyzed(usually tif)
filename = 'C:\PURDUE\Year 5 (Graduate)\Research\Experiments\Bryan Segregation\TIF vids\5 wt% 3 to 1 sugar mix v4\full 0s v4.tif';
PartDiameter = 9; %Smallest diameter of larger particles in size of pixels
PartDiameter2 = 15; %Smallest diameter of largest particles in size of pixels
PartSize = (PartDiameter/2)^2*pi; %Smallest area of larger particles
PartSize2 = (PartDiameter2/2)^2*pi; %Smallest area of largest particles
multi=1;% 1 = yes, 2 = no Use if there are different size glass or sugar particles

tifInfo = imfinfo(filename); %These two functions obtain the number of photos found within the Tiff file
tifLength = numel(tifInfo); %Keeps track of how many files are in a multipage tif file

TotArea = 0;%Variable that keeps track of total area of particles(Sugar or Glass and Polymer)
BigArea = 0;%Variable that keep track of area of only large particles(Sugar or Glass beads)
BiggerArea = 0;%Variable that keep track of area of largest particles
area = 0;
PartAreas = table(area);

TotVol = 0;
BigVol =0;
BiggerVol = 0;


for i = 1:5:tifLength %Looks at every 5th frame/image
%for i = 1:5:20 % do 4 images
    imBase = imread(filename,i); %calls up file to be analyzed
    imGray = im2gray(imBase); %converts image to gray scale
    imBiner = imcomplement(imbinarize(imGray));%binarizes image
    %figure
    %imshowpair(imBase,imBiner,'montage')
    imCropped = imcrop(imBiner,[0 320 720 639]); %crops the binarized image to only show the bottom half of the image
    %figure
    %imshowpair(imBase,imCropped,'montage')
    % imshowpair(imread(filename,10),imread(filename,100),'montage')


    CC = bwconncomp(imCropped);%funciton that determines whether a particle is present
    NumParticles = CC.NumObjects;
    stats = regionprops('table',CC,'Area','Circularity','MinorAxisLength','Centroid','EquivDiameter');%calculates the area of each determined particle
    area = stats.Area;%places determined areas into a table
    circ = stats.Circularity;%determines the circularity of the particle
    minAxis = stats.MinorAxisLength;%determines the shortest diameter of a particle
    EDia = stats.EquivDiameter;
    
    % radii = minAxis/2;
    % center = stats.Centroid;
    tabArea = array2table(area);%converts the array that contains the areas into an 
    PartAreas = [PartAreas; tabArea];%adds the current areas to a table containing all areas
   
    for row = 1:length(area) %Calculates the total area of particles
        TotArea = TotArea + area(row);
        if area(row) > PartSize && circ(row) > 0.4 && minAxis(row) > (PartDiameter*0.9) %Criteria determines if particle is a polymer or glass or sugar
            TotVol = TotVol + (EDia(row)/2)^3*(4/3)*pi;%If is glass or sugar assumes it is a perfect sphere to calculate the volume
        else
            TotVol = TotVol + area(row)*5.65;%If it is a polymer assumes that the thickness is 5.65 pixels which the is the diameter of the polymer
        end
    end

    selection = (area > (PartSize) & circ > 0.4 & minAxis > (PartDiameter*0.9));%criteria for determining which particle it is
    imBigParticles = cc2bw(CC,ObjectsToKeep=selection);%rebinerizes image with new parameter
    %figure
    %imshowpair(imCropped,imBigParticles,'montage')
    selection2 = (area > (PartSize2) & circ > 0.5 & minAxis > (PartDiameter2*0.9));%second criteria if there are more than two particles present
    imBiggerParticles = cc2bw(CC,ObjectsToKeep=selection2);%Uses second criteria to further filterout particles

    %imagelist = {imcrop(imBase,[0 320 720 639]) imCropped imBigParticles imBiggerParticles};
    %montage(imagelist)
    
    %figure
    %imshow(imCropped)
    %hold on
    %viscircles(center,radii)
    % hold off

    CCBig = bwconncomp(imBigParticles);%Counts the number of particles that are bigger than a given size
    stats2 = regionprops('table',CCBig,'Area','EquivDiameter');
    area2 = stats2.Area;
    EDia2 = stats2.EquivDiameter;
    CCBig2 = bwconncomp(imBiggerParticles);%Counts the number of particles that are bigger than another given size
    stats3 = regionprops('table',CCBig2,'Area','EquivDiameter');
    area3 = stats3.Area;
    EDia3 = stats3.EquivDiameter;
     
    for row = 1:length(area2)%Calculates the total area of large particles
        BigArea = BigArea + area2(row);
        BigVol = BigVol + (EDia2(row)/2)^3*(4/3)*pi;%Can assume that all particles are either glass or sugar thus only perfect spheres are assumed
    end
    if multi == 1%Activates if there more than two different sizes for either glass or sugar
        for row =1:length(area3)
            BiggerArea = BiggerArea + area3(row);
            BiggerVol = BiggerVol + (EDia3(row)/2)^3*(4/3)*pi;%Can assume that only the largest particles are glass or sugar thus only perfect spheres are assumed.
        end
    end
    NumBigParticles = CCBig.NumObjects;
    NumSmlParticles = NumParticles - NumBigParticles;
    
end

PolyArea = TotArea - BigArea;%Calculates the total area occupied by the polymer
SmallPartArea = BigArea - BiggerArea; %Calculates either the whole area of sugar or glass(1 size) or area of the smaller size(2 sizes)
LargePartArea = BiggerArea;%Calculates the area of the largest sugar or glass particles only if there are 2 sizes, will be 0 if multi = 2
Distro = table2array(PartAreas);%Converts the table with all of the particle areas to an array to be used in a histogram

PercentPoly     = PolyArea/TotArea %Calculates the % area that the Polymer takes up
PercentSmall = SmallPartArea/TotArea %Calculates the % area the smaller glass or sugar particles take up
PercentLarge = LargePartArea/TotArea %Calculates the % area the larger glass or sugar particles take up

PartDistro = histogram(Distro,'Normalization','probability')%Creates the histogram of the probability for particle size
hold on
title('Particle Size Distribution')
xlabel('Particle Size')
ylabel('Proability of Particle Size')
hold off

PolyVol = TotVol - BigVol;%Calculates the volume of polymer particles
SmallPartVol = BigVol - BiggerVol; %Calculates the volume of the smaller sugar or glass particles
LargePartVol = BiggerVol; %Calculates the volume of the larger sugar or glass particles, will be zero if multi = 2

PercentPolyVol = PolyVol/TotVol%Calculates the % volume of polymer particles
PercentSmallVol = SmallPartVol/TotVol%Calculates the % volume of smaller glass or sugar particles
PercentLargeVol = LargePartVol/TotVol%Calculates the % volume of larger glass or sugar particles


toc