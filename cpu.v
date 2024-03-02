module cpu(clk, rst_n, hlt, pc);

input clk, rst_n; // System clock & Active low reset. A low on this resets the processor and causes execution to start at address 0x0000
output hlt; 
output [15:0] pc; // PC value over the course of program execution

// when processor encounters the HLT instruction, 
//it will assert this signal once it is finished processing the instruction prior to the HLT
 
wire [15:0] br_pc; //keep track of PC, PC+4

wire MemWrite2, MemRead2, RegWrite2; // control signals
wire [15:0] ALUSrcMux, MemtoRegMux, PCSrcMux, nxt_pc;
wire [2:0] F;
wire Ovfl;
wire [3:0] opcode, destination, operand1, operand2, SrcReg1, SrcReg2;
wire [15:0] SrcData1, SrcData2; // used to pull instruction
wire [15:0] data_out, ALU_Out, instruction; // stores intruction from mem

Memory iMemory(.data_out(instruction), .data_in(16'b0), .addr(pc), .enable(1'b1), .wr(1'b0), .clk(clk), .rst(~rst_n));

Memory dMemory(.data_out(data_out), .data_in(SrcData2), .addr(ALU_Out), .enable(MemRead2), .wr(MemWrite2), .clk(clk), .rst(~rst_n));

RegisterFile registerFile(.clk(clk), .rst(~rst_n), .SrcReg1(SrcReg1), .SrcReg2(SrcReg2), .DstReg(destination), .WriteReg(RegWrite2), .DstData(MemtoRegMux), .SrcData1(SrcData1), .SrcData2(SrcData2));

ALU alu(.ALU_In1(SrcData1), .ALU_In2(ALUSrcMux), .Opcode(opcode), .ALU_Out(ALU_Out), .F(F), .rst(~rst_n), .clk(clk));

PC_control pc_control(.C(destination[3:1]), .I(instruction[8:0]), .F(F), .PC_in(pc), .PC_out(br_pc));

dff cur_pc[15:0](.q(pc), .d(PCSrcMux), .wen(1'b1), .clk(clk), .rst(~rst_n));

Add_Sub_16bit adder(.A(pc), .B(16'h0002), .sub(1'b0), .Sum(nxt_pc), .Ovfl(Ovfl));

control_signals control(
  .opcode(opcode), 
  .destination(destination), 
  .operand1(operand1), 
  .operand2(operand2), 
  .data_out(data_out), 
  .SrcData1(SrcData1),
  .SrcData2(SrcData2),
  .ALU_Out(ALU_Out),  
  .instruction(instruction), 
  .F(F),
  .pc(pc),
  .br_pc(br_pc),
  .rst_n(rst_n),
  .MemWrite2(MemWrite2), 
  .MemRead2(MemRead2),  
  .RegWrite2(RegWrite2), 
  .SrcReg1(SrcReg1), 
  .SrcReg2(SrcReg2), 
  .ALUSrcMux(ALUSrcMux), 
  .MemtoRegMux(MemtoRegMux),  
  .PCSrcMux(PCSrcMux), 
  .nxt_pc(nxt_pc), 
  .hlt(hlt)
);

assign opcode = instruction[15:12];
assign destination = instruction[11:8];
assign operand1 = instruction[7:4];
assign operand2 = instruction[3:0];


endmodule

