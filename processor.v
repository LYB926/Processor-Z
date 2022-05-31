//处理器Z的顶层文件 processor.v
`timescale 1ns/10ps
module processor(
input           clock,
input[8:0]      addr,
input           wr,
input[31:0]     wdata,
input           working,
output[31:0]    valA,
output[31:0]    valB,
output[31:0]    r0,
output[31:0]    r1,
output[31:0]    r2,
output[31:0]    r3,
output[31:0]    r4,
output[31:0]    r5,
output[31:0]    r6,
output[31:0]    r7
//output[3:0]     icode,
//output[3:0]     ifun,
//output[3:0]     rA,
//output[3:0]     rB,
//output[15:0]    valC
);
parameter IRMOV = 8'h10;
ram ram(
                .clock(clock),
                .addr(addr_w),
                .wr(wr),
                .wdata(wdata),
                .rd(rd),
                .rdata(rdata)
);
regfile regfile(
                .dstE(),
                .valE(),
                .dstM(w_dstM),
                .valM(w_valM),
                .rA(d_rA),
                .rB(d_rB),
                .reset(e_reg_rst),
                .clock(clock),
                .valA(d_valA),
                .valB(d_valB),
                .r0(r0),
                .r1(r1),
                .r2(r2),
                .r3(r3),
                .r4(r4),
                .r5(r5),
                .r6(r6),
                .r7(r7)
);
//-----Fetch stage signals-----//
reg[8:0]        PC = 0;
wire[8:0]       addr_w;
wire            rd;
wire[31:0]      rdata;
wire[31:0]      F_read;
//------------Fetch--------------//
assign addr_w = (working) ? PC   : addr;
assign rd     = (working) ? 1    : 0;
assign F_read = rdata;
always @(posedge clock) begin
    if (working)begin
        PC <= PC + 1;
    end
end

//------Decode stage signals-----//
reg[3:0]        D_icode = 4'bz;
reg[3:0]        D_ifun  = 4'bz;
reg[3:0]        D_rA    = 4'bz;
reg[3:0]        D_rB    = 4'bz;
reg[15:0]       D_valC  = 16'bz;
reg[31:0]       D_valA  = 32'bz;
reg[31:0]       D_valB  = 32'bz;
wire[31:0]      d_valA  = 32'bz;
wire[31:0]      d_valB  = 32'bz;
wire[3:0]       d_rA    = 4'bz;
wire[3:0]       d_rB    = 4'bz;
//-------------Decode------------//
//assign icode  = D_icode;
//assign ifun   = D_ifun;
//assign rA     = D_rB;
//assign rB     = D_rB;
//assign valC   = D_valC;
//assign valA     = d_valA;
//assign valB     = d_valB;
assign valA     = d_valA;
assign valB     = d_valB;
assign d_rA     = D_rA;
assign d_rB     = D_rB;         
always @(posedge clock) begin
    if (working)begin
        D_icode <= F_read[31:28];
        D_ifun  <= F_read[27:24];
        D_rA    <= F_read[23:20];
        D_rB    <= F_read[19:16];
        D_valC  <= F_read[15: 0];
        D_valA  <= d_valA;
        D_valB  <= d_valB;
    end
end

//------Execute stage signals-----//
reg[3:0]          E_dstM = 4'bz;
reg[31:0]         E_valM = 32'bz;
reg               e_reg_rst;
initial begin
        e_reg_rst <= 1;
    #20 e_reg_rst <= 0;
end
//----------Execute stage---------//
always @(posedge clock) begin
    if ({D_icode, D_ifun} == IRMOV)begin
        E_dstM <= D_rB;
        E_valM <= D_valC;
    end
end
//----Write-back stage signals----//
reg[3:0]          w_dstM = 4'bz;
reg[31:0]         w_valM = 32'bz;
//-----------Write-back-----------//
always @(posedge clock) begin
    //if ({D_icode, D_ifun} == IRMOV)begin
        w_dstM <= E_dstM;
        w_valM <= E_valM;
    //end
end

endmodule


module pro_tb2;
reg             clock;
reg[8:0]        addr;
reg             wr;
reg[31:0]       wdata;
reg             working;
wire[31:0]      valA, valB; 
wire[31:0]      r0, r1, r2, r3, r4, r5, r6, r7;
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
                //icode,
                //ifun,
                //rA,
                //rB,
                //valC,
                valA,
                valB,
                r0, r1, r2, r3, r4, r5, r6, r7
                //valE
);
initial begin
    clock <= 0; addr <= 0; wr <= 0; wdata <= 0; working <= 0;
    #20         addr <= 0; wr <= 1; wdata <= 32'h10F00080;
    #20         addr <= 1; wr <= 1; wdata <= 32'h10F10081;
    #20         addr <= 2; wr <= 1; wdata <= 32'h10F20082;
    #20         addr <= 3; wr <= 1; wdata <= 32'h10F30083;
    #20         addr <= 4; wr <= 1; wdata <= 32'h10F40084;
    #20         addr <= 5; wr <= 1; wdata <= 32'h10F50085;
    #20         addr <= 6; wr <= 1; wdata <= 32'h10F60086;
    #20         addr <= 7; wr <= 1; wdata <= 32'h10F70087;
    #20         addr <= 8; wr <= 1; wdata <= 32'h20010000;
    #20         addr <= 9; wr <= 1; wdata <= 32'h21230000;
    #20         addr <= 10;wr <= 1; wdata <= 32'h22450000;
    #20         addr <= 11;wr <= 1; wdata <= 32'h23670000;
    #20         addr <= 0; wr <= 0; wdata <= 0;
    #10         working <= 1;
    #500        $stop;
end
always #10 clock = ~clock;
initial begin
    $dumpfile("pro_tb3.vcd");
    $dumpvars();
end
endmodule


/*
//-----Testbench of processor (Task 1)-------//
module pro_tb;
reg             clock;
reg[8:0]        addr;
reg             wr;
reg[31:0]       wdata;
reg             working;
wire[3:0]       icode;
wire[3:0]       ifun;
wire[3:0]       rA;
wire[3:0]       rB;
wire[15:0]      valC; 
processor processor(
                clock,
                addr,
                wr,
                wdata,
                working,
                icode,
                ifun,
                rA,
                rB,
                valC
);
initial begin
    clock <= 0; addr <= 0; wdata <= 32'h00000000; wr <= 0; working <= 0;
    #20         addr <= 0; wdata <= 32'h10f00010; wr <= 1;
    #20         addr <= 1; wdata <= 32'h20010000;
    #20         addr <= 2; wdata <= 32'h21230000;
    #20         addr <= 3; wdata <= 32'h22450000;
    #20         addr <= 4; wdata <= 32'h23670000;
    #20         addr <= 0; wdata <= 32'h00000000; wr <= 0; working <= 1;
    //#20         working <= 1;
    #150        $stop;
end
always #10 clock = ~clock;
initial begin
    $dumpfile("pro_tb.vcd");
    $dumpvars;
end
endmodule*/

/*module processor(
input           clock,
input[8:0]      addr,
input           wr,
input[31:0]     wdata,
input           working,
output[3:0]     icode,
output[3:0]     ifun,
output[3:0]     rA,
output[3:0]     rB,
output[15:0]    valC,
//output[15:0]    valD, /////////
output[31:0]    r0,
output[31:0]    r1,
output[31:0]    r2,
output[31:0]    r3,
output[31:0]    r4,
output[31:0]    r5,
output[31:0]    r6,
output[31:0]    r7,
output[31:0]    valA,
output[31:0]    valB,
output[31:0]    valE
);

//wire            read = 0;
//reg[8:0]       addr_buffer;
//reg[31:0]      read_buffer = 0;
//assign icode = read_buffer[31:28];
//assign ifun  = read_buffer[27:24];
//assign rA    = read_buffer[23:20];
//assign rB    = read_buffer[19:16];
//assign valC  = read_buffer[15: 0];

wire[8:0]       addr_w;
wire[31:0]      read_w;
reg[8:0]        PC = 0;
reg             read = 0; //3
reg[3:0]        dstE_reg = 4'hF;
reg[3:0]        dstM = 0;
reg[31:0]       valM = 0;
reg[15:0]       valC;
reg             reg_rst;
wire[31:0]      aluA;
wire[31:0]      aluB;
reg[3:0]        alufun;
wire[31:0]      aluValE;
// Separate instruction fetching and decoding
// adding a pipeline
reg[3:0]        icode;
reg[3:0]        ifun;
reg[3:0]        rA;
reg[3:0]        rB;
//assign icode  = read_w[31:28];
//assign ifun   = read_w[27:24];
//assign rA     = read_w[23:20];
//assign rB     = read_w[19:16];
//
assign addr_w = (working) ? PC : addr;
assign aluA   = valA;
assign aluB   = valB;
assign valE   = aluValE;
//assign valE_reg = valE;
//assign valC   = read_w[15: 0];
//assign read   = (working) ? 1  : 0;

ram ram(
                .clock(clock),
                .addr(addr_w),
                .wr(wr),
                .wdata(wdata),
                .rd(read),
                .rdata(read_w)
);
regfile regfile(
                .dstE(dstE_reg),
                .valE(aluValE),
                .dstM(dstM),
                .valM(valM),
                .rA(rA),
                .rB(rB),
                .reset(reg_rst),
                .clock(clock),
                .r0(r0),
                .r1(r1),
                .r2(r2),
                .r3(r3),
                .r4(r4),
                .r5(r5),
                .r6(r6),
                .r7(r7),
                .valA(valA),
                .valB(valB)
);
alu alu(
        .aluA(aluA),
        .aluB(aluB),
        .alufun(alufun),
        .valE(aluValE)
);

initial begin
        reg_rst <= 1;
    #20 reg_rst <= 0;
end

always @(posedge clock) begin
    if(working)begin
        //addr_w <= PC;
        //read_buffer <= read_w;
        read = 1; 
        PC <= PC+1;
        icode <= read_w[31:28];
        ifun  <= read_w[27:24];
        valC  <= read_w[15: 0];//////////
        rA    <= read_w[23:20];
        rB    <= read_w[19:16];
        case(read_w[31:24])
            8'h10: begin
                dstM <= read_w[19:16];
                valM <= read_w[15: 0]; 
            end            
            8'h20: begin
                alufun <= 0;
                dstE_reg <= rA;
                //valE_reg <= valE;
            end
            8'h21: begin
                alufun <= 1;
                dstE_reg <= rA;
                //valE_reg <= valE;
            end
            8'h22: begin
                alufun <= 2;
                dstE_reg <= rA;
               //valE_reg <= valE;
            end
            8'h23: begin
                alufun <= 3;
                dstE_reg <= rA;
               //valE_reg <= valE;
            end
        endcase
    end
    else begin
        if (wr)begin
        read = 0; //
        //addr_w <= addr;
        //read_buffer <= read_w;
        //icode <= read_buffer[31:28];
        end
    end
end
endmodule

module pro_tb2;
reg             clock;
reg[8:0]        addr;
reg             wr;
reg[31:0]       wdata;
reg             working;
wire[3:0]       icode;
wire[3:0]       ifun;
wire[3:0]       rA;
wire[3:0]       rB;
wire[15:0]      valC;
//wire[15:0]      valD;/////////
wire[31:0]      valB, valA; 
wire[31:0]      r0, r1, r2, r3, r4, r5, r6, r7;
wire[31:0]      valE;
processor processor(
                clock,
                addr,
                wr,
                wdata,
                working,
                icode,
                ifun,
                rA,
                rB,
                valC,
                r0, r1, r2, r3, r4, r5, r6, r7,
                valA,
                valB,
                valE
);
initial begin
    clock <= 0; addr <= 0; wr <= 0; wdata <= 0; working <= 0;
    #20         addr <= 0; wr <= 1; wdata <= 32'h10F00080;
    #20         addr <= 1; wr <= 1; wdata <= 32'h10F10081;
    #20         addr <= 2; wr <= 1; wdata <= 32'h10F20082;
    #20         addr <= 3; wr <= 1; wdata <= 32'h10F30083;
    #20         addr <= 4; wr <= 1; wdata <= 32'h10F40084;
    #20         addr <= 5; wr <= 1; wdata <= 32'h10F50085;
    #20         addr <= 6; wr <= 1; wdata <= 32'h10F60086;
    #20         addr <= 7; wr <= 1; wdata <= 32'h10F70087;
    #20         addr <= 8; wr <= 1; wdata <= 32'h20010000;
    #20         addr <= 9; wr <= 1; wdata <= 32'h21230000;
    #20         addr <= 10;wr <= 1; wdata <= 32'h22450000;
    #20         addr <= 11;wr <= 1; wdata <= 32'h23670000;
    #20         addr <= 0; wr <= 0; wdata <= 0;
    #10         working <= 1;
    #500        $stop;
end
always #10 clock = ~clock;
initial begin
    $dumpfile("tb/pro_tb4.vcd");
    $dumpvars();
end
endmodule
*/
