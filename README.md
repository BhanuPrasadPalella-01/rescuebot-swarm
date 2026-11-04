# RescueBot Swarm: Disaster-Response Robots

A mobile "black box" robot (and a swarm design) for search and rescue after disasters: it drives through rubble, avoids obstacles and looks for signs of people and hazards.

| Folder | What's inside |
|---|---|
| `firmware/` | ESP32 firmware: obstacle avoidance with a VL53L0X ToF sensor, gyro-measured turns and a Wi-Fi status API |
| `scripts/radar.py` | Live polar "radar" map of what the robot detects, read over serial |
| `simulink/` | MATLAB/Simulink models: RescueBot full system and human-detection navigation (v1, v2), plus scripts that generate the models |
| `docs/` | Wiring guide, pin-to-pin connections, sensor mounting, Simulink notes and a low-cost YOLO human-detection plan |

## Hardware
ESP32 Dev Module, VL53L0X ToF distance sensor, MPU6050 gyro, MLX90614 thermal sensor, SSD1306 OLED, servos and DC motors.
A Raspberry Pi 5 can read the robot's state from its Wi-Fi API.

## Simulink
Open the `.slx` files in MATLAB/Simulink (R2023+). `Swarm_Model.m` and `create_perfect_model.m` build models from script.

*B.Tech AI (CPS), Amrita Vishwa Vidyapeetham.*
