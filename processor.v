//处理器Z的顶层文件 processor.v
`timescale 1ns/10ps
module processor(
input           clock,
input[31:0]     addr,
input           wr,
input[31:0]     wdata,
input           working,
input[3:0]      rID,
//output[31:0]    valA,
//output[31:0]    valB,
output[31:0]    valE,
output[31:0]    r0,
output[31:0]    r1,
output[31:0]    r2,
output[31:0]    r3,
output[31:0]    r4,
output[31:0]    r5,
output[31:0]    r6,
output[31:0]    r7,
output[31:0]    rdata,
output[2:0]     cc
//output[3:0]     icode,
//output[3:0]     ifun,
//output[3:0]     rA,
//output[3:0]     rB,
//output[15:0]    valC
);
// 指定各指令的指令代码和功能代码
parameter IRMOV  = 8'h10;
parameter HALT   = 8'h11;
parameter NOP    = 8'h12;
parameter ADD    = 8'h20;
parameter SUB    = 8'h21;
parameter AND    = 8'h22;
parameter XOR    = 8'h23;
parameter RRMOV  = 8'h30;
parameter CMOVLE = 8'h31;
parameter CMOVL  = 8'h32;
parameter CMOVE  = 8'h33;
parameter CMOVNE = 8'h34;
parameter CMOVGE = 8'h35;
parameter CMOVG  = 8'h36;
parameter JMP    = 8'h70;
parameter JLE    = 8'h71;
parameter JL     = 8'h72;
parameter JE     = 8'h73;
parameter JNE    = 8'h74;
parameter JGE    = 8'h75;
parameter JG     = 8'h76;
ram ram(
                .clock(clock),
                .addr(f_addr),
                .wr(wr),
                .wdata(wdata),
                .rd(f_rd),
                .rdata(f_rdata)
);
regfile regfile(
                .dstE(w_dstE),
                .valE(w_valE),
                .dstM(w_dstM),
                .valM(w_valM),
                .rA(d_rA),         //将译码得到的rA和rB连接到寄存器文件进行取操作数
                .rB(d_rB),
                .reset(e_reg_rst),
                .clock(clock),
                .valA(d_valA_reg), //使用d_valA_reg读取寄存器的值
                .valB(d_valB_reg),
                .r0(r0),
                .r1(r1),
                .r2(r2),
                .r3(r3),
                .r4(r4),
                .r5(r5),
                .r6(r6),
                .r7(r7)
);
alu alu(
                .aluA(e_valA),
                .aluB(e_valB),
                .alufun(e_alufun),
                .valE(e_valE),
                .cc(cc)
);
//-----Fetch stage signals-----//
reg[31:0]       PC = 0;
wire[31:0]      f_addr;
wire            f_rd;
wire[31:0]      f_rdata;
//wire[31:0]      F_read;
reg[31:0]       F_read;
//------------Fetch--------------//
assign f_addr = (working) ?  PC : addr;
assign f_rd   = (working) ?  1  : 0;     //判断写入还是读取指令
//assign F_read = f_rdata;
always @(posedge clock) begin
    if (working)begin
        case(d_jflg)                     //更新PC时考察d_jflg是否有效
            0: begin PC <= PC + 1; end   //d_jflg无效，正常进行PC+1
            1: begin PC <= d_jpc;  end   //d_jflg有效，进行地址跳转
            default: begin
                PC <= PC + 1;
            end
        endcase
    end
    F_read <= f_rdata;
end

//------Decode stage signals-----//
wire[3:0]       d_icode = 4'bz;
wire[3:0]       d_ifun  = 4'bz;
wire[3:0]       d_rA    = 4'bz;
wire[3:0]       d_rB    = 4'bz;
wire[15:0]      d_valC  = 16'bz;
wire[31:0]      d_valA  = 32'bz; // 操作数A和操作数B
wire[31:0]      d_valB  = 32'bz;
wire[31:0]      d_valA_reg  = 32'bz; 
wire[31:0]      d_valB_reg  = 32'bz;
wire            d_halt;
wire            d_jflg  = 1'bz;
wire[31:0]      d_jpc   = 32'bz;     
reg[3:0]        D_icode = 4'bz;
reg[3:0]        D_ifun  = 4'bz;
reg[3:0]        D_rA    = 4'bz;
reg[3:0]        D_rB    = 4'bz;
reg[31:0]       D_valA  = 32'bz;
reg[31:0]       D_valB  = 32'bz;
reg[15:0]       D_valC  = 16'bz;
reg             D_halt  = 1'bz;
reg             D_jflg  = 1'b0;
//reg[31:0]       D_jpc   = 32'bz;  
//-------------Decode------------//
//assign icode  = D_icode;
//assign ifun   = D_ifun;
//assign rA     = D_rB;
//assign rB     = D_rB;
//assign valC   = D_valC;
//assign valA     = d_valA;
//assign valB     = d_valB;
//assign d_rA     = D_rA;
//assign d_rB     = D_rB;
/*
assign          d_icode = F_read[31:28];
assign          d_ifun  = F_read[27:24];
assign          d_rA    = F_read[23:20];
assign          d_rB    = F_read[19:16];
assign          d_valC  = F_read[15: 0];*/
// 从流水线寄存器中得到译码结果
// 译码阶段读取流水线寄存器时检查D_jflg是否有效，有效则替换指令为NOP
assign          {d_icode, d_ifun} = D_jflg ? NOP  : F_read[31:24];
assign          {d_rA, d_rB}      = D_jflg ? 8'b0 : F_read[23:16];
assign          d_valC  = F_read[15: 0];
// 按照转发源的优先级进行条件判断和赋值，实现转发：
assign          d_valA = (e_dstE == d_rA) ? e_valE :
                         (e_dstM == d_rA) ? e_valM :
                         (w_dstE == d_rA) ? w_valE :
                         (w_dstM == d_rA) ? w_valM : d_valA_reg;
assign          d_valB = (e_dstE == d_rB) ? e_valE :
                         (e_dstM == d_rB) ? e_valM :
                         (w_dstE == d_rB) ? w_valE :
                         (w_dstM == d_rB) ? w_valM : d_valB_reg;
// 判断是否译码出HALT指令：
assign          d_halt = ({d_icode, d_ifun} == HALT) ? 1 : 0;
// 根据译码结果确定d_jflg是否有效并且计算跳转地址d_jpc，
// 读取到JXX指令且满足条件时，d_jflg才有效：
assign          d_jflg = ({d_icode, d_ifun} == JMP&&working) ? 1 : 
                         ({d_icode, d_ifun} == JLE&&working&&((e_SF^e_OF)|e_ZF)) ? 1 :
                         ({d_icode, d_ifun} == JL &&working&&(e_SF^e_OF)) ? 1 : 
                         ({d_icode, d_ifun} == JE &&working&&(e_ZF))  ? 1 : 
                         ({d_icode, d_ifun} == JNE&&working&&(~e_ZF)) ? 1 :
                         ({d_icode, d_ifun} == JGE&&working&&(~(e_SF^e_OF))) ? 1 :
                         ({d_icode, d_ifun} == JG &&working&&(~(e_SF^e_OF)&(~e_ZF))) ? 1 : 0;
assign          d_jpc  = {8'h0, d_rA, d_rB, d_valC};
always @(posedge clock) begin
    if (working)begin  
        if (d_halt) begin            //译码得到HALT指令的情况
            {D_icode, D_ifun} <={D_icode, D_ifun};
            D_rA    <= 4'hF;         //将rA和rB设置为F，停止写回寄存器
            D_rB    <= 4'hF;
            D_valC  <= D_valC;       //停止更新译码阶段的流水线寄存器
            D_valA  <= D_valA;
            D_valB  <= D_valB;
            D_halt  <= d_halt;
        end
        else begin                   //非HALT指令的情况
            case({d_icode, d_ifun})  //对部分指令进行替换
                NOP:    begin {D_icode, D_ifun} <= AND; end
                RRMOV:  begin {D_icode, D_ifun} <= ADD; end
                CMOVLE: begin {D_icode, D_ifun} <= ADD; end
                CMOVL:  begin {D_icode, D_ifun} <= ADD; end
                CMOVE:  begin {D_icode, D_ifun} <= ADD; end
                CMOVNE: begin {D_icode, D_ifun} <= ADD; end
                CMOVGE: begin {D_icode, D_ifun} <= ADD; end
                CMOVG:  begin {D_icode, D_ifun} <= ADD; end
                JMP:    begin {D_icode, D_ifun} <= AND; end
                JLE:    begin {D_icode, D_ifun} <= AND; end
                JL :    begin {D_icode, D_ifun} <= AND; end
                JE :    begin {D_icode, D_ifun} <= AND; end
                JNE:    begin {D_icode, D_ifun} <= AND; end
                JGE:    begin {D_icode, D_ifun} <= AND; end
                JG :    begin {D_icode, D_ifun} <= AND; end
                default:begin
                    D_icode <= d_icode;
                    D_ifun  <= d_ifun;                    
                end
            endcase

            case({d_icode, d_ifun})             //修改更新给流水线的操作数
                RRMOV:begin                     //若为RRMOV，更新D_valA为0    
                    D_valA  <= 0;
                    D_valB  <= d_valB;
                    D_rA    <= d_rA;
                    D_rB    <= d_rB; 
                end
                CMOVLE: begin   
                    D_valA  <= 0;
                    D_valB  <= d_valB;
                    D_rB    <= d_rB; 
                    if((e_SF^e_OF)|e_ZF)begin    //检查条件是否满足
                        D_rA    <= d_rA;         //条件满足，写入到rA
                    end
                    else begin
                        D_rA    <= d_rB;         //条件不满足，写回到rB，相当于NOP
                    end
                end
                CMOVL: begin
                    D_valA  <= 0;
                    D_valB  <= d_valB;
                    D_rB    <= d_rB; 
                    if(e_SF^e_OF)begin
                        D_rA    <= d_rA;
                    end
                    else begin
                        D_rA    <= d_rB;
                    end
                end
                CMOVE: begin
                    D_valA  <= 0;
                    D_valB  <= d_valB;
                    D_rB    <= d_rB;                     
                    if(e_ZF)begin
                        D_rA    <= d_rA;
                    end
                    else begin
                        D_rA    <= d_rB;
                    end
                end
                CMOVNE: begin
                    D_valA  <= 0;
                    D_valB  <= d_valB;
                    D_rB    <= d_rB;  
                    if(~e_ZF)begin
                        D_rA    <= d_rA;
                    end
                    else begin
                        D_rA    <= d_rB;
                    end                    
                end
                CMOVGE: begin
                    D_valA  <= 0;
                    D_valB  <= d_valB;
                    D_rB    <= d_rB; 
                    if(~(e_SF^e_OF))begin
                        D_rA    <= d_rA;
                    end
                    else begin
                        D_rA    <= d_rB;
                    end
                end
                CMOVG: begin
                    D_valA  <= 0;
                    D_valB  <= d_valB;
                    D_rB    <= d_rB; 
                    if(~(e_SF^e_OF)&(~e_ZF))begin
                        D_rA    <= d_rA;
                    end
                    else begin
                        D_rA    <= d_rB;
                    end                
                end
                default: begin
                    D_valA  <= d_valA;
                    D_valB  <= d_valB;
                    D_rA    <= d_rA;
                    D_rB    <= d_rB;                    
                end
            endcase
            D_valC <= d_valC;
            D_halt <= d_halt;

            //更新D_jflg的值到下一个周期：
            if ({d_icode, d_ifun} == JMP) begin
                D_jflg <= 1;
            end
            else if({d_icode, d_ifun} == JLE&&((e_SF^e_OF)|e_ZF))begin
                D_jflg <= 1;
            end
            else if({d_icode, d_ifun} == JL &&(e_SF^e_OF))begin
                D_jflg <= 1;
            end
            else if({d_icode, d_ifun} == JE &&(e_ZF))begin
                D_jflg <= 1;
            end
            else if({d_icode, d_ifun} == JNE&&(~e_ZF))begin
                D_jflg <= 1;
            end
            else if({d_icode, d_ifun} == JGE&&(~(e_SF^e_OF)))begin
                D_jflg <= 1;
            end
            else if({d_icode, d_ifun} == JG &&(~(e_SF^e_OF)&(~e_ZF)))begin
                D_jflg <= 1;
            end
            else begin
                D_jflg <= 0;
            end
            //D_jpc  <= d_jpc;
        end
    end
end

//------Execute stage signals-----//
reg[3:0]          E_dstM = 4'bz;
reg[31:0]         E_valM = 32'bz;
reg[3:0]          E_dstE = 4'bz;
reg[31:0]         E_valE = 32'bz;
reg               E_halt = 1'bz;
wire              e_ZF;
wire              e_SF;
wire              e_OF;
wire              e_halt = 1'bz;
reg               e_reg_rst;
wire[3:0]         e_dstM   = 4'bz;
wire[31:0]        e_valM = 32'bz;
wire[31:0]        e_valA = 32'bz;
wire[31:0]        e_valB = 32'bz;
wire[3:0]         e_alufun = 4'bz;
wire[31:0]        e_valE = 32'bz; //用于保存运算结果和写回寄存器地址
wire[3:0]         e_dstE = 4'bz;
initial begin     //使用initial语句生成寄存器清零信号
        e_reg_rst <= 1;
    #20 e_reg_rst <= 0;
end
//----------Execute stage---------//
assign            valE   = e_valE; 
assign            e_valA = D_valA;
assign            e_valB = D_valB;
assign            e_valM = D_valC;
assign            e_halt = D_halt;
assign            e_dstE = D_rA;   //新增：指令执行结果保存到rA
// 从译码阶段的流水线寄存器读取数据，当指令为IRMOV时写入地址dstM才有效
assign            e_dstM = ({D_icode, D_ifun}==IRMOV) ? D_rB : 4'hF;
assign            e_alufun =  //确定功能代码
                  ({D_icode, D_ifun} == ADD) ? 0 :
                  ({D_icode, D_ifun} == SUB) ? 1 :
                  ({D_icode, D_ifun} == AND) ? 2 :
                  ({D_icode, D_ifun} == XOR) ? 3 : 4'bz;
// 读取来自ALU的条件码
assign            e_ZF = cc[2];
assign            e_SF = cc[1];
assign            e_OF = cc[0];
// 每个时钟上升沿更新执行阶段的流水线寄存器
always @(posedge clock) begin
    if ({D_icode, D_ifun} == IRMOV) begin
        E_dstM <= e_dstM;
        E_valM <= e_valM;
    end
    else begin
        E_dstM <= 4'hF;
        E_valM <= 32'bz;
    end
    E_dstE <= e_dstE;
    E_valE <= e_valE;
    E_halt <= e_halt;
end

//----Write-back stage signals----//
wire[3:0]          w_dstM = 4'bz;
wire[31:0]         w_valM = 32'bz;
wire[3:0]          w_dstE = 4'bz;
wire[31:0]         w_valE = 32'bz;
assign            rdata  = (rID == 0) ? r0 :
                           (rID == 1) ? r1 :
                           (rID == 2) ? r2 :
                           (rID == 3) ? r3 :
                           (rID == 4) ? r4 :
                           (rID == 5) ? r5 :
                           (rID == 6) ? r6 :
                           (rID == 7) ? r7 : 32'bz;
//-----------Write-back-----------//
assign        w_dstM = E_dstM;
assign        w_valM = E_valM;
assign        w_dstE = E_dstE;
assign        w_valE = E_valE;    
endmodule

/*
//-----Testbench of processor(EX Task 4)-----//
module pro_tb4;
reg             clock;
reg[31:0]       addr;
reg             wr;
reg[31:0]       wdata;
reg             working;
reg[3:0]        rID;
//wire[31:0]    valA, valB; 
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
                valE,
                r0, r1, r2, r3, r4, r5, r6, r7,
                rdata,
                cc
);
initial begin
    clock <= 0; addr <= 0; wr <= 0; wdata <= 0; working <= 0; rID <= 4'b1111;
    //EXTask 5 Final Bench
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
endmodule*/