#include <Wire.h>
#include <VL53L0X.h>
#include <MPU6050.h>
#include <math.h>

// ======================================================
// I2C PINS FOR ESP32
// ======================================================
#define SDA_PIN 21
#define SCL_PIN 22

// ======================================================
// MOTOR DRIVER PINS
// ======================================================
#define MOTOR_LEFT_IN1 27
#define MOTOR_LEFT_IN2 26
#define MOTOR_LEFT_PWM 25

#define MOTOR_RIGHT_IN1 14
#define MOTOR_RIGHT_IN2 12
#define MOTOR_RIGHT_PWM 13

#define MOTOR_ENABLE 23

// ======================================================
// DETECTION THRESHOLDS
// ======================================================
#define DISTANCE_THRESHOLD 500
#define MOTION_THRESHOLD 0.5

// ======================================================
// SENSOR OBJECTS
// ======================================================
VL53L0X distanceSensor;
MPU6050 mpu;

// ======================================================
// ROBOT STATE VARIABLES
// ======================================================
float distance_current = 0;
float distance_previous = 0;
float motion_velocity = 0;

float robot_heading_deg = 0;

unsigned long last_sample = 0;
unsigned long last_rotation = 0;

float robot_x = 0;
float robot_y = 0;

// ======================================================
// MAP STORAGE
// ======================================================
struct MapPoint{
  float x;
  float y;
  int type;
};

MapPoint mapPoints[50];
int mapIndex = 0;


// ======================================================
// SETUP
// ======================================================
void setup(){

  Serial.begin(115200);
  delay(2000);

  Serial.println("Robot Starting...");

  Wire.begin(SDA_PIN,SCL_PIN);

  // VL53L0X
  if(!distanceSensor.init()){
    Serial.println("VL53L0X FAILED");
    while(1);
  }

  distanceSensor.startContinuous();
  Serial.println("VL53L0X OK");

  // MPU6050
  mpu.initialize();
  Serial.println("MPU INITIALIZED");

  // Motor pins
  pinMode(MOTOR_LEFT_IN1,OUTPUT);
  pinMode(MOTOR_LEFT_IN2,OUTPUT);
  pinMode(MOTOR_LEFT_PWM,OUTPUT);

  pinMode(MOTOR_RIGHT_IN1,OUTPUT);
  pinMode(MOTOR_RIGHT_IN2,OUTPUT);
  pinMode(MOTOR_RIGHT_PWM,OUTPUT);

  pinMode(MOTOR_ENABLE,OUTPUT);

  digitalWrite(MOTOR_ENABLE,HIGH);

  last_sample = millis();
  last_rotation = millis();
}


// ======================================================
// MAIN LOOP
// ======================================================
void loop(){

  if(millis()-last_sample < 100) return;
  last_sample = millis();

  updateHeading();

  distance_previous = distance_current;
  distance_current = distanceSensor.readRangeContinuousMillimeters();

  float distance_change = abs(distance_current-distance_previous);
  motion_velocity = (distance_change/0.1)/1000.0;

  bool human=false;
  bool obstacle=false;

  if(distance_current < DISTANCE_THRESHOLD){

    if(motion_velocity > MOTION_THRESHOLD)
      human=true;
    else
      obstacle=true;

  }

  if(human){

    stopMotors();

    Serial.println("HUMAN DETECTED");

    logObject(distance_current,1);
  }

  else if(obstacle){

    Serial.println("OBSTACLE DETECTED");

    logObject(distance_current,0);

    avoidObstacle();
  }

  else{

    moveForward(150);
  }

  printStatus();
}


// ======================================================
// UPDATE HEADING
// ======================================================
void updateHeading(){

  int16_t gx,gy,gz;

  mpu.getRotation(&gx,&gy,&gz);

  float gyro_z = gz/131.0;

  float dt = (millis()-last_rotation)/1000.0;

  robot_heading_deg += gyro_z*dt;

  // Normalize angle
  while(robot_heading_deg >= 360) robot_heading_deg -= 360;
  while(robot_heading_deg < 0) robot_heading_deg += 360;

  last_rotation = millis();
}


// ======================================================
// MOTOR CONTROL
// ======================================================
void moveForward(int speed){

  digitalWrite(MOTOR_LEFT_IN1,HIGH);
  digitalWrite(MOTOR_LEFT_IN2,LOW);
  analogWrite(MOTOR_LEFT_PWM,speed);

  digitalWrite(MOTOR_RIGHT_IN1,HIGH);
  digitalWrite(MOTOR_RIGHT_IN2,LOW);
  analogWrite(MOTOR_RIGHT_PWM,speed);
}

void turnLeft(int speed){

  digitalWrite(MOTOR_LEFT_IN1,LOW);
  digitalWrite(MOTOR_LEFT_IN2,HIGH);
  analogWrite(MOTOR_LEFT_PWM,speed);

  digitalWrite(MOTOR_RIGHT_IN1,HIGH);
  digitalWrite(MOTOR_RIGHT_IN2,LOW);
  analogWrite(MOTOR_RIGHT_PWM,speed);
}

void turnRight(int speed){

  digitalWrite(MOTOR_LEFT_IN1,HIGH);
  digitalWrite(MOTOR_LEFT_IN2,LOW);
  analogWrite(MOTOR_LEFT_PWM,speed);

  digitalWrite(MOTOR_RIGHT_IN1,LOW);
  digitalWrite(MOTOR_RIGHT_IN2,HIGH);
  analogWrite(MOTOR_RIGHT_PWM,speed);
}

void stopMotors(){

  analogWrite(MOTOR_LEFT_PWM,0);
  analogWrite(MOTOR_RIGHT_PWM,0);
}


// ======================================================
// OBSTACLE AVOIDANCE
// ======================================================
void avoidObstacle(){

  Serial.println("Scanning surroundings...");

  stopMotors();
  delay(200);

  // Scan LEFT
  turnLeft(150);
  delay(350);
  stopMotors();

  int leftDistance = distanceSensor.readRangeContinuousMillimeters();

  // Return center
  turnRight(150);
  delay(350);

  // Scan RIGHT
  turnRight(150);
  delay(350);
  stopMotors();

  int rightDistance = distanceSensor.readRangeContinuousMillimeters();

  // Return center
  turnLeft(150);
  delay(350);

  if(leftDistance > rightDistance){

    Serial.println("Turning LEFT");

    turnLeft(150);
    delay(450);

  }else{

    Serial.println("Turning RIGHT");

    turnRight(150);
    delay(450);
  }
}


// ======================================================
// LOG OBJECT FOR 2D MAP
// ======================================================
void logObject(float distance,int type){

  // Circular buffer
  if(mapIndex >= 50) mapIndex = 0;

  float d = distance/1000.0;

  float x = robot_x + d*cos(robot_heading_deg*PI/180.0);
  float y = robot_y + d*sin(robot_heading_deg*PI/180.0);

  mapPoints[mapIndex].x = x;
  mapPoints[mapIndex].y = y;
  mapPoints[mapIndex].type = type;

  mapIndex++;

  Serial.print("MAP:");
  Serial.print(x);
  Serial.print(",");
  Serial.print(y);
  Serial.print(",");
  Serial.println(type);
}


// ======================================================
// SERIAL STATUS
// ======================================================
void printStatus(){

  Serial.print("Dist: ");
  Serial.print(distance_current/10);
  Serial.print(" cm ");

  Serial.print("Motion: ");
  Serial.print(motion_velocity);

  Serial.print(" Heading: ");
  Serial.print(robot_heading_deg);

  Serial.print(" Points: ");
  Serial.println(mapIndex);
}