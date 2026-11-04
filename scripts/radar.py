import serial
import matplotlib.pyplot as plt
import numpy as np

PORT = '/dev/cu.usbserial-0001'
BAUD = 115200

ser = serial.Serial(PORT, BAUD)

print("Radar Map Viewer Started")

points_x = []
points_y = []
types = []

plt.ion()

fig = plt.figure()
ax = fig.add_subplot(111, polar=True)

while True:
    try:

        line = ser.readline().decode('utf-8', errors='ignore').strip()

        if line.startswith("MAP:"):

            data = line.replace("MAP:","").split(",")

            x = float(data[0])
            y = float(data[1])
            t = int(data[2])

            points_x.append(x)
            points_y.append(y)
            types.append(t)

            ax.clear()

            for i in range(len(points_x)):

                r = np.sqrt(points_x[i]**2 + points_y[i]**2)
                theta = np.arctan2(points_y[i], points_x[i])

                if types[i] == 1:
                    ax.scatter(theta, r, c='red', s=80)
                else:
                    ax.scatter(theta, r, c='blue', s=60)

            ax.scatter(0,0,c='green',s=150)

            ax.set_rmax(2)
            ax.set_title("Robot Radar Map")

            plt.draw()
            plt.pause(0.01)

    except Exception as e:
        print("Error:", e)
