#ifndef _ISE3_H
#define _ISE3_H

#if RV64_TYPE3                                                  
.macro sike.and.p434x2.add64 rd, rs1, rs2, imm            
.insn r  CUSTOM_3, 2, \imm+( 3* 8), \rd, \rs1, \rs2      
.endm 
.macro sike.and.p434.add64   rd, rs1, rs2, imm            
.insn r  CUSTOM_3, 2, \imm+( 4* 8), \rd, \rs1, \rs2      
.endm                                                     
#endif                                                  

#endif 
