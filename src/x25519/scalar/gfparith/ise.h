#ifndef _ISE_H
#define _ISE_H

#include "../config.h"

// TYPE2 
.macro macc51lo              rd, rs1, rs2, rs3            
.insn r4 CUSTOM_2, 0,      ( 0* 1), \rd, \rs1, \rs2, \rs3 
.endm                                                     
.macro macc51hi              rd, rs1, rs2, rs3            
.insn r4 CUSTOM_2, 0,      ( 1* 1), \rd, \rs1, \rs2, \rs3 
.endm                                                    
.macro srladd                rd, rs1, rs2, imm            
.insn r  CUSTOM_2, 1, \imm+( 0*64), \rd, \rs1, \rs2       
.endm                                                     


#endif 