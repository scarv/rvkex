#ifndef _ISE3_H
#define _ISE3_H

//#if RV64_TYPE3                                                  
.macro csidh.sub.p512.57     rd, rs1,      imm
.insn r  CUSTOM_0, 6, \imm+( 0*16), \rd, \rs1, x0
.endm
.macro csidh.and.p512.add57   rd, rs1, rs2  imm
.insn r  CUSTOM_0, 7, \imm+( 1*16), \rd, \rs1, \rs2
.endm
.macro csidh.sub.p512.add57   rd, rs1, rs2  imm 
.insn r  CUSTOM_0, 7, \imm+( 2*16), \rd, \rs1, \rs2       
.endm
                                                   
//#endif                                                  

#endif 
