#ifndef _ISE3_H
#define _ISE3_H

#if RV64_TYPE3
.macro sike.add.p434x2.sub56 rd, rs1, rs2, imm            
.insn r  CUSTOM_2, 2, \imm+( 0* 8), \rd, \rs1, \rs2       
.endm                                                     
.macro sike.add.p434x4.sub56 rd, rs1, rs2, imm            
.insn r  CUSTOM_2, 2, \imm+( 1* 8), \rd, \rs1, \rs2       
.endm                                                     
.macro sike.sub.p434x2.add56 rd, rs1, rs2, imm            
.insn r  CUSTOM_2, 2, \imm+( 2* 8), \rd, \rs1, \rs2      
.endm                                                     
.macro sike.and.p434x2.add56 rd, rs1, rs2, imm            
.insn r  CUSTOM_2, 2, \imm+( 3* 8), \rd, \rs1, \rs2      
.endm 
.macro sike.and.p434.add56   rd, rs1, rs2, imm            
.insn r  CUSTOM_2, 2, \imm+( 4* 8), \rd, \rs1, \rs2      
.endm                                                     
#endif                                                  

#endif 
