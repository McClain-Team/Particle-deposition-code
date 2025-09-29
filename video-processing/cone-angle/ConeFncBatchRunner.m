close all; clc; clear
tic

filenames = ["S1-*-H.png", "S6-*-H.png","S7-*-H.png","S8-*-H.png"...
    "S9-*-H.png","S11-*-H.png","S10-*-H.png","S12-*-H.png"];
outplottitles = ["Coarse SL Tapered 20Ga", "Coarse SL Blunt-end 20Ga"...
    "Sugar Tapered 20Ga","Sugar Blunt-end 20Ga"...
    "Med Sm SL Tapered 25Ga","PA12 Tapered 22Ga",...
    "Fine SL Tapered 20Ga","Fine SL Tapered 25Ga"];

% SUBSET for material based plot
filenames = ["S1-*-H.png","S7-*-H.png","S9-*-H.png","S11-*-H.png","S10-*-H.png"];
outplottitles = ["Coarse SL","Sugar","Medium SL","PA12","Fine SL"];

% % SUBESET for nozzle type
filenames = ["S1-*-H.png", "S6-*-H.png","S7-*-H.png","S8-*-H.png"];
outplottitles = ["Coarse SL PP 20Ga", "Coarse SL SS 20Ga"...
    "Sugar PP 20Ga","Sugar SS 20Ga"];
% fig update
filenames = ["S1-*-H.png", "S7-*-H.png","S11-*-H.png"];
outplottitles = ["Coarse SL 20 Ga", "Sugar 20 Ga","PA12 22 Ga"];


% % SUBSET for nozzle size (useless bc 12 is 2 voltage set)
% filenames = ["S10-*-H.png","S12-*-H.png"];
% outplottitles = ["Fine SL Tapered 20Ga","Fine SL Tapered 25Ga"];

% % SUBSET for vibration stand dynamics (latter 3 sets don't process well)
% filenames = ["S1-*-H.png", "S2-*-H.png","S3-*-H.png","S4-*-H.png"...
%     "S5-*-H.png"];
% outplottitles = ["Default", "Arm extended"...
%     "Motor parallel to stand arm","Motor normal to syringe"...
%     "Motor vertical"];


% filenames = ["S9-*-H.png"]; % errors out
% outplottitles = ["Med SL Tapered 25Ga"];
% 
% filenames = ["S1-*-H.png"]; % errors out too now??
% outplottitles = ["Coarse SL Tapered 20Ga"];

figure(1)
hold on
xlabel('Voltage')
ylabel('Cone angle (^o)')
%legend(names,Location,'best')
for i = 1:length(filenames)
    %try
        ConeAnglePlotterFnc(filenames(i),outplottitles(i)+" Cone Angle Variance",1)
    %catch
     %   error = filenames(i)+" errored out, moving to next set"% run the fnc once for each material and plot results
    %end
end

figure(1)
legend(outplottitles,'location','best')

toc
% set 8 erroring out. needs deeper investigation
% data for other sets overall really sloppy, just use and discuss one good
% set in journal paper anyway (coarse SL or sugar)