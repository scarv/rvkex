//reduced radix csidh Instruction Set Extension
module xalu_ise (
    ise_clk,
    ise_rst,
    ise_fn,
    ise_imm,   
    ise_in1,   
    ise_in2,  
    ise_val,
    ise_oval,         
    ise_out    );
input           ise_clk, ise_rst;
input  [ 5:0]   ise_fn;
input  [ 6:0]   ise_imm;
input  [63:0]   ise_in1;
input  [63:0]   ise_in2;
input           ise_val;
output          ise_oval;
output [63:0]   ise_out; 

parameter [2:0] ISE_V  = 3'b111;

localparam [1:0] CUSTOM_0 = 2'b00;
localparam [1:0] CUSTOM_1 = 2'b01;
localparam [1:0] CUSTOM_2 = 2'b10;
localparam [1:0] CUSTOM_3 = 2'b11; 

wire [6:0] funct    = ise_imm;

//decode csidh_ise2
wire        csidh_ise2_sel;
wire [63:0] csidh_ise2_rd;  
generate 
    if (ISE_V[1] == 1'b1) begin : CSIDH_ISE2_IMP
//for TYPE2        
wire   op_sraiadd       = (funct[6] == 1'b1) && (ise_fn[1:0] == CUSTOM_1);

assign csidh_ise2_sel  = op_sraiadd ;

csidh_ise2 csidh_ise2_ins(
    .rs1(      ise_in1       ),
    .rs2(      ise_in2       ),
    .shamt(    ise_imm[5:0]  ),
    .rd (      csidh_ise2_rd ),

    .op_sraiadd( op_sraiadd  )
);
end else begin            : No_CSIDH_ISE2
assign  csidh_ise2_sel =  1'b0;
assign  csidh_ise2_rd  = 64'd0;  
    end
endgenerate

//decode csidh_ise3
wire        csidh_ise3_sel;
wire [63:0] csidh_ise3_rd;  
generate 
    if (ISE_V[2] == 1'b1) begin : CSIDH_ISE3_IMP
//for TYPE3
wire   op_csidh_sub    = (funct[6:4] == 3'b000) && (ise_fn[1:0] == CUSTOM_0);
wire   op_csidh_andadd = (funct[6:4] == 3'b001) && (ise_fn[1:0] == CUSTOM_0);
wire   op_csidh_subadd = (funct[6:4] == 3'b010) && (ise_fn[1:0] == CUSTOM_0);


assign csidh_ise3_sel  = op_csidh_sub | op_csidh_andadd | op_csidh_subadd;

csidh_ise3 csidh_ise3_ins(
    .rs1(      ise_in1       ),
    .rs2(      ise_in2       ),
    .imm(      ise_imm[3:0]  ),
    .rd (      csidh_ise3_rd ),

    .op_csidh_sub(   op_csidh_sub),
    .op_csidh_andadd(op_csidh_andadd),
    .op_csidh_subadd(op_csidh_subadd)
);

end else begin            : No_CSIDH_ISE3
assign  csidh_ise3_sel =  1'b0;
assign  csidh_ise3_rd  = 64'd0;  
    end
endgenerate

wire [63:0] dout = {64{ csidh_ise2_sel }} & csidh_ise2_rd |
                   {64{ csidh_ise3_sel }} & csidh_ise3_rd ;

assign  ise_oval = ise_val && (csidh_ise2_sel || csidh_ise3_sel);
assign  ise_out  = dout;

endmodule

