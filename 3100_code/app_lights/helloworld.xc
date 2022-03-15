// #include <stdio.h>

// int main() {
//     printf("Hello World\n");
//     return 0;
// }

#include <platform.h>
#include <xs1.h>
#include <timer.h>
#include <i2c.h>
on tile[1]: port i2c_port = XS1_PORT_4E ;

int toggle() {
    while (1) {
        p <: 2;
        delay_milliseconds (1000) ;
        p <: 0;
        delay_milliseconds (1000) ;
    }
    return 0;
}

int updateleds(i2c_master_if i2c, uint8_t leds1, uint8_t leds2) {
    i2c.write_reg(leds1, 0x25, 0x00);
    i2c.write_reg(leds2, 0x25, 0x00);
    return 0;
}

int writeleds(int** leds, i2c_master_if i2c, uint8_t leds1, uint8_t leds2) {
    for (int i = 0; i < 12; i++) {
        i2c.write_reg(leds1, i*3+1, leds[i][0]);
        i2c.write_reg(leds1, i*3+2, leds[i][1]);
        i2c.write_reg(leds1, i*3+3, leds[i][2]);
    }
    for (int i = 0; i < 12; i++) {
        i2c.write_reg(leds2, i*3+1, leds[i+12][0]);
        i2c.write_reg(leds2, i*3+2, leds[i+12][1]);
        i2c.write_reg(leds2, i*3+3, leds[i+12][2]);
    }
    updateleds(i2c, leds1, leds2);
    return 0;
}

int setupleds(i2c_master_if i2c, uint8_t leds1, uint8_t leds2) {
    i2c.write_reg(leds1, 0x00, 0b00000001);
    i2c.write_reg(leds2, 0x00, 0b00000001);
    for (int i = 38; i < 74; i++) {
        i2c.write_reg(leds1, i, 0b00000011);
        i2c.write_reg(leds2, i, 0b00000011);
    }
    updateleds(i2c, leds1, leds2);
    return 0;
}

int run(i2c_master_if i2c, uint8_t leds1, uint8_t leds2) {
    setupleds(i2c, leds1, leds2);
    int leds[24][3];
    for (int i = 0; i < 24; i++) {
        for (int j = 0; j < 3; j++) {
            leds[i][j] == 128;
        }
    }
    writeleds(leds, i2c, leds1, leds2)
    return 0;
}

int setup() {
    i2c_master_if i2c[1];
    uint8_t leds1 = 0x3C;
    uint8_t leds2 = 0x3F;
    par {
        i2c_master_single_port(i2c, 1, i2c_port, 100, 1, 0, 0);
        run(i2c, leds1, leds2);
    }
    return 0;
}
// i2c_master_single_port(i2c, 1, p_i2c, 100, 1, 3, 0);


// port led = XS1_PORT
int main () {
    par {
        on tile[1]: toggle();
    }
    return 0;
}


