module x25519_ise (
input  wire [63:0]  rs1,
input  wire [63:0]  rs2,
input  wire [63:0]  rs3,

input  wire         op_maddlu,
input  wire         op_maddhu,

output wire [63:0]  rd
);

wire [127:0] mul  = rs1 * rs2;
wire  [63:0] resh = mul[127:64] + rs3;
wire  [63:0] resl = mul[ 63: 0] + rs3;
assign      rd  = {64{op_maddlu}} & resl |
                  {64{op_maddhu}} & resh ;

endmodule


