% BRYAN SEGREGATION ANALYSIS REIMPLIMENTATION/AUTOMATION
% he manually ran each video, copied mtl fractions into excel and plotted
% there. This fnc compiles the results automatically after running the
% segregation calc fnc on each clip.

clear; clc
%close all
tic
% suppress TIF warnings...


%% Set up video list to run thru
% choose which folder to run
folderpath = 'C:\PURDUE\Year 5 (Graduate)\Research\Experiments\Bryan Segregation\TIF vids\5 wt% 3 to 1 sugar mix v1';
%folderpath = 'C:\PURDUE\Year 5 (Graduate)\Research\Experiments\Bryan Segregation\TIF vids\5 wt% 3 to 1 sugar mix v2';
%folderpath = 'C:\PURDUE\Year 5 (Graduate)\Research\Experiments\Bryan Segregation\TIF vids\5 wt% 3 to 1 sugar mix v3';
%folderpath = 'C:\PURDUE\Year 5 (Graduate)\Research\Experiments\Bryan Segregation\TIF vids\5 wt% 3 to 1 sugar mix v4';
filename = '*.tif';
filepattern = fullfile(folderpath, filename);
filelist = dir(filepattern); % list order doesn't smart-sort times from title, i.e. 135s before 15s. Need to re-sort
no_tests = length(filelist);

% extract times from filenames
timelist = zeros(no_tests,1);
for row = 1:no_tests
    name = filelist(row).name;
    sInd = strfind(name, 's');
    spaceInd = strfind(name,' ');
    timelist(row) = str2double(name(spaceInd(1)+1:sInd-1)) ;
end
%%
% re-sort filelist to accurately reflect time in titles
filetable = struct2table(filelist);
filetable.("time") = timelist;
sortedtable = sortrows(filetable,"time");
sortedfilelist = table2struct(sortedtable);

% create var to track fnc outputs of each loop iteration
mtlFractions = zeros(no_tests,5); % [PA, other, PA% w/o comp, PAVolFrac,PAMassFrac] per fnc output
bad = zeros(no_tests,1);


%% process videos and create structure of results
for i = 1:no_tests
    baseFileName = sortedfilelist(i).name;
    fullFileName = fullfile(sortedfilelist(i).folder, baseFileName); % More robust than calling folderPath from above, but data is clean so it wouldnt matter here
    [a, b, c, d, e, bad(i)] = mixSegregationPA(fullFileName);
    mtlFractions(i,:) = [a, b, c, d, e]; % shouldnt be necessary to do this, but idk how to do it right
end


%% plot results vs time
% for now, assume each vid is 15 sec after previous
% could look at other styles of plot (shade fraction above/below a line
% instead of two separate lines since they are complimentary?)

%testtimes = 0:15:(no_tests*15-1); % x variable for plotting, could pull from file names, but data sets are "clean"
testtimes = sort(timelist); % could alternatively extract from sortedfilelist structure?

figure
plot(testtimes, mtlFractions(:,1)*100,'--xb','DisplayName','PA12')
hold on
plot(testtimes, mtlFractions(:,2)*100,'--xg','DisplayName','Sugar')
xlabel('Dispensing time (s)')
ylabel('Mix Percentage')
title('Compensated Segregation Analysis:\newline(number basis fraction)')
ylim([0 100])
legend('Location','best')

figure % plot non-compensated version for comparison
plot(testtimes, mtlFractions(:,3)*100,'--xr','DisplayName','No Compensation')
hold on
plot(testtimes, mtlFractions(:,1)*100,'--xb','DisplayName','Double Count Compensation')
xlabel('Dispensing time (s)')
ylabel('Mix Percentage')
title('Segregation Compensation Analysis:\newlinePA12 fraction below, Sugar fraction above lines')
ylim([0 100])
legend('Location','best')

figure % plot non-compensated version for comparison
plot(testtimes, mtlFractions(:,1)*100,'--xb','DisplayName','Number Frac')
hold on
plot(testtimes, mtlFractions(:,4)*100,'--xr','DisplayName','Vol Frac')
plot(testtimes, mtlFractions(:,5)*100,'--xg','DisplayName','Mass Frac')
xlabel('Dispensing time (s)')
ylabel('Mix Percentage')
title('Compensated Number vs Volume vs Mass fractions:\newlinePA12 fraction below, Sugar fraction above lines')
ylim([0 100])
legend('Location','best')

%% final pretty plot:
% shade above and below line
% add nominal mixture percentage
% also calc average

figure % plot non-compensated version for comparison
hold on
fill([testtimes' testtimes(end) 0],[mtlFractions(:,5)'*100 100 100],[.5 1 .5]) % sugar, upper fill
fill([testtimes' testtimes(end) 0],[mtlFractions(:,5)'*100 0 0],[.5 .5 1]) % PA, lower fill, rgb
yline(5,':k','LineWidth',1.4)
yline(mean(mtlFractions(:,5)*100),'--k')
plot(testtimes, mtlFractions(:,5)*100,'-k','DisplayName','Wt %')
xlabel('Dispensing time (s)')
ylabel('Weight Percentage')
xlim([0 testtimes(end)])
ylim([0 100]) 
massAvg = mean(mtlFractions(:,5)*100);
massDev = std(mtlFractions(:,5)*100);
legend('Sugar','PA12','Nominal wt%', "Average wt% = " + sprintf('%0.2f',massAvg) + "\newline\sigma = " + sprintf('%0.2f',massDev))


deviation = std(mtlFractions(:,5));

% Plot how much is filtered over time --> could overlay onto other plot?
figure
plot(testtimes, bad*100)
xlabel('Time (s)')
ylabel('Percent filtered')
title("Corresponding test: "+folderpath(end-1:end))

%% Overlay plot
figure % plot non-compensated version for comparison
hold on
fill([testtimes' testtimes(end) 0],[mtlFractions(:,5)'*100 100 100],[.5 1 .5]) % sugar, upper fill
fill([testtimes' testtimes(end) 0],[mtlFractions(:,5)'*100 0 0],[.5 .5 1]) % PA, lower fill, rgb
yline(5,':k','LineWidth',1.4)
yline(mean(mtlFractions(:,5)*100),'--k')
yyaxis left
plot(testtimes, mtlFractions(:,5)*100,'-k','DisplayName','Wt %')
xlabel('Dispensing time (s)')
ylabel('Weight Percentage')
xlim([0 testtimes(end)])
ylim([0 15]) 
massAvg = mean(mtlFractions(:,5)*100);
massDev = std(mtlFractions(:,5)*100);

yyaxis right
plot(testtimes, bad*100,'rx--')
ylabel('Percent filtered')
ylim([0 20])

legend('Sugar','PA12','Nominal wt%', "Average wt% = " + sprintf('%0.2f',massAvg) + "\newline\sigma = " + sprintf('%0.2f',massDev),'?','Filtered num%')

% ADD PLOT SHOWING NOMINAL MASS/VOL %'s?? (should avg out around it, not
% aligning there indicates detection issues (PA sticking to sugar or
% clumping with itself)

% could plot on 0-20% to better show variance... (plotbreak above to show
% up to 1?)

toc