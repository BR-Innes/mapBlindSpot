function mapBlindSpot 
%% mapBlindSpot 
% 
% A mod of Peter Scarfe's tutorial.
% Reference: http://peterscarfe.com/keyboardsquaredemo.html
% 
% This function presents a fixation point and a large circle, the position
% and size of which you can change.
% You can use this to map your blindspot by fixating on the point with one
% eye closed and altering the properties of the circle. 
% The function will return a rough location and size value for your
% blindspot (note: this is based on estimates of the monitor size and your
% viewing distance only). 
% 
% CONTROLS
% Move          - Arrow Keys
% Make Smaller  - C
% Make Bigger   - V
% End           - Esc 
%

%% Main Function  

%~ Clear the workspace and the screen
sca;
close all;
clearvars;
myTimingSucksMode = true; 

%~ Psych Default Setup (Unify Keynames/FP Colour Range) 
PsychDefaultSetup(2)

%~ Skip Sync (if using laptop w/graphics issues) 
if myTimingSucksMode
    Screen('Preference', 'SkipSyncTests', 1);
    Screen('Preference','SuppressAllWarnings', 1);
    Screen('Preference','VisualDebugLevel', 0); 
end 

%~ Screen Variables 
scr.background = []; 
scr.foreground = []; 
scr.window = []; 
scr.windowRect = []; 
scr.height = []; 
scr.width = []; 
scr.cenX = []; 
scr.cenY = [];
scr.ifi = []; 
scr.vbl = []; 
scr.waitFrames = [];
scr.exit = false; 

%~ Estimates 
scr.dist = 570; % [mm]
scr.widthmm  = 520; 
scr.heighmm  = 320; 
scr.dotPitch = 0.2692; 

deg2pix = pi / 180 * scr.dist / scr.dotPitch;

%~ Circle Variables
cir.diam = 100; 
cir.size = [0 0 cir.diam cir.diam];
cir.cenX = []; 
cir.cenY = []; 
cir.colour = [1, 0, 0]; 
cir.centered = [];
cir.minSize = 20; 
cir.maxSize = 200; 

%~ Controls 
% For diagonal movement I sort the key combinations because find gives you
% them in order, and it's important for evaluating whether the key combos
% equal your conditionals

ctrls.esc           = KbName('ESCAPE');
ctrls.up            = KbName('UpArrow');
ctrls.down          = KbName('DownArrow');
ctrls.left          = KbName('LeftArrow');
ctrls.right         = KbName('RightArrow'); 
ctrls.small         = KbName('c'); 
ctrls.big           = KbName('v'); 
ctrls.leftUp        = sort([ctrls.left,  ctrls.up]); 
ctrls.rightUp       = sort([ctrls.right, ctrls.up]); 
ctrls.leftDown      = sort([ctrls.left,  ctrls.down]); 
ctrls.rightDown     = sort([ctrls.right, ctrls.down]);
ctrls.movePerPress  = 10; % pixels
ctrls.growPerPress  = 5;  

%~ PTB Setup 
screens = Screen('Screens');
scr.number = max(screens);

scr.foreground = WhiteIndex(scr.number);
scr.background = BlackIndex(scr.number);

[scr.window, scr.windowRect] = PsychImaging('OpenWindow', scr.number, scr.background);
[scr.width, scr.height] = Screen('WindowSize', scr.window);
[scr.cenX, scr.cenY] = RectCenter(scr.windowRect);
scr.ifi = Screen('GetFlipInterval', scr.window);

%~ Circle Setup
cir.cenX = scr.cenX;
cir.cenY = scr.cenY;

%~ Sync
scr.vbl = Screen('Flip', scr.window);
scr.waitFrames = 1;

%~ Priority Set 
topPriorityLevel = MaxPriority(scr.window);
Priority(topPriorityLevel);

%~ Animation Loop 
while scr.exit == false 
    
    %~ Check Keys 
    [~,~,keyCode] = KbCheck;
    pressedKeys = find(keyCode); 
    [ctrls, cir, scr] = controlInput(pressedKeys, ctrls, cir, scr);
    
    %~ Replot Circle 
    cir.centered = CenterRectOnPointd(cir.size, cir.cenX, cir.cenY);

    %~ Draw Circle
    Screen('FillOval', scr.window, cir.colour, cir.centered); 
    Screen('gluDisk', scr.window, [1, 1, 1], scr.cenX, scr.cenY, 5);
     
    %~ Flip 
    scr.vbl  = Screen('Flip', scr.window, scr.vbl + (scr.waitFrames - 0.5) * scr.ifi);
    
end

%~ Command Line Output
xC = cir.centered(1)+(cir.size(3)/2)-scr.cenX;
yC = cir.centered(2)+(cir.size(3)/2)-scr.cenY;
disp(' '); 
disp('BLIND SPOT DETAILS **************************************************'); 
disp(['Co-ordinates:  X = ' num2str(xC / deg2pix) ', Y = ' num2str(-yC / deg2pix)]); 
disp(['Size:          ' num2str(cir.size(3) / deg2pix) ' degrees']); 
disp('*********************************************************************'); 

%~ Clear screen
sca;
end 

function [ctrls, cir, scr] = controlInput(pressedKeys, ctrls, cir, scr) 
    
    %~ Check Button Combo 
    if length(pressedKeys) == 1
        if pressedKeys == ctrls.esc
            scr.exit = true;
        elseif pressedKeys == ctrls.left
            cir.cenX = cir.cenX - ctrls.movePerPress;
        elseif pressedKeys == ctrls.right
            cir.cenX = cir.cenX + ctrls.movePerPress;
        elseif pressedKeys == ctrls.up
            cir.cenY = cir.cenY - ctrls.movePerPress;
        elseif pressedKeys == ctrls.down
            cir.cenY = cir.cenY + ctrls.movePerPress;
        elseif pressedKeys == ctrls.small
            if cir.size(3) >= cir.minSize && cir.size(4) >= cir.minSize 
                [cir.size(3), cir.size(4)] = ...
                    deal(cir.size(3)-ctrls.growPerPress, cir.size(4)-ctrls.growPerPress); 
            end 
        elseif pressedKeys == ctrls.big
            if cir.size(3) <= cir.maxSize && cir.size(4) <= cir.maxSize
                [cir.size(3), cir.size(4)] = ...
                    deal(cir.size(3)+ctrls.growPerPress, cir.size(4)+ctrls.growPerPress); 
            end 
        end 
    	
    elseif length(pressedKeys) == 2
        if pressedKeys == ctrls.leftUp
            cir.cenX = cir.cenX - ctrls.movePerPress;
            cir.cenY = cir.cenY - ctrls.movePerPress;
        elseif pressedKeys == ctrls.leftDown
            cir.cenX = cir.cenX - ctrls.movePerPress;
            cir.cenY = cir.cenY + ctrls.movePerPress;
        elseif pressedKeys == ctrls.rightUp
            cir.cenX = cir.cenX + ctrls.movePerPress;
            cir.cenY = cir.cenY - ctrls.movePerPress;
        elseif pressedKeys == ctrls.rightDown
            cir.cenX = cir.cenX + ctrls.movePerPress;
            cir.cenY = cir.cenY + ctrls.movePerPress;
        end 
    end 

    %~ Eccentricity Checks
    if cir.cenX < 0
        cir.cenX = 0;
    elseif cir.cenX > scr.width
        cir.cenX = scr.width;
    end

    if cir.cenY < 0
        cir.cenY = 0;
    elseif cir.cenY > scr.height
        cir.cenY = scr.height;
    end
    
end 
