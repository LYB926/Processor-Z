//处理器Z的顶层文件processor.v
module processor(
input           clock,
input[8:0]      addr,
input           wr,
input[31:0]     wdata,
input           working,
output[3:0]     icode,
output[3:0]     ifun,
output[3:0]     rA,
output[3:0]     rB,
output[15:0]    valC
);
//TBD

endmodule