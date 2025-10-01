%% RateCheckGraphs.m
% Description: Plots the time history of mass deposition and the line of
% best fit for a linear region of the data. Calculates the R^2 value for
% each subplot.
% Author: Katie Hart
% Last Modified: 2025-09-29

% cycle through sets of ten trials for each material and voltage
% combination
figure
plotrate("FSL_19V_0911_",1,10,1,12,22,30)
plotrate("FSL_25V_0911_",1,10,6,12,22,30)
plotrate("FSL_31V_0911_",21,30,11,12,22,30)
plotrate("MSL_19V_0909_",1,10,3,20,40,75)
plotrate("MSL_25V_0909_",1,10,8,20,40,75)
plotrate("MSL_31V_0909_",1,10,13,20,40,75)
plotrate("CSL_19V_0911_",11,20,4,11,18,40)
plotrate("CSL_25V_0911_",21,30,9,11,18,40)
plotrate("CSL_31V_0911_",11,20,14,11,18,40)
plotrate("PA12_19V_0915_",1,10,2,50,125,200)
plotrate("PA12_25V_0915_",1,10,7,50,125,200)
plotrate("PA12_31V_0915_",21,30,12,50,125,200)
plotrate("S_19V_0918_",11,20,5,12,24,50)
plotrate("S_25V_0918_",21,30,10,12,24,50)
plotrate("S_31V_0918_",1,10,15,12,24,50)

% label columns of plots for each material
subplot(3,5,1)
title("Fine SL", 'FontSize',20)
subplot(3,5,2)
title("PA12", 'FontSize',20)
subplot(3,5,3)
title("Medium SL", 'FontSize',20)
subplot(3,5,4)
title("Coarse SL", 'FontSize',20)
subplot(3,5,5)
title("Sugar", 'FontSize',20)

% label y-axis and x-axis for the whole figure
subplot(3,5,6)
ylabel("Particle Mass (g)",'FontSize',24,'FontWeight','bold')
subplot(3,5,13)
xlabel("Time (s)",'FontSize',24,'FontWeight','bold')

function plotrate(filename,filestart,filefinish,plotnum,ts,te,tlim)
    % Plots the time history data of mass deposition, highlights the data
    % in the defined linear region, and plots the line of best fit with R^2
    % value. 
    % Inputs: 
        % filename: basename of file, specifying the material, voltage, and
        % date
        % filestart: number of the first trial
        % filefinish: number of the last trial
        % plotnum: the window in which data should be plotted
        % ts: start time of linear region, determined visually by using the
        % plots from MassTimeNew.m
        % te: end time of linear region, determined visually by using the
        % plots from MassTimeNew.m
        % tlim: largest time value to include on plot

    % set style features for given subplot
    subplot(3,5,plotnum)
    hold on
    ylim([0 0.025])
    xlim([0 tlim])

    % initializes vectors used for linear regression
    regx = linspace(ts,te,(te-ts)/0.25+1);
    regx = transpose(repmat(regx,10,1));
    regy = zeros((te-ts)/0.25+1,10);
    k = 1; % start trial count
    for i = filestart:filefinish
        % read mass measurements from the output data file
        A = readtable(strcat(filename, num2str(i),".txt"));
        a = table2array(A(:,2));
        t = linspace(1,length(a), length(a));
        % set time vector based on the scale sampling rate of 250ms
        t = t.*0.250;
        % plot the mass deposition versus time in black
        plot(t,a,'k');
        regy(:,k) = a(ts/0.25:te/0.25); % store mass deposition measurement in the linear region
        k = k+1; % move to next trial
    end

    % plot the data used to calculate the linear regression in blue
    subplot(3,5,plotnum)
    plot(regx,regy,'b')

    % calculate coefficients for linear regression and plot line in red
    coeff = polyfit(regx,regy,1);
    regfit = polyval(coeff,regx);
    plot(regx,regfit,'r','LineWidth',2)

    % calculate and display the R^2 value
    SStot = sum((regy-mean(regy)).^2);
    SSres = sum((regy - regfit).^2);
    Rsq = 1 - (SSres / SStot);
    text(1, 0.023, strcat("R^2: ",num2str(Rsq)),'FontSize',15);
end