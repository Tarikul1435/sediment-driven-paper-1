
clc;
clear;
close all;

%% =========================================================
% SWARNA DWIP ISLAND COASTLINE EVOLUTION
% AUTOMATIC AREA MATCHING WITH POLYGON BUFFER
% 2050 TARGET AREA = 471.75 km^2
% LEGEND INSIDE GRAPH
% IMPROVED X-Y AXIS MARGINS
% FONT: TIMES NEW ROMAN
%% =========================================================

%% TARGET AREAS (km^2)
A2005 = 190.00;
A2013 = 280.00;
A2020 = 360.00;
A2050 = 471.75;

%% NUMBER OF INTERPOLATED POINTS
N = 1000;

%% ORIGINAL SWARNA DWIP LATITUDE DATA
lat_final = [...
22.610389,22.602297,22.593272,22.586113,22.572418,...
22.553428,22.540352,22.520735,22.503918,22.495000,...
22.478378,22.462491,22.444421,22.428842,22.431958,...
22.428842,22.421363,22.415872,22.412698,22.424122,...
22.439352,22.446015,22.456166,22.459656,22.477420,...
22.510720,22.525624,22.549561,22.558913,22.581893,...
22.595363,22.608356,22.610574,22.610389];

%% ORIGINAL SWARNA DWIP LONGITUDE DATA
lon_final = [...
91.350979,91.335135,91.320302,91.312211,91.304458,...
91.284232,91.270410,91.263331,91.255577,91.252500,...
91.249510,91.233328,91.201978,91.212091,91.221867,...
91.230632,91.233328,91.244717,91.260164,91.269432,...
91.278357,91.288655,91.296722,91.319549,91.339458,...
91.357823,91.368121,91.378590,91.380821,91.385284,...
91.381851,91.372411,91.359024,91.350979];

%% CHECK DATA
if numel(lat_final) ~= numel(lon_final)
    error('Latitude and longitude arrays must have the same length.');
end

%% CLOSE BOUNDARY IF REQUIRED
if lat_final(1) ~= lat_final(end) || ...
        lon_final(1) ~= lon_final(end)

    lat_final(end+1) = lat_final(1);
    lon_final(end+1) = lon_final(1);
end

%% CONVERT LATITUDE AND LONGITUDE TO LOCAL KM COORDINATES
lat_center = mean(lat_final);
lon_center = mean(lon_final);

km_per_degree_lat = 111.32;
km_per_degree_lon = 111.32*cosd(lat_center);

x_raw = (lon_final-lon_center)*km_per_degree_lon;
y_raw = (lat_final-lat_center)*km_per_degree_lat;

%% CREATE AND CLEAN ORIGINAL POLYGON
pg_raw = polyshape(x_raw,y_raw);
pg_base = simplify(pg_raw);

if area(pg_base) <= 0
    error('The original boundary polygon has zero or invalid area.');
end

%% EXTRACT BASE BOUNDARY
[xb,yb] = boundary(pg_base);

valid = ~(isnan(xb) | isnan(yb));
xb = xb(valid);
yb = yb(valid);

if numel(xb) < 4
    error('The cleaned boundary contains too few points.');
end

%% ENSURE CLOSED BOUNDARY
if xb(1) ~= xb(end) || yb(1) ~= yb(end)
    xb(end+1) = xb(1);
    yb(end+1) = yb(1);
end

%% ARC-LENGTH PARAMETERIZATION
ds = hypot(diff(xb),diff(yb));
s = [0;cumsum(ds)];

[s_unique,ia] = unique(s,'stable');

xb_unique = xb(ia);
yb_unique = yb(ia);

if numel(s_unique) < 4
    error('Not enough unique boundary points for interpolation.');
end

s_fine = linspace(0,s_unique(end),N)';

%% PCHIP INTERPOLATION
x0 = interp1(s_unique,xb_unique,s_fine,'pchip');
y0 = interp1(s_unique,yb_unique,s_fine,'pchip');

x0(end) = x0(1);
y0(end) = y0(1);

%% CREATE SMOOTH BASE POLYGON
pg0 = simplify(polyshape(x0,y0));
baseArea = area(pg0);

if baseArea <= 0
    error('The smoothed base polygon has zero or invalid area.');
end

[xc,yc] = centroid(pg0);

fprintf('\n');
fprintf('=============================================\n');
fprintf('       SWARNA DWIP COASTLINE MODEL\n');
fprintf('=============================================\n');
fprintf('Control points = %d\n',numel(lat_final));
fprintf('Smooth points  = %d\n',N);
fprintf('Base area      = %.6f km^2\n',baseArea);
fprintf('Centroid X     = %.6f km\n',xc);
fprintf('Centroid Y     = %.6f km\n',yc);

%% =========================================================
% GENERATE NESTED BOUNDARIES BY AUTOMATIC AREA MATCHING
%% =========================================================

fprintf('\nGenerating 2005 boundary...\n');
pg2005 = createExactAreaBuffer(pg0,A2005);

fprintf('Generating 2013 boundary...\n');
pg2013 = createExactAreaBuffer(pg2005,A2013);

fprintf('Generating 2020 boundary...\n');
pg2020 = createExactAreaBuffer(pg2013,A2020);

fprintf('Generating 2050 boundary...\n');
pg2050 = createExactAreaBuffer(pg2020,A2050);

%% EXTRACT BOUNDARIES
[x2005,y2005] = boundary(pg2005);
[x2013,y2013] = boundary(pg2013);
[x2020,y2020] = boundary(pg2020);
[x2050,y2050] = boundary(pg2050);

%% CALCULATE AREAS
Area2005 = area(pg2005);
Area2013 = area(pg2013);
Area2020 = area(pg2020);
Area2050 = area(pg2050);

fprintf('\n');
fprintf('=============================================\n');
fprintf('             FINAL VERIFIED AREAS\n');
fprintf('=============================================\n');
fprintf('2005 = %.6f km^2 (target %.2f)\n',Area2005,A2005);
fprintf('2013 = %.6f km^2 (target %.2f)\n',Area2013,A2013);
fprintf('2020 = %.6f km^2 (target %.2f)\n',Area2020,A2020);
fprintf('2050 = %.6f km^2 (target %.2f)\n',Area2050,A2050);

fprintf('\nArea errors (calculated - target):\n');
fprintf('2005 Error = %.10f km^2\n',Area2005-A2005);
fprintf('2013 Error = %.10f km^2\n',Area2013-A2013);
fprintf('2020 Error = %.10f km^2\n',Area2020-A2020);
fprintf('2050 Error = %.10f km^2\n',Area2050-A2050);

%% =========================================================
% CONVERT LOCAL KM COORDINATES TO GEOGRAPHIC COORDINATES
% The polygon-buffer calculations above remain unchanged.
%% =========================================================

lon2005 = lon_center + x2005/km_per_degree_lon;
lat2005 = lat_center + y2005/km_per_degree_lat;

lon2013 = lon_center + x2013/km_per_degree_lon;
lat2013 = lat_center + y2013/km_per_degree_lat;

lon2020 = lon_center + x2020/km_per_degree_lon;
lat2020 = lat_center + y2020/km_per_degree_lat;

lon2050 = lon_center + x2050/km_per_degree_lon;
lat2050 = lat_center + y2050/km_per_degree_lat;

lon_label = lon_center + xc/km_per_degree_lon;
lat_label = lat_center + yc/km_per_degree_lat;

%% =========================================================
% COMBINE ALL BOUNDARIES FOR AXIS LIMITS
%% =========================================================

allLon = [lon2005(:);lon2013(:);lon2020(:);lon2050(:)];
allLat = [lat2005(:);lat2013(:);lat2020(:);lat2050(:)];

%% AXIS MARGINS - SAME STYLE AS SANDWIP CODE
lon_margin = 0.35*(max(allLon)-min(allLon));
lat_margin = 0.15*(max(allLat)-min(allLat));

lon_min = min(allLon)-lon_margin;
lon_max = max(allLon)+lon_margin;

lat_min = min(allLat)-lat_margin;
lat_max = max(allLat)+lat_margin;

%% =========================================================
% CREATE FIGURE
%% =========================================================

figure(...
    'Color','white',...
    'Position',[100 100 1200 750],...
    'Name','Swarna Dwip Coastline Evolution');

hold on;

%% =========================================================
% LIGHT GREEN LAND FILL - INSIDE 2005 BOUNDARY ONLY
%% =========================================================

fill(lon2005,lat2005,...
    [0.91 0.96 0.86],...
    'EdgeColor','none',...
    'HandleVisibility','off');

%% =========================================================
% 2005 COASTLINE - GREEN
%% =========================================================

h2005 = plot(lon2005,lat2005,...
    'Color',[0.00 0.55 0.00],...
    'LineWidth',2.2,...
    'LineStyle','-');

%% =========================================================
% 2013 COASTLINE - BLUE
%% =========================================================

h2013 = plot(lon2013,lat2013,...
    'Color',[0.00 0.35 0.85],...
    'LineWidth',2.2,...
    'LineStyle','-');

%% =========================================================
% 2020 COASTLINE - PURPLE
%% =========================================================

h2020 = plot(lon2020,lat2020,...
    'Color',[0.75 0.00 0.75],...
    'LineWidth',2.2,...
    'LineStyle','-');

%% =========================================================
% 2050 PREDICTED COASTLINE - RED
%% =========================================================

h2050 = plot(lon2050,lat2050,...
    'Color',[1.00 0.00 0.00],...
    'LineWidth',2.5,...
    'LineStyle','-');

%% =========================================================
% ISLAND NAME
%% =========================================================

text(lon_label,lat_label,'Swarna Dwip',...
    'HorizontalAlignment','center',...
    'VerticalAlignment','middle',...
    'FontSize',20,...
    'FontWeight','bold',...
    'FontName','Times New Roman');

%% =========================================================
% LEGEND INSIDE THE GRAPH
%% =========================================================

lgd = legend([h2005 h2013 h2020 h2050],{...
    'Swarna Dwip - 2005 (190 km^2)',...
    'Swarna Dwip - 2013 (280 km^2)',...
    'Swarna Dwip - 2020 (360 km^2)',...
    'Swarna Dwip - 2050 (Predicted: 471.75 km^2)'},...
    'Location','northeast',...
    'FontSize',15,...
    'FontName','Times New Roman',...
    'Box','on');

set(lgd,'Color','white');

%% =========================================================
% AXIS LABELS
%% =========================================================

xlabel('Longitude (^oE)',...
    'FontSize',13,...
    'FontWeight','bold',...
    'FontName','Times New Roman');

ylabel('Latitude (^oN)',...
    'FontSize',13,...
    'FontWeight','bold',...
    'FontName','Times New Roman');

%% =========================================================
% GRID AND BOX
%% =========================================================

grid on;
box on;

%% =========================================================
% EQUAL GEOGRAPHIC SCALE
%% =========================================================

axis equal;

%% =========================================================
% AXIS APPEARANCE
%% =========================================================

set(gca,...
    'FontSize',11,...
    'LineWidth',1.2,...
    'Layer','top',...
    'FontName','Times New Roman');

%% =========================================================
% AXIS LIMITS
%% =========================================================

xlim([91.12 91.45]);
ylim([22.35 22.71]);

%% LONGITUDE TICKS
xticks(floor(lon_min*100)/100:0.02:ceil(lon_max*100)/100);

%% LATITUDE TICKS
yticks(floor(lat_min*100)/100:0.02:ceil(lat_max*100)/100);

%% TICK FORMAT
xtickformat('%.2f');
ytickformat('%.2f');

%% FINISH
hold off;

fprintf('\nSwarna Dwip coastline plot completed.\n\n');

%% =========================================================
% LOCAL FUNCTION: AUTOMATIC EXACT-AREA BUFFER
%% =========================================================

function pgOut = createExactAreaBuffer(pgIn,targetArea)

    currentArea = area(pgIn);

    if abs(currentArea-targetArea) < 1e-8
        pgOut = pgIn;
        return;
    end

    %% OUTWARD BUFFER: TARGET AREA IS LARGER
    if targetArea > currentArea

        low = 0;
        high = 1;

        % Find an upper buffer distance
        for k = 1:60

            pgTest = polybuffer(pgIn,high);

            if area(pgTest) >= targetArea
                break;
            end

            high = high*2;
        end

        if area(polybuffer(pgIn,high)) < targetArea
            error(['Could not bracket target area for outward ', ...
                   'buffering.']);
        end

        % Binary search
        for k = 1:60

            mid = (low+high)/2;
            pgTest = polybuffer(pgIn,mid);

            if area(pgTest) < targetArea
                low = mid;
            else
                high = mid;
            end
        end

        pgOut = polybuffer(pgIn,(low+high)/2);

    %% INWARD BUFFER: TARGET AREA IS SMALLER
    else

        high = 0;
        low = -0.1;
        bracketFound = false;

        % Find a lower buffer distance
        for k = 1:60

            pgTest = polybuffer(pgIn,low);

            if isempty(pgTest.Vertices)
                break;
            end

            if area(pgTest) <= targetArea
                bracketFound = true;
                break;
            end

            low = low*2;
        end

        if ~bracketFound
            error(['Could not find inward buffer distance. ', ...
                   'The polygon may collapse before reaching ', ...
                   'the target area.']);
        end

        % Binary search
        for k = 1:60

            mid = (low+high)/2;
            pgTest = polybuffer(pgIn,mid);

            if isempty(pgTest.Vertices)
                low = mid;
                continue;
            end

            if area(pgTest) > targetArea
                high = mid;
            else
                low = mid;
            end
        end

        pgOut = polybuffer(pgIn,(low+high)/2);

    end

    %% CLEAN FINAL POLYGON
    pgOut = simplify(pgOut);

end
