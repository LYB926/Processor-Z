//处理器Z的顶层文件processor.v
`timescale 1ns/10ps
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

reg[8:0]        PC = 0;
reg             read = 0; //3
//wire            read = 0;
wire[8:0]       addr_w;
wire[31:0]      read_w;
reg[8:0]        addr_buffer;
reg[31:0]       read_buffer = 0;

//assign icode = read_buffer[31:28];
//assign ifun  = read_buffer[27:24];
//assign rA    = read_buffer[23:20];
//assign rB    = read_buffer[19:16];
//assign valC  = read_buffer[15: 0];
assign icode  = read_w[31:28];
assign ifun   = read_w[27:24];
assign rA     = read_w[23:20];
assign rB     = read_w[19:16];
assign valC   = read_w[15: 0];
assign addr_w = (working) ? PC : addr;
//assign read   = (working) ? 1  : 0;
ram ram(
                .clock(clock),
                .addr(addr_w),
                .wr(wr),
                .wdata(wdata),
                .rd(read),
                .rdata(read_w)
);
always @(posedge clock) begin
    if(working)begin
        read = 1; //
        //addr_w <= PC;
        //read_buffer <= read_w;
        PC <= PC+1;
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

//-----Testbench of processor-------//
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
    #160        $stop;
end
always #10 clock = ~clock;
initial begin
    $dumpfile("tb/pro_tb.vcd");
    $dumpvars;
end
endmodule