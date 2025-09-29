
% This script was the first attempt for analyzing high speed video. The
% envelope development can be output as a video, but it is ultimately less
% useful than the two components of the original video and the final image.



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


savevideo = false; % change to true or 1 if video file is desired.

outputname = "Set1-3_1V";
filename = "T1_3_1V.tif";

outputname = "Set1-1_9V";
filename = "T1_1_9V.tif";

filepath = "C:\PURDUE\Year 5 (Graduate)\Research\hi-speed video\IPS Video\Voltage Ramp Effects\Set 1\";

fullpath = filepath + filename;
ts = Tiff(fullpath);
noFrames = length(imfinfo(fullpath));

xres = 720;
yres = 1280;
% xres = 200; % used for testing, uncomment
% yres = 200;


stopFlag = 0; % logic value
targetFrame = noFrames - 1; % what frame to stop after (50 = end of short)
bwims = zeros(xres,yres,targetFrame);
joinims = zeros(xres,yres,targetFrame);

ind = 1;
while (~stopFlag) % run until reaching a preset frame #
    imdata = read(ts);
    %imdata = imdata(300:499,1000:1199,:); % reduce for easier testing
    gray = im2gray(imdata);
    bwims(:,:,ind) = ~imbinarize(gray); % "~" inverts image
    if ind>1
        joinims(:,:,ind) = joinims(:,:,ind-1) | bwims(:,:,ind); % | = logic OR, "adds" white of binary images together
    else
        joinims(:,:,ind) = bwims(:,:,ind); % first frame is same, no adding (no prev frame to OR)
    end
    
    stopFlag = (currentDirectory(ts) == targetFrame); % check if we're on last frame of interest
    nextDirectory(ts) % gives error if going out of range, doesn't end code and close then...
    ind = ind+1; % update for next loop
end
close(ts)

if savevideo
    v = VideoWriter(outputname,'Grayscale AVI');
    v.FrameRate = 32;
    open(v)
    
    % add frames to the video file
    for frame = 1:length(joinims(1,1,:))
        writeVideo(v,joinims(:,:,frame))
    end
    close(v)
end
% save the final "envelope"
imwrite(joinims(:,:,end), outputname+".png"); % png or tiff for binary image out

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

