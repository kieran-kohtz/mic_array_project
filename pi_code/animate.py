from lights import setpixels
import noise
import time
import math

pixels = [(50, 50, 50) for x in range(24)]
increment = 0.1
# setpixels(pixels)

def formatnoise(val):
    return min(max(int((val*2+0.2)*160), 0), 160)

def get24vals(step, base):
    return [formatnoise(noise.pnoise2(float(x)*increment, step, octaves=2, repeatx=increment*24, base=base)) for x in range(24)]
# noise = perlin_noise.PerlinNoise(octaves=10, seed=12345)
# for i in range(100):
#     print(formatnoise(noise.pnoise1(float(i)*0.1, octaves=10, repeat=10)))

# for i in range(10):
#     print(get24vals(i*0.1))


i = 0
while True:
    red = get24vals(i, 0)
    green = get24vals(i, 300)
    blue = get24vals(i, 600)
    setpixels([(red[x], green[x], blue[x]) for x in range(24)])
    i += 0.02
    time.sleep(0.01)
# radius = 1
# while True:
#     for i in range(24):
#         x = radius * math.cos((i/24)*2*math.pi) + radius