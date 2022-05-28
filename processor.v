//处理器Z的顶层文件processor.v
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
reg             rd = 0;
reg[31:0]       rdata = 0;
reg[31:0]       rdata_buffer = 0;
reg[8:0]        addr_buffer = 0;
reg[3:0]        icode;
reg[3:0]        ifun;
reg[3:0]        rA;
reg[3:0]        rB;
reg[15:0]       valC;
/*module ram(
input               clock,
input[8:0]          addr,
input               wr,
input[31:0]         wdata,
input               rd,
output reg[31:0]    rdata
);*/
ram ram(
                .clock(clock),
                .addr(addr_buffer),
                .wr(wr),
                .wdata(wdata),
                .rd(rd),
                .rdata(rdata_buffer)                
);
always @(posedge clock) begin
    if (working) begin
        rd <= 1; addr_buffer <= PC;
        rdata_buffer <= rdata;
        icode <= rdata_buffer[31:28];
        ifun  <= rdata_buffer[27:24];
        rA    <= rdata_buffer[23:20];
        rB    <= rdata_buffer[19:16];
        valC  <= rdata_buffer[15:0];
        PC    <= PC+1;
    end
    else begin
        if (wr) begin
            addr_buffer <= addr;
        end 
    end
end
endmodule