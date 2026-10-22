
clc;
clear;
close all;

%% ============================================================
% FOUR ISLANDS AREA EVOLUTION
% (a) Urir Char
% (b) Sandwip
% (c) Swarna Dwip
% (d) Bhasan Char
% =============================================================

%% URIR CHAR
yr1 = [1972 1980 1990 2000 2010 2012 2015 2017 2020];
ar1 = [5 20 45 69 89 94 99 101 103];

yp1 = [2025 2028 2031 2035 2039 2043 2047 2050];
ap1 = [106 108 111 114 117 120 123 125.48];

%% SANDWIP
yr2 = [1960 1970 1980 1990 2000 2010 2020];
ar2 = [220 230 240 245 250 254.5 256];

yp2 = [2025 2028 2032 2036 2040 2045 2050];
ap2 = [256.5 258.5 260 261 262 263 264.14];

%% SWARNA DWIP
yr3 = [1973 1978 1985 1990 1996 2000 2006 ...
       2010 2013 2015 2017 2020];
ar3 = [8 18 42 66 99 134 188 238 280 318 350 360];

yp3 = [2025 2028 2030 2033 2036 2040 2044 2047 2050];
ap3 = [370 382 395 410 425 440 455 463 471.75];

%% BHASAN CHAR
yr4 = [2002 2003 2005 2007 2012 2015 2020 2025];
ar4 = [5.46 11.40 20 35 46 53 55.50 58];

yp4 = [2028 2030 2032 2035 2037 2040 ...
       2043 2045 2047 2050];
ap4 = [58.5 60.5 64 68.5 72.5 77 ...
       81.5 85.5 89.5 94.04];

%% STORE DATA IN CELL ARRAYS
yearsObs = {yr1,yr2,yr3,yr4};
areasObs = {ar1,ar2,ar3,ar4};

yearsPred = {yp1,yp2,yp3,yp4};
areasPred = {ap1,ap2,ap3,ap4};

panelNames = {'(a) Urir Char','(b) Sandwip', ...
              '(c) Swarna Dwip','(d) Bhasan Char'};

xLimits = {[1970 2050],[1960 2050], ...
           [1970 2050],[2000 2050]};

yLimits = {[0 140],[210 270],[0 500],[0 100]};

xSteps = [10 10 10 5];
ySteps = [20 10 50 10];

%% CREATE FIGURE
fig = figure('Color','w', ...
    'Name','Four Island Area Evolution', ...
    'NumberTitle','off', ...
    'Position',[50 50 1450 850], ...
    'Visible','on');

%% DRAW ALL FOUR PANELS
for i = 1:4

    ax = subplot(2,2,i,'Parent',fig);
    hold(ax,'on');
    box(ax,'on');
    grid(ax,'on');

    xo = yearsObs{i};
    ao = areasObs{i};
    xp = yearsPred{i};
    ap = areasPred{i};

    % 1. Smooth observed trend
    xx = linspace(xo(1),xo(end),500);
    yy = interp1(xo,ao,xx,'pchip');

    hTrend = plot(ax,xx,yy,'k-', ...
        'LineWidth',1.7);

    % 2. Annual connection from observed endpoint
    xa = [xo(end),xp];
    ya = [ao(end),ap];

    hAnnual = plot(ax,xa,ya,'--', ...
        'Color',[0.55 0.55 0.55], ...
        'LineWidth',1.0);

    % 3. Observed points
    hObs = plot(ax,xo,ao,'o', ...
        'LineStyle','none', ...
        'MarkerSize',6, ...
        'MarkerFaceColor',[0 0.447 0.741], ...
        'MarkerEdgeColor','k');

    % 4. Predicted points
    hPred = plot(ax,xp,ap,'s', ...
        'LineStyle','none', ...
        'MarkerSize',5, ...
        'MarkerFaceColor',[0.85 0.20 0.18], ...
        'MarkerEdgeColor',[0.65 0.10 0.10]);

    % Axes formatting
    xlim(ax,xLimits{i});
    ylim(ax,yLimits{i});

    xticks(ax,xLimits{i}(1):xSteps(i):xLimits{i}(2));
    yticks(ax,yLimits{i}(1):ySteps(i):yLimits{i}(2));

    xlabel(ax,'Year','FontWeight','bold');
    ylabel(ax,'Area (km^2)','FontWeight','bold');

    title(ax,panelNames{i}, ...
        'FontWeight','bold','FontSize',14);

    set(ax,'FontName','Arial', ...
        'FontSize',10, ...
        'LineWidth',0.8, ...
        'Layer','top', ...
        'XMinorGrid','on', ...
        'YMinorGrid','on');

    legend(ax,[hTrend hObs hPred hAnnual], ...
        {'Spline Trend','Observed Data', ...
         'Predicted Data','Annual Connection'}, ...
        'Location','northwest', ...
        'FontSize',8, ...
        'Box','on');

    hold(ax,'off');

end

% Force MATLAB to render all four axes
drawnow;

% Save the complete figure
set(fig,'PaperPositionMode','auto');

print(fig,'Four_Island_Area_Evolution.png','-dpng','-r300');

disp('SUCCESS: All four island graphs have been generated.');
disp('Saved file: Four_Island_Area_Evolution.png');
