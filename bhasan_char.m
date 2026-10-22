
clc;
clear;
close all;

%% =========================================================
% BHASAN CHAR COASTLINE EVOLUTION
% ACTUAL BOUNDARY AND PREDICTED COASTLINE
% TARGET AREA IN 2050 = 94.04 km^2
% LEGEND INSIDE THE GRAPH
%% =========================================================

%% TARGET AREAS (km^2)
A2008 = 30.80;
A2013 = 47.53;
A2020 = 55.50;
A2050 = 94.04;

N = 1000;

%% ACTUAL BHASAN CHAR LATITUDE
lat = [...
22.377970,22.380197,22.382577,22.388257,22.395012,22.404223,...
22.408445,22.408905,22.403840,22.395703,22.379199,22.368451,...
22.358930,22.353402,22.351405,22.350407,22.350254,22.348795,...
22.349179,22.350023,22.354554,22.361694,22.366820,22.375760];

%% ACTUAL BHASAN CHAR LONGITUDE
lon = [...
91.359130,91.361039,91.364775,91.369839,91.374904,91.388187,...
91.401720,91.406950,91.419819,91.425547,91.430031,91.428868,...
91.419985,91.410686,91.399894,91.397818,91.394995,91.388935,...
91.378972,91.373492,91.367598,91.361537,91.359679,91.359186];

%% CLOSE THE BOUNDARY
if lat(1) ~= lat(end) || lon(1) ~= lon(end)
    lat = [lat lat(1)];
    lon = [lon lon(1)];
end

%% CONVERT LATITUDE AND LONGITUDE TO LOCAL KM COORDINATES
lat_center = mean(lat);
lon_center = mean(lon);

km_per_deg_lat = 111;
km_per_deg_lon = 111*cosd(lat_center);

x_raw = (lon-lon_center)*km_per_deg_lon;
y_raw = (lat-lat_center)*km_per_deg_lat;

%% CREATE AND CLEAN POLYGON
pg = polyshape(x_raw,y_raw);
pg = simplify(pg);

[xb,yb] = boundary(pg);

valid = ~(isnan(xb) | isnan(yb));
xb = xb(valid);
yb = yb(valid);

%% ENSURE CLOSED BOUNDARY
if xb(1) ~= xb(end) || yb(1) ~= yb(end)
    xb(end+1) = xb(1);
    yb(end+1) = yb(1);
end

%% REMOVE CONSECUTIVE DUPLICATE POINTS
keep = [true; hypot(diff(xb),diff(yb)) > 1e-10];
xb = xb(keep);
yb = yb(keep);

if xb(1) ~= xb(end) || yb(1) ~= yb(end)
    xb(end+1) = xb(1);
    yb(end+1) = yb(1);
end

%% RESAMPLE BOUNDARY
ds = hypot(diff(xb),diff(yb));
s = [0;cumsum(ds)];

[s_unique,ia] = unique(s,'stable');
x_unique = xb(ia);
y_unique = yb(ia);

if numel(s_unique) < 4
    error('Boundary has too few unique points for interpolation.');
end

s_fine = linspace(0,s_unique(end),N)';

x0 = interp1(s_unique,x_unique,s_fine,'pchip');
y0 = interp1(s_unique,y_unique,s_fine,'pchip');

x0(end) = x0(1);
y0(end) = y0(1);

%% BASE POLYGON AND AREA
pg0 = polyshape(x0,y0);
baseArea = area(pg0);

if baseArea <= 0
    error('Base polygon area is zero or invalid.');
end

[xc,yc] = centroid(pg0);

fprintf('\n');
fprintf('====================================\n');
fprintf('BHASAN CHAR COASTLINE EVOLUTION\n');
fprintf('====================================\n');
fprintf('Base area: %.4f km^2\n',baseArea);

%% SCALE FACTORS
S2008 = sqrt(A2008/baseArea);
S2013 = 1.01*sqrt(A2013/baseArea);
S2020 = 1.07*sqrt(A2020/baseArea);
S2050 = sqrt(A2050/baseArea);

%% GENERATE COASTLINE BOUNDARIES
x2008 = xc + S2008*(x0-xc);
y2008 = yc + S2008*(y0-yc);

x2013 = xc + S2013*(x0-xc);
y2013 = yc + S2013*(y0-yc);

x2020 = xc + S2020*(x0-xc);
y2020 = yc + S2020*(y0-yc);

x2050 = xc + S2050*(x0-xc);
y2050 = yc + S2050*(y0-yc);

%% CALCULATE AREAS
area2008 = polyarea(x2008,y2008);
area2013 = polyarea(x2013,y2013);
area2020 = polyarea(x2020,y2020);
area2050 = polyarea(x2050,y2050);

fprintf('\nCalculated areas:\n');
fprintf('2008: %.4f km^2\n',area2008);
fprintf('2013: %.4f km^2\n',area2013);
fprintf('2020: %.4f km^2\n',area2020);
fprintf('2050: %.4f km^2\n',area2050);

%% =========================================================
% PLOT COASTLINE EVOLUTION
%% =========================================================

figure('Color','white',...
    'Position',[100 80 1150 750],...
    'Name','Bhasan Char Coastline Evolution');

hold on;

%% LAND FILL
fill(x2008,y2008,[0.91 0.96 0.86],...
    'EdgeColor','none',...
    'HandleVisibility','off');

%% 2008 BOUNDARY
h2008 = plot(x2008,y2008,...
    'Color',[0.00 0.55 0.00],...
    'LineWidth',2.2,...
    'LineStyle','-');

%% 2013 BOUNDARY
h2013 = plot(x2013,y2013,...
    'Color',[0.00 0.35 0.85],...
    'LineWidth',2.2,...
    'LineStyle','--');

%% 2020 BOUNDARY
h2020 = plot(x2020,y2020,...
    'Color',[0.75 0.00 0.75],...
    'LineWidth',2.2,...
    'LineStyle','-');

%% 2050 PREDICTED BOUNDARY
h2050 = plot(x2050,y2050,...
    'Color',[1.00 0.00 0.00],...
    'LineWidth',2.7,...
    'LineStyle','-');

%% ISLAND LABEL
text(xc,yc,'Bhasan Char',...
    'HorizontalAlignment','center',...
    'VerticalAlignment','middle',...
    'FontSize',18,...
    'FontWeight','bold',...
    'FontName','Times New Roman');

%% LEGEND INSIDE THE GRAPH
lgd = legend([h2008 h2013 h2020 h2050],...
    {...
    'Bhasan Char - 2008 (30.80 km^2)',...
    'Bhasan Char - 2013 (47.53 km^2)',...
    'Bhasan Char - 2020 (55.50 km^2)',...
    'Bhasan Char - 2050 (Predicted: 94.04 km^2)'...
    },...
    'Location','northeast',...
    'FontSize',16,...
    'FontName','Times New Roman',...
    'Box','on');

set(lgd,'Color','white');

%% AXIS LIMITS WITH 15 PERCENT MARGIN
allX = [x2008(:);x2013(:);x2020(:);x2050(:)];
allY = [y2008(:);y2013(:);y2020(:);y2050(:)];

xmin = min(allX);
xmax = max(allX);
ymin = min(allY);
ymax = max(allY);

xrange = xmax-xmin;
yrange = ymax-ymin;

if xrange == 0
    xrange = 1;
end

if yrange == 0
    yrange = 1;
end

xmargin = 0.25*xrange;
ymargin = 0.25*yrange;

xlim([xmin-xmargin xmax+xmargin]);
ylim([ymin-ymargin ymax+ymargin]);

%% CONVERT AXIS TICKS TO LONGITUDE AND LATITUDE
current_xlim = xlim;
current_ylim = ylim;

lon_min = lon_center + current_xlim(1)/km_per_deg_lon;
lon_max = lon_center + current_xlim(2)/km_per_deg_lon;

lat_min = lat_center + current_ylim(1)/km_per_deg_lat;
lat_max = lat_center + current_ylim(2)/km_per_deg_lat;

%% LONGITUDE TICKS
lon_start = ceil(lon_min/0.02)*0.02;
lon_end = floor(lon_max/0.02)*0.02;
lon_ticks = lon_start:0.02:lon_end;

%% LATITUDE TICKS
lat_start = ceil(lat_min/0.02)*0.02;
lat_end = floor(lat_max/0.02)*0.02;
lat_ticks = lat_start:0.02:lat_end;

%% SET TICK POSITIONS
xtick_positions = (lon_ticks-lon_center)*km_per_deg_lon;
ytick_positions = (lat_ticks-lat_center)*km_per_deg_lat;

xticks(xtick_positions);
yticks(ytick_positions);

%% SET TICK LABELS
xticklabels(compose('%.2f',lon_ticks));
yticklabels(compose('%.2f',lat_ticks));

%% AXIS LABELS
xlabel('Longitude (degrees)',...
    'FontSize',13,...
    'FontName','Times New Roman');

ylabel('Latitude (degrees)',...
    'FontSize',13,...
    'FontName','Times New Roman');



%% GRAPH FORMATTING
axis equal;
grid on;
box on;

set(gca,...
    'FontSize',11,...
    'LineWidth',1.2,...
    'FontName','Times New Roman');

hold off;

%% AREA ERROR
fprintf('\nArea differences from target values:\n');
fprintf('2008 difference: %.4f km^2\n',area2008-A2008);
fprintf('2013 difference: %.4f km^2\n',area2013-A2013);
fprintf('2020 difference: %.4f km^2\n',area2020-A2020);
fprintf('2050 difference: %.4f km^2\n',area2050-A2050);

fprintf('\nCoastline plotting completed.\n');
