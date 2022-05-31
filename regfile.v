//寄存器读写文件 regfile.v
`timescale 1ns/10ps
module regfile(
input[3:0]          dstE,
input[31:0]         valE,
input[3:0]          dstM,
input[31:0]         valM,
input[3:0]          rA,
input[3:0]          rB,
input               reset,
input               clock,
output[31:0]        valA,
output[31:0]        valB,
output[31:0]        r0,
output[31:0]        r1,
output[31:0]        r2,
output[31:0]        r3,
output[31:0]        r4,
output[31:0]        r5,
output[31:0]        r6,
output[31:0]        r7
);
reg[31:0]           r_r0, r_r1, r_r2, r_r3, r_r4, r_r5,r_r6, r_r7;
reg[31:0]           r_valA, r_valB;
assign              valA = r_valA;
assign              valB = r_valB;
assign              r0   = r_r0;
assign              r1   = r_r1;
assign              r2   = r_r2;
assign              r3   = r_r3;
assign              r4   = r_r4;
assign              r5   = r_r5;
assign              r6   = r_r6;
assign              r7   = r_r7;
always @(posedge clock or negedge reset) begin
    if (reset)begin
        r_valA <= 0; r_valB <= 0;
        r_r0 <= 0; r_r1 <= 0; r_r2 <= 0; r_r3 <= 0; 
        r_r4 <= 0; r_r5 <= 0; r_r6 <= 0; r_r7 <= 0; 
    end
    else begin
        case(dstE)
            0: begin r_r0 <= valE; end
            1: begin r_r1 <= valE; end
            2: begin r_r2 <= valE; end
            3: begin r_r3 <= valE; end
            4: begin r_r4 <= valE; end
            5: begin r_r5 <= valE; end
            6: begin r_r6 <= valE; end
            7: begin r_r7 <= valE; end
        endcase
        case(dstM)
            0: begin r_r0 <= valM; end
            1: begin r_r1 <= valM; end
            2: begin r_r2 <= valM; end
            3: begin r_r3 <= valM; end
            4: begin r_r4 <= valM; end
            5: begin r_r5 <= valM; end
            6: begin r_r6 <= valM; end
            7: begin r_r7 <= valM; end
        endcase
        case(rA)
            0: begin r_valA <= r0; end
            1: begin r_valA <= r1; end
            2: begin r_valA <= r2; end
            3: begin r_valA <= r3; end
            4: begin r_valA <= r4; end
            5: begin r_valA <= r5; end
            6: begin r_valA <= r6; end
            7: begin r_valA <= r7; end
            default: begin r_valA <= 32'bz; end
        endcase
        case(rB)
            0: begin r_valB <= r0; end
            1: begin r_valB <= r1; end
            2: begin r_valB <= r2; end
            3: begin r_valB <= r3; end
            4: begin r_valB <= r4; end
            5: begin r_valB <= r5; end
            6: begin r_valB <= r6; end
            7: begin r_valB <= r7; end
            default: begin r_valB <= 32'bz; end
        endcase 
    end
end
endmodule

/*
module regfile_tb;
reg[3:0]          dstE;
reg[3:0]          dstM;
wire[31:0]        valE;
wire[31:0]        valM;
reg[3:0]          rA;
reg[3:0]          rB;
reg               reset;
reg               clock;
wire[31:0]        r0;
wire[31:0]        r1;
wire[31:0]        r2;
wire[31:0]        r3;
wire[31:0]        r4;
wire[31:0]        r5;
wire[31:0]        r6;
wire[31:0]        r7;

reg[31:0]         write_bufferE;
reg[31:0]         write_bufferM;
reg[12:0]         con;
assign            valE = write_bufferE;
assign            valM = write_bufferM;
regfile regfile(
                  dstE,
                  valE,
                  dstM,
                  valM,
                  rA,
                  rB,
                  reset,
                  clock,
                  valA,
                  valB,
                  r0, r1, r2, r3, r4, r5, r6, r7
);
initial begin
            clock <= 0; reset <= 1;
            dstE <= 0;  dstM <= 1; con <= 1;
            write_bufferE <= 32'hABCDEF98;
            write_bufferM <= 32'h7654321A;
    #37     reset <= 0;
    #2000   $stop;
end
always #10 clock = ~clock;
always @(posedge clock) begin
    if (con == 4-1)begin
        con <= 0;
    end
    else begin
        con <= con+1;
    end
    if (con == 0)begin
        write_bufferE[31:1] <= write_bufferE[30:0];
        write_bufferE[0]    <= write_bufferE[31];
        write_bufferM[31:1] <= write_bufferM[30:0];
        write_bufferM[0]    <= write_bufferM[31];
        dstE <= dstE + 2; dstM <= dstM + 2;
        if (dstE == 6)begin
            dstE <= 0;
        end
        if (dstM == 7)begin
            dstM <= 1;
        end
    end
end
initial begin
    $dumpfile("regfile_tb.vcd");
    $dumpvars;
end
endmodule*/