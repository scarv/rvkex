#ifndef _ISE_H
#define _ISE_H

#include "../config.h"

// TYPE2 
.macro vmacc51lo.vv         vd, vs1, vs2           
.insn r CUSTOM_1, 2, (   0* 2), \vd, \vs1, \vs2 
.endm                                             
.macro vmacc51hi.vv         vd, vs1, vs2           
.insn r CUSTOM_1, 2, (   1* 2), \vd, \vs1, \vs2 
.endm
.macro vmul51lo.vv          vd, vs1, vs2              
.insn r CUSTOM_1, 2, (   2* 2), \vd, \vs1, \vs2      
.endm                                                 
.macro vmul51hi.vv          vd, vs1, vs2              
.insn r CUSTOM_1, 2, (   3* 2), \vd, \vs1, \vs2       
.endm
.macro vsrl51add.vv         vd, vs1, vs2
.insn r CUSTOM_1, 1, (   0* 2), \vd, \vs1, \vs2
.endm
.macro vpermute.vv          vd, vs1, vs2
.insn r CUSTOM_1, 0, (   0* 2), \vd, \vs1, \vs2
.endm
.macro vmvidx1.s.x          vd, rs1      
.insn r CUSTOM_1, 0, (   1* 2), \vd, \rs1, x0
.endm 
// TYPE3
.macro vmacclo.vvi          vd, vs1, vs2, imm         
.insn r CUSTOM_0, 2, (\imm* 2), \vd, \vs1, \vs2
.endm                                                 
.macro vmacchi.vvi          vd, vs1, vs2, imm        
.insn r CUSTOM_0, 3, (\imm* 2), \vd, \vs1, \vs2
.endm
.macro vmullo.vvi           vd, vs1, vs2, imm        
.insn r CUSTOM_0, 4, (\imm* 2), \vd, \vs1, \vs2       
.endm                                                
.macro vmulhi.vvi           vd, vs1, vs2, imm        
.insn r CUSTOM_0, 5, (\imm* 2), \vd, \vs1, \vs2       
.endm                                                


.macro VMAC51LO vd, vs1, vs2
#if   TYPE2
  vmacc51lo.vv \vd, \vs1, \vs2
#elif TYPE3
  vmacclo.vvi  \vd, \vs1, \vs2, 51
#endif 
.endm
.macro VMAC51HI vd, vs1, vs2
#if   TYPE2
  vmacc51hi.vv \vd, \vs1, \vs2  
#elif TYPE3
  vmacchi.vvi  \vd, \vs1, \vs2, 51
#endif 
.endm
.macro VMUL51LO vd, vs1, vs2
#if   TYPE2
  vmul51lo.vv  \vd, \vs1, \vs2  
#elif TYPE3
  vmullo.vvi   \vd, \vs1, \vs2, 51
#endif 
.endm
.macro VMUL51HI vd, vs1, vs2
#if   TYPE2
  vmul51hi.vv  \vd, \vs1, \vs2
#elif TYPE3
  vmulhi.vvi   \vd, \vs1, \vs2, 51
#endif 
.endm

#endif
