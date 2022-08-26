#ifndef _ISE2_H
#define _ISE2_H

#if ( RV64_TYPE2 || RV64_TYPE3 )
.macro madd57lu              rd, rs1, rs2, rs3            
.insn r4 CUSTOM_2, 7,      ( 2* 1), \rd, \rs1, \rs2, \rs3 
.endm                                                     
.macro madd57hu              rd, rs1, rs2, rs3            
.insn r4 CUSTOM_2, 7,      ( 3* 1), \rd, \rs1, \rs2, \rs3 
.endm                                                    
.macro sraiadd               rd, rs1, rs2, imm            
.insn r  CUSTOM_1, 7, \imm+( 1*64), \rd, \rs1, \rs2       
.endm 
#endif                                                  

#endif 
