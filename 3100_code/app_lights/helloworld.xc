// #include <stdio.h>

// int main() {
//     printf("Hello World\n");
//     return 0;
// }

#include <stdio.h>
#include <stdlib.h>
#include <platform.h>
#include <xs1.h>
#include <timer.h>
#include <i2c.h>
#include <math.h>
#include "led_control.h"

on tile[0]: port btn_port = XS1_PORT_4C ;

double fmax(double a, double b) {
    return a > b ? a : b;
}

int HSVtoRGB(int hue, double sat, double val, int* rgb) {
    double c = sat * val;
    double x0 = fmod(((double) hue / 60), 2);
    double x = c * (1 - fabs(x0 - 1));
    double m = val - c;
    double r0, g0, b0;
    switch (hue/60) {
        case 0:
            r0 = c; g0 = x; b0 = 0; break;
        case 1:
            r0 = x; g0 = c; b0 = 0; break;
        case 2:
            r0 = 0; g0 = c; b0 = x; break;
        case 3:
            r0 = 0; g0 = x; b0 = c; break;
        case 4:
            r0 = x; g0 = 0; b0 = c; break;
        case 5:
            r0 = c; g0 = 0; b0 = x; break;
    }
    // printf("%f %f %f\n", r0, g0, b0);
    rgb[0] = (r0 + m) * 255;
    rgb[1] = (g0 + m) * 255;
    rgb[2] = (b0 + m) * 255;
    // printf("%d %d %d\n", rgb[0], rgb[1], rgb[2]);
    return 0;
}

int orbit(chanend ledchan) {
    int pos = 0;
    int leds[24][3];
    for (int i = 0; i < 24; i++) {
        for (int j = 0; j < 3; j++) {
            leds[i][j] = 0;
        }
    }
    while (1) {
        leds[pos][0] = 32;
        leds[pos][1] = 32;
        leds[pos][2] = 32;
        setleds(leds, ledchan);
        delay_milliseconds (50) ;
        leds[pos][0] = 0;
        leds[pos][1] = 0;
        leds[pos][2] = 0;
        pos = (pos + 1) % 24;
    }
    return 0;
}

int fadeorbit(chanend ledchan) {
    double pos = 0;
    int leds[24][3];
    for (int i = 0; i < 24; i++) {
        for (int j = 0; j < 3; j++) {
            leds[i][j] = 0;
        }
    }
    while (1) {
        int low = (int) pos;
        int high = (low + 1) % 24;
        int prev = (low + 23) % 24;
        HSVtoRGB(0, 0, 0, leds[prev]);
        HSVtoRGB(0, 0, high - pos, leds[low]);
        HSVtoRGB(0, 0, pos - low, leds[high]);
        setleds(leds, ledchan);
        // delay_milliseconds(5);
        pos = fmod(pos + 0.1, 24);
    }
    return 0;
}

int colorfadeorbit(chanend ledchan) {
    int leds[24][3];
    for (int i = 0; i < 24; i++) {
        for (int j = 0; j < 3; j++) {
            leds[i][j] = 0;
        }
    }
    double pos = 0;
    double posstep = 0.2;
    double color = 0;
    double colorstep = 5;
    int fadeout = 16;
    int fadein = 2;
    while (1) {
        // printf("pos: %3.2f, color: %2.2f -> ", pos, color);
        for (int i = 0; i < 24; i++) {
            double relpos = i - pos;
            if (relpos > fadein) {
                relpos -= 24;
            } else if (relpos < -fadeout) {
                relpos += 24;
            }
            double hue = fmod(360 + color + relpos * colorstep, 360);
            double value;
            if (relpos <= 0) {
                value = fmax(1 + relpos * (1.0f / fadeout), 0);
            } else {
                value = fmax(1 - relpos * (1.0f / fadein), 0);
            }
            // printf("%3.2f|%2.2f ", hue, value);
            HSVtoRGB((int) hue, 1, value, leds[i]);
        }
        // printf("\n");
        setleds(leds, ledchan);
        pos = fmod(pos + posstep, 24);
        color = fmod(color + colorstep * posstep, 360);
        // delay_milliseconds(5);
    }
    return 0;
}

int run() {
    chan ledchan;
    // int hue = 120;
    // double sat = 1;
    // double val = 1;
    // int rgb[3];
    // HSVtoRGB(hue, sat, val, rgb);
    // printf("%d %d %d\n", rgb[0], rgb[1], rgb[2]);
    // printf("%d %f %f -> %d %d %d\n", hue, sat, val, rgb[0], rgb[1], rgb[2]);
    // for (int i = 0; i < 360; i++) {
    //     HSVtoRGB(i, sat, val, rgb);
    //     printf("%d %f %f -> %d %d %d\n", i, sat, val, rgb[0], rgb[1], rgb[2]);
    // }
    // printf("%f\n", 0.5f - 1);
    par {
        setup(ledchan);
        colorfadeorbit(ledchan);
    }
    return 0;
}

int buttons() {
    int btns[] = {0, 0, 0, 0};
    int state;
    while (1) {
        btn_port :> state;
        // printf("%d: %d %d %d %d\n", state, (state>>3)&1?1:0, (state>>2)&1?1:0, (state>>1)&1?1:0, (state)&1?1:0);
        for (int i = 0; i < 4; i++) {
            int val = (state >> i) & 1 ? 0 : 1;
            if (val == 1 && btns[i] == 0) {
                printf("Button %c pressed\n", 65+i);
            }
            btns[i] = val;
        }
        delay_milliseconds (10) ;
    }
    return 0;
}

int main () {
    par {
        on tile[1]: run();
        on tile[0]: buttons();
    }
    return 0;
}


