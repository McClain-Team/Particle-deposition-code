%% MassTimeNew.m
% Description: Reads time history data collected from the scale. Plots each
% of the 10 trials per material-voltage combination in a 3x5 grid.
% Author: Katie Hart
% Last Modified: 2025-09-29

% cycle through sets of ten trials for each material and voltage
% combination
figure
plotdata("FSL_19V_0911_",1,10,1)
plotdata("FSL_25V_0911_",1,10,6)
plotdata("FSL_31V_0911_",21,30,11)
plotdata("MSL_19V_0909_",1,10,3)
plotdata("MSL_25V_0909_",1,10,8)
plotdata("MSL_31V_0909_",1,10,13)
plotdata("CSL_19V_0911_",11,20,4)
plotdata("CSL_25V_0911_",21,30,9)
plotdata("CSL_31V_0911_",11,20,14)
plotdata("PA12_19V_0915_",1,10,2)
plotdata("PA12_25V_0915_",1,10,7)
plotdata("PA12_31V_0915_",21,30,12)
plotdata("S_19V_0918_",11,20,5)
plotdata("S_25V_0918_",21,30,10)
plotdata("S_31V_0918_",1,10,15)

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

% set x axes for each material
spFSL = [1 6 11];
tlim(spFSL,30)
spMSL = [3 8 13];
tlim(spMSL,75)
spCSL = [4 9 14];
tlim(spCSL,40)
spPA = [2 7 12];
tlim(spPA,200)
spS = [5 10 15];
tlim(spS,50)

% label y-axis and x-axis for the whole figure
subplot(3,5,6)
ylabel("Particle Mass (g)",'FontSize',24,'FontWeight','bold')
subplot(3,5,13)
xlabel("Time (s)",'FontSize',24,'FontWeight','bold')

function plotdata(filename,filestart,filefinish,plotnum)
    % Plots ten trials in a window within the figure.
    % Inputs: 
        % filename: basename of file, specifying the material, voltage, and
        % date
        % filestart: number of the first trial
        % filefinish: number of the last trial
        % plotnum: the window in which data should be plotted

    % set style features for current subplot
    subplot(3,5,plotnum)
    hold on
    yline(0.02,'k', LineWidth=1)
    ylim([0 0.025])
    ax = gca;
    set(get(ax,'XAxis'), 'FontWeight', 'bold');
    set(get(ax,'YAxis'), 'FontWeight', 'bold');

    for i = filestart:filefinish
        % read mass measurements from the output data file
        A = readtable(strcat(filename, num2str(i),".txt"));
        a = table2array(A(:,2));
        % set time vector based on the scale sampling rate of 250ms
        t = linspace(1,length(a), length(a));
        t = t.*0.250;
        % plot the mass deposition versus time
        plot(t,a); 
    end

end

function tlim(sp,tmax)
    % Sets the limits for the x-axis of the plot.
    % Inputs: 
        % sp: subplot number
        % tmax: largest time value to include on plot
    
    % cycles through each subplot and assigns x-axis limits
    for i = 1:length(sp)
        subplot(3,5,sp(i))
        xlim([0 tmax])
    end
end