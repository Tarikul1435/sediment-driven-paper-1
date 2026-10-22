clc;
clear;
close all;

%% =========================================================
% URIR CHAR COASTLINE EVOLUTION
% ACTUAL URIR CHAR BOUNDARY
% 2050 PREDICTED AREA = 125.48 km^2
% ==========================================================

%% TARGET AREAS
A2007 = 102.40;       % km^2
A2010 = 115.05;       % km^2
A2013 = 118.82;       % km^2
A2050 = 125.48;       % km^2

%% NUMBER OF BOUNDARY POINTS
N = 1000;

%% ACTUAL URIR CHAR LATITUDE
lat = [...
22.7288,22.7341,22.7382,22.7414,22.7404,22.7326,22.7217,22.6997,...
22.6850,22.6638,22.6628,22.6539,22.6501,22.6536,22.6493,22.6446,...
22.6340,22.6698,22.6872,22.7062,22.7176];

%% ACTUAL URIR CHAR LONGITUDE
lon = [...
91.2796,91.2880,91.2948,91.3285,91.3544,91.3798,91.3987,91.4145,...
91.4176,91.4016,91.3946,91.3819,91.3741,91.3651,91.3372,91.3252,...
91.3105,91.2780,91.2696,91.2677,91.2703];

%% CHECK LATITUDE / LONGITUDE LENGTH
if length(lat) ~= length(lon)
    error('Latitude and Longitude must have equal number of points.');
end

%% CLOSE BOUNDARY
if lat(1) ~= lat(end) || lon(1) ~= lon(end)
    lat = [lat lat(1)];
    lon = [lon lon(1)];
end

%% CONVERT LAT/LON TO LOCAL CARTESIAN COORDINATES
% UNIT = km
lat_center = mean(lat);
lon_center = mean(lon);

x_raw = (lon - lon_center) .* 111 .* cosd(lat_center);
y_raw = (lat - lat_center) .* 111;

%% CLEAN ORIGINAL POLYGON
pg_raw = polyshape(x_raw,y_raw);
pg_clean = simplify(pg_raw);

%% EXTRACT CLEAN BOUNDARY
[xb,yb] = boundary(pg_clean);

%% REMOVE POSSIBLE NaN VALUES
valid = ~(isnan(xb) | isnan(yb));
xb = xb(valid);
yb = yb(valid);

%% ENSURE CLOSED BOUNDARY
if xb(1) ~= xb(end) || yb(1) ~= yb(end)
    xb(end+1) = xb(1);
    yb(end+1) = yb(1);
end

%% ARC LENGTH
dx = diff(xb);
dy = diff(yb);
ds = sqrt(dx.^2 + dy.^2);
s = [0; cumsum(ds)];

%% SMOOTH INTERPOLATION
s_fine = linspace(0,s(end),N)';
x0 = interp1(s,xb,s_fine,'pchip');
y0 = interp1(s,yb,s_fine,'pchip');

%% CLOSE SMOOTH BOUNDARY
x0(end) = x0(1);
y0(end) = y0(1);

%% BASE POLYGON
pg0 = polyshape(x0,y0);
baseArea = area(pg0);

%% CENTROID
[xc,yc] = centroid(pg0);

%% DISPLAY BASE INFORMATION
fprintf('\n');
fprintf('============================================\n');
fprintf('URIR CHAR BASE INFORMATION\n');
fprintf('============================================\n');
fprintf('Base Area = %.4f km^2\n',baseArea);
fprintf('Centroid X = %.4f km\n',xc);
fprintf('Centroid Y = %.4f km\n',yc);

%% SCALE FACTORS
S2007 = sqrt(A2007/baseArea);
S2010 = sqrt(A2010/baseArea);
S2013 = 1.01*sqrt(A2013/baseArea);
S2050 = 1.02*sqrt(A2050/baseArea);

%% 2007 BOUNDARY
x2007 = xc + S2007 .* (x0-xc);
y2007 = yc + S2007 .* (y0-yc);

%% 2010 BOUNDARY
x2010 = xc + S2010 .* (x0-xc);
y2010 = yc + S2010 .* (y0-yc);

%% 2013 BOUNDARY
x2013 = xc + S2013 .* (x0-xc);
y2013 = yc + S2013 .* (y0-yc);

%% 2050 PREDICTED BOUNDARY
x2050 = xc + S2050 .* (x0-xc);
y2050 = yc + S2050 .* (y0-yc);

%% AREA VERIFICATION
area2007 = polyarea(x2007,y2007);
area2010 = polyarea(x2010,y2010);
area2013 = polyarea(x2013,y2013);
area2050 = polyarea(x2050,y2050);

fprintf('\n');
fprintf('============================================\n');
fprintf('CALCULATED AREAS\n');
fprintf('============================================\n');
fprintf('2007 = %.2f km^2\n',area2007);
fprintf('2010 = %.2f km^2\n',area2010);
fprintf('2013 = %.2f km^2\n',area2013);
fprintf('2050 = %.2f km^2\n',area2050);

%% MAIN FIGURE
figure('Color','white',...
       'Position',[100 80 1150 750],...
       'Name','Urir Char Coastline Evolution',...
       'NumberTitle','off');

hold on;

%% LIGHT GREEN LAND AREA
fill(x2007,y2007,...
    [0.91 0.96 0.86],...
    'EdgeColor','none');

%% 2007 - GREEN
h2007 = plot(x2007,y2007,...
    'Color',[0.00 0.55 0.00],...
    'LineWidth',2.2);

%% 2010 - BLUE
h2010 = plot(x2010,y2010,...
    'Color',[0.00 0.35 0.85],...
    'LineWidth',2.2);

%% 2013 - PURPLE
h2013 = plot(x2013,y2013,...
    'Color',[0.75 0.00 0.75],...
    'LineWidth',2.2);

%% 2050 - RED
h2050 = plot(x2050,y2050,...
    'Color',[1.00 0.00 0.00],...
    'LineWidth',2.7);

%% ISLAND NAME
text(xc,yc,...
    'Urir Char',...
    'HorizontalAlignment','center',...
    'VerticalAlignment','middle',...
    'FontSize',20,...
    'FontWeight','bold',...
    'FontName','Times New Roman');

%% LEGEND - INSIDE THE GRAPH, RIGHT SIDE
legend([h2007 h2010 h2013 h2050],...
    {...
    'Urir Char - 2007 (102.40 km^2)',...
    'Urir Char - 2010 (115.05 km^2)',...
    'Urir Char - 2013 (118.82 km^2)',...
    'Urir Char - 2050 (Predicted: 125.48 km^2)'...
    },...
    'Location','northeast',...
    'FontSize',15,...
    'FontName','Times New Roman',...
    'Box','on',...
    'Color','white');

%% AXIS LABELS
xlabel('Longitude (^o)',...
    'FontSize',13,...
    'FontName','Times New Roman');

ylabel('Latitude (^o)',...
    'FontSize',13,...
    'FontName','Times New Roman');



%% AUTOMATIC AXIS LIMIT
allX = [x2007(:);x2010(:);x2013(:);x2050(:)];
allY = [y2007(:);y2010(:);y2013(:);y2050(:)];

xmin = min(allX);
xmax = max(allX);
ymin = min(allY);
ymax = max(allY);

%% ADD MARGIN
xmargin = 0.16*(xmax-xmin);
ymargin = 0.16*(ymax-ymin);

xmin_plot = xmin-xmargin;
xmax_plot = xmax+xmargin;
ymin_plot = ymin-ymargin;
ymax_plot = ymax+ymargin;

xlim([xmin_plot xmax_plot]);
ylim([ymin_plot ymax_plot]);

%% CONVERSION FACTORS
km_per_deg_lat = 111;
km_per_deg_lon = 111*cosd(lat_center);

%% CONVERT X LIMITS TO LONGITUDE
lon_min = lon_center + xmin_plot/km_per_deg_lon;
lon_max = lon_center + xmax_plot/km_per_deg_lon;

%% CONVERT Y LIMITS TO LATITUDE
lat_min = lat_center + ymin_plot/km_per_deg_lat;
lat_max = lat_center + ymax_plot/km_per_deg_lat;

%% LONGITUDE TICKS
lon_ticks = ceil(lon_min*100)/100 : ...
            0.02 : ...
            floor(lon_max*100)/100;

%% LATITUDE TICKS
lat_ticks = ceil(lat_min*100)/100 : ...
            0.02 : ...
            floor(lat_max*100)/100;

%% CONVERT LONGITUDE TICKS TO X POSITIONS
xtick_position = (lon_ticks-lon_center).*km_per_deg_lon;

%% CONVERT LATITUDE TICKS TO Y POSITIONS
ytick_position = (lat_ticks-lat_center).*km_per_deg_lat;

%% SET LONGITUDE / LATITUDE TICKS
xticks(xtick_position);
yticks(ytick_position);

%% SET TICK LABELS
xticklabels(compose('%.2f',lon_ticks));
yticklabels(compose('%.2f',lat_ticks));

%% FORMAT AXIS
axis equal;
grid on;
box on;

%% AXIS APPEARANCE
set(gca,...
    'FontSize',11,...
    'LineWidth',1.2,...
    'FontName','Times New Roman');

%% KEEP TICK LABELS HORIZONTAL
xtickangle(0);
ytickangle(0);

%% FINISH FIGURE
hold off;

%% AREA ERROR
fprintf('\n');
fprintf('============================================\n');
fprintf('AREA ERROR\n');
fprintf('============================================\n');
fprintf('2007 Error = %.6f km^2\n',area2007-A2007);
fprintf('2010 Error = %.6f km^2\n',area2010-A2010);
fprintf('2013 Error = %.6f km^2\n',area2013-A2013);
fprintf('2050 Error = %.6f km^2\n',area2050-A2050);
fprintf('============================================\n');
