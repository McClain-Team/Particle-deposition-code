%% only this section has actual code
% updates: automate processing for a series of tests, ~30s per clip it
% seems... unfortunately binary out not supported with video formats so
% filesize is an issue... (output straight to harddrive?)

tic
close all
clear
%clc
warning('off','imageio:tiffmexutils:libtiffWarning'); % prevent Tiff metadata error from spamming terminal
warning('off'); % prevent extra 2 warning/trial from spamming terminal


% basepath = "C:\PURDUE\Year 5 (Graduate)\Research\hi-speed video\IPS Video\Voltage Ramp Effects\Set ";
basepath = "D:\Non-Backup Files\Large Research Files\High Speed Video\IPS Videos\Voltage Ramp Effects\Set ";
sets = string(1:11);
conds = ["1_3V","1_6V","1_9V","2_2V","2_5V","2_8V","3_1V","3_4V"];
% sets = string(1:7); % need to run special segments for tests not in every set (start with them to verify code)
% conds = "1_0V";
% sets = "12";
% conds = ["1_9V","3_1V"];

        
for s = 1:length(sets)
    for c = 1:length(conds)
        loopind = (s-1)*length(conds) + c;
        fullpath(loopind) = basepath + sets(s) + "\tiffs\T" + sets(s)+"_" + conds(c) +".tif";
        %outputname(loopind) = baseout + sets(s) +"-"+ conds(c);
    end
end




framecttable = string(zeros(length(fullpath),2));

for i = 1:length(fullpath)
    
    ts = Tiff(fullpath(i)); % tiff stack object
    noFrames = length(imfinfo(fullpath(i)));
    
    framecttable(i,1) = fullpath(i);
    framecttable(i,2) = noFrames;
    
    note = "loop " + i + " done"
end

toc % runtime was ~5 min for 88 files... slow just to open ig