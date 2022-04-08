#include <platform.h>
#include <i2c.h>

on tile[1]: port i2c_port = XS1_PORT_4E ;
uint8_t leds1 = 0x3C;
uint8_t leds2 = 0x3F;

int writeleds(chanend ledchan, client i2c_master_if i2c);

// Sends an update signal to the controllers to update the LEDs
int updateleds(client i2c_master_if i2c) {
    i2c.write_reg(leds1, 0x25, 0x00);
    i2c.write_reg(leds2, 0x25, 0x00);
    return 0;
}

// Enables the LEDs
int setupleds(client i2c_master_if i2c, chanend ledchan) {
    i2c.write_reg(leds1, 0x00, 0b00000001);
    i2c.write_reg(leds2, 0x00, 0b00000001);
    for (int i = 38; i < 74; i++) {
        i2c.write_reg(leds1, i, 0b00000011);
        i2c.write_reg(leds2, i, 0b00000011);
    }
    updateleds(i2c);
    writeleds(ledchan, i2c);
    return 0;
}

// writes rgb values for a specific LED, does not update LEDs
int setled(int index, int led[3], client i2c_master_if i2c) {
    if (index < 12) {
        i2c.write_reg(leds1, index*3+1, led[0]);
        i2c.write_reg(leds1, index*3+2, led[1]);
        i2c.write_reg(leds1, index*3+3, led[2]);
    } else {
        i2c.write_reg(leds2, (index-12)*3+1, led[0]);
        i2c.write_reg(leds2, (index-12)*3+2, led[1]);
        i2c.write_reg(leds2, (index-12)*3+3, led[2]);
    }
    return 0;
}

// Sets LED values using data from the chanend
int writeleds(chanend ledchan, client i2c_master_if i2c) {
    while (1) {
        for (int i = 0; i < 24; i++) {
            int leddata;
            ledchan :> leddata;
            int led[3];
            led[0] = leddata & 255;
            led[1] = (leddata >> 8) & 255;
            led[2] = (leddata >> 16) & 255;
            setled(i, led, i2c);
        }
        updateleds(i2c);
    }
    return 0;
}

// Takes an array of LED data and sends it through the chanend
int setleds(int leds[24][3], chanend ledchan) {
    for (int i = 0; i < 24; i++) {
        int leddata = 0;
        leddata += leds[i][0];
        leddata += leds[i][1] << 8;
        leddata += leds[i][2] << 16;
        ledchan <: leddata;
    }
    return 0;
}

// Sets up LED control
int setup(chanend ledchan) {
    i2c_master_if i2c[1];
    par {
        i2c_master_single_port(i2c, 1, i2c_port, 100, 0, 1, 0);
        setupleds(i2c[0], ledchan);
    }
    return 0;
}


