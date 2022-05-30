//算数逻辑运算单元 alu.v
module alu(
input[31:0]         aluA,
input[31:0]         aluB,
input[3:0]          alufun,
output[31:0]        valE
);
reg[31:0]           valE;
always @(alufun) begin
    case(alufun)
        0: begin valE <= aluA + aluB; end
        1: begin valE <= aluA - aluB; end
        2: begin valE <= aluA && aluB; end
        3: begin //logical XOR: AB'+A'B, not bitwise XOR: A^B
            valE <= ((!aluA)&&aluB)||(aluA&&(!aluB)); 
           end
    endcase
end
endmodule

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
        alufun <= 0; aluA <= 32'hBE; aluB <= 32'hAA; 
    #30 alufun <= 1;
    #30 alufun <= 2;
    #30 alufun <= 3;
    #80 $stop;
end
initial begin
    $dumpfile("tb/alu_tb.vcd");
    $dumpvars();
end
endmodule
