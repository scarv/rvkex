#ifndef _ISE3_H
#define _ISE3_H

//#if RV64_TYPE3                                                  
.macro csidh.sub.p512        rd, rs1,      imm            
.insn r  CUSTOM_3, 7, 16*\imm+( 3* 1), \rd, \rs1, x0     
.endm 
.macro csidh.and.p512.add    rd, rs1, rs2, imm            
.insn r  CUSTOM_3, 7, 16*\imm+( 7* 1), \rd, \rs1, \rs2      
.endm                                                     
//#endif                                                  

#endif 
