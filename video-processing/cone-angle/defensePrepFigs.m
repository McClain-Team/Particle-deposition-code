% Defense fig aids

%% threshold map legend
plotcolors = ["#f31a1a" "#ff8f20" "#FFD133" "#75FF33" "#01BCD4" "#7B1FA2"]; %rainbow

figure
hold on
for i = 1:length(plotcolors)
    plot([0 1], [0 1], 'LineWidth',3,'Color',plotcolors(i))
end
legend("All","> 10%","> 20%","> 30%","> 40%","> 50%")

%% Segregation identification legend (rest of code in matlab 2024)
plotcolors = ["#ff0000" "#00ff00" "#0000ff" "#000000"]; %rainbow

figure
hold on
for i = 1:length(plotcolors)
    plot([0 1], [0 1], '.','MarkerSize',20,'Color',plotcolors(i))
end
legend("Filtered out","Sugar","PA12","Search boundary")

%% XYZ vibration legend
figure
hold on
for i = 1:3
    plot([0 1], [0 1])
end
legend("X","Y","Z",'Orientation','horizontal')