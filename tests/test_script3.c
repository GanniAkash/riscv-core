// Define the base address of the IO port
#define IO_PORT_BASE_ADDRESS 0x04

// Define the control signals
#define RS_PIN 0
#define RW_PIN 1
#define EN_PIN 2

unsigned int read_io_port();
void write_io_port(unsigned int);
void _delay_ms(unsigned int);
void write_nibble_to_lcd(unsigned char);
void write_byte_to_lcd(unsigned char);
void send_command_to_lcd(unsigned char);
void send_data_to_lcd(unsigned char);
void initialize_lcd();
void write_string_to_lcd(const char*);

// Example usage
int main() {
    // Assuming "Hello, World!" is the text to be displayed on the LCD
    const char *text = "Hello, World!";
    
    // Initialize the LCD
    initialize_lcd();
    
    // Write the text to the LCD
    write_string_to_lcd(text);

    int x = 0;
    while (1) {
      x =0;
    }
    
    return 0;
}


// Function to read from the 32-bit IO port
unsigned int read_io_port() {
    return *((volatile unsigned int *)IO_PORT_BASE_ADDRESS);
}

// Function to write to the 32-bit IO port
void write_io_port(unsigned int data) {
    *((volatile unsigned int *)IO_PORT_BASE_ADDRESS) = data;
}

// Function to create a delay (in milliseconds)
void _delay_ms(unsigned int milliseconds) {
    // Implementation of delay goes here
}

// Function to write a nibble (4 bits) to the LCD
void write_nibble_to_lcd(unsigned char nibble) {
    // Mask out the lower 4 bits and write them to the data lines
    unsigned int data = read_io_port() & 0xFFFFFFF0;
    data |= nibble;
    write_io_port(data);
    
    // Pulse the Enable pin to latch the data
    write_io_port(data | (1 << EN_PIN));
    _delay_ms(1); // Delay for a short period
    write_io_port(data);
}

// Function to write a byte (8 bits) to the LCD
void write_byte_to_lcd(unsigned char byte) {
    // Write the higher nibble first
    write_nibble_to_lcd(byte >> 4);
    
    // Write the lower nibble
    write_nibble_to_lcd(byte & 0x0F);
}

// Function to send a command to the LCD
void send_command_to_lcd(unsigned char command) {
    // Set RS to 0 for command mode
    write_io_port(read_io_port() & ~(1 << RS_PIN));
    
    // Set RW to 0 for write mode
    write_io_port(read_io_port() & ~(1 << RW_PIN));
    
    // Write the command to the LCD
    write_byte_to_lcd(command);
}

// Function to send data to the LCD
void send_data_to_lcd(unsigned char data) {
    // Set RS to 1 for data mode
    write_io_port(read_io_port() | (1 << RS_PIN));
    
    // Set RW to 0 for write mode
    write_io_port(read_io_port() & ~(1 << RW_PIN));
    
    // Write the data to the LCD
    write_byte_to_lcd(data);
}

// Function to initialize the LCD
void initialize_lcd() {
    // Initialize sequence for 4-bit mode
    send_command_to_lcd(0x33); // Initialize
    send_command_to_lcd(0x32); // Set to 4-bit mode
    send_command_to_lcd(0x28); // 2 lines, 5x8 character matrix
    send_command_to_lcd(0x0C); // Turn cursor off
    send_command_to_lcd(0x06); // Cursor direction increment
    send_command_to_lcd(0x01); // Clear display
    _delay_ms(2);              // Delay to allow LCD to process the command
}

// Function to write a string to the LCD
void write_string_to_lcd(const char *str) {
    while (*str != '\0') {
        send_data_to_lcd(*str);
        str++;
    }
}
