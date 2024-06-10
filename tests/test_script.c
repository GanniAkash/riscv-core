#include <stdint.h>

// Memory-mapped I/O addresses for the GPIO controller
#define GPIO_BASE_ADDR 0x00000000
#define GPIO_OUTPUT_ADDR (GPIO_BASE_ADDR + 0x04) // GPIO Output Register


void delay(uint32_t iteration);
void count1();
void count2();

int main() {

    // Pointer to the GPIO Output Register
    volatile uint32_t *gpio_output = (uint32_t *)GPIO_OUTPUT_ADDR;

    // Set bit 0 as output
    *gpio_output |= 0x1;

    while (1) {
        // Toggle the LED by flipping bit 0
        /* *gpio_output ^= 0x1; */

        /* // Delay for some time */
        /* delay(10000); */

        count2();
        count1();
    }

    // To stop veriog sim
    __asm__(".byte 0x13, 0x01, 0x20, 0x4d");  // Make x2 1234
    __asm__(".byte 0x93, 0x01, 0x50, 0x04");  // Make x3 69
    __asm__ (".byte 0x67, 0x00, 0x80, 0x3e");  // jump to some random address

}

void count2() {
    volatile uint32_t *gpio = (uint32_t *)GPIO_OUTPUT_ADDR;
    *gpio &= 0xFFFF00FF;
    *gpio |= (0b1000000 << 8); //0
    count1();

    *gpio &= 0xFFFF00FF;
    *gpio |= (0b1111001 << 8); //1
    count1();

    *gpio &= 0xFFFF00FF;
    *gpio |= (0b0100100 << 8); //2
    count1();

    *gpio &= 0xFFFF00FF;
    *gpio |= (0b0110000 << 8); //3
    count1();

    *gpio &= 0xFFFF00FF;
    *gpio |= (0b0011001 << 8); //4
    count1();

    *gpio &= 0xFFFF00FF;
    *gpio |= (0b0010010 << 8); //5
    count1();

    *gpio &= 0xFFFF00FF;
    *gpio |= (0b0000010 << 8); //6
    count1();

    *gpio &= 0xFFFF00FF;
    *gpio |= (0b1111000 << 8); //7
    count1();

    *gpio &= 0xFFFF00FF;
    *gpio |=(0b0000000 << 8); //8
    count1();

    *gpio &= 0xFFFF00FF;
    *gpio |= (0b0010000 << 8); //9
    count1();
}


void count1() {
    volatile uint32_t *gpio = (uint32_t *)GPIO_OUTPUT_ADDR;
    *gpio &= 0xFFFFFF00;
    *gpio |= 0b1000000; //0
    delay(50000);

    *gpio &= 0xFFFFFF00;
    *gpio |= 0b1111001; //1
    delay(50000);

    *gpio &= 0xFFFFFF00;
    *gpio |= 0b0100100; //2
    delay(50000);

    *gpio &= 0xFFFFFF00;
    *gpio |= 0b0110000; //3
    delay(50000);

    *gpio &= 0xFFFFFF00;
    *gpio |= 0b0011001; //4
    delay(50000);

    *gpio &= 0xFFFFFF00;
    *gpio |= 0b0010010; //5
    delay(50000);

    *gpio &= 0xFFFFFF00;
    *gpio |= 0b0000010; //6
    delay(50000);

    *gpio &= 0xFFFFFF00;
    *gpio |= 0b1111000; //7
    delay(50000);

    *gpio &= 0xFFFFFF00;
    *gpio |= 0b0000000; //8
    delay(50000);

    *gpio &= 0xFFFFFF00;
    *gpio |= 0b0010000; //9
    delay(50000);
}


// Function to delay for a specified number of iterations
void delay(uint32_t iterations) {
    for (volatile uint32_t i = 0; i < iterations; i++);
}
