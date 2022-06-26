#ifndef _ISE_H
#define _ISE_H

#include "../config.h"

// TYPE2 
.macro macc56lo              rd, rs1, rs2, rs3            
.insn r4 CUSTOM_2, 0,      ( 2* 1), \rd, \rs1, \rs2, \rs3 
.endm                                                     
.macro macc56hi              rd, rs1, rs2, rs3            
.insn r4 CUSTOM_2, 0,      ( 3* 1), \rd, \rs1, \rs2, \rs3 
.endm                                                    
.macro srladd                rd, rs1, rs2, imm            
.insn r  CUSTOM_2, 1, \imm+( 0*64), \rd, \rs1, \rs2       
.endm                                                     


#endif 