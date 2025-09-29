% %fmts = VideoReader.getFileFormats()
%
%     % convert file to tiff stack first!
%     % binarize
%     % look at "intensity" plots
%
%     t = Tiff("C:\PURDUE\Year 5 (Graduate)\Research\hi-speed video\IPS Video\Voltage Ramp Effects\Set 1\T1_3_1V_short.tif");
%     %%
%     bwims = zeros(200,200,4);
%     joinims = zeros(200,200,4);
%
%     for pic = (1:4) % need to be # of frames in tiff... cant easily pull?
%
%         imdata = read(t);
%         reducedim = (imdata(300:499,1000:1199,:));
%
%         grey = im2gray(reducedim);
%         bwims(:,:,pic) = imbinarize(grey);
%     end
%     imshowpair(bwims(:,:,1),bwims(:,:,4))
%     %imshowpair(reducedim, grey, 'montage')
%     %figure
%     %imshowpair(grey,bw,'montage')
%% only this section has actual code
% updates: automate processing for a series of tests, ~30s per clip it
% seems... unfortunately binary out not supported with video formats so
% filesize is an issue... (output straight to harddrive?)

tic
warning('off','imageio:tiffmexutils:libtiffWarning'); % prevent Tiff metadata error from spamming terminal

% select which images to output
bwimout = 1;
heatmapimout = 1;
%%
basepath = "C:\PURDUE\Year 5 (Graduate)\Research\hi-speed video\IPS Video\Voltage Ramp Effects\Set ";
sets = string(1:11);
conds = ["1_9V","3_1V"];

baseout = "C:\PURDUE\Year 5 (Graduate)\Research\Experiments\High Speed Camera\IPS Cone Flow Image Processing\Bulk test\S";


for s = 1:length(sets)
    for c = 1:length(conds)
        loopind = (s-1)*length(conds) + c;
        fullpath(loopind) = basepath + sets(s) + "\T" + sets(s)+"_" + conds(c) +".tif";
        outputname(loopind) = baseout + sets(s) +"-"+ conds(c);
    end
end



%%
% outputname = "Set1-3_1V-Heat";
% filename = "T1_3_1V.tif";
%
%    outputname = "Set1-1_9V-new";
%    filename = "T1_1_9V.tif";
%
% filepath = "C:\PURDUE\Year 5 (Graduate)\Research\hi-speed video\IPS Video\Voltage Ramp Effects\Set 1\";
%
% fullpath = filepath + filename;

% set up a script to create a bunch of images. Seems like ~12s per test
% processed. maybe print to terminal when each test is done?

for i = 1:length(fullpath)
    
    ts = Tiff(fullpath(i)); % tiff stack object
    noFrames = length(imfinfo(fullpath(i)));
    
    xres = 720;
    yres = 1280;
    % xres = 200; % used for testing, uncomment
    % yres = 200;
    
    
    stopFlag = 0; % logic value
    targetFrame = noFrames - 1; % what frame to stop after (50 = end of short)
    % targetFrame = 6; % debug
    bwim = zeros(xres,yres);
    totalim = zeros(xres,yres);
    
    ind = 1;
    while (~stopFlag) % run until reaching a preset frame #
        imdata = read(ts);
        %imdata = imdata(300:499,1000:1199,:); % reduce for easier testing
        gray = imcomplement(im2gray(imdata)); % invert image, particles white for better adding...
        
        % filter background of gray to be black
        grayf = gray;
        grayf(gray<=64) = 0;
        totalim = totalim+double(grayf);
        
        bwim = bwim | imbinarize(gray); % "add" frame into BW envelope
        
%         % generate basic images
%         imwrite(bwim, outputname(i)+"-binary-frame.png")
%         imwrite(imdata, outputname(i)+"-color-frame.png")
%         break
        
        % debug
        %     figure
        %     imshow(bwim)
        
        
        stopFlag = (currentDirectory(ts) == targetFrame); % check if we're on last frame of interest
        nextDirectory(ts) % gives error if going out of range, doesn't end code and close then...
        ind = ind+1; % update for next loop
    end
    close(ts)
    %%
    %totalim = totalimgsafe; % "backup" to prevent rerunning prev section since I overwrite img
    
    
    % total img = doubles...
    scalefac = max(max(totalim(:,900:1000))); % identify max in non-saturated area to scale to full brightness
    totalim = totalim / (scalefac/230); % 230 to give +25 upshift room
    
    % logical indexing to filter tracks to max/min brightnesses)
    totalim(totalim>230) = 230;
    %totalimg(totalimg>0 & totalimg<30) = 30; % min track brightness = 26 (10%... maybe work on scale adjustment instead of floor)..
    
    totalim = totalim + 25; % shift brightness up
    totalim(totalim==25) = 0; % reset background values to be zero (black)
    totalim = round(totalim); % convert to integers
    totalim = uint8(totalim);
    
    if heatmapimout
        imwrite(totalim, outputname(i)+"-H.png"); % png or tiff for binary image out
    end
    
    if bwimout
        imwrite(bwim, outputname(i)+"-BW.png");
    end
    
    note = "loop " + i + " done"
end

% figure
% imshow(totalimg)


% Could filter below values that represent basically a single particle or
% some threshold percentage to represent a 99% cone angle...

%%

%   v = VideoWriter(outputname,'Grayscale AVI');
%   v.FrameRate = 32;
%   open(v)
%
%   % add frames to the video file
%   for frame = 1:length(joinims(1,1,:))
%       writeVideo(v,joinims(:,:,frame))
%   end
%   close(v)
%
% save the final "envelope"
%imwrite(totalimg, outputname+".png"); % png or tiff for binary image out

toc


%% Ideas to improve from binary v1
% do grayscale "heatmap" tracing how much/how little areas within the
% envelope see.
% have a min floor above the background (i.e. 10%) for visible contrast
% of faint areas
% add grayscale values and then uniformly scale image down based on max
% value within certain coords to ignore the nozzle tip
% could try and scale continuously to create "rolling" animation again,
% or just sum across all frames and then scale once at the end.
% scaling: max becomes 255, then everything else get multiplied to fit
% between that and the floor...

% start with image output
% then adapt video to continuous heatmap...

% problem: background isn't full black/white, test alg to start, then
% adjust/filter (if pixel < value, set to 0 --> low 60s is proper cutoff
% for inverted grayscale)
% stuck particles on lens also create issues...


%% above didn't work, alt method using imread("path", frame_index)...

% CORRECTION: it didn't work bc I wasn't referencing the new frame data.
% that method throws an error every frame tho, so maybe clean up later.
% use it for now at least.

% if frame_index is beyond last frame of video, get below error:
% "Error using imread (line 440)
% TIFF library error - 'TIFFAdvanceDirectory:  Error fetching directory
% count.'"
% helpful example: https://www.mathworks.com/matlabcentral/answers/105739-how-to-show-tiff-stacks



%
%   trgFrm = 5;
%   bwims = zeros(200,200,trgFrm);
%   joinims = zeros(200,200,trgFrm);
%
%   for frm = 2:trgFrm
%
%   end

