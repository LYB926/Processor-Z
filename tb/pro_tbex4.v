//-----Testbench of processor(EX Task 4)-----//
module pro_tb4;
reg             clock;
reg[31:0]        addr;
reg             wr;
reg[31:0]       wdata;
reg             working;
reg[3:0]        rID;
//wire[31:0]      valA, valB; 
wire[31:0]      valE;
wire[31:0]      r0, r1, r2, r3, r4, r5, r6, r7;
wire[31:0]      rdata;
reg             flg = 0;
wire[2:0]       cc;
//wire[3:0]       icode;
//wire[3:0]       ifun;
//wire[3:0]       rA;
//wire[3:0]       rB;
//wire[15:0]      valC;
//wire[31:0]      valE;
processor processor(
                clock,
                addr,
                wr,
                wdata,
                working,
                rID,
                //icode,
                //ifun,
                //rA,
                //rB,
                //valC,
                //valA,
                //valB,
                valE,
                r0, r1, r2, r3, r4, r5, r6, r7,
                rdata,
                cc
                //valE
);
initial begin
    clock <= 0; addr <= 0; wr <= 0; wdata <= 0; working <= 0; rID <= 4'b1111;
    //EXTask 5 Final Bench
    //JMP    = 8'h70;JLE    = 8'h71;
    //JL     = 8'h72;JE     = 8'h73;
    //JNE    = 8'h74;JGE    = 8'h75;JG     = 8'h76;
    #20         addr <= 0; wr <= 1; wdata <= 32'h10F00001;
    #20         addr <= 1; wr <= 1; wdata <= 32'h10F10002;
    #20         addr <= 2; wr <= 1; wdata <= 32'h10F20003;
    #20         addr <= 3; wr <= 1; wdata <= 32'h10F30004;
    #20         addr <= 4; wr <= 1; wdata <= 32'h10F40005;
    #20         addr <= 5; wr <= 1; wdata <= 32'h10F50006;
    #20         addr <= 6; wr <= 1; wdata <= 32'h10F60007;
    #20         addr <= 7; wr <= 1; wdata <= 32'h10F70008;
    #20         addr <= 8; wr <= 1; wdata <= 32'h7000000A;
    #20         addr <= 9; wr <= 1; wdata <= 32'h21760000;//B
    #20         addr <= 10;wr <= 1; wdata <= 32'h20760000;//C
    #20         addr <= 11;wr <= 1; wdata <= 32'h20100000;//D
    #20         addr <= 12;wr <= 1; wdata <= 32'h21700000;//E
    #20         addr <= 13;wr <= 1; wdata <= 32'h7500000B;//F
    #20         addr <= 14;wr <= 1; wdata <= 32'h20760000;//G
    #20         addr <= 15;wr <= 1; wdata <= 32'h20200000;//H
    #20         addr <= 16;wr <= 1; wdata <= 32'h21700000;//I
    #20         addr <= 17;wr <= 1; wdata <= 32'h7600000F;//J
    #20         addr <= 18;wr <= 1; wdata <= 32'h20750000;//K
    #20         addr <= 19;wr <= 1; wdata <= 32'h20300000;//L
    #20         addr <= 20;wr <= 1; wdata <= 32'h21700000;//M  
    #20         addr <= 21;wr <= 1; wdata <= 32'h73000013;//N  
    #20         addr <= 22;wr <= 1; wdata <= 32'h20750000;//O
    #20         addr <= 23;wr <= 1; wdata <= 32'h20300000;//P
    #20         addr <= 24;wr <= 1; wdata <= 32'h21700000;//Q
    #20         addr <= 25;wr <= 1; wdata <= 32'h74000017;//R
    #20         addr <= 26;wr <= 1; wdata <= 32'h21600000;//S
    #20         addr <= 27;wr <= 1; wdata <= 32'h21670000;//T
    #20         addr <= 28;wr <= 1; wdata <= 32'h7100001A;//U
    #20         addr <= 29;wr <= 1; wdata <= 32'h21500000;//V
    #20         addr <= 30;wr <= 1; wdata <= 32'h21570000;//W
    #20         addr <= 31;wr <= 1; wdata <= 32'h7200001D;//X

    #20         addr <= 0; wr <= 0; wdata <= 0;
    #10         working <= 1;
    #3100       working <= 0; flg <= 1;
    #100       $stop;
end
always #10 clock = ~clock;
always @(posedge clock ) begin
    if (flg)begin
        rID <= rID + 1;
    end
end
initial begin
    $dumpfile("pro_tb.vcd");
    $dumpvars();
end
endmodule