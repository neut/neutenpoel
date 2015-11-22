% Lichtenberg simulation script for 3D simulating a Lichtenberg figure.
% This script is an extension of the original Neutenpoel script by M.W.M. Neut
% and E.P. van der Poel
%
% ==============================================================================
% Licence:
%   This code is distributed under the GNU General Public Licence.
% 
% Authors:
%   Original version:
%       M.W.M. Neut <m.neut@immend.com>
%       E.P. van der Poel <e.p.vanderpoel@immend.com>
%
%   Extension to 3 dimensions:
%       M. van Dijk <mwvandijk@gmail.com>
% ==============================================================================

close all;
clear all;

% -------- Aan te passen vars -------- %

rib = 21;           % lxbxh waarde voor grootte kubus
initx = 3;          % waarden voor de x y en z origin
inity = 3;
initz = 1;
initPotential = 1;  % Potentiaalverschil initpunt met rest in arb. units

cubeAdd = 0.025;    % optelwaarde voor waardering van de punten
maxSpark = 1;       % hoeveel stappen meg de spark maximaal maken
visible = 0;        % welke lijnen worden wel en niet geplot. Dit is een
                    % waarde tussen 0 en 1, met 0 is alle lijnen en 1 geen
                    % enkele.

% ----- Einde aan te passen vars ----- %

cube = ones(rib, rib, rib);
checked = zeros(rib, rib, rib);

lines = 0;

checked(initx, inity, initz) = 1;

for x = 1:rib
    for y = 1:rib
        for z = 1:rib
            cube(x, y, z) = cube(x, y, z) + initPotential / (sqrt((initx - x)^2 + (inity - y)^2 + (initz - z)^2) + 1);
        end
    end
end

allRoute = 0;
stillZeros = true;
%% lichtenberg3D

while stillZeros
    
    %% checkForZeros
    
    stillZeros = false;
    for x = 1:rib
        for y = 1:rib
            for z = 1:rib
                if checked(x, y, z) == 0
                    stillZeros = true;
                    break;
                end
            end
            if stillZeros
                break;
            end
        end
        if stillZeros
            break;
        end
    end
    
    if ~stillZeros
        % geen enkele coord is nog 1
        break;
    end
    
    
    
    %% randomCoords
    
    availableCoords = [0 0 0];
    for x = 1:rib
        for y = 1:rib
            for z = 1:rib
                if checked(x, y, z) == 0
                    availableCoords(size(availableCoords, 1) + 1, 1) = x;
                    availableCoords(size(availableCoords, 1), 2) = y;
                    availableCoords(size(availableCoords, 1), 3) = z;
                end
            end
        end
    end
    
    randNum = ceil(rand(1) * (size(availableCoords, 1) - 1)) + 1;
    
    coord.x = availableCoords(randNum, 1);
    coord.y = availableCoords(randNum, 2);
    coord.z = availableCoords(randNum, 3);
    
    checked(coord.x, coord.y, coord.z) = 1;
    cube(coord.x, coord.y, coord.z) = cube(coord.x, coord.y, coord.z) + 1;
    
    
    
    %% createRoute
    
    route(1,1) = coord.x;
    route(1,2) = coord.y;
    route(1,3) = coord.z;
    
    while coord.x ~= initx || coord.y ~= inity || coord.z ~= initz
        
        %% determainNextStep
        
        weightValues = zeros(rib, rib, rib);
        for x = coord.x - maxSpark:coord.x + maxSpark
            for y = coord.y - maxSpark:coord.y + maxSpark
                for z = coord.z - maxSpark:coord.z + maxSpark
                    if x < rib && x > 0 && y < rib && y > 0 && z < rib && z > 0
                        if x == coord.x && y == coord.y && z == coord.z
                            weightValues(x, y, z) = 0;
                        else
                            weightValues(x, y, z) = cube(x, y, z) / sqrt((coord.x - x)^2 + (coord.y - y)^2 + (coord.z - z)^2);
                        end
                    end
                end
            end
        end
        
        nextStepInRoute = true;
%         nextStepCrossRoute = true;
        while nextStepInRoute % && nextStepCrossRoute
            
            [C, Iz] = max(max(max(weightValues)));
            [C, Iy] = max(max(weightValues(:,:,Iz)));
            [C, Ix] = max(weightValues(:,Iy,Iz));
            
            nextStepInRoute = false;
            for i = 1:size(route, 1)
                if route(i, 1) == Ix && route(i, 2) == Iy && route(i, 3) == Iz
                    nextStepInRoute = true;
                    weightValues(Ix, Iy, Iz) = 0;
                    break;
                end
            end
            
%             nextStepCrossRoute = false;
%             if allRoute ~= 0 && (route(i, 1) == Ix || route(i, 2) == Iy || route(i, 3) == Iz)
%                 for i = 1:size(allRoute, 3)
%                     for lineNo = 1:size(allRoute, 1) - 1
%                         
%                         if allRoute(lineNo, 1, i) == Ix &&  allRoute(lineNo + 1, 1, i) == Ix
%                             if allRoute(lineNo, 2, i)
%                         end
%                         if allRoute(lineNo, 2, i) == Ix &&  allRoute(lineNo + 1, 2, i) == Ix
%                         end
%                         if allRoute(lineNo, 3, i) == Ix &&  allRoute(lineNo + 1, 3, i) == Ix
%                         end
%                     end
%                 end
%             end
            
            
        end
        
        coord.x = Ix;
        coord.y = Iy;
        coord.z = Iz;
        
        route(size(route, 1) + 1, 1) = coord.x;
        route(size(route, 1), 2) = coord.y;
        route(size(route, 1), 3) = coord.z;
        
        checked(coord.x, coord.y, coord.z) = 1;
        cube(coord.x, coord.y, coord.z) = cube(coord.x, coord.y, coord.z) + cubeAdd;
        
        
        %% rememberLines
        
        if lines == 0
            lines = [route(size(route, 1) - 1, 1) route(size(route, 1) - 1, 2) route(size(route, 1) - 1, 3) coord.x coord.y coord.z];
        else
            lines = [lines; route(size(route, 1) - 1, 1) route(size(route, 1) - 1, 2) route(size(route, 1) - 1, 3) coord.x coord.y coord.z];
        end        
        
        
        %% checkForExistingLines
        
        followRoute = false;
        for i = 1:size(allRoute, 3)
            for lineNo = 1:size(allRoute, 1)
                    
                if coord.x == allRoute(lineNo, 1, i) &&...
                        coord.y == allRoute(lineNo, 2, i) &&...
                        coord.z == allRoute(lineNo, 3, i)
                    
                    followRoute = true;
                    break;
                end
            end
            if followRoute == true
                break;
            end
        end
        
        if followRoute
            for j = lineNo + 1:size(allRoute, 1)
                if allRoute(j, 1, i) ~= 0 &&...
                        allRoute(j, 2, i) ~= 0 &&...
                        allRoute(j, 3, i) ~= 0
                    
                    cube(allRoute(j, 1, i), allRoute(j, 2, i), allRoute(j, 3, i)) = cube(allRoute(j, 1, i), allRoute(j, 2, i), allRoute(j, 3, i)) + cubeAdd;
                    
                    route(size(route, 1) + 1, 1) = allRoute(j, 1, i);
                    route(size(route, 1), 2) = allRoute(j, 2, i);
                    route(size(route, 1), 3) = allRoute(j, 3, i);
                    
                    
                    lines = [lines; route(size(route, 1) - 1, 1) route(size(route, 1) - 1, 2) route(size(route, 1) - 1, 3)...
                        route(size(route, 1), 1), route(size(route, 1), 2), route(size(route, 1), 3)];
                    
                    
                end
            end
            
            coord.x = initx;
            coord.y = inity;
            coord.z = initz;
        end
       

    end
    
    if allRoute == 0
        allRoute = route;
    else
        allRoute(1:size(route, 1), 1:size(route, 2), size(allRoute, 3) + 1) = route;
    end
    clear route;
    
    
end

%% plotLinesInGraph

set(0, 'DefaultFigureColor', [0 0 0.4], 'DefaultAxesColor', [0 0 0.4]);


initPlot = figure(1);
% set(initPlot, 'Color', [0 0 0.4]);
% axes(initPlot, 'Color', 'none');
plot3(initx, inity, initz);
hold on;

[sortedLines, useless, times] = unique(lines, 'rows');

thickness = zeros(size(sortedLines, 1), 1);
for i = 1:size(times, 1)
    thickness(times(i, 1), 1) = thickness(times(i, 1), 1) + 1;
end


for i = 1:size(thickness, 1)
    if thickness(i, 1) > visible * max(thickness)
        
        colorCode = (1 / (max(thickness) * 1.1)) * thickness(i, 1);
        lijnWidth = ceil((10 / max(thickness)) * thickness(i, 1));
        lijntjes = plot3([sortedLines(i, 1) sortedLines(i, 4)], [sortedLines(i, 2) sortedLines(i, 5)], [sortedLines(i, 3) sortedLines(i, 6)], 'LineWidth', lijnWidth);
                            
        set(lijntjes, 'Color', [colorCode colorCode 1]);
    end
end

hold off;

xlim([1 rib]);
ylim([1 rib]);
zlim([1 rib]);

xlabel('x');
ylabel('y');
zlabel('z');