# SIMULINK MODIFICATIONS - VISUAL GUIDE
## Exact Blocks to Add for Human Detection

---

## **CURRENT PROBLEM (Image 8 - Your Obstacle Detection)**

```
CURRENT BLOCK DIAGRAM:

distance_sensor
      ↓
  [< 0.5 ?]  ← Simple threshold
      ↓
 OBSTACLE DETECTED
 
Problem: Can't tell HUMAN from WALL!
```

---

## **SOLUTION: ADD MOTION DETECTION**

### **STEP 1: Create Delay Buffer**

**In Simulink, add:**

```
Block Name: Delay_Buffer
Type: MATLAB Function block or Enabled Subsystem

INPUT: distance_sensor (scalar)
OUTPUT: [d_t-3, d_t-2, d_t-1, d_t] (vector)

CODE (if using MATLAB Function):
────────────────────────────────────
function [d_buffer] = delay_buffer(distance_in, reset)
    persistent buffer
    
    if isempty(buffer) || reset
        buffer = [0, 0, 0, 0];
    end
    
    % Shift values: [d_t-3, d_t-2, d_t-1, d_t]
    buffer = [buffer(2), buffer(3), buffer(4), distance_in];
    
    d_buffer = buffer;
end
────────────────────────────────────
```

**Simulink Visual:**
```
distance_sensor ──→ [Delay Buffer] ──→ [d(t-3), d(t-2), d(t-1), d(t)]
                   (MATLAB Function)
```

---

### **STEP 2: Calculate Rate of Change**

**In Simulink, add:**

```
Block Name: Rate_Calculator
Type: MATLAB Function block

INPUT: [d_t-3, d_t-2, d_t-1, d_t]
OUTPUT: rate (scalar, in m/s)

CODE:
────────────────────────────────────
function [rate] = calculate_rate(d_buffer)
    % Buffer format: [d_t-3, d_t-2, d_t-1, d_t]
    % Time step between samples: 0.1s
    % So 4 samples = 0.3s total
    
    d_current = d_buffer(4);
    d_past = d_buffer(1);
    time_window = 0.3;  % seconds
    
    % Rate of change in m/s
    rate = abs(d_current - d_past) / time_window;
end
────────────────────────────────────
```

**Simulink Visual:**
```
[d(t-3), d(t-2), ...] ──→ [Rate Calculator] ──→ rate (m/s)
                          (MATLAB Function)
```

---

### **STEP 3: Human Detection Logic**

**In Simulink, add:**

```
Block Name: Human_Detector
Type: Logic gates or MATLAB Function

INPUTS: 
  - distance (scalar)
  - rate (scalar)

OUTPUT: 
  - human_detected (boolean: 0 or 1)

THRESHOLDS:
  - DISTANCE_THRESHOLD = 0.5 m (too close)
  - RATE_THRESHOLD = 0.05 m/s (moving)

LOGIC:
  IF (distance < 0.5 AND rate > 0.05) THEN
    human_detected = 1 (TRUE)
  ELSE
    human_detected = 0 (FALSE)
  END
```

**Simulink Visual (Using Logic Gates):**

```
distance < 0.5 ──→ [Relational Operator] ──→ [AND Gate] ──→ human_detected = 1
                                              ↑
rate > 0.05 ────→ [Relational Operator] ─────┘

```

**OR Using MATLAB Function:**

```matlab
function [human_det] = detect_human(distance, rate)
    DISTANCE_THRESH = 0.5;  % meters
    RATE_THRESH = 0.05;      % m/s
    
    if (distance < DISTANCE_THRESH) && (rate > RATE_THRESH)
        human_det = 1;  % HUMAN DETECTED
    else
        human_det = 0;  % NOT A HUMAN
    end
end
```

---

### **STEP 4: Obstacle Detection Logic**

**In Simulink, add:**

```
Block Name: Obstacle_Detector
Type: Logic gates or MATLAB Function

INPUTS: 
  - distance (scalar)
  - rate (scalar)

OUTPUT: 
  - obstacle_detected (boolean: 0 or 1)

LOGIC:
  IF (distance < 0.5 AND rate <= 0.05) THEN
    obstacle_detected = 1 (TRUE - static obstacle)
  ELSE
    obstacle_detected = 0 (FALSE - no obstacle)
  END
```

**Simulink Visual:**

```
distance < 0.5 ──→ [Relational Operator] ──→ [AND Gate] ──→ obstacle_detected = 1
                                              ↑
rate <= 0.05 ────→ [Relational Operator] ────┘
```

---

## **COMPLETE MODIFIED BLOCK DIAGRAM**

### **Replace/Modify Image 8 With This:**

```
┌─────────────────────────────────────────────────────────────────┐
│                   ENHANCED OBSTACLE & HUMAN DETECTION            │
└─────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│ INPUT SIGNALS                                                    │
└──────────────────────────────────────────────────────────────────┘

   distance_sensor    sensor_noise
         ↓                 ↓
   ┌─────────┐       ┌─────────┐
   │ Measured│       │ Add     │
   │Distance │───→ [+] Noise  │
   └─────────┘       └────┬────┘
                          ↓
                    ┌─────────────┐
                    │ Measured    │
                    │ Distance    │
                    │ (noisy)     │
                    └────┬────────┘
                         │
        ┌────────────────┴────────────────┐
        ↓                                  ↓
   ┌─────────────┐               ┌──────────────────┐
   │Delay Buffer │               │Rate Calculator   │
   │(4 samples)  │               │(rate of change)  │
   └────┬────────┘               └────┬─────────────┘
        │                             │
        │ [d(t-3), d(t-2), ...]      │ rate (m/s)
        │                             │
        └────────┬────────────────────┘
                 ↓
        ┌─────────────────────────────────────┐
        │ CLASSIFICATION LOGIC                │
        ├─────────────────────────────────────┤
        │                                     │
        │  [Check 1: Distance < 0.5m?]       │
        │           ↓                         │
        │  YES → [Check 2: Rate > 0.05?]    │
        │           ↓                         │
        │  YES → human_detected = 1 ✓         │
        │  NO  → obstacle_detected = 1 ✓      │
        │           ↓                         │
        │  NO  → clear_path = 1 ✓             │
        │                                     │
        └────────┬────────────────────────────┘
                 ↓
        ┌─────────────────────────────────────┐
        │ OUTPUTS                             │
        ├─────────────────────────────────────┤
        │ human_detected (0/1)               │
        │ obstacle_detected (0/1)            │
        │ clear_path (0/1)                   │
        │ threat_level (enum)                │
        │ confidence_score (0-100%)          │
        └─────────────────────────────────────┘
```

---

## **SIMULINK SUBSYSTEM STRUCTURE**

### **Create a Subsystem: human_obstacle_classifier**

```
Subsystem Inputs:
  ├─ distance_sensor (scalar)
  ├─ sensor_noise (scalar)
  └─ time (scalar)

Subsystem Outputs:
  ├─ human_detected (boolean)
  ├─ obstacle_detected (boolean)
  ├─ clear_path (boolean)
  └─ threat_type (enum)

Internal Blocks:
  1. Add noise to distance
  2. Create delay buffer (4-tap)
  3. Calculate rate of change
  4. Detect human (distance + rate logic)
  5. Detect obstacle (distance + no_rate logic)
  6. Output priority (human > obstacle > clear)
```

**Subsystem Diagram:**

```
┌─ SUBSYSTEM: human_obstacle_classifier ────────────────────────┐
│                                                               │
│  distance_sensor ──→┐                                        │
│                     ├→ [Noise] ──→ [Delay] ──→ [Rate] ──→   │
│  sensor_noise ────→┘                             ↓           │
│                                            [Classifier] ──→  │
│                                                 ↓             │
│  Stop_command ──────→────────────────────────────┘            │
│                                                               │
│  OUTPUTS:                                                     │
│  human_detected ─────→ [mux] ──→ [Display]                  │
│  obstacle_detected ──→         ──→ [Display]                │
│  clear_path ─────────→         ──→ [Display]                │
│                                                               │
└───────────────────────────────────────────────────────────────┘
```

---

## **EXACT BLOCKS TO ADD IN SIMULINK**

### **From Simulink Library:**

```
1. MATH OPERATIONS:
   ☐ Add (Sum block) - for noise
   ☐ Abs (Absolute Value) - for absolute rate
   ☐ Divide - for rate calculation
   ☐ Product - for gain multiplication

2. LOGIC:
   ☐ Relational Operator (<, >, <=, >=)
   ☐ Logical Operator (AND, OR)
   ☐ If Action Subsystem - for conditional logic
   ☐ Switch - for decision making

3. SIGNAL PROCESSING:
   ☐ Delay / Unit Delay - for buffer
   ☐ Shift Register - for [d_t-3, d_t-2, d_t-1, d_t]
   ☐ Moving Average Filter - to smooth distance

4. USER-DEFINED:
   ☐ MATLAB Function - for calculate_rate()
   ☐ MATLAB Function - for human_detector()
   ☐ MATLAB Function - for obstacle_detector()

5. I/O:
   ☐ Scope - to plot distance vs rate
   ☐ Display - to show human_detected
   ☐ Display - to show obstacle_detected
```

---

## **STEP-BY-STEP SIMULINK BUILD**

### **Step 1: Create New Subsystem**

```
1. Open your Image 8 model
2. Create New → Subsystem → Blank Subsystem
3. Name it: "human_obstacle_classifier"
4. Double-click to open it
```

### **Step 2: Add Input Ports**

```
From Simulink Library:
  Ports & Subsystems → In1, In2, In3

Create 3 input ports:
  - port 1: distance_sensor
  - port 2: sensor_noise
  - port 3: time
```

### **Step 3: Add Processing Blocks**

```
Math Operations:
  - Add block (for noise)
  - 2x Relational Operators (< and >)
  - Logical Operator (AND gate)

User-Defined:
  - MATLAB Function: delay_buffer()
  - MATLAB Function: calculate_rate()
  - MATLAB Function: human_classifier()
```

### **Step 4: Wire Them**

```
distance_sensor ──→ [Add] ←─ sensor_noise
                     ↓
                [Delay_Buffer]
                     ↓
              (d_t-3, d_t-2, d_t-1, d_t)
                     ↓
              [Rate_Calculator]
                     ↓
                  rate (m/s)
                     ↓
  ┌──────────────────┴──────────────────┐
  ↓                                      ↓
[< 0.5?] ────→ [AND] ←──── [> 0.05?]
  (distance)      ↓      (rate)
               human = 1
```

### **Step 5: Add Output Ports**

```
Ports & Subsystems → Out1, Out2, Out3, Out4

Create 4 output ports:
  - port 1: human_detected
  - port 2: obstacle_detected
  - port 3: clear_path
  - port 4: threat_level
```

### **Step 6: Connect to Main Model**

```
Original Image 8:
distance_sensor ──→ [< 0.5?] ──→ OBSTACLE_DETECTED

MODIFIED:
distance_sensor ──┐
sensor_noise ────→ [human_obstacle_classifier] ──→ human_detected
                  └──→ obstacle_detected
                  └──→ clear_path
```

---

## **TEST YOUR HUMAN DETECTOR**

### **Create Test Cases:**

```
TEST CASE 1: Static Wall
  distance: constant 0.4m
  rate: 0.0 m/s
  Expected: obstacle_detected = 1, human_detected = 0
  
TEST CASE 2: Moving Human
  distance: 0.6m → 0.4m → 0.3m (approaching)
  rate: 0.1 m/s (moving)
  Expected: human_detected = 1, obstacle_detected = 0
  
TEST CASE 3: Clear Path
  distance: 2.5m
  rate: 0.0 m/s
  Expected: clear_path = 1, both detected = 0
  
TEST CASE 4: Stationary Person (edge case)
  distance: 0.4m (human range)
  rate: 0.0 m/s (standing still)
  Expected: This might fail! (Need to add backup logic)
```

---

## **HANDLING EDGE CASES**

### **Problem: Stationary Human**

```
Human stands still = rate = 0 = misclassified as obstacle!

Solution: Add heartbeat detection
  1. Use MPU6050 accelerometer
  2. Measure micro-vibrations from standing human
  3. IF distance in [0.2, 1.0] AND vibration > threshold
     THEN: possible_stationary_human = 1
```

**Simulink Addition:**

```
MPU6050 acceleration ──→ [High Pass Filter] ──→ [RMS Calculator]
                                                    ↓
                                            vibration_level
                                                    ↓
distance in [0.2, 1.0] AND vibration > 0.05g ──→ HUMAN
```

---

## **PRESENTATION TO PROFESSOR**

### **Show These 3 Plots:**

```
PLOT 1: Distance vs Time
  Shows: Which detection triggered

PLOT 2: Rate of Change vs Time
  Shows: Motion detection working

PLOT 3: Classification Output
  Shows:
    - Green: Human detected
    - Red: Obstacle detected
    - Blue: Clear path
```

**Example Simulink Scope Output:**

```
Distance (m)        Rate (m/s)      Classification
─────────────       ───────────     ──────────────
0.6                0.05            HUMAN ✓
0.4                0.08            HUMAN ✓
0.3                0.10            HUMAN ✓
0.5                0.02            OBSTACLE ✓
1.5                0.0             CLEAR ✓
0.4                0.0             OBSTACLE ✓
```

---

## **FINAL CHECKLIST**

Before showing professor:

```
☐ Added Delay Buffer block
☐ Added Rate Calculator block
☐ Added Human Detector logic
☐ Added Obstacle Detector logic
☐ All blocks properly connected
☐ Test with sample data
☐ Plots showing correct classification
☐ Code comments explaining logic
☐ Documentation of thresholds used
☐ Edge case handling (stationary human)
```

**If you complete this, professor will be VERY impressed!** 🎓

