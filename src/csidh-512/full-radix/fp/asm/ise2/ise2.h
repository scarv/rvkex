#ifndef _ISE2_H
#define _ISE2_H

#if ( RV64_TYPE2 || RV64_TYPE3 )
.macro maddlu                rd, rs1, rs2, rs3            
.insn r4 CUSTOM_3, 7,      ( 0* 1), \rd, \rs1, \rs2, \rs3 
.endm                                                     
.macro maddhu                rd, rs1, rs2, rs3            
.insn r4 CUSTOM_3, 7,      ( 1* 1), \rd, \rs1, \rs2, \rs3 
.endm    
.macro cadd                  rd, rs1, rs2, rs3            
.insn r4 CUSTOM_3, 7,      ( 2* 1), \rd, \rs1, \rs2, \rs3 
.endm                                                                                                           
#endif

#endif
