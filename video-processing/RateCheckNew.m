%% RateCheckNew.m
% Description: Calculates the line of best fit for a linear region of data
% for each trial. For each material-voltage combination, the average slope
% of the linear regression is found and is displayed in a bar graph with
% error bars showing the highest and lowest slope values.
% Author: Katie Hart
% Last Modified: 2025-09-29

% calculate the average, lowest deviaiton, and highest deviaition of slope
% of the linear regression for Fine SL at all voltages
[FSLlowa, FSLlowh, FSLlowl] = findslope(12,22,"FSL_19V_0911_",1,10);
[FSLmeda, FSLmedh, FSLmedl] = findslope(12,22,"FSL_25V_0911_",1,10);
[FSLhigha, FSLhighh, FSLhighl] = findslope(12,22,"FSL_31V_0911_",21,30);

% calculate the average, lowest deviaiton, and highest deviaition of slope
% of the linear regression for Medium SL at all voltages
[MSLlowa, MSLlowh, MSLlowl] = findslope(20,40,"MSL_19V_0909_",1,10);
[MSLmeda, MSLmedh, MSLmedl] = findslope(20,40,"MSL_25V_0909_",1,10);
[MSLhigha, MSLhighh, MSLhighl] = findslope(20,40,"MSL_31V_0909_",1,10);

% calculate the average, lowest deviaiton, and highest deviaition of slope
% of the linear regression for Coarse SL at all voltages
[CSLlowa, CSLlowh, CSLlowl] = findslope(11,18,"CSL_19V_0911_",11,20);
[CSLmeda, CSLmedh, CSLmedl] = findslope(11,18,"CSL_25V_0911_",21,30);
[CSLhigha, CSLhighh, CSLhighl] = findslope(11,18,"CSL_31V_0911_",11,20);

% calculate the average, lowest deviaiton, and highest deviaition of slope
% of the linear regression for PA12 at all voltages
[PAlowa, PAlowh, PAlowl] = findslope(50,125,"PA12_19V_0915_",1,10);
[PAmeda, PAmedh, PAmedl] = findslope(50,125,"PA12_25V_0915_",1,10);
[PAhigha, PAhighh, PAhighl] = findslope(50,125,"PA12_31V_0915_",21,30);

% calculate the average, lowest deviaiton, and highest deviaition of slope
% of the linear regression for Sugar at all voltages
[Slowa, Slowh, Slowl] = findslope(12,24,"S_19V_0918_",11,20);
[Smeda, Smedh, Smedl] = findslope(12,24,"S_25V_0918_",21,30);
[Shigha, Shighh, Shighl] = findslope(12,24,"S_31V_0918_",1,10);

% compile all average values
barmean = [FSLlowa PAlowa MSLlowa CSLlowa Slowa;
           FSLmeda PAmeda MSLmeda CSLmeda Smeda;
           FSLhigha PAhigha MSLhigha CSLhigha Shigha];

% compile all lowest deviations
devlow = [FSLlowl PAlowl MSLlowl CSLlowl Slowl;
          FSLmedl PAmedl MSLmedl CSLmedl Smedl;
          FSLhighl PAhighl MSLhighl CSLhighl Shighl];

% compile all highest deviations
devhigh = [FSLlowh PAlowh MSLlowh CSLlowh Slowh;
           FSLmedh PAmedh MSLmedh CSLmedh Smedh;
           FSLhighh PAhighh MSLhighh CSLhighh Shighh];

% convert from g/s to mg/s
barmean = barmean.*1000;
devlow = devlow.*1000;
devhigh = devhigh.*1000;

% create bar graph to display slope of linear regression for each
% material-voltage combination
figure
hold on
% set style features
ax = gca;
ax.XAxis.FontSize = 30;
ax.YAxis.FontSize = 16;
xticks([]);

%produce bar graph
x = categorical({'1.9'; '2.5'; '3.1'});
hBar = bar(x, barmean);

% style features for each material
hBar(5).FaceColor = hex2rgb("#f7514b");
hBar(4).FaceColor = hex2rgb("#ff8f1f");
hBar(3).FaceColor = hex2rgb("#76ff34");
hBar(1).FaceColor = hex2rgb("#00bcd4");
hBar(2).FaceColor = hex2rgb("#935aab");
% label axes
ylabel("Linear Approximation of Mass Flow Rate (mg/s)","FontSize",30)
xlabel("Motor Voltage (V)","FontSize",30)

% plot error bars with one tail showing the lowest slope and the other
% showing the greatest slope
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

function [slopesavg, slopesdevh, slopesdevl] = findslope(ts,te,filename,filestart,filefinish)
    % Calculate the average, lowest deviation, and highest deviation of
    % slope of linear regression for a set of ten trials.
    % Inputs: 
        % ts: start time of linear region, determined visually by using the
        % plots from MassTimeNew.m
        % te: end time of linear region, determined visually by using the
        % plots from MassTimeNew.m
        % filename: basename of file, specifying the material, voltage, and
        % date
        % filestart: number of the first trial
        % filefinish: number of the last trial
    % Outputs: 
        % slopesavg: the average of ten trials for a material-voltage combination
        % slopesdevh: the difference between the largest slope and average
        % slope for a set of trials
        % slopesdevl: the difference between the average slope and lowest
        % slope for a set of trials
    
    % initialize vectors used to store slopes
    slopes = zeros(1,10);
    x = linspace(ts,te,(te-ts)/0.25+1);
    k = 1; % start trial count
    for i = filestart:filefinish
        % read mass measurements from the output data file
        A = readtable(strcat(filename,num2str(i),".txt"));
        a = table2array(A(:,2));
        % extract data contributing to linear regression
        y = a(ts/0.25:te/0.25);
        % calculate coefficients for linear regression and store in slopes
        % vector
        coeff = polyfit(x,y,1);
        slopes(k) = coeff(1);
        k = k+1; % move to next trial
    end
    slopesavg = mean(slopes); % find average of trials
    slopesdevh = max(slopes)-slopesavg; % find lowest deviation
    slopesdevl = slopesavg - min(slopes); % find greatest deviation
end