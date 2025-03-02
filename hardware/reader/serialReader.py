import matplotlib.pyplot as plt
import time
import serial

# Define the serial port and baud rate
port = "/dev/tty.usbmodem2401"  # Replace with your serial port
baud_rate = 9600

# Create a serial object
try:
    ser = serial.Serial(port, baud_rate, timeout=1)
    print(f"Connected to {port} at {baud_rate} baud")
except serial.SerialException as e:
    print(f"Error: Could not open serial port: {e}")
    exit()

# Read data from the serial port

start_time = time.time()
x_data = []
y_data = []

plt.ion()  # Enable interactive mode
line = plt.plot(x_data, y_data)[0]
plt.pause(3)
# fig, ax = plt.subplots()
# line = ax.plot(x_data, y_data, 'r-')[0]

try:
    while True:
        if ser.in_waiting > 0:
            print("Received data!")
            data = ser.readline().decode('utf-8').rstrip()
            try:
                data_val = int(data)
            except ValueError:
                print("Missing value")
                continue
            
            x_data.append(time.time() - start_time)
            y_data.append(data_val)

            line.remove()

            line = plt.plot(x_data, y_data, color='b')[0]
            plt.pause(0.05)
            # line.set_xdata(x_data)
            # line.set_ydata(y_data)
            
            # fig.canvas.draw_idle()
            # fig.canvas.flush_events()
except KeyboardInterrupt:
    print("Exiting...")
finally:
    ser.close()
    print("Serial port closed")