
module EX_MEMRegister(
  input [3:0] X_Destination,
  input [15:0] X_ALUout,
  input [15:0] X_WriteData,
  input [15:0] X_Nxt_Pc,
  input X_hlt,
  input X_MemtoReg,
  input X_MemRead,
  input X_MemWrite,
  input X_RegWrite,
  input X_Pcs,
  input X_load_byte,
  input X_sw,
  output [3:0] M_Destination,
  output [15:0] M_ALUout,
  output [15:0] M_WriteData,
  output [15:0] M_Nxt_Pc,
  output M_hlt,
  output M_MemtoReg,
  output M_MemRead,
  output M_MemWrite,
  output M_RegWrite,
  output M_Pcs,
  output M_load_byte,
  output M_sw
);

  // Instruction
  dff Destination[3:0](.q(M_Destination), .d(X_Destination), .wen(1'b1), .clk(clk), .rst(~rst_n));

  // Data
  dff Operand1_Out[15:0](.q(M_ALUout), .d(X_ALUout), .wen(1'b1), .clk(clk), .rst(~rst_n));
  dff Operand2_Out[15:0](.q(M_WriteData), .d(X_WriteData), .wen(1'b1), .clk(clk), .rst(~rst_n));

  // PC
  dff Nxt_Pc[15:0](.q(M_Nxt_Pc), .d(X_Nxt_Pc), .wen(1'b1), .clk(clk), .rst(~rst_n));

  // Control Signals
  dff hlt(.q(M_hlt), .d(X_hlt), .wen(1'b1), .clk(clk), .rst(~rst_n));
  dff MemtoReg(.q(M_MemtoReg), .d(X_MemtoReg), .wen(1'b1), .clk(clk), .rst(~rst_n));
  dff MemRead(.q(M_MemRead), .d(X_MemRead), .wen(1'b1), .clk(clk), .rst(~rst_n));
  dff MemWrite(.q(M_MemWrite), .d(X_MemWrite), .wen(1'b1), .clk(clk), .rst(~rst_n));
  dff RegWrite(.q(M_RegWrite), .d(X_RegWrite), .wen(1'b1), .clk(clk), .rst(~rst_n));
  dff Pcs(.q(M_Pcs), .d(X_Pcs), .wen(1'b1), .clk(clk), .rst(~rst_n));
  dff load_byte(.q(M_load_byte), .d(X_load_byte), .wen(1'b1), .clk(clk), .rst(~rst_n));
  dff sw(.q(M_sw), .d(X_sw), .wen(1'b1), .clk(clk), .rst(~rst_n));

endmodule
