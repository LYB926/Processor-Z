//-----Testbench of processor (Task 1)-------//
module pro_tb1;
reg             clock;
reg[31:0]       addr;
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
    clock <= 0; addr <= 0; wdata <= 32'h00000000; wr <= 0; working <= 0;
    #20         addr <= 0; wdata <= 32'h10f00010; wr <= 1;
    #20         addr <= 1; wdata <= 32'h20010000;
    #20         addr <= 2; wdata <= 32'h21230000;
    #20         addr <= 3; wdata <= 32'h22450000;
    #20         addr <= 4; wdata <= 32'h23670000;
    #20         addr <= 0; wdata <= 32'h00000000; wr <= 0; working <= 1;
    #150        $stop;
end
always #10 clock = ~clock;
initial begin
    $dumpfile("pro_tb1.vcd");
    $dumpvars;
end
endmodule