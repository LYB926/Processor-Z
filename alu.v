//算数逻辑运算单元 alu.v
module alu(
input[31:0]         aluA,
input[31:0]         aluB,
input[3:0]          alufun,
output[31:0]        valE
);
assign valE = (alufun == 0) ? (aluA + aluB) : 
              (alufun == 1) ? (aluA - aluB) :
              //(alufun == 2) ? (aluA && aluB):
              //(alufun == 3) ? ((!aluA)&&aluB)||(aluA&&(!aluB)) :
              (alufun == 2) ? (aluA & aluB):
              (alufun == 3) ? ((~aluA)&aluB)|(aluA&(~aluB)) :
              32'bz;
endmodule
/*
//-------Testbench of ALU-------//
module alu_tb;
reg[31:0]       aluA;
reg[31:0]       aluB;
reg[3:0]        alufun;
wire[31:0]      valE;
alu alu(
                aluA,
                aluB,
                alufun,
                valE
);
initial begin
        alufun <= 0; aluA <= 32'h0AE20D6A; aluB <= 32'h59BB45EB; 
    #30 alufun <= 1;
    #30 alufun <= 2;
    #30 alufun <= 3;
    #80 $stop;
end
initial begin
    $dumpfile("alu_tb.vcd");
    $dumpvars();
end
endmodule
*/