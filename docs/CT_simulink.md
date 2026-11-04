# 🎯 COMPLETE SIMULINK MODELS - COPY-PASTE READY
## Ultra-Detailed Step-by-Step (Bruh, This Is Everything!)

---

## **PART 0: SETUP BEFORE YOU START**

### **Prerequisites:**
```
✅ MATLAB installed (R2021b or later)
✅ Simulink installed
✅ Control Systems Toolbox (for PID)
✅ Signal Processing Toolbox (optional, for scopes)
```

### **File Locations:**
```
Create a folder: C:\Users\YourName\My Documents\MATLAB\SwarmRobots\

Inside, create:
  model1_pid_navigation\
  model2_swarm_system\
  model3_fault_tolerance\
  model4_trajectory\
```

---

# **🤖 MODEL 1: ROBOT PID NAVIGATION**
## Single Robot Autonomous Navigation

### **What This Model Does:**
```
Robot approaches obstacle until it reaches desired distance
PID controller adjusts motor PWM to maintain distance
Shows: Error, Control Signal, and Position in real-time
```

### **STEP 1: Create New Model**

```
Open MATLAB
File → New → Model
Ctrl+S → Save as "model1_pid_navigation.slx"
Location: C:\Users\YourName\My Documents\MATLAB\SwarmRobots\model1_pid_navigation\
```

### **STEP 2: Add Constant - Desired Distance**

```
Left panel → Simulink → Sources → Constant
Drag onto canvas
Double-click it
  ✏️ Constant value: 0.5
  ✏️ Interpret vector parameters as 1-D: ☑
Save block name: desired_distance

Position: Top-left of canvas
```

### **STEP 3: Add Pulse Generator - Distance Sensor**

```
Simulink → Sources → Pulse Generator
Drag onto canvas
Double-click it
  ✏️ Amplitude: 2
  ✏️ Period (secs): 10
  ✏️ Pulse Width (%): 50
  ✏️ Phase Delay: 0
  ✏️ Sample time: -1

Save block name: distance_sensor_input
Position: Top-right of canvas
```

### **STEP 4: Add Sum Block - Error Calculator**

```
Simulink → Math Operations → Sum
Drag onto canvas
Double-click it
  ✏️ List of signs: +-
  ✏️ Icon shape: rectangular
  ✏️ Collapse mode: off

Name it: error_calculator
Position: Center-top

Connect:
  desired_distance → [+] input of Sum
  distance_sensor_input → [-] input of Sum
```

### **STEP 5: Add PID Controller**

```
Simulink → Continuous → PID Controller
Drag onto canvas
Double-click it:
  ✏️ Controller: PID
  ✏️ Form: Parallel
  ✏️ P (Proportional gain): 2
  ✏️ I (Integral gain): 0.5
  ✏️ D (Derivative gain): 0.1
  ✏️ Filter coefficient N: 100
  ✏️ Integrator method: Forward Euler
  ✏️ Derivative filter: Tustin

Click "Apply" then "OK"
Name it: PID_Controller
Position: Center of canvas

Connect:
  error_calculator output → PID_Controller input
```

### **STEP 6: Add First-Order Transfer Function - Motor Model**

```
Simulink → Continuous → Transfer Fcn
Drag onto canvas
Double-click it:
  ✏️ Numerator: [1]
  ✏️ Denominator: [0.1 1]
  (This means: tau=0.1s, steady-state gain=1)

Name it: motor_model
Position: Center-right

Connect:
  PID_Controller output → Transfer Fcn input
```

### **STEP 7: Add Gain - Motor to Velocity**

```
Simulink → Math Operations → Gain
Drag onto canvas
Double-click it:
  ✏️ Gain: 1
  ✏️ Multiplication: Element-wise (K.*u)

Name it: motor_gain
Position: Right of motor_model

Connect:
  motor_model output → motor_gain input
```

### **STEP 8: Add Integrator - Velocity to Position**

```
Simulink → Continuous → Integrator
Drag onto canvas
Double-click it:
  ✏️ Initial condition: 0
  ✏️ Limit output: off
  ✏️ Wrap state: off

Name it: position_integrator
Position: Right of motor_gain

Connect:
  motor_gain output → position_integrator input
```

### **STEP 9: Create Feedback Loop**

```
Draw connection line from position_integrator output
Run line backward along bottom
Connect to distance_sensor_input
(This is negative feedback - actual distance feeds back)

Now the loop is closed!
```

### **STEP 10: Add Scope - Error Monitoring**

```
Simulink → Sinks → Scope
Drag onto canvas (left side)
Double-click it:
  ✏️ Number of axes: 1
  ✏️ Time range: 50
  ✏️ Ymin: -1
  ✏️ Ymax: 2

Name it: scope_error
Position: Left side

Connect:
  error_calculator output → scope_error input
```

### **STEP 11: Add Scope - Control Signal**

```
Simulink → Sinks → Scope
Drag onto canvas (middle-left)
Settings same as above but:
  ✏️ Ymin: -5
  ✏️ Ymax: 5

Name it: scope_control_signal
Position: Middle-left

Connect:
  PID_Controller output → scope_control_signal input
```

### **STEP 12: Add Scope - Position Monitoring**

```
Simulink → Sinks → Scope
Drag onto canvas (right side)
Settings same as above but:
  ✏️ Ymin: 0
  ✏️ Ymax: 2.5

Name it: scope_position
Position: Right side

Connect:
  position_integrator output → scope_position input
```

### **STEP 13: Set Simulation Parameters**

```
Top menu → Simulation → Model Configuration Parameters
  ✏️ Stop time: 50
  ✏️ Solver: ode45 (Dormand-Prince)
  ✏️ Max step size: auto
  ✏️ Min step size: auto
  ✏️ Relative tolerance: 1e-3
  ✏️ Absolute tolerance: auto

Click "OK"
```

### **STEP 14: Visual Block Diagram (What You Should See)**

```
┌──────────────────┐
│ desired_distance │    ┌────────┐
│      (0.5)       │───→│        │
└──────────────────┘    │  Sum   │     ┌──────────┐
                        │ (error)│────→│ PID      │    ┌────────┐
┌──────────────────┐    │        │     │Controller│───→│ Motor  │
│ distance_sensor  │───→│        │     └──────────┘    │ Model  │
│  (Pulse Gen)     │    └────────┘                     └────────┘
└──────────────────┘                                        │
         ↑                                                   ▼
         │                                                 ┌──────┐
         │              ┌───────────────────────────────→│ Gain │
         │              │                                │      │
         │              │                                └──────┘
         │              │                                   │
         │              │                                   ▼
         │              │                              ┌──────────┐
         │              │                              │Integrator│
         │              │                              │(Position)│
         │              └──────────────────────────────│          │
         │                                             └──────────┘
         │
    (Feedback loop connects output back to input)

SCOPES:
  error_calculator output → [Scope Error]
  PID output → [Scope Control Signal]
  position_integrator output → [Scope Position]
```

### **STEP 15: Run Simulation**

```
Press Ctrl+T or click "Run" button
Wait for simulation to complete (10 seconds)
Double-click each scope to see plots:

Expected results:
  Scope 1 (Error): Starts at -1.5, decreases to ~0
  Scope 2 (Control): Starts high, settles to low
  Scope 3 (Position): Rises from 2.0 toward 0.5

✅ Model 1 is DONE!
```

---

# **🤖 MODEL 2: SWARM ROBOT SYSTEM**
## 3 Robots Operating Together

### **What This Model Does:**
```
3 independent robots with PID controllers
Each robot has different setpoint
Robots communicate via simulated ESP-NOW
Shows all 3 positions in real-time
```

### **STEP 1: Create Robot Unit Subsystem**

**First, save Model 1 properly:**
```
File → Save As
Location: C:\...\model1_pid_navigation\
Name: model1_pid_navigation.slx
```

**Create Robot Unit:**
```
File → New → Model
Save as: robot_unit.slx
Location: C:\...\model2_swarm_system\
```

### **STEP 2: Build Robot Unit (Same as Model 1 but with inputs)**

```
Add these blocks:
  1. In1 (Simulink → Ports & Subsystems → In1) - desired_distance input
  2. In2 (another In1) - sensor_input
  
  3. Sum → PID → Motor → Gain → Integrator
  4. Out1 (Simulink → Ports & Subsystems → Out1) - position output
  5. Out2 (another Out1) - motor_output

Full structure:
  desired_distance [In1] ──→ [Sum] ──→ [PID] ──→ [Motor] ──→ [Integrator] ──→ [Out1]
                             ↑
  sensor_input [In2] ────────┘

Parameters same as Model 1:
  PID_P=2, PID_I=0.5, PID_D=0.1
  Motor tau=0.1
```

**Save Robot Unit:**
```
File → Save
(Keep as robot_unit.slx)
```

### **STEP 3: Create Swarm System Model**

```
File → New → Model
Save as: model2_swarm_system.slx
Location: C:\...\model2_swarm_system\
```

### **STEP 4: Add 3 Robot Units**

```
In the new model:

Simulink → Subsystems → Subsystem (or drag robot_unit.slx)
Drag 3 times on canvas
Name them:
  Robot_1
  Robot_2
  Robot_3

Position:
  Robot_1: Top-left
  Robot_2: Top-middle
  Robot_3: Top-right
```

### **STEP 5: Add Setpoints for Each Robot**

```
For Robot_1:
  Constant block: value = 0.5
  Name: setpoint_r1
  Connect to Robot_1 In1

For Robot_2:
  Constant block: value = 1.0
  Name: setpoint_r2
  Connect to Robot_2 In1

For Robot_3:
  Constant block: value = 1.5
  Name: setpoint_r3
  Connect to Robot_3 In1
```

### **STEP 6: Add Sensor Inputs**

```
For Robot_1:
  Pulse Generator: Amplitude=2, Period=10, Phase=0
  Name: sensor_r1
  Connect to Robot_1 In2

For Robot_2:
  Pulse Generator: Amplitude=2.5, Period=12, Phase=1
  Name: sensor_r2
  Connect to Robot_2 In2

For Robot_3:
  Pulse Generator: Amplitude=2, Period=11, Phase=2
  Name: sensor_r3
  Connect to Robot_3 In2
```

### **STEP 7: Add Communication Simulation**

```
Create MATLAB Function block:

Simulink → User-Defined Functions → MATLAB Function

Paste this code:

function [r1_adj, r2_adj, r3_adj] = communication(pos1, pos2, pos3)
    % Simulate ESP-NOW communication
    % Robots within 5m can share information
    
    COMM_RANGE = 5.0;
    
    % Calculate distances between robots
    d12 = abs(pos1 - pos2);
    d23 = abs(pos2 - pos3);
    d13 = abs(pos1 - pos3);
    
    % Initialize adjustments
    r1_adj = 0;
    r2_adj = 0;
    r3_adj = 0;
    
    % If robots 1-2 in range
    if d12 < COMM_RANGE
        r1_adj = pos2 * 0.05;  % 5% influence from robot 2
        r2_adj = pos1 * 0.05;  % 5% influence from robot 1
    end
    
    % If robots 2-3 in range
    if d23 < COMM_RANGE
        r2_adj = r2_adj + pos3 * 0.05;
        r3_adj = pos2 * 0.05;
    end
    
    % If robots 1-3 in range
    if d13 < COMM_RANGE
        r1_adj = r1_adj + pos3 * 0.05;
        r3_adj = r3_adj + pos1 * 0.05;
    end
end

Name it: esp_now_simulator
Position: Middle of canvas
```

### **STEP 8: Connect Communication**

```
Extract outputs from each robot:
  Robot_1 output (position) → communication input pos1
  Robot_2 output (position) → communication input pos2
  Robot_3 output (position) → communication input pos3
```

### **STEP 9: Add Displays**

```
Add 3 Display blocks (Sinks → Display):

Display 1:
  Name: display_r1
  Connect: Robot_1 position output
  
Display 2:
  Name: display_r2
  Connect: Robot_2 position output
  
Display 3:
  Name: display_r3
  Connect: Robot_3 position output
```

### **STEP 10: Add XY Plot**

```
Simulink → Sinks → XY Graph
  Name: swarm_position_plot
  X-axis: Robot_1 position
  Y-axis: Robot_2 position
  
(This shows 2D visualization of swarm movement)

Connect Robot_1 position to X input
Connect Robot_2 position to Y input
```

### **STEP 11: Full Block Diagram**

```
┌─────────────┐  ┌─────────────┐  ┌─────────────┐
│setpoint_r1  │  │setpoint_r2  │  │setpoint_r3  │
│    (0.5)    │  │    (1.0)    │  │    (1.5)    │
└──────┬──────┘  └──────┬──────┘  └──────┬──────┘
       │                │                │
       ▼                ▼                ▼
┌──────────────┐ ┌──────────────┐ ┌──────────────┐
│  Robot_1     │ │  Robot_2     │ │  Robot_3     │
└──────┬───────┘ └──────┬───────┘ └──────┬───────┘
       │                │                │
       └────────────────┼────────────────┘
                        ▼
                 [esp_now_simulator]
                        │
       ┌────────────────┼────────────────┐
       ▼                ▼                ▼
   [Display1]      [Display2]       [Display3]
   (position1)     (position2)      (position3)
       
   [XY Graph] (shows 2D swarm path)
```

### **STEP 12: Run Simulation**

```
Simulation → Model Configuration Parameters
  Stop time: 50
  Solver: ode45

Click Run
Watch displays update with positions
XY Graph shows trajectory

Expected:
  Robot_1 position: converges to 0.5
  Robot_2 position: converges to 1.0
  Robot_3 position: converges to 1.5
```

---

# **🤖 MODEL 3: FAULT TOLERANCE**
## Detects Failures & Redistributes Tasks

### **STEP 1: Create Model**

```
File → New → Model
Save as: model3_fault_tolerance.slx
Location: C:\...\model3_fault_tolerance\
```

### **STEP 2: Add Robot Status Inputs**

```
Create 3 Constant blocks:
  
  Block 1: status_r1
    Value: 1 (1=OK, 0=Failed)
    Position: Top-left
    
  Block 2: status_r2
    Value: 1
    Position: Top-middle
    
  Block 3: status_r3
    Value: 1
    Position: Top-right

These will be switched to 0 at t=20 to simulate failure
```

### **STEP 3: Add Failure Detector**

```
Create MATLAB Function:

Simulink → User-Defined Functions → MATLAB Function

Code:
function [failed_id, is_failure] = failure_detector(s1, s2, s3)
    failed_id = 0;
    is_failure = 0;
    
    if s1 == 0
        failed_id = 1;
        is_failure = 1;
    elseif s2 == 0
        failed_id = 2;
        is_failure = 1;
    elseif s3 == 0
        failed_id = 3;
        is_failure = 1;
    end
end

Name it: failure_detector
Position: Middle-top

Connect:
  status_r1 → input 1
  status_r2 → input 2
  status_r3 → input 3
  
Outputs:
  failed_id (which robot failed)
  is_failure (did failure occur)
```

### **STEP 4: Add Task Redistributor**

```
Create MATLAB Function:

Code:
function [task_r1, task_r2, task_r3] = task_redistributor(failed_id, is_failure)
    
    % Normal workload per robot
    normal_load = 33;
    
    if is_failure == 0
        % Normal operation
        task_r1 = normal_load;
        task_r2 = normal_load;
        task_r3 = normal_load;
    else
        % Failure mode - redistribute
        if failed_id == 1
            task_r1 = 0;           % Failed robot gets nothing
            task_r2 = normal_load + 16;  % Others get extra
            task_r3 = normal_load + 17;
        elseif failed_id == 2
            task_r1 = normal_load + 16;
            task_r2 = 0;
            task_r3 = normal_load + 17;
        else  % failed_id == 3
            task_r1 = normal_load + 17;
            task_r2 = normal_load + 16;
            task_r3 = 0;
        end
    end
end

Name it: task_redistributor
Position: Middle

Connect:
  failed_id → input 1
  is_failure → input 2
  
Outputs:
  task_r1, task_r2, task_r3
```

### **STEP 5: Add Task Displays**

```
Add 3 Display blocks:

Display 1:
  Name: task_display_r1
  Connect: task_r1 output
  Position: Bottom-left
  
Display 2:
  Name: task_display_r2
  Connect: task_r2 output
  Position: Bottom-middle
  
Display 3:
  Name: task_display_r3
  Connect: task_r3 output
  Position: Bottom-right
```

### **STEP 6: Add Alert Message Generator**

```
Create MATLAB Function:

Code:
function alert = failure_alert(failed_id, is_failure)
    if is_failure == 1
        alert = sprintf('ROBOT %d FAILED! Redistributing tasks...', failed_id);
    else
        alert = 0;  % No alert
    end
end

Name it: alert_generator
Position: Middle-bottom

Connect to Display:
  alert output → Display alert
```

### **STEP 7: Complete Block Diagram**

```
status_r1 ──┐
status_r2 ──┤
status_r3 ──┘
            │
            ▼
     [failure_detector]
            │
            ├─→ failed_id ──┐
            └─→ is_failure ─┤
                            ▼
                   [task_redistributor]
                            │
            ┌───────────────┼───────────────┐
            ▼               ▼               ▼
       [Display1]      [Display2]      [Display3]
       (task_r1)      (task_r2)       (task_r3)
       
    [alert_generator]
            │
            ▼
      [Display alert]
```

### **STEP 8: Run Simulation**

```
Simulation → Model Configuration Parameters
  Stop time: 30

At t=0-20:
  task_r1 = 33, task_r2 = 33, task_r3 = 33 (equal distribution)
  
At t=20:
  Simulate Robot_2 failure (change status_r2 to 0)
  
At t=20-30:
  task_r1 = 49, task_r2 = 0, task_r3 = 50
  (Robot_2's tasks redistributed to others!)

Alert appears: "ROBOT 2 FAILED! Redistributing..."
```

---

# **🤖 MODEL 4: ROBOT TRAJECTORY**
## 2D Position Mapping & Visualization

### **STEP 1: Create Model**

```
File → New → Model
Save as: model4_trajectory.slx
Location: C:\...\model4_trajectory\
```

### **STEP 2: Create Trajectory Calculator**

```
Create MATLAB Function:

Code:
function [x_pos, y_pos] = trajectory_calc(velocity, heading, dt)
    persistent x_history y_history
    
    if isempty(x_history)
        x_history = 0;
        y_history = 0;
    end
    
    % Calculate incremental position
    dx = velocity * cos(heading) * dt;
    dy = velocity * sin(heading) * dt;
    
    % Update position
    x_current = x_history(end) + dx;
    y_current = y_history(end) + dy;
    
    % Store history
    x_history = [x_history; x_current];
    y_history = [y_history; y_current];
    
    x_pos = x_current;
    y_pos = y_current;
end

Name it: trajectory_calculator
Position: Left side
```

### **STEP 3: Add Velocity Input**

```
Create inputs:
  1. Constant: velocity = 0.5 m/s
     Name: velocity_input
     
  2. Constant: heading = 0.1 (radians, 5.7 degrees)
     Name: heading_input
     
  3. Constant: dt = 0.01 (simulation time step)
     Name: time_step
```

### **STEP 4: Connect Inputs to Trajectory Calculator**

```
velocity_input → trajectory_calculator input 1
heading_input → trajectory_calculator input 2
time_step → trajectory_calculator input 3

Outputs:
  x_pos (X position)
  y_pos (Y position)
```

### **STEP 5: Add XY Graph for Trajectory**

```
Simulink → Sinks → XY Graph
Double-click:
  ✏️ X min: 0
  ✏️ X max: 10
  ✏️ Y min: 0
  ✏️ Y max: 10
  ✏️ Grid: on

Name it: trajectory_map
Position: Right side

Connect:
  x_pos → XY Graph X input
  y_pos → XY Graph Y input
```

### **STEP 6: Add Obstacle Detection**

```
Create MATLAB Function:

Code:
function [obs_x, obs_y, obs_detected] = 
    obstacle_detect(distance_sensor, heading, robot_x, robot_y)
    
    OBSTACLE_THRESHOLD = 1.0;  % 1 meter
    
    if distance_sensor < OBSTACLE_THRESHOLD
        obs_detected = 1;
        obs_x = robot_x + distance_sensor * cos(heading);
        obs_y = robot_y + distance_sensor * sin(heading);
    else
        obs_detected = 0;
        obs_x = 0;
        obs_y = 0;
    end
end

Name it: obstacle_detector
Position: Middle
```

### **STEP 7: Add Distance Sensor Input**

```
Pulse Generator:
  Amplitude: 2
  Period: 10
  Name: distance_sensor_input
  Connect to obstacle_detector
```

### **STEP 8: Add Obstacle Map Display**

```
XY Graph 2:
  Name: obstacle_map
  X min/max: 0, 10
  Y min/max: 0, 10
  
Connect:
  obs_x → X input
  obs_y → Y input
```

### **STEP 9: Add Statistics**

```
Create MATLAB Function:

Code:
function [total_dist, obs_count, time_elapsed] = 
    trajectory_stats(x_history, y_history, obs_detected, time)
    
    % Total distance
    dx = diff(x_history);
    dy = diff(y_history);
    distances = sqrt(dx.^2 + dy.^2);
    total_dist = sum(distances);
    
    % Obstacle count
    obs_count = sum(obs_detected);
    
    % Time
    time_elapsed = time;
end

Name it: stats_calculator
Position: Bottom
```

### **STEP 10: Add Display for Statistics**

```
Add 3 Display blocks:
  Display 1: Total Distance
  Display 2: Obstacles Found
  Display 3: Time Elapsed
  
Connect stats_calculator outputs
```

### **STEP 11: Full Block Diagram**

```
velocity ──┐
heading ───┤
dt ────────┘
            │
            ▼
    [trajectory_calculator]
            │
        ┌───┴────┐
        ▼        ▼
       x_pos   y_pos
        │        │
        └────┬───┘
             ▼
        [XY Graph 1]
     (Shows robot path)
     
distance_sensor ──┐
heading ──────────┤
x_pos ────────────┤
y_pos ────────────┘
      │
      ▼
[obstacle_detector]
      │
   obs_x, obs_y
      │
      ▼
  [XY Graph 2]
(Shows obstacles)

[stats_calculator]
      │
      ├─→ [Display1] (distance)
      ├─→ [Display2] (obs count)
      └─→ [Display3] (time)
```

### **STEP 12: Run Simulation**

```
Simulation time: 50 seconds

Expected Output:
  XY Graph 1: Shows spiral/circular trajectory
  XY Graph 2: Shows obstacle points detected
  Display 1: Total distance ~25 meters
  Display 2: Obstacles count: 5-10
  Display 3: Elapsed time: 50s
```

---

# **📊 HOW TO RUN ALL 4 MODELS**

### **Quick Test Sequence:**

```
STEP 1: Test Model 1
  ✓ Open model1_pid_navigation.slx
  ✓ Press Ctrl+T (Run)
  ✓ Watch 3 scopes for correct behavior
  ✓ Time: 50s
  ✓ Expected: Position converges to 0.5m
  ✓ Close without saving

STEP 2: Test Model 2
  ✓ Open model2_swarm_system.slx
  ✓ Press Ctrl+T
  ✓ Watch 3 displays update
  ✓ Time: 50s
  ✓ Expected: 3 robots reach different setpoints
  ✓ Close

STEP 3: Test Model 3
  ✓ Open model3_fault_tolerance.slx
  ✓ Change status_r2 to 0 at t=20
  ✓ Press Ctrl+T
  ✓ Time: 30s
  ✓ Expected: Tasks redistribute at t=20
  ✓ Close

STEP 4: Test Model 4
  ✓ Open model4_trajectory.slx
  ✓ Press Ctrl+T
  ✓ Watch XY graphs plot paths
  ✓ Time: 50s
  ✓ Expected: 2D trajectory appears
  ✓ Close
```

---

# **🔧 TROUBLESHOOTING GUIDE**

### **Problem: Simulation hangs (doesn't run)**
```
Solution:
  ☐ Check all inputs are connected
  ☐ Tools → Diagnostics → Check Model (fix warnings)
  ☐ Reduce simulation time to 10s
  ☐ Increase solver tolerance (1e-3 → 1e-2)
```

### **Problem: Scope shows flat line (no change)**
```
Solution:
  ☐ Make sure input blocks are actual Pulse Generators (not Constants)
  ☐ Check PID gains aren't zero
  ☐ Increase simulation time to 50s
```

### **Problem: XY Graph empty**
```
Solution:
  ☐ Verify x_pos and y_pos are connected
  ☐ Use Mux block to combine x,y before XY Graph
  ☐ Check axis limits aren't inverted
```

### **Problem: "Unexpected dimension" error**
```
Solution:
  ☐ All block inputs/outputs should be scalars (1D)
  ☐ Add Concatenate block if combining multiple signals
  ☐ Use Reshape block to ensure correct dimensions
```

---

# **📝 PARAMETER REFERENCE**

```
┌──────────────────────┬──────────────┬─────────────────────────┐
│ Parameter            │ Value        │ Description             │
├──────────────────────┼──────────────┼─────────────────────────┤
│ Desired Distance R1  │ 0.5 m        │ Target distance         │
│ Desired Distance R2  │ 1.0 m        │ Target distance         │
│ Desired Distance R3  │ 1.5 m        │ Target distance         │
│ PID P Gain           │ 2.0          │ Proportional response   │
│ PID I Gain           │ 0.5          │ Integral response       │
│ PID D Gain           │ 0.1          │ Derivative response     │
│ Motor Tau            │ 0.1 s        │ Motor response time     │
│ Motor Gain           │ 1.0          │ Velocity multiplier     │
│ Comm Range           │ 5.0 m        │ ESP-NOW range           │
│ Obstacle Threshold   │ 1.0 m        │ Danger distance         │
│ Simulation Time      │ 50 s         │ Total runtime           │
│ Sample Time          │ 0.01 s       │ Discrete time step      │
└──────────────────────┴──────────────┴─────────────────────────┘
```

---

# **✅ QUICK CHECKLIST**

Before running each model:

```
MODEL 1:
  ☐ 1 Constant (desired = 0.5)
  ☐ 1 Pulse Generator (sensor)
  ☐ 1 Sum block (error)
  ☐ 1 PID Controller
  ☐ 1 Transfer Fcn (motor)
  ☐ 1 Gain
  ☐ 1 Integrator
  ☐ 3 Scopes
  ☐ Feedback loop connected

MODEL 2:
  ☐ 3 Robot subsystems
  ☐ 3 Constant setpoints
  ☐ 3 Pulse sensors
  ☐ 1 Communication function
  ☐ 3 Displays
  ☐ 1 XY Graph

MODEL 3:
  ☐ 3 Status constants
  ☐ 1 Failure detector
  ☐ 1 Task redistributor
  ☐ 1 Alert generator
  ☐ 3 Task displays
  ☐ 1 Alert display

MODEL 4:
  ☐ 1 Trajectory calculator
  ☐ 3 Input constants (velocity, heading, dt)
  ☐ 1 Obstacle detector
  ☐ 1 Distance sensor
  ☐ 1 Obstacle detector
  ☐ 2 XY Graphs (trajectory + obstacles)
  ☐ 1 Stats calculator
  ☐ 3 Statistics displays
```

---

## **YOU'RE READY TO BUILD!**

Start with **Model 1** - it's the foundation!
Once that works perfectly, move to Model 2, 3, 4.

**Each model takes about 30-45 minutes to build.**

**Total time for all 4: ~3 hours**

**Questions on any specific block?** Ask! 🚀

