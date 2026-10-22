clc;
clear;
close all;

%% Create grid
figure('Color','w');
hold on;
axis equal;

xlim([-4 4]);
ylim([-3 3]);

grid on;
set(gca,'GridLineStyle','-','GridAlpha',0.4,...
    'XTick',-4:0.5:4,...
    'YTick',-3:0.5:3,...
    'FontSize',11);

%% Parameter
t = linspace(0,2*pi,600);

%% Interface (phi = 0)
r = 2 + 0.25*cos(3*t) + 0.12*sin(2*t);

x = r.*cos(t);
y = 0.75*r.*sin(t);

plot(x,y,'k','LineWidth',3);

%% Inside contours (phi < 0)

for s = [0.80 0.60 0.40]
    plot(s*x,s*y,'Color',[0.45 0.45 0.45],...
        'LineStyle','--','LineWidth',1.2);
end

%% Outside contours (phi > 0)

for s = [1.15 1.30 1.45]
    plot(s*x,s*y,'Color',[0.45 0.45 0.45],...
        'LineStyle','--','LineWidth',1.2);
end

%% Labels

text(0.9,-0.1,'\phi < 0','FontSize',20,'FontWeight','bold');
text(0.9,-0.45,'inside','FontSize',20);

text(2.25,1.1,'\phi > 0','FontSize',20,'FontWeight','bold');
text(2.1,0.7,'outside','FontSize',20);

%% Arrow pointing to interface

annotation('textarrow',[0.70 0.52],[0.93 0.72],...
    'String',{'interface (\phi = 0)';},...
    'FontSize',20,...
    'LineWidth',1.5);

%% Remove tick labels (optional)
xticklabels([]);
yticklabels([]);

box on;