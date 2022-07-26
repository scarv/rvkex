#ifndef _ISE_H
#define _ISE_H

#if RV64_TYPE2
.macro madd51lu              rd, rs1, rs2, rs3            
.insn r4 CUSTOM_2, 0,      ( 0* 1), \rd, \rs1, \rs2, \rs3 
.endm                                                     
.macro madd51hu              rd, rs1, rs2, rs3            
.insn r4 CUSTOM_2, 0,      ( 1* 1), \rd, \rs1, \rs2, \rs3 
.endm                                                    
.macro sraiadd               rd, rs1, rs2, imm            
.insn r  CUSTOM_2, 1, \imm+( 1*64), \rd, \rs1, \rs2       
.endm                                                         
#endif

#endif
