#include <stdint.h>

#define lcd 0x04

#define RS 9
#define EN 10

void init(void);
void delay();
void cmd(char);
void display(char);
void string(char *);

void main(){
  	__asm__(".byte 0x93, 0x01, 0x50, 0x04");
	char temp [12] = {'H', 'e', 'l', 'l', 'o', ' ', 'W', 'o', 'r', 'l', 'd', '!'};
	__asm__(".byte 0x93, 0x01, 0x50, 0x04");
	init();
	cmd(0x80);
//	string(&temp[0]);
//	display('D');
//		display('H');
//		display('D');
//		display(' ');
//		display('E');
//		display('C');
//		display('P');
//		display('-');
//		display('3');
//		display('1');
//		display('3');

	for(int i = 0; i < 12; i++ ) {
	 display(temp[i]);
	}
	while(1);
}

void delay() {
	unsigned char i;
	for ( i=5000; i>0; i--);
}

void cmd (char c) {
        volatile uint32_t *gpio = (uint32_t *)lcd;
	*gpio = c | (0b10 << 8);
	delay();
	*gpio = c | (0b00 << 8);
	
}

void display(char c) {
  //lcd=c;
  //	rs=1;
  //	e=1;
  //	delay();
  //	e=0;
       volatile uint32_t *gpio = (uint32_t *)lcd;
	*gpio = c | (0b11 << 8);
	delay();
	*gpio = c | (0b01 << 8);
}
void string(char* p) {
	while(*p) {
		display (*p++);
	}
}
void init (void) {
	cmd(0x38);
	cmd(0x0F);
	cmd(0x01);
	cmd(0x80);
}
