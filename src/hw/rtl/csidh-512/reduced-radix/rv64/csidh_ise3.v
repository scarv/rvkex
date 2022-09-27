module csidh_ise3 (
input  wire [63:0]  rs1,
input  wire [63:0]  rs2,
input  wire [ 3:0]  imm,

input  wire         op_csidh_sub,
input  wire         op_csidh_andadd,
input  wire         op_csidh_subadd,
output wire [63:0]  rd
);

wire [63:0] immdec = (imm == 0)? 64'h0181B90533C6C87B :
                     (imm == 1)? 64'h010DFA2BD6541A8D :
                     (imm == 2)? 64'h003307C2D3C9709C :
                     (imm == 3)? 64'h00ACFE6AA0EA2CE6 :
                     (imm == 4)? 64'h01322C9CDA7AAC6C :
                     (imm == 5)? 64'h00446212D7DFE634 :
                     (imm == 6)? 64'h01312AD0B420EBB7 :
                     (imm == 7)? 64'h017FF91561A2BC7C :
                     (imm == 8)? 64'h0065B48E8F740F89 :
                     /*default*/ 64'h0000000000000000 ;


wire [63:0] csidh_sub    = rs1 - immdec;
wire [63:0] csidh_subadd = rs1 - immdec   + rs2;
wire [63:0] csidh_andadd = (rs1 & immdec) + rs2;

assign rd = {64{ op_csidh_andadd }} & csidh_andadd |
            {64{ op_csidh_subadd }} & csidh_subadd |
            {64{ op_csidh_sub    }} & csidh_sub    ;
endmodule


