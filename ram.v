//存储器文件ram.v
`timescale 1ns/10ps
module ram(
input               clock,
input[8:0]          addr,
input               wr,
input[31:0]         wdata,
input               rd,
output reg[31:0]    rdata
);

reg[31:0]            ram[127:0];
always @(negedge clock) begin
    if (wr)begin
        ram[addr] <= wdata;
    end
    if (rd) begin
        rdata <= ram[addr];
    end
    else begin
        rdata <= 32'bz;      //读写均无效时，为高阻态。若不加此句，时序会出现问题
    end
end
endmodule

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
    clock <= 0; rd <= 0; wr <= 0; wdata <= 0; addr <= 0;
    data_buffer[63:32] = {4'h2, 4'h2, 4'h4, 4'h5, 8'h0, 8'h0}; 
    data_buffer[31:0]  = {4'h1, 4'h0, 4'hf, 4'h0, 4'h0, 4'h0, 4'h1, 4'h0};
    addr_buffer[15:0]  = {8'h0, 8'h1};
    #10   addr <= addr_buffer[15:8]; wr <= 1; wdata <= data_buffer[63:32];
    #400  wr <= 0;
    #500  addr <= addr_buffer[7:0];  wr <= 1; wdata <= data_buffer[31:0];
    #900  wr <= 0; addr <= addr_buffer[15:8]; wdata <= 0;
    #1000 rd <= 1;
    #1200 rd <= 0; addr <= addr_buffer[7:0];
    #1500 rd <= 1;
    #1900 rd <= 0;
    #2000 $stop;
end
always #5 clock <= ~clock;
initial begin
    $dumpfile("tb/ram_tb.vcd");
    $dumpvars(addr, wr, rd, wdata, rdata, addr);
end
endmodule