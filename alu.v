//算数逻辑运算单元 alu.v
module alu(
input[31:0]         aluA,
input[31:0]         aluB,
input[3:0]          alufun,
output[31:0]        valE,
output[2:0]         cc
);

wire                ZF, SF, OF;
wire signed[31:0]   A, B, E;
assign              A = aluA;
assign              B = aluB;
assign              E = valE;
assign              cc = {ZF, SF, OF};
assign valE = (alufun == 0) ? (aluA + aluB) : 
              (alufun == 1) ? (aluA - aluB) :
              (alufun == 2) ? (aluA & aluB) :
              (alufun == 3) ? ((~aluA)&aluB)|(aluA&(~aluB)) :
              32'bz;

//cc[2] = ZF, cc[1] = SF, cc[0] = OF.
assign ZF = (valE == 0) ? 1'b1 : 1'b0;          //判断运算结果是否为0
assign SF = (valE[31] == 1) ? 1'b1 : 1'b0;      //判断运算结果是否小于0
assign OF = (alufun == 1) ?                     //分别考虑做减法和其他运算时的溢出
            ((((A > 0)&&(B < 0)&&(E <= 0))||((A < 0)&&(B > 0)&&(E >= 0))) ? 1 : 0) : 
             (((A < 0)&&(B < 0)&&(E >= 0))||((A >= 0)&&(B >= 0)&&(E < 0))) ? 1 : 0;

endmodule
/*
//-------Testbench of ALU-------//
module alu_tb;
reg[31:0]       aluA;
reg[31:0]       aluB;
reg[3:0]        alufun;
wire[31:0]      valE;
wire[2:0]       cc;
alu alu(
                aluA,
                aluB,
                alufun,
                valE,
                cc
);
//initial begin
//        alufun <= 0; aluA <= 32'h0AE20D6A; aluB <= 32'h59BB45EB; 
//    #30 alufun <= 1;
//    #30 alufun <= 2;
//    #30 alufun <= 3;
//    #80 $stop;
//end
initial begin
        alufun <= 2; aluA <= 32'h1100; aluB <= 32'h11;
    #20 alufun <= 1; aluA <= 32'h11; aluB <= 32'h133;
    #20 alufun <= 0; aluA <= 32'h7FFED28A; aluB <= 32'h7FFED28A;
    #20 alufun <= 1; aluA <= 32'hEECE2ADD; aluB <= 32'h7EFFC55C;
    #80 $stop;
end
initial begin
    $dumpfile("alu_tb_cc.vcd");
    $dumpvars();
end
endmodule
*/