from smbus import SMBus
import time
import math

# i2c addresses
# 0x3c
# 0x3f

addr1 = 0x3C
addr2 = 0x3F
i2cbus = SMBus(1)

def setup():
    i2cbus.write_byte_data(addr1, 0x00, 0b00000001)
    i2cbus.write_byte_data(addr2, 0x00, 0b00000001)
    for i in range(38, 74):
        i2cbus.write_byte_data(addr1, i, 0b00000011)
        i2cbus.write_byte_data(addr2, i, 0b00000011)
    update()

def setpixels(pixels):
    for i in range(12):
        i2cbus.write_byte_data(addr1, i*3+1, pixels[i][0])
        i2cbus.write_byte_data(addr1, i*3+2, pixels[i][1])
        i2cbus.write_byte_data(addr1, i*3+3, pixels[i][2])
    for i in range(12):
        i2cbus.write_byte_data(addr2, i*3+1, pixels[i+12][0])
        i2cbus.write_byte_data(addr2, i*3+2, pixels[i+12][1])
        i2cbus.write_byte_data(addr2, i*3+3, pixels[i+12][2])
    update()

def update():
    i2cbus.write_byte_data(addr1, 0x25, 0x00)
    i2cbus.write_byte_data(addr2, 0x25, 0x00)

def singlecos(val):
    if abs(val) <= math.pi:
        return int(((math.cos(val)+1)/2)*255)
    else:
        return 0

def getwave(center, width):
    vals = []
    for i in range(24):
        adjval = i-(center%24)
        # val = singlecos(((adjval)/24)*width) + singlecos(((24 - adjval)/24)*width)
        val = singlecos((adjval*math.pi*2)/width) + singlecos(((24 - adjval)*math.pi*2)/width) + singlecos(((24 + adjval)*math.pi*2)/width)
        vals.append(val)
    return vals

# pixels = [(64,0,64) for x in range(24)]

setup()
# setpixels(pixels)

inc = 0.01
speed = 5

def animate():
    step = 0
    while True:
        time.sleep(inc)
        step += speed*inc
        red = getwave(step*3, 10)
        green = getwave(step*-5, 10)
        blue = getwave(step*7 + 12, 10)
        pixels = []
        for i in range(24):
            pixels.append((red[i],green[i],blue[i]))
        setpixels(pixels)

# animate()