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
                .rA(d_rA),
                .rB(d_rB),
                .reset(e_reg_rst),
                .clock(clock),
                .valA(d_valA_reg),
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
wire[31:0]      F_read;
//------------Fetch--------------//
assign f_addr = (working) ?  PC : addr;
assign f_rd   = (working) ?  1  : 0;
assign F_read = f_rdata;
always @(posedge clock) begin
    if (working)begin
        case(d_jflg)
            0: begin PC <= PC + 1; end
            1: begin PC <= d_jpc;  end
            default: begin
                PC <= PC + 1;
            end
        endcase
        
    end
end

//------Decode stage signals-----//
wire[3:0]       d_icode = 4'bz;
wire[3:0]       d_ifun  = 4'bz;
wire[3:0]       d_rA    = 4'bz;
wire[3:0]       d_rB    = 4'bz;
wire[15:0]      d_valC  = 16'bz;
wire[31:0]      d_valA  = 32'bz;
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
assign          {d_icode, d_ifun} = D_jflg ? NOP  : F_read[31:24];
assign          {d_rA, d_rB}      = D_jflg ? 8'b0 : F_read[23:16];
assign          d_valC  = F_read[15: 0];

//Determine valA and valB with forwarding:
assign          d_valA = (e_dstE == d_rA) ? e_valE :
                         (E_dstE == d_rA) ? E_valE :
                         (w_dstE == d_rA) ? w_valE :
                         (w_dstM == d_rA) ? w_valM : d_valA_reg;
assign          d_valB = (e_dstE == d_rB) ? e_valE :
                         (E_dstE == d_rB) ? E_valE :
                         (w_dstE == d_rB) ? w_valE :
                         (w_dstM == d_rB) ? w_valM : d_valB_reg;
assign          d_halt = ({d_icode, d_ifun} == HALT) ? 1 : 0;
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
        /*d_icode <= F_read[31:28];
        d_ifun  <= F_read[27:24];
        d_rA    <= F_read[23:20];
        d_rB    <= F_read[19:16]; 
        d_valC  <= F_read[15: 0];*/
        
        if (d_halt) begin
            {D_icode, D_ifun} <= 8'bz;
            D_rA    <= 4'hF;
            D_rB    <= 4'hF;
            D_valC  <= 16'bz;
            D_valA  <= 32'bz;
            D_valB  <= 32'bz;
            D_halt  <= d_halt;
        end
        else begin
            /*if ({d_icode, d_ifun} == NOP) begin
                {D_icode, D_ifun} <= AND;//NOP = AND R0, R0
            end
            else begin 
                D_icode <= d_icode;
                D_ifun  <= d_ifun;
            end*/
            case({d_icode, d_ifun})
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

            case({d_icode, d_ifun})
                RRMOV:begin
                    D_valA  <= d_valA;
                    D_valB  <= 0;
                    D_rA    <= d_rB;
                    D_rB    <= d_rA; 
                end
                CMOVLE: begin
                    D_valA  <= d_valA;
                    D_valB  <= 0;
                    if((e_SF^e_OF)|e_ZF)begin
                        D_rA    <= d_rB;
                        D_rB    <= d_rA; 
                    end
                    else begin
                        D_rA    <= d_rA;
                        D_rB    <= d_rB; 
                    end
                end
                CMOVL: begin
                    D_valA  <= d_valA;
                    D_valB  <= 0;
                    if(e_SF^e_OF)begin
                        D_rA    <= d_rB;
                        D_rB    <= d_rA; 
                    end
                    else begin
                        D_rA    <= d_rA;
                        D_rB    <= d_rB; 
                    end
                end
                CMOVE: begin
                    D_valA  <= d_valA;
                    D_valB  <= 0;
                    if(e_ZF)begin
                        D_rA    <= d_rB;
                        D_rB    <= d_rA; 
                    end
                    else begin
                        D_rA    <= d_rA;
                        D_rB    <= d_rB; 
                    end
                end
                CMOVNE: begin
                    D_valA  <= d_valA;
                    D_valB  <= 0;
                    if(~e_ZF)begin
                        D_rA    <= d_rB;
                        D_rB    <= d_rA; 
                    end
                    else begin
                        D_rA    <= d_rA;
                        D_rB    <= d_rB; 
                    end                    
                end
                CMOVGE: begin
                    D_valA  <= d_valA;
                    D_valB  <= 0;
                    if(~(e_SF^e_OF))begin
                        D_rA    <= d_rB;
                        D_rB    <= d_rA; 
                    end
                    else begin
                        D_rA    <= d_rA;
                        D_rB    <= d_rB; 
                    end
                end
                CMOVG: begin
                    D_valA  <= d_valA;
                    D_valB  <= 0;
                    if(~(e_SF^e_OF)&(~e_ZF))begin
                        D_rA    <= d_rB;
                        D_rB    <= d_rA; 
                    end
                    else begin
                        D_rA    <= d_rA;
                        D_rB    <= d_rB; 
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
wire[31:0]        e_valA = 32'bz;
wire[31:0]        e_valB = 32'bz;
wire[3:0]         e_alufun = 4'bz;
wire[31:0]        e_valE = 32'bz;
wire[3:0]         e_dstE = 4'bz;
initial begin
        e_reg_rst <= 1;
    #20 e_reg_rst <= 0;
end
//----------Execute stage---------//
assign            valE   = e_valE; 
assign            e_valA = D_valA;
assign            e_valB = D_valB;
assign            e_halt = D_halt;
assign            e_dstE = D_rA;
assign            e_alufun = 
                  ({D_icode, D_ifun} == ADD) ? 0 :
                  ({D_icode, D_ifun} == SUB) ? 1 :
                  ({D_icode, D_ifun} == AND) ? 2 :
                  ({D_icode, D_ifun} == XOR) ? 3 : 4'bz;
assign            e_ZF = cc[2];
assign            e_SF = cc[1];
assign            e_OF = cc[0];
always @(posedge clock) begin
    if ({D_icode, D_ifun} == IRMOV) begin
        E_dstM <= D_rB;
        E_valM <= D_valC;
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
/*always @(posedge clock) begin
        w_dstM <= E_dstM;
        w_valM <= E_valM;
        w_dstE <= E_dstE;
        w_valE <= E_valE;
end*/
assign        w_dstM = E_dstM;
assign        w_valM = E_valM;
assign        w_dstE = E_dstE;
assign        w_valE = E_valE;    
endmodule
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
    //Bench Group 1
    #20         addr <= 0; wr <= 1; wdata <= 32'h10F00001;
    #20         addr <= 1; wr <= 1; wdata <= 32'h10F10002;
    #20         addr <= 2; wr <= 1; wdata <= 32'h10F20003;
    #20         addr <= 3; wr <= 1; wdata <= 32'h10F30004;
    #20         addr <= 4; wr <= 1; wdata <= 32'h10F40005;
    #20         addr <= 5; wr <= 1; wdata <= 32'h10F50006;
    #20         addr <= 6; wr <= 1; wdata <= 32'h10F60007;
    #20         addr <= 7; wr <= 1; wdata <= 32'h10F70008;
    #20         addr <= 8; wr <= 1; wdata <= 32'h21210000;  
    #20         addr <= 9; wr <= 1; wdata <= 32'h7600000C; 
    #20         addr <= 10;wr <= 1; wdata <= 32'h20760000;
    #20         addr <= 11;wr <= 1; wdata <= 32'h20100000;
    #20         addr <= 12;wr <= 1; wdata <= 32'h21700000;
    /*
    #20         addr <= 8; wr <= 1; wdata <= 32'h7000000B;   
    #20         addr <= 9; wr <= 1; wdata <= 32'h21760000;
    #20         addr <= 10;wr <= 1; wdata <= 32'h20760000;
    #20         addr <= 11;wr <= 1; wdata <= 32'h20100000;
    #20         addr <= 12;wr <= 1; wdata <= 32'h21700000;*/

    #20         addr <= 0; wr <= 0; wdata <= 0;
    #10         working <= 1;
    #560        working <= 0; flg <= 1;
    #1000       $stop;
end
always #10 clock = ~clock;
always @(posedge clock ) begin
    if (flg)begin
        rID <= rID + 1;
    end
end
initial begin
    $dumpfile("pro_tbe1.vcd");
    $dumpvars();
end
endmodule

//-----Testbench of processor(EX Task 3)-----//
/*module pro_tb4;
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
    //Bench Group 1
    #20         addr <= 0; wr <= 1; wdata <= 32'h10F00080;
    #20         addr <= 1; wr <= 1; wdata <= 32'h10F10081;
    #20         addr <= 2; wr <= 1; wdata <= 32'h10F20082;
    #20         addr <= 3; wr <= 1; wdata <= 32'h10F30083;
    #20         addr <= 4; wr <= 1; wdata <= 32'h10F40084;
    #20         addr <= 5; wr <= 1; wdata <= 32'h10F50085;
    #20         addr <= 6; wr <= 1; wdata <= 32'h10F60086;
    #20         addr <= 7; wr <= 1; wdata <= 32'h10F70087;
    #20         addr <= 8; wr <= 1; wdata <= 32'h30010000;
    #20         addr <= 9; wr <= 1; wdata <= 32'h21320000;
    #20         addr <= 10;wr <= 1; wdata <= 32'h31450000;
    #20         addr <= 11;wr <= 1; wdata <= 32'h21010000;
    #20         addr <= 12;wr <= 1; wdata <= 32'h31450000;
    #20         addr <= 13;wr <= 1; wdata <= 32'h21320000;
    #20         addr <= 14;wr <= 1; wdata <= 32'h31670000;
    
    //Bench group 2
    #20         addr <= 0; wr <= 1; wdata <= 32'h10F00088;
    #20         addr <= 1; wr <= 1; wdata <= 32'h10F10089;
    #20         addr <= 2; wr <= 1; wdata <= 32'h10F2008A;
    #20         addr <= 3; wr <= 1; wdata <= 32'h10F3008B;
    #20         addr <= 4; wr <= 1; wdata <= 32'h10F4008C;
    #20         addr <= 5; wr <= 1; wdata <= 32'h10F5008D;
    #20         addr <= 6; wr <= 1; wdata <= 32'h10F6008E;
    #20         addr <= 7; wr <= 1; wdata <= 32'h10F7008F;
    #20         addr <= 8; wr <= 1; wdata <= 32'h30010000;
    #20         addr <= 9; wr <= 1; wdata <= 32'h21320000;
    #20         addr <= 10;wr <= 1; wdata <= 32'h32450000;
    #20         addr <= 11;wr <= 1; wdata <= 32'h21010000;
    #20         addr <= 12;wr <= 1; wdata <= 32'h32450000;
    #20         addr <= 13;wr <= 1; wdata <= 32'h21320000;
    #20         addr <= 14;wr <= 1; wdata <= 32'h32670000;
    
    //Bench group 3
    #20         addr <= 0; wr <= 1; wdata <= 32'h10F00090;
    #20         addr <= 1; wr <= 1; wdata <= 32'h10F10091;
    #20         addr <= 2; wr <= 1; wdata <= 32'h10F20092;
    #20         addr <= 3; wr <= 1; wdata <= 32'h10F30093;
    #20         addr <= 4; wr <= 1; wdata <= 32'h10F40094;
    #20         addr <= 5; wr <= 1; wdata <= 32'h10F50095;
    #20         addr <= 6; wr <= 1; wdata <= 32'h10F60096;
    #20         addr <= 7; wr <= 1; wdata <= 32'h10F70097;
    #20         addr <= 8; wr <= 1; wdata <= 32'h30010000;
    #20         addr <= 9; wr <= 1; wdata <= 32'h21320000;
    #20         addr <= 10;wr <= 1; wdata <= 32'h33450000;
    #20         addr <= 11;wr <= 1; wdata <= 32'h21010000;
    #20         addr <= 12;wr <= 1; wdata <= 32'h33450000;
    #20         addr <= 13;wr <= 1; wdata <= 32'h21320000;
    #20         addr <= 14;wr <= 1; wdata <= 32'h33670000;
    //Bench group 4
    //CMOVLE = 8'h31; CMOVL  = 8'h32;
    //CMOVE  = 8'h33; CMOVNE = 8'h34;
    //CMOVGE = 8'h35; CMOVG  = 8'h36;
    #20         addr <= 0; wr <= 1; wdata <= 32'h10F00090;
    #20         addr <= 1; wr <= 1; wdata <= 32'h10F10091;
    #20         addr <= 2; wr <= 1; wdata <= 32'h10F20092;
    #20         addr <= 3; wr <= 1; wdata <= 32'h10F30093;
    #20         addr <= 4; wr <= 1; wdata <= 32'h10F40094;
    #20         addr <= 5; wr <= 1; wdata <= 32'h10F50095;
    #20         addr <= 6; wr <= 1; wdata <= 32'h10F60096;
    #20         addr <= 7; wr <= 1; wdata <= 32'h10F70097;
    #20         addr <= 8; wr <= 1; wdata <= 32'h30010000;
    #20         addr <= 9; wr <= 1; wdata <= 32'h21320000;
    #20         addr <= 10;wr <= 1; wdata <= 32'h34450000;
    #20         addr <= 11;wr <= 1; wdata <= 32'h21010000;
    #20         addr <= 12;wr <= 1; wdata <= 32'h34450000;
    #20         addr <= 13;wr <= 1; wdata <= 32'h21320000;
    #20         addr <= 14;wr <= 1; wdata <= 32'h34670000;
    //Bench group 5
    //CMOVLE = 8'h31; CMOVL  = 8'h32;
    //CMOVE  = 8'h33; CMOVNE = 8'h34;
    //CMOVGE = 8'h35; CMOVG  = 8'h36;
    #20         addr <= 0; wr <= 1; wdata <= 32'h10F00090;
    #20         addr <= 1; wr <= 1; wdata <= 32'h10F10091;
    #20         addr <= 2; wr <= 1; wdata <= 32'h10F20092;
    #20         addr <= 3; wr <= 1; wdata <= 32'h10F30093;
    #20         addr <= 4; wr <= 1; wdata <= 32'h10F40094;
    #20         addr <= 5; wr <= 1; wdata <= 32'h10F50095;
    #20         addr <= 6; wr <= 1; wdata <= 32'h10F60096;
    #20         addr <= 7; wr <= 1; wdata <= 32'h10F70097;
    #20         addr <= 8; wr <= 1; wdata <= 32'h30010000;
    #20         addr <= 9; wr <= 1; wdata <= 32'h21320000;
    #20         addr <= 10;wr <= 1; wdata <= 32'h35450000;
    #20         addr <= 11;wr <= 1; wdata <= 32'h21010000;
    #20         addr <= 12;wr <= 1; wdata <= 32'h35450000;
    #20         addr <= 13;wr <= 1; wdata <= 32'h21320000;
    #20         addr <= 14;wr <= 1; wdata <= 32'h35670000;
    //Bench group 6
    //CMOVLE = 8'h31; CMOVL  = 8'h32;
    //CMOVE  = 8'h33; CMOVNE = 8'h34;
    //CMOVGE = 8'h35; CMOVG  = 8'h36;
    #20         addr <= 0; wr <= 1; wdata <= 32'h10F00090;
    #20         addr <= 1; wr <= 1; wdata <= 32'h10F10091;
    #20         addr <= 2; wr <= 1; wdata <= 32'h10F20092;
    #20         addr <= 3; wr <= 1; wdata <= 32'h10F30093;
    #20         addr <= 4; wr <= 1; wdata <= 32'h10F40094;
    #20         addr <= 5; wr <= 1; wdata <= 32'h10F50095;
    #20         addr <= 6; wr <= 1; wdata <= 32'h10F60096;
    #20         addr <= 7; wr <= 1; wdata <= 32'h10F70097;
    #20         addr <= 8; wr <= 1; wdata <= 32'h30010000;
    #20         addr <= 9; wr <= 1; wdata <= 32'h21320000;
    #20         addr <= 10;wr <= 1; wdata <= 32'h36450000;
    #20         addr <= 11;wr <= 1; wdata <= 32'h21010000;
    #20         addr <= 12;wr <= 1; wdata <= 32'h36450000;
    #20         addr <= 13;wr <= 1; wdata <= 32'h21320000;
    #20         addr <= 14;wr <= 1; wdata <= 32'h36670000;

    #20         addr <= 0; wr <= 0; wdata <= 0;
    #10         working <= 1;
    #560        working <= 0; flg <= 1;
    #1000       $stop;
end
always #10 clock = ~clock;
always @(posedge clock ) begin
    if (flg)begin
        rID <= rID + 1;
    end
end
initial begin
    $dumpfile("pro_tbe1.vcd");
    $dumpvars();
end
endmodule*/

/*
//-----Testbench of processor(Task 5)-----//
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
    #20         addr <= 0; wr <= 1; wdata <= 32'h10F00080;
    #20         addr <= 1; wr <= 1; wdata <= 32'h10F10081;
    #20         addr <= 2; wr <= 1; wdata <= 32'h10F20082;
    #20         addr <= 3; wr <= 1; wdata <= 32'h10F30083;
    #20         addr <= 4; wr <= 1; wdata <= 32'h10F40084;
    #20         addr <= 5; wr <= 1; wdata <= 32'h10F50085;
    #20         addr <= 6; wr <= 1; wdata <= 32'h10F60086;
    #20         addr <= 7; wr <= 1; wdata <= 32'h10F70087;
    //CMOVLE = 8'h31; CMOVL  = 8'h32;
    //CMOVE  = 8'h33; CMOVNE = 8'h34;
    //CMOVGE = 8'h35; CMOVG  = 8'h36;
    //#20         addr <= 8; wr <= 1; wdata <= 32'h21430000;  
    //#20         addr <= 9; wr <= 1; wdata <= 32'h32120000;
    //#20         addr <= 10;wr <= 1; wdata <= 32'h22320000;
    //#20         addr <= 11;wr <= 1; wdata <= 32'h23430000;
    //#20         addr <= 12;wr <= 1; wdata <= 32'h30430000;  
    //#20         addr <= 13;wr <= 1; wdata <= 32'h22430000;
    //#20         addr <= 14;wr <= 1; wdata <= 32'h20430000;
    //#20         addr <= 15;wr <= 1; wdata <= 32'h23430000;

    //Ex Task 2 added
    //#20         addr <= 8; wr <= 1; wdata <= 32'h20100000;  
    //#20         addr <= 9; wr <= 1; wdata <= 32'h21210000;
    //#20         addr <= 10;wr <= 1; wdata <= 32'h22320000;
    //#20         addr <= 11;wr <= 1; wdata <= 32'h23430000;
    //#20         addr <= 12;wr <= 1; wdata <= 32'h21430000;  
    //#20         addr <= 13;wr <= 1; wdata <= 32'h22430000;
    //#20         addr <= 14;wr <= 1; wdata <= 32'h20430000;
    //#20         addr <= 15;wr <= 1; wdata <= 32'h23430000;
    //#20         addr <= 16;wr <= 1; wdata <= 32'h20340000;
    //#20         addr <= 17;wr <= 1; wdata <= 32'h21430000;
    //#20         addr <= 18;wr <= 1; wdata <= 32'h23340000;
    //#20         addr <= 19;wr <= 1; wdata <= 32'h22430000;
    //Ex Task 1 added 
    //#20         addr <= 8; wr <= 1; wdata <= 32'h20010000;
    //#20         addr <= 9; wr <= 1; wdata <= 32'h11000000;
    //#20         addr <= 10;wr <= 1; wdata <= 32'h11000000;
    //#20         addr <= 11;wr <= 1; wdata <= 32'h21230000;
    //#20         addr <= 12;wr <= 1; wdata <= 32'h12000000;
    //#20         addr <= 13;wr <= 1; wdata <= 32'h12000000;
    //#20         addr <= 14;wr <= 1; wdata <= 32'h22450000;
    //#20         addr <= 15;wr <= 1; wdata <= 32'h11000000;
    //#20         addr <= 16;wr <= 1; wdata <= 32'h12000000;
    //#20         addr <= 17;wr <= 1; wdata <= 32'h23670000;

    //EX Task 1 simple bench
    //#20         addr <= 8; wr <= 1; wdata <= 32'h20010000;
    //#20         addr <= 9; wr <= 1; wdata <= 32'h21230000;
    //#20         addr <= 10;wr <= 1; wdata <= 32'h11000000;
    //#20         addr <= 11;wr <= 1; wdata <= 32'h22450000;
    //#20         addr <= 12;wr <= 1; wdata <= 32'h23670000;
    //#20         addr <= 8; wr <= 1; wdata <= 32'h20010000;
    //#20         addr <= 9; wr <= 1; wdata <= 32'h21230000;
    //#20         addr <= 10;wr <= 1; wdata <= 32'h11000000;
    //#20         addr <= 11;wr <= 1; wdata <= 32'h11000000;
    //#20         addr <= 12;wr <= 1; wdata <= 32'h22450000;
    //#20         addr <= 13;wr <= 1; wdata <= 32'h23670000;

    //Task 3 added
    //#20         addr <= 8; wr <= 1; wdata <= 32'h20010000;
    //#20         addr <= 9; wr <= 1; wdata <= 32'h21230000;
    //#20         addr <= 10;wr <= 1; wdata <= 32'h22450000;
    //#20         addr <= 11;wr <= 1; wdata <= 32'h23670000;
    
    //Task 5 added
    //#20         addr <= 12;wr <= 1; wdata <= 32'h21540000;
    //#20         addr <= 13;wr <= 1; wdata <= 32'h22760000;
    //#20         addr <= 14;wr <= 1; wdata <= 32'h20320000;
    //#20         addr <= 15;wr <= 1; wdata <= 32'h23100000;
    //#20         addr <= 16;wr <= 1; wdata <= 32'h20350000;
    //#20         addr <= 17;wr <= 1; wdata <= 32'h21240000;
    //#20         addr <= 18;wr <= 1; wdata <= 32'h23060000;
    //#20         addr <= 19;wr <= 1; wdata <= 32'h22170000;
    #20         addr <= 0; wr <= 0; wdata <= 0;
    #10         working <= 1;
    #560        working <= 0; flg <= 1;
    #1000       $stop;
end
always #10 clock = ~clock;
always @(posedge clock ) begin
    if (flg)begin
        rID <= rID + 1;
    end
end
initial begin
    $dumpfile("pro_tbe1.vcd");
    $dumpvars();
end
endmodule
*/
/*
//-----Testbench of processor-----//
module pro_tb4;
reg             clock;
reg[31:0]        addr;
reg             wr;
reg[31:0]       wdata;
reg             working;
//reg[3:0]        rID;
//wire[31:0]      valA, valB; 
wire[31:0]      valE;
wire[31:0]      r0, r1, r2, r3, r4, r5, r6, r7;
//wire[31:0]      rdata;
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
                //rID,
                //icode,
                //ifun,
                //rA,
                //rB,
                //valC,
                //valA,
                //valB,
                valE,
                r0, r1, r2, r3, r4, r5, r6, r7
                //rdata
                //valE
);
initial begin
    clock <= 0; addr <= 0; wr <= 0; wdata <= 0; working <= 0; //rID <=0;
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
    $dumpfile("pro_tb4.vcd");
    $dumpvars();
end
endmodule
*/

/*
//-----Testbench of processor (Task 1)-------//
module pro_tb;
reg             clock;
reg[31:0]        addr;
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
input[31:0]      addr,
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
//reg[31:0]       addr_buffer;
//reg[31:0]      read_buffer = 0;
//assign icode = read_buffer[31:28];
//assign ifun  = read_buffer[27:24];
//assign rA    = read_buffer[23:20];
//assign rB    = read_buffer[19:16];
//assign valC  = read_buffer[15: 0];

wire[31:0]       addr_w;
wire[31:0]      read_w;
reg[31:0]        PC = 0;
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
reg[31:0]        addr;
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