#ifndef _ISE2_H
#define _ISE2_H

#if ( RV64_TYPE2 || RV64_TYPE3 )
.macro macclo                rd, rs1, rs2, rs3            
.insn r4 CUSTOM_3, 0,      ( 0* 1), \rd, \rs1, \rs2, \rs3 
.endm                                                     
.macro macchi                rd, rs1, rs2, rs3            
.insn r4 CUSTOM_3, 0,      ( 1* 1), \rd, \rs1, \rs2, \rs3 
.endm                                                                                                           
#endif

#endif
