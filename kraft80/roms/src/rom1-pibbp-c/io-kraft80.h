#ifndef __IO_ALPHA_H
#define __IO_ALPHA_H

char *lgets_noecho(char *buf, int bufsize);
char *lgets(char *buf, int bufsize);
void putstr(char *s);
void putstr_lcd(char *s);
int putchar_lcd(char c);
void lcd_begin();
void d100ms();
void setleds(char leds);
unsigned char readbuttons();
void lcd_home();
void lcd_home2();

#endif

