//csidh Instruction Set Extension
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

parameter [1:0] ISE_V  = 2'b11;

localparam [1:0] CUSTOM_0 = 2'b00;
localparam [1:0] CUSTOM_1 = 2'b01;
localparam [1:0] CUSTOM_2 = 2'b10;
localparam [1:0] CUSTOM_3 = 2'b11; 

wire [6:0] funct    = ise_imm;

//decode csidh_ise
wire        csidh_ise_sel;
wire [63:0] csidh_ise_rd;  
generate 
    if (ISE_V[1] == 1'b1) begin : csidh_ISE_IMP
wire   op_csidh_andadd = (funct[3:0] == 4'b0111) && (ise_fn[1:0] == CUSTOM_0);
wire   op_csidh_sub    = (funct[3:0] == 4'b0011) && (ise_fn[1:0] == CUSTOM_0);

assign csidh_ise_sel  = op_csidh_andadd || op_csidh_sub;


csidh_ise csidh_ise_ins2(
    .rs1(      ise_in1      ),
    .rs2(      ise_in2      ),
    .imm(      ise_imm[6:4] ),
    .rd (      csidh_ise_rd ),

    .op_csidh_andadd( op_csidh_andadd   ),
    .op_csidh_sub(    op_csidh_sub      )
);
end else begin            : No_csidh_ISE
assign  csidh_ise_sel =  1'b0;
assign  csidh_ise_rd  = 64'd0;  
    end
endgenerate

wire [63:0] dout = {64{ csidh_ise_sel }} & csidh_ise_rd ;

// assign  ise_oval = ise_val && csidh_ise_sel;
// assign  ise_out  = dout;
assign ise_oval = 0;
assign ise_out  = 0;

endmodule

