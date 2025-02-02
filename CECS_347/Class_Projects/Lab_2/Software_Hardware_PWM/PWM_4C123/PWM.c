// PWM.c
// Runs on TM4C123
// Use PWM0/PB6 and PWM1/PB7 to generate pulse-width modulated outputs.
// Daniel Valvano
// March 28, 2014

/* This example accompanies the book
   "Embedded Systems: Real Time Interfacing to ARM Cortex M Microcontrollers",
   ISBN: 978-1463590154, Jonathan Valvano, copyright (c) 2014
  Program 6.7, section 6.3.2

 Copyright 2014 by Jonathan W. Valvano, valvano@mail.utexas.edu
    You may use, edit, run or distribute this file
    as long as the above copyright notice remains
 THIS SOFTWARE IS PROVIDED "AS IS".  NO WARRANTIES, WHETHER EXPRESS, IMPLIED
 OR STATUTORY, INCLUDING, BUT NOT LIMITED TO, IMPLIED WARRANTIES OF
 MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE APPLY TO THIS SOFTWARE.
 VALVANO SHALL NOT, IN ANY CIRCUMSTANCES, BE LIABLE FOR SPECIAL, INCIDENTAL,
 OR CONSEQUENTIAL DAMAGES, FOR ANY REASON WHATSOEVER.
 For more information about my classes, my research, and my books, see
 http://users.ece.utexas.edu/~valvano/
 */
#include <stdint.h>
//#include "inc/tm4c123gh6pm.h"
#include "tm4c123gh6pm.h"
#define PWM_0_GENA_ACTCMPAD_ONE 0x000000C0  // Set the output signal to 1
#define PWM_0_GENA_ACTLOAD_ZERO 0x00000008  // Set the output signal to 0
#define PWM_0_GENB_ACTCMPBD_ONE 0x00000C00  // Set the output signal to 1
#define PWM_0_GENB_ACTLOAD_ZERO 0x00000008  // Set the output signal to 0

#define SYSCTL_RCC_USEPWMDIV    0x00100000  // Enable PWM Clock Divisor
#define SYSCTL_RCC_PWMDIV_M     0x000E0000  // PWM Unit Clock Divisor
#define SYSCTL_RCC_PWMDIV_2     0x00000000  // /2


// period is 16-bit number of PWM clock cycles in one period (3<=period)
// duty is number of PWM clock cycles output is high  (2<=duty<=period-1)
// PWM clock rate = processor clock rate/SYSCTL_RCC_PWMDIV
//                = BusClock/2 
//                = 80 MHz/2 = 40 MHz (in this example)
// Output on PF2/M1PWM6
void PWM6A_Init(uint16_t period, uint16_t duty){
  SYSCTL_RCGCPWM_R 			|= 0x02;            // 1) activate PWM1
  SYSCTL_RCGCGPIO_R 		|= 0x20;            // 2) activate port F
  while((SYSCTL_PRGPIO_R&0x20) == 0){};
  GPIO_PORTF_AFSEL_R 		|= 0x04;           	// enable alt funct on PF2
  GPIO_PORTF_PCTL_R 		&= ~0x00000F00;     // configure PF as PWM6
  GPIO_PORTF_PCTL_R 		|= 0x00000500;
  GPIO_PORTF_AMSEL_R 		&= ~0x04;          	// disable analog functionality on PF2
  GPIO_PORTF_DEN_R 			|= 0x04;            // enable digital I/O on PF2
  SYSCTL_RCC_R = 0x00100000 |           		// 3) use PWM divider
      (SYSCTL_RCC_R & (~0x000E0000));   		//    configure for /2 divider
  PWM1_3_CTL_R = 0;                     		// 4) re-loading down-counting mode
  PWM1_3_GENA_R = 0xC8;                 		// low on LOAD, high on CMPA down
  // PF2 goes low on LOAD
  // PF2 goes high on CMPA down
  PWM1_3_LOAD_R = period - 1;           		// 5) cycles needed to count down to 0
  PWM1_3_CMPA_R = duty - 1;             		// 6) count value when output rises
  PWM1_3_CTL_R |= 0x00000001;           		// 7) start PWM1
  PWM1_ENABLE_R |= 0x00000040;          		// enable PB6/M0PWM0
}
// change duty cycle of PF2
// duty is number of PWM clock cycles output is high  (2<=duty<=period-1)
void PWM6A_Duty(uint16_t duty){
  PWM1_3_CMPA_R = duty - 1;             // 6) count value when output rises
}
// period is 16-bit number of PWM clock cycles in one period (3<=period)
// period for PB6 and PB7 must be the same
// duty is number of PWM clock cycles output is high  (2<=duty<=period-1)
// PWM clock rate = processor clock rate/SYSCTL_RCC_PWMDIV
//                = BusClock/2 
//                = 80 MHz/2 = 40 MHz (in this example)
// Output on PB7/M0PWM1
/*void PWM0B_Init(uint16_t period, uint16_t duty){
  volatile unsigned long delay;
  SYSCTL_RCGCPWM_R 					|= 0x01;            // 1) activate PWM0
  SYSCTL_RCGCGPIO_R 				|= 0x02;            // 2) activate port B
  delay = SYSCTL_RCGCGPIO_R;            				// allow time to finish activating
  GPIO_PORTB_AFSEL_R 				|= 0x80;           	// enable alt funct on PB7
  GPIO_PORTB_PCTL_R 				&= ~0xF0000000;     // configure PB7 as M0PWM1
  GPIO_PORTB_PCTL_R 				|= 0x40000000;
  GPIO_PORTB_AMSEL_R 				&= ~0x80;          	// disable analog functionality on PB7
  GPIO_PORTB_DEN_R 					|= 0x80;            // enable digital I/O on PB7
  SYSCTL_RCC_R |= SYSCTL_RCC_USEPWMDIV; 				// 3) use PWM divider
  SYSCTL_RCC_R &= ~SYSCTL_RCC_PWMDIV_M; 				// clear PWM divider field
  SYSCTL_RCC_R += SYSCTL_RCC_PWMDIV_2;  				// configure for /2 divider
  PWM0_0_CTL_R = 0;                     				// 4) re-loading down-counting mode
  PWM0_0_GENB_R = (PWM_0_GENB_ACTCMPBD_ONE|PWM_0_GENB_ACTLOAD_ZERO);
  // PB7 goes low on LOAD
  // PB7 goes high on CMPB down
  PWM0_0_LOAD_R = period - 1;           // 5) cycles needed to count down to 0
  PWM0_0_CMPB_R = duty - 1;             // 6) count value when output rises
  PWM0_0_CTL_R |= 0x00000001;           // 7) start PWM0
  PWM0_ENABLE_R |= 0x00000002;          // enable PB7/M0PWM1
}
// change duty cycle of PB7
// duty is number of PWM clock cycles output is high  (2<=duty<=period-1)
void PWM0B_Duty(uint16_t duty){
  PWM0_0_CMPB_R = duty - 1;             // 6) count value when output rises
}*/

