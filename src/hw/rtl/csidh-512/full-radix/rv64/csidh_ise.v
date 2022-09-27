module csidh_ise (
input  wire [63:0]  rs1,
input  wire [63:0]  rs2,
input  wire [ 2:0]  imm,

input  wire         op_csidh_andadd,
input  wire         op_csidh_sub,

output wire [63:0]  rd
);

wire [63:0] immdec = (imm == 0)? 64'h1b81b90533c6c87b :
                     (imm == 1)? 64'hc2721bf457aca835 :
                     (imm == 2)? 64'h516730cc1f0b4f25 :
                     (imm == 3)? 64'ha7aac6c567f35507 :
                     (imm == 4)? 64'h5afbfcc69322c9cd :
                     (imm == 5)? 64'hb42d083aedc88c42 :
                     (imm == 6)? 64'hfc8ab0d15e3e4c4a :
                   /*(imm == 7)*/64'h65b48e8f740f89bf ;

wire [63:0] csidh_andadd = (rs1 & immdec) + rs2;
wire [63:0] csidh_sub    = rs1 - immdec;

assign rd = {64{ op_csidh_andadd }} & csidh_andadd |
            {64{ op_csidh_sub    }} & csidh_sub    ;
endmodule


