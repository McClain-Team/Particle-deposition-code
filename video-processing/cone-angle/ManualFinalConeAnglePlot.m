% UPDATED (manual) cone angle plotting to correct messy data

Vlist = [1 1.3 1.6 1.9 2.2 2.5 2.8 3.1 3.4];
% measured angles for 90% threshold, saved in excel sheet with notes on auto
% vs manual fitting to detected edges
SLCa = [19.55	32.31	31.06	24.49	37.32	62.53	63.64	58.66	59.39];
SLMa = [40.52	28.81	27.67	38.9	57.66	89.26	105.76	87.15];
SLFa = [-12.12	-5.15	-4.91	-6.19	11.03	19.51	37.09	47.62];
PAa = [-1.25	4.76	16.59	7.52	49.72	27.55	26.08	18.05];
Sa = [29.58	27.08	21.98	24.17	20.43	30.03	59.3	70.13	77.68];
SLCaSS = [39.82 31.27 30.76 27.81 18.47 31.79 31.68 34 56.8];
SaSS = [10.81 45.08 38.54 49.17 68.97 109.67 68.62]; % no 1 or 1.6V

figure(1)
plot(Vlist,Sa,'--x','DisplayName','Sugar, 20 Ga','Color',"#f31a1a")
hold on
plot(Vlist,SLCa,'--x','DisplayName','Coarse SL, 20 Ga','Color',"#ff8f20")
plot(Vlist(2:end),SLMa,'--x','DisplayName','Medium SL, 25 Ga','Color',"#FFD133")
plot(Vlist(2:end),SLFa,'--x','DisplayName','Fine SL, 20 Ga','Color',"#75FF33")
plot(Vlist(2:end),PAa,'--x','DisplayName','PA12, 22 Ga','Color',"#00BCD4")
xlabel('Vibration Motor Voltage (V)')
ylabel('> 10% Filtered Cone Angle (^o)')
legend('Location','best')
% ylim([])
% xlim([0 3.5]) % ugly

sugarSSV = [1.3 1.9 2.2 2.5 2.8 3.1 3.4];
figure(2)
plot(Vlist,Sa,'--x','DisplayName','Sugar, 20 Ga PP','Color',"#f31a1a")
hold on
plot(sugarSSV,SaSS,'-.o','DisplayName','Sugar, 20 Ga SS','Color',"#f31a1a")
plot(Vlist,SLCa,'--x','DisplayName','Coarse SL, 20 Ga PP','Color',"#ff8f20")
plot(Vlist,SLCaSS,'-.o','DisplayName','Coarse SL, 20 Ga SS','Color',"#ff8f20")
xlabel('Vibration Motor Voltage (V)')
ylabel('> 10% Filtered Cone Angle (^o)')
legend('Location','best')
ylim([0 120])
% xlim([0  3.5]) % ugly

% Here for reference to copy from
% plotcolors = [
%     "1_0", "#fa6beb"; "1_3", "#f31a1a"; "1_6", "#ff8f20"; ...
%     "1_9", "#FFD133"; "2_2", "#75FF33"; "2_5", "#00BCD4"; ...
%     "2_8", "#00796B"; "3_1", "#003DA5"; "3_4", "#7B1FA2"; ...
%     ];
