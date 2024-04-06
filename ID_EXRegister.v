module ID_EXRegister(
  input clk,
  input rst_n,
  input [3:0] D_Operand1,
  input [3:0] D_Operand2_Mux,
  input [3:0] D_Operand2_Fw,
  input [3:0] D_Destination,
  input [3:0] D_Opcode,
  input [15:0] D_Operand1_Out,
  input [15:0] D_Operand2_Out,
  input [15:0] D_Nxt_Pc,
  input D_hlt,
  input D_ALUSrc,
  input D_MemtoReg,
  input D_MemRead,
  input D_MemWrite,
  input D_RegWrite,
  input D_Pcs,
  input D_load_byte,
  input D_sw,
  output [3:0] X_Operand1,
  output [3:0] X_Operand2_Mux,
  output [3:0] X_Operand2_Fw,
  output [3:0] X_Destination,
  output [3:0] X_Opcode,
  output [15:0] X_Operand1_Out,
  output [15:0] X_Operand2_Out,
  output [15:0] X_Nxt_Pc,
  output X_hlt,
  output X_ALUSrc,
  output X_MemtoReg,
  output X_MemRead,
  output X_MemWrite,
  output X_RegWrite,
  output X_Pcs,
  output X_load_byte,
  output X_sw
);
  // Instruction
  dff Operand1[3:0](.q(X_Operand1), .d(D_Operand1), .wen(1'b1), .clk(clk), .rst(~rst_n));
  dff Operand2_mux[3:0](.q(X_Operand2_Mux), .d(D_Operand2_Mux), .wen(1'b1), .clk(clk), .rst(~rst_n));
  dff Operand2_Fw[3:0](.q(X_Operand2_Fw), .d(D_Operand2_Fw), .wen(1'b1), .clk(clk), .rst(~rst_n));
  dff Destination[3:0](.q(X_Destination), .d(D_Destination), .wen(1'b1), .clk(clk), .rst(~rst_n));
  dff Opcode[3:0](.q(X_Opcode), .d(D_Opcode), .wen(1'b1), .clk(clk), .rst(~rst_n));

  // Data
  dff Operand1_Out[15:0](.q(X_Operand1_Out), .d(D_Operand1_Out), .wen(1'b1), .clk(clk), .rst(~rst_n));
  dff Operand2_Out[15:0](.q(X_Operand2_Out), .d(D_Operand2_Out), .wen(1'b1), .clk(clk), .rst(~rst_n));

  // PC
  dff Nxt_Pc[15:0](.q(X_Nxt_Pc), .d(D_Nxt_Pc), .wen(1'b1), .clk(clk), .rst(~rst_n));

  // Control Signals
  dff hlt(.q(X_hlt), .d(D_hlt), .wen(1'b1), .clk(clk), .rst(~rst_n));
  dff ALUSrc(.q(X_ALUSrc), .d(D_ALUSrc), .wen(1'b1), .clk(clk), .rst(~rst_n));
  dff MemtoReg(.q(X_MemtoReg), .d(D_MemtoReg), .wen(1'b1), .clk(clk), .rst(~rst_n));
  dff MemRead(.q(X_MemRead), .d(D_MemRead), .wen(1'b1), .clk(clk), .rst(~rst_n));
  dff MemWrite(.q(X_MemWrite), .d(D_MemWrite), .wen(1'b1), .clk(clk), .rst(~rst_n));
  dff RegWrite(.q(X_RegWrite), .d(D_RegWrite), .wen(1'b1), .clk(clk), .rst(~rst_n));
  dff Pcs(.q(X_Pcs), .d(D_Pcs), .wen(1'b1), .clk(clk), .rst(~rst_n));
  dff load_byte(.q(X_load_byte), .d(D_load_byte), .wen(1'b1), .clk(clk), .rst(~rst_n));
  dff sw(.q(X_sw), .d(D_sw), .wen(1'b1), .clk(clk), .rst(~rst_n));

endmodule

/*
ID_EXRegister(
  .D_Operand1(D_Operand1),
  .D_Operand2_Mux(D_Operand2_Mux),
  .D_Operand2_Fw(D_Operand2_Fw),
  .D_Destination(D_Destination),
  .D_Opcode(D_Opcode),
  .D_Operand1_Out(D_Operand1_Out),
  .D_Operand2_Out(D_Operand2_Out),
  .D_Nxt_Pc(D_Nxt_Pc),
  .D_hlt(D_hlt),
  .D_ALUSrc(D_ALUSrc),
  .D_MemtoReg(D_MemtoReg),
  .D_MemRead(D_MemRead),
  .D_MemWrite(D_MemWrite),
  .D_RegWrite(D_RegWrite),
  .D_Pcs(D_Pcs),
  .D_load_byte(D_load_byte),
  .D_sw(D_sw),
  .X_Operand1(X_Operand1),
  .X_Operand2_Mux(X_Operand2_Mux),
  .X_Operand2_Fw(X_Operand2_Fw),
  .X_Destination(X_Destination),
  .X_Opcode(X_Opcode),
  .X_Operand1_Out(X_Operand1_Out),
  .X_Operand2_Out(X_Operand2_Out),
  .X_Nxt_Pc(X_Nxt_Pc),
  .X_hlt(X_hlt),
  .X_ALUSrc(X_ALUSrc),
  .X_MemtoReg(X_MemtoReg),
  .X_MemRead(X_MemRead),
  .X_MemWrite(X_MemWrite),
  .X_RegWrite(X_RegWrite),
  .X_Pcs(X_Pcs),
  .X_load_byte(X_load_byte),
  .X_sw(X_sw)
);
*/