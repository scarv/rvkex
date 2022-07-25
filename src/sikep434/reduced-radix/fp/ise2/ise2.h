#ifndef _ISE2_H
#define _ISE2_H

#if ( RV64_TYPE2 || RV64_TYPE3 )
.macro macc56lo              rd, rs1, rs2, rs3            
.insn r4 CUSTOM_2, 0,      ( 2* 1), \rd, \rs1, \rs2, \rs3 
.endm                                                     
.macro macc56hi              rd, rs1, rs2, rs3            
.insn r4 CUSTOM_2, 0,      ( 3* 1), \rd, \rs1, \rs2, \rs3 
.endm                                                    
.macro sraadd                rd, rs1, rs2, imm            
.insn r  CUSTOM_2, 1, \imm+( 1*64), \rd, \rs1, \rs2       
.endm 
#endif                                                  

#endif 
