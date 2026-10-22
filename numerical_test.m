function fig9_validation_plot()
% Validation figure for Sect. 4.6.1
%   (a) Exact solution vs level-set simulation (circular island, Urir Char data)
%   (b) Grid convergence of the area error
%   (c) Analytic two-disc merging criterion (Swarna Dwip + Bhasan Char)
%
% HOW TO RUN: save as  fig9_validation_plot.m  in MATLAB's current folder and
% type   fig9_validation_plot   in the Command Window (do not paste the code
% into the Command Window).  Takes ~1-2 minutes.  No toolboxes needed.

close all; clc;
red  = [0.84 0.15 0.16];
gray = [0.50 0.50 0.50];

%% ---------------- parameters (Urir Char, Tables 2-3) -----------------
A0 = 105;  VA = 0.7;  a = 1.5;  w = 2*pi/6;  T = 25;
G  = @(t) t + (a/w)*(1 - cos(w*t));          % integral of g(t), phi = 0
Aex = A0 + VA*G(T);                           % exact area at T (Prop. 2)

%% ---------------- level-set runs on three grids ----------------------
tReq = [0:2:24, 25];                          % output times (yr)
Ns   = [101 201 401];
err  = zeros(1,3);  dxs = zeros(1,3);
for q = 1:3
    fprintf('Running N = %d ...\n', Ns(q));
    [AA, dxs(q)] = runDisc(Ns(q), A0, VA, a, w, tReq);
    err(q) = abs(AA(end) - Aex);
    fprintf('   A_num = %.3f, A_exact = %.3f, error = %.4f (%.4f %%)\n', ...
            AA(end), Aex, err(q), 100*err(q)/Aex);
    if Ns(q) == 401, ASim = AA; end
end
p = polyfit(log(dxs), log(err), 1);           % observed order (log-log slope)
fprintf('Observed convergence order ~ %.2f\n', p(1));

%% ---------------- two-disc merging (analytic, Prop. 3) ----------------
A1 = 376.67; V1 = 3.3;                        % Swarna Dwip
A2 = 61.19;  V2 = 1.14;                       % Bhasan Char
gap = 2;                                      % ASSUMED initial gap (km)
R   = @(A,V,t) sqrt((A + V*G(t))/pi);         % with tide
Rm  = @(A,V,t) sqrt((A + V*t)/pi);            % mean rate, no tide
d   = R(A1,V1,0) + R(A2,V2,0) + gap;          % centre distance
t2  = linspace(0,30,601);
S   = R(A1,V1,t2)  + R(A2,V2,t2);
S0  = Rm(A1,V1,t2) + Rm(A2,V2,t2);
tF  = linspace(0,60,60001);
tStar = firstCross(R(A1,V1,tF)  + R(A2,V2,tF)  - d, tF);   % with tide
t0    = firstCross(Rm(A1,V1,tF) + Rm(A2,V2,tF) - d, tF);   % no tide
fprintf('Merging time: t* = %.2f yr (tide), t0 = %.2f yr (no tide), shift = %.2f yr (bound %.3f)\n', ...
        tStar, t0, t0-tStar, 2*a/w);

%% ---------------------------- PLOT -----------------------------------
figure('Color','w','Position',[80 80 1500 430]);

% (a) area vs time
subplot(1,3,1); hold on; box on; grid on;
tt = linspace(0,T,500);
h1 = plot(tt, A0 + VA*G(tt), 'k-', 'LineWidth',1.6);
h2 = plot(tReq, ASim, 'o', 'Color',red, 'MarkerFaceColor',red, 'MarkerSize',5);
h3 = plot(tt, A0 + VA*tt, '--', 'Color',gray, 'LineWidth',1.4);
xlabel('Time since 2025 (yr)'); ylabel('Area (km^2)');
title('(a) Urir Char-type disc');
legend([h1 h2 h3], {'Exact (Prop. 2)','Level-set, N = 401','Mean rate (no tide)'}, ...
       'Location','northwest');

% (b) convergence
subplot(1,3,2);
loglog(dxs, err, 'o-', 'Color',red, 'MarkerFaceColor',red, 'LineWidth',1.5); hold on;
loglog(dxs, err(1)*(dxs/dxs(1)).^p(1), 'k--', 'LineWidth',1.6);
grid on; box on;
xlabel('\Delta x (km)'); ylabel('Abs. area error (km^2)');
title('(b) Grid convergence');
legend({'Observed', sprintf('slope \\approx %.2f', p(1))}, 'Location','northwest');

% (c) merging
subplot(1,3,3); hold on; box on; grid on;
hA = plot(t2, S,  '-',  'Color',red,  'LineWidth',1.5);
hB = plot(t2, S0, '--', 'Color',gray, 'LineWidth',1.5);
hC = plot([0 30], [d d], 'k-', 'LineWidth',1);
yl = [min(S)-0.1, max(S)+0.1];  ylim(yl);
plot([tStar tStar], yl, ':', 'Color',red,  'LineWidth',1.6);
plot([t0 t0],       yl, ':', 'Color',gray, 'LineWidth',1.6);
xlabel('Time since 2025 (yr)'); ylabel('km');
title(sprintf('(c) Two-disc merging (\\delta_0 = %d km, assumed)', gap));
legend([hA hB hC], {'R_1 + R_2 with tide','R_1 + R_2 no tide','centre distance d'}, ...
       'Location','northwest');
drawnow;
% print(gcf,'fig9_validation.png','-dpng','-r200');   % uncomment to save
end

%% ------------------------- SUBFUNCTIONS ------------------------------
function [Aout, dx] = runDisc(N, A0, VA, a, w, tReq)
% Level-set evolution of a circular island:
%   phi_t + V |grad phi| = 0,  V = VA*g(t)/L(t),  g = 1 + a*sin(w t)
% L(t) is the perimeter (here 2*sqrt(pi*A)), Godunov upwind + forward Euler.
    L  = 10;  x = linspace(-L,L,N);  dx = x(2) - x(1);
    [X,Y] = meshgrid(x,x);
    R0  = sqrt(A0/pi);
    phi = sqrt(X.^2 + Y.^2) - R0;
    t = 0;  Cn = 0.5;  Aout = zeros(size(tReq));
    for q = 1:numel(tReq)
        while t < tReq(q) - 1e-12
            A  = landArea(phi,dx);
            V  = VA*(1 + a*sin(w*t))/(2*sqrt(pi*A));
            dt = min([Cn*dx/max(abs(V),1e-9), tReq(q)-t, 0.05]);
            phi = phi - dt*V*upwindGrad(phi,dx,V);
            t = t + dt;
        end
        Aout(q) = landArea(phi,dx);
    end
end

function G = upwindGrad(phi,dx,V)
% Godunov upwind |grad phi| for phi_t + V|grad phi| = 0
    am = (phi - circshift(phi, 1,2))/dx;  ap = (circshift(phi,-1,2) - phi)/dx;
    bm = (phi - circshift(phi, 1,1))/dx;  bp = (circshift(phi,-1,1) - phi)/dx;
    if V >= 0
        G = sqrt(max(am,0).^2 + min(ap,0).^2 + max(bm,0).^2 + min(bp,0).^2);
    else
        G = sqrt(min(am,0).^2 + max(ap,0).^2 + min(bm,0).^2 + max(bp,0).^2);
    end
end

function A = landArea(phi,dx)
% Land area (km^2) with a smoothed Heaviside of width 1.5*dx
    e  = 1.5*dx;
    H  = double(phi < -e);
    in = abs(phi) <= e;
    H(in) = 0.5*(1 - phi(in)/e - sin(pi*phi(in)/e)/pi);
    A  = sum(H(:))*dx*dx;
end

function tc = firstCross(f,t)
% First time at which f crosses from negative to >= 0 (linear interpolation)
    idx = find(f >= 0, 1);
    if isempty(idx), tc = NaN; return; end
    if idx == 1, tc = t(1); return; end
    tc = t(idx-1) + (0 - f(idx-1))*(t(idx)-t(idx-1))/(f(idx)-f(idx-1));
end