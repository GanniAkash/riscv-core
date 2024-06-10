#include <stdint.h>

// Memory-mapped I/O addresses for the GPIO controller
#define GPIO_BASE_ADDR 0x00000000
#define GPIO_OUTPUT_ADDR (GPIO_BASE_ADDR + 0x04) // GPIO Output Register


void delay(uint32_t iteration);

int main() {

    // Pointer to the GPIO Output Register
    volatile uint32_t *gpio_output = (uint32_t *)GPIO_OUTPUT_ADDR;

    // Set bit 0 as output
    *gpio_output |= 0x1;

    while (1) {
        // Toggle the LED by flipping bit 0
        *gpio_output ^= 0x1;

        // Delay for some time
        delay(5000);
    }

    // To stop veriog sim
    __asm__(".byte 0x13, 0x01, 0x20, 0x4d");  // Make x2 1234
    __asm__(".byte 0x93, 0x01, 0x50, 0x04");  // Make x3 69
    __asm__ (".byte 0x67, 0x00, 0x80, 0x3e");  // jump to some random address

}


// Function to delay for a specified number of iterations
void delay(uint32_t iterations) {
    for (volatile uint32_t i = 0; i < iterations; i++);
}
