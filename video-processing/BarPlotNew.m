%% BarPlotNew.m
% Description: Finds the measurement of the total mass deposited in a trial
% from the time history data collected from the scale. For each
% material-voltage combination, the average mass deposited is found and
% displayed in a bar graph with error bars showing the highest and lowest
% values.
% Author: Katie Hart
% Last Modified: 2025-09-29


% calculate the average, lowest deviation, and highest deviation of mass
% deposited for each material-voltage combination
[mFSLlow leFSLlow heFSLlow] = barvals("FSL_19V_0911_",1,10,48);
[mFSLmed leFSLmed heFSLmed]= barvals("FSL_25V_0911_",1,10,48);
[mFSLhigh leFSLhigh heFSLhigh] = barvals("FSL_31V_0911_",21,30,48);
[mMSLlow leMSLlow heMSLlow] = barvals("MSL_19V_0909_",1,10,64);
[mMSLmed leMSLmed heMSLmed] = barvals("MSL_25V_0909_",1,10,64);
[mMSLhigh leMSLhigh heMSLhigh] = barvals("MSL_31V_0909_",1,10,64);
[mCSLlow leCSLlow heCSLlow] = barvals("CSL_19V_0911_",11,20,30);
[mCSLmed leCSLmed heCSLmed] = barvals("CSL_25V_0911_",21,30,30);
[mCSLhigh leCSLhigh heCSLhigh] = barvals("CSL_31V_0911_",11,20,30);
[mPAlow lePAlow hePAlow] = barvals("PA12_19V_0915_",1,10,190);
[mPAmed lePAmed hePAmed] = barvals("PA12_25V_0915_",1,10,190);
[mPAhigh lePAhigh hePAhigh] = barvals("PA12_31V_0915_",21,30,190);
[mSlow leSlow heSlow] = barvals("S_19V_0918_",11,20,40);
[mSmed leSmed heSmed] = barvals("S_25V_0918_",21,30,40);
[mShigh leShigh heShigh] = barvals("S_31V_0918_",1,10,40);

% compile all average values
barmean = [mFSLlow mPAlow mMSLlow mCSLlow mSlow;
           mFSLmed mPAmed mMSLmed mCSLmed mSmed;
           mFSLhigh mPAhigh mMSLhigh mCSLhigh mShigh];

% compile all lowest deviations
devlow = [leFSLlow lePAlow leMSLlow leCSLlow leSlow;
           leFSLmed lePAmed leMSLmed leCSLmed leSmed;
           leFSLhigh lePAhigh leMSLhigh leCSLhigh leShigh];

% compile all highest deviations
devhigh = [heFSLlow hePAlow heMSLlow heCSLlow heSlow;
           heFSLmed hePAmed heMSLmed heCSLmed heSmed;
           heFSLhigh hePAhigh heMSLhigh heCSLhigh heShigh];

% create bar graph to display mass deposited for each material-voltage
% combination
figure
hold on
% set style features
ax = gca;
ax.XAxis.FontSize = 30;
ax.YAxis.FontSize = 16;
xticks([]);
ylim([0 0.028])

% produce bar graph
x = categorical({'1.9'; '2.5'; '3.1'});
hBar = bar(x, barmean); 

% style features for each material
hBar(5).FaceColor = hex2rgb("#f7514b");
hBar(4).FaceColor = hex2rgb("#ff8f1f");
hBar(3).FaceColor = hex2rgb("#76ff34");
hBar(1).FaceColor = hex2rgb("#00bcd4");
hBar(2).FaceColor = hex2rgb("#935aab");
% label axes and plot target mass line
ylabel("Mass Deposited (g)","FontSize",30)
xlabel("Motor Voltage (V)","FontSize",30)
yline(0.02,'LineWidth',1)

% plot error bars with one tail showing the lowest mass deposited and the
% other showing the greatest mass deposited
[numGroups, numBars] = size(barmean);
xBar = nan(numGroups,numBars);
for k = 1:numBars
    xBar(:,k) = hBar(k).XEndPoints;
end

for k = 1:numGroups
    for i = 1:numBars
        errorbar(xBar(k,i),barmean(k,i),devlow(k,i),devhigh(k,i),'k','linestyle','none','LineWidth',2)
    end
end

% include legend for materials
lgd = legend('Fine SL','PA12','Medium SL','Coarse SL','Sugar');
fontsize(lgd,18,'points')

function [avg, errlow, errhigh] = barvals(filename,filestart,filefinish,tcheck)
    % Calculate the average, lowest deviation, and highest deviation of
    % mass deposited for a set of ten trials.
    % Inputs: 
        % filename: basename of file, specifying the material, voltage, and
        % date
        % filestart: number of the first trial
        % filefinish: number of the last trial
        % tcheck: Time at which to take the reading from the output of the
        % scale. Determined visually by using the plots from MassTimeNew.m
    % Outputs: 
        % avg: the average of ten trials for a material-voltage combination
        % errlow: the difference between the average and lowest value of
        % mass deposited
        % errhigh: the difference between the highest value and average of
        % mass deposited
    
    % initialize vector to hold mass deposited readings for each trial
    mdep = zeros(1,10);
    pt = tcheck/0.25; % convert tcheck to the index of where to read the file based on scale sample rate
    k = 1; % start trial count
    for i = filestart:filefinish
        % read mass measurements from the output data file
        A = readtable(strcat(filename, num2str(i),".txt"));
        a = table2array(A(:,2));
        % pull the mass measurement at the desired point
        mdep(k) = a(pt,1);
        k = k+1; % move to next trial
    end
    avg = mean(mdep); % find average of trials
    errlow = avg-min(mdep); % find lowest deviation
    errhigh = max(mdep)-avg; % find greatest deviation
end