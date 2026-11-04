clc;
clear;
close all;

%% =========================================================
% RESCUEBOT COMPLETE ALGORITHM MODEL
% FULL VISUAL FLOW GENERATOR
% EVERYTHING ON SINGLE SIMULINK PAGE
%% =========================================================

model = 'RescueBot_Complete_Algorithm';

%% ---------------------------------------------------------
% DELETE OLD MODEL IF EXISTS
%% ---------------------------------------------------------

if bdIsLoaded(model)
    close_system(model,0);
end

if exist([model '.slx'],'file')
    delete([model '.slx']);
end

%% ---------------------------------------------------------
% CREATE MODEL
%% ---------------------------------------------------------

new_system(model);
open_system(model);

%% =========================================================
% BLOCK POSITIONS
%% =========================================================

x1 = 50;
x2 = 250;
x3 = 500;
x4 = 800;
x5 = 1100;
x6 = 1450;

y1 = 50;
gap = 120;

%% =========================================================
% START BUTTON
%% =========================================================

add_block('simulink/Sources/Constant', ...
    [model '/START_BUTTON'], ...
    'Value','1', ...
    'Position',[x1 y1 x1+60 y1+40]);

%% =========================================================
% SENSOR BLOCKS
%% =========================================================

sensorNames = {'distL','distC','distR','movingFlag','presenceFlag'};

sensorValues = {'100','100','100','0','0'};

for i = 1:length(sensorNames)

    ypos = y1 + i*gap;

    add_block('simulink/Sources/Constant', ...
        [model '/' sensorNames{i}], ...
        'Value',sensorValues{i}, ...
        'Position',[x1 ypos x1+70 ypos+40]);

end

%% =========================================================
% STARTUP LOGIC
%% =========================================================

startupBlocks = { ...
    'Disable_All', ...
    'Init_Left', ...
    'Assign_0x30', ...
    'Init_Center', ...
    'Assign_0x31', ...
    'Init_Right', ...
    'Startup_Done'};

for i = 1:length(startupBlocks)

    ypos = y1 + (i-1)*gap;

    add_block('simulink/Commonly Used Blocks/Gain', ...
        [model '/' startupBlocks{i}], ...
        'Gain','1', ...
        'Position',[x2 ypos x2+100 ypos+50]);

end

%% =========================================================
% SENSOR READ DISPLAY
%% =========================================================

for i = 1:3

    ypos = y1 + i*gap;

    add_block('simulink/Sinks/Display', ...
        [model ['/Display_' sensorNames{i}]], ...
        'Position',[x2+180 ypos x2+250 ypos+40]);

end

%% =========================================================
% OBSTACLE CHECKS
%% =========================================================

obstacleBlocks = {'Check_Left',...
                  'Check_Center',...
                  'Check_Right'};

for i = 1:3

    ypos = y1 + i*gap;

    add_block('simulink/Logic and Bit Operations/Compare To Constant', ...
        [model '/' obstacleBlocks{i}], ...
        'const','25', ...
        'Position',[x3 ypos x3+100 ypos+50]);

end

%% =========================================================
% HUMAN DETECTION CHECK
%% =========================================================

add_block('simulink/Logic and Bit Operations/Logical Operator', ...
    [model '/Human_AND'], ...
    'Operator','AND', ...
    'Inputs','2', ...
    'Position',[x3 y1+500 x3+100 y1+550]);

add_block('simulink/Logic and Bit Operations/Compare To Constant', ...
    [model '/Human_Range_Check'], ...
    'const','150', ...
    'Position',[x3 y1+620 x3+120 y1+670]);

%% =========================================================
% DEBOUNCE COUNTERS
%% =========================================================

for i = 1:3

    ypos = y1 + i*gap;

    add_block('simulink/Discrete/Counter Free-Running', ...
        [model ['/Counter_' num2str(i)]], ...
        'Position',[x4 ypos x4+80 ypos+50]);

end

%% =========================================================
% 3 READ VALIDATION
%% =========================================================

for i = 1:3

    ypos = y1 + i*gap;

    add_block('simulink/Logic and Bit Operations/Compare To Constant', ...
        [model ['/Three_Reads_' num2str(i)]], ...
        'const','3', ...
        'Position',[x4+150 ypos x4+250 ypos+50]);

end

%% =========================================================
% STATEFLOW CHART
%% =========================================================

add_block('sflib/Chart', ...
    [model '/ROBOT_STATE_MACHINE'], ...
    'Position',[x5 150 x5+400 700]);

%% =========================================================
% DECISION ENGINE
%% =========================================================

decisionBlocks = { ...
    'Move_Forward',...
    'Turn_Left',...
    'Turn_Right',...
    'Stop_Robot',...
    'Reverse',...
    'UTurn'};

for i = 1:length(decisionBlocks)

    ypos = y1 + (i-1)*100;

    add_block('simulink/Commonly Used Blocks/Switch', ...
        [model '/' decisionBlocks{i}], ...
        'Position',[x6 ypos x6+100 ypos+50]);

end

%% =========================================================
% MOTOR OUTPUTS
%% =========================================================

motorOutputs = {'LEFT_PWM','RIGHT_PWM'};

for i = 1:2

    ypos = y1 + i*200;

    add_block('simulink/Sinks/Display', ...
        [model '/' motorOutputs{i}], ...
        'Position',[x6+250 ypos x6+320 ypos+50]);

end

%% =========================================================
% ROBOT PATH VISUALIZATION
%% =========================================================

add_block('simulink/Sinks/XY Graph', ...
    [model '/ROBOT_PATH'], ...
    'Position',[x6+400 200 x6+600 450]);

%% =========================================================
% CONNECT SENSOR INPUTS
%% =========================================================

add_line(model,'distL/1','Display_distL/1');
add_line(model,'distC/1','Display_distC/1');
add_line(model,'distR/1','Display_distR/1');

%% =========================================================
% CONNECT OBSTACLE CHECKS
%% =========================================================

add_line(model,'distL/1','Check_Left/1');
add_line(model,'distC/1','Check_Center/1');
add_line(model,'distR/1','Check_Right/1');

%% =========================================================
% CONNECT COUNTERS
%% =========================================================

add_line(model,'Check_Left/1','Counter_1/1');
add_line(model,'Check_Center/1','Counter_2/1');
add_line(model,'Check_Right/1','Counter_3/1');

%% =========================================================
% CONNECT 3 READ VALIDATION
%% =========================================================

add_line(model,'Counter_1/1','Three_Reads_1/1');
add_line(model,'Counter_2/1','Three_Reads_2/1');
add_line(model,'Counter_3/1','Three_Reads_3/1');

%% =========================================================
% CONNECT HUMAN DETECTION
%% =========================================================

add_line(model,'movingFlag/1','Human_AND/1');
add_line(model,'presenceFlag/1','Human_AND/2');

add_line(model,'distC/1','Human_Range_Check/1');

%% =========================================================
% CONNECT TO STATE MACHINE
%% =========================================================

add_line(model,'Three_Reads_1/1','ROBOT_STATE_MACHINE/1');
add_line(model,'Three_Reads_2/1','ROBOT_STATE_MACHINE/2');
add_line(model,'Three_Reads_3/1','ROBOT_STATE_MACHINE/3');

add_line(model,'Human_AND/1','ROBOT_STATE_MACHINE/4');
add_line(model,'Human_Range_Check/1','ROBOT_STATE_MACHINE/5');

%% =========================================================
% MODEL SETTINGS
%% =========================================================

set_param(model,'StopTime','30');

%% =========================================================
% AUTO ARRANGE
%% =========================================================

Simulink.BlockDiagram.arrangeSystem(model);

%% =========================================================
% SAVE MODEL
%% =========================================================

save_system(model);

%% =========================================================
% OPEN MODEL
%% =========================================================

open_system(model);

%% =========================================================
% DONE
%% =========================================================

disp('============================================');
disp(' RESCUEBOT COMPLETE ALGORITHM GENERATED ');
disp('============================================');
disp('NEXT STEP:');
disp('1. Double click ROBOT_STATE_MACHINE');
disp('2. Add states:');
disp('   IDLE');
disp('   STARTUP');
disp('   EXPLORING');
disp('   OBSTACLE_AVOID');
disp('   HUMAN_CONFIRMING');
disp('   HUMAN_FOUND');
disp('============================================');