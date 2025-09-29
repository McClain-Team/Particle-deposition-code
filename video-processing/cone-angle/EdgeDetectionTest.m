% This script is a messy version of testing and figuring out the cone angle
% parameter calculation workflow.

% Parabola fitting seemed problematic/less accurate than desired, so
% fitting two lines to the first mm of flow was decided upon instead.
% Additionally, the front amplitude coefficient on the quadratic would be a
% slightly harder metric to understand than cone angle

% one of the quadratic issues seems to be the tip not being oriented with
% the y axis, so flow skews one way and the parabola can't compensate. The
% image could be rotated, but an alg for this would be annoying.

folderpath = "C:\PURDUE\Year 5 (Graduate)\Research\Experiments\High Speed Camera\IPS Cone Flow Image Processing\AllDataLongEx\";
binName = "S9-2_5V-BW.png";
greyName = "S9-2_5V-H.png";

binIm = imread(folderpath+binName);
greyIm = imread(folderpath+greyName);

binIm = imrotate(binIm,90);
greyIm = imrotate(greyIm,90);

threshold = 32; % remove errant particle trails (1 or 2 basically)
threshBin = greyIm > threshold;

binEdge = edge(threshBin);
greyEdge = edge(greyIm);

% figure;
% imshow(binEdge);
% figure;
% imshow(greyEdge);


cleanBinEdge = bwareaopen(binEdge,50);
cleanGreyEdge = bwareaopen(greyEdge,50);

figure
imshowpair(binEdge,cleanBinEdge,'montage')
figure
imshowpair(greyEdge,cleanGreyEdge,'montage')
%%
cropBin = cleanBinEdge(181:1180,:);
figure
imshow(cropBin)

leftEdge = zeros(size(cropBin),'logical');
rightEdge = zeros(size(cropBin),'logical');
for row = 1:length(cropBin(:,1))
    whites = find(cropBin(row,:) == 1); % identify white pixels in row
    % create a new image of only the left and right bound
    if ~isempty(whites) % prevent error if row had no pixels
    leftEdge(row, whites(1)) = 1;
    rightEdge(row, whites(end)) = 1;
    end
end
LRim = leftEdge+rightEdge;

figure
imshow(LRim)
%% angle, non-parabola method

[yl,xl] = find(leftEdge(1:100,:) == 1); % 100px = angle based on first 1mm from tip
pl = polyfit(xl,yl,1); % 1st index = slope
[yr,xr] = find(rightEdge(1:100,:) == 1); % 100px = angle based on first 1mm from tip
pr = polyfit(xr,yr,1); % 1st index = slope

xf = 1:length(binIm(1,:));

ylf = polyval(pl, xf);
yrf = polyval(pr, xf);

% Plot the original points and the fitted parabola
figure;
plot(xl, yl, 'b.', xr, yr, 'b.', xf, ylf, 'r-', xf, yrf, 'g-');


%%
%angle = rad2deg(atan((pl(1)-pr(1))/(1+pl(1)*pr(1)))); % only gives
%acute... eqn found online for two slopes

% left *should* always be negative... light/blowing may cause issues tho
% could do if statements to prevent errors
% just go with it for now

% difference between angles from 0 of 2 slopes = cone angle
angle = rad2deg(atan2(-pl(1),-1)) - rad2deg(atan2(pr(1),1)); 



%%
% Chat gpt code
[y, x] = find(LRim(1:100,:) == 1); % coordinate sys flipped...

% Fit a parabola to the coordinates using polyfit
p = polyfit(x, y, 2); % Fit a parabola of order 2 (a*x^2 + b*x + c)

% Generate x values for the fitted parabola
x_fit = min(x):0.1:max(x);

% Evaluate the fitted parabola at x_fit
y_fit = polyval(p, x_fit);

% Plot the original points and the fitted parabola
figure;
plot(x, y, 'b.', x_fit, y_fit, 'r-');
xlabel('X');
ylabel('Y');
title('Fitted Parabola to Binarized Image');
legend('Original Points', 'Fitted Parabola');
grid on;

%%
% Chat gpt code

shortcrop = LRim(1:300,:); % fit on a smaller portion of the parabola?
figure
imshow(shortcrop)


[y, x] = find(shortcrop == 1); % coordinate sys flipped...

% Fit a parabola to the coordinates using polyfit
p = polyfit(x, y, 2); % Fit a parabola of order 2 (a*x^2 + b*x + c)

% Generate x values for the fitted parabola
x_fit = min(x):0.1:max(x);

% Evaluate the fitted parabola at x_fit
y_fit = polyval(p, xf);

% Plot the original points and the fitted parabola
figure;
plot(x, y, 'b.', xf, y_fit, 'r-');
xlabel('X');
ylabel('Y');
title('Fitted Parabola to Binarized Image');
legend('Original Points', 'Fitted Parabola');
grid on;
%% plot stuff over the image
greyImF = flipud(greyIm); % invert y axis to match plotting

figure(100)
%imshow(greyImF)
image([1,720],[-179,1100],greyImF)
hold on
%scatter(xf, y_fit) % calling from previous section, parabola based on 3mm of thresholded im
plot(xf, y_fit,'r-')
%set(gca,'YDir','normal') % correct orientation, gca = get current axes
axis on


%% convert quadratic form
%a*x^2+b*x+c %quadratic formula, this is what you have
% h=-b/(2*a) %calculate h
% k=c-b^2/(4*a) %calculate k
% a*(x-h)^2+k %this is your equivalent formula

%% Improvements
% impliment fitting for full envelope, binarize versions at diff
% accuracies... (95%, 68%? 2 and 1 std. dev.'s from avg)
% crop image to remove nozzle tip (should be fairly consistent
% maybe flip coords to represent same thing when plotted. 
% maybe shift coords to have 0,0 at nozzle tip (x is less consistent than
% y... need some form of recognition...
% filter out bad corner data (maybe just crop bottom edge out too
% filter out edges not near anything else stuck particles

% small particles aren't clean envelope, need to establish outermost
% boundary...

%% grey to thresholded binary
for threshold = 30:30:180 % testing to see how heatmap stacks up basically
threshBin = greyIm > threshold;

figure
imshow(threshBin)   
title(threshold)
end
% 
% %%
% for threshold = 25:3:37
%     figure
%     imshowpair(greyIm,greyIm>threshold,'montage')
%     title(threshold)
% end
