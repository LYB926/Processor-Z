//存储器文件ram.v
`timescale 1ns/10ps
module ram(
input               clock,
input[31:0]          addr,
input               wr,
input[31:0]         wdata,
input               rd,
output reg[31:0]    rdata = 32'bz
);

reg[31:0]           ram[255:0];   //使用数组模拟RAM
always @(negedge clock) begin
    if (wr)begin
        ram[addr] <= wdata;       //向RAM中写入数据
    end
    if (rd) begin
        rdata <= ram[addr];       //从RAM中读取数据
    end
    else begin
        rdata <= 32'bz;           //读写均无效时，为高阻态。
    end
end
endmodule

/*
//-----Testbench of ram-------//
module ram_tb;
reg             clock;
reg[8:0]        addr;
reg             wr, rd;
reg[31:0]       wdata;
wire[31:0]      rdata;

reg[63:0]       data_buffer;
reg[15:0]       addr_buffer;
ram ram(
                clock,
                addr,
                wr,
                wdata,
                rd,
                rdata
);
initial begin
    clock <= 0; rd <= 0; addr <= 0;
    data_buffer[63:32] = {4'h2, 4'h2, 4'h4, 4'h5, 8'h0, 8'h0}; 
    data_buffer[31:0]  = {4'h1, 4'h0, 4'hf, 4'h0, 4'h0, 4'h0, 4'h1, 4'h0};
    addr_buffer[15:0]  = {8'h0, 8'h1};
    addr <= addr_buffer[15:8]; wr <= 1; wdata <= data_buffer[63:32];

    #20  addr <= addr_buffer[7:0];  wr <= 1; wdata <= data_buffer[31:0];
    #20  addr <= addr_buffer[15:8]; wr <= 0; wdata <= 0; rd <= 1;
    #20  addr <= addr_buffer[7:0]; 
    #20  rd <= 0; addr <= addr_buffer[15:8];
    #50  $stop; 
end
always #10 clock = ~clock;
initial begin
    $dumpfile("tb/ram_tb.vcd");
    $dumpvars();
end
endmodule
*/