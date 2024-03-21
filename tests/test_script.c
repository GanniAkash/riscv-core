int factorial(int n);

// Define a structure for complex numbers
typedef struct {
    int real;
    int imag;
} Complex;

// Function to add two complex numbers
Complex add(Complex n1, Complex n2);

int main() {
    Complex n1, n2, result;
    int real, imag;

    n1.real = -10;
    n1.imag = 45;

    n2.real = 1341;
    n2.imag = -193;

    result = add(n1, n2);

    real = result.real;
    imag = result.imag;

    // To stop veriog sim
    __asm__(".byte 0x13, 0x01, 0x20, 0x4d");  // Make x2 1234
    __asm__(".byte 0x93, 0x01, 0x50, 0x04");  // Make x3 69
    __asm__ (".byte 0x67, 0x00, 0x80, 0x3e");  // jump to some random address

}

Complex add(Complex n1, Complex n2) {
    Complex result;
    result.real = n1.real + n2.real;
    result.imag = n1.imag + n2.imag;
    return result;
}
