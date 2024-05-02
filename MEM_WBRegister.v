
module MEM_WBRegister(
  input clk,
  input rst_n,
  input [3:0] M_Destination,
  input [15:0] M_MemData,
  input [15:0] M_ALUout,
  input [15:0] M_Nxt_Pc,
  input M_hlt,
  input M_MemtoReg,
  input M_RegWrite,
  input M_Pcs,
  output [3:0] W_Destination,
  output [15:0] W_MemData,
  output [15:0] W_ALUout,
  output [15:0] W_Nxt_Pc,
  output W_hlt,
  output W_MemtoReg,
  output W_RegWrite,
  output W_Pcs
);

  // Instruction
  dff Destination[3:0](.q(W_Destination), .d(M_Destination), .wen(1'b1), .clk(clk), .rst(~rst_n));

  // Data
  dff MemData[15:0](.q(W_MemData), .d(M_MemData), .wen(1'b1), .clk(clk), .rst(~rst_n));
  dff ALUout[15:0](.q(W_ALUout), .d(M_ALUout), .wen(1'b1), .clk(clk), .rst(~rst_n));

  // PC
  dff Nxt_Pc[15:0](.q(W_Nxt_Pc), .d(M_Nxt_Pc), .wen(1'b1), .clk(clk), .rst(~rst_n));

  // Control Signals
  dff hlt(.q(W_hlt), .d(M_hlt), .wen(1'b1), .clk(clk), .rst(~rst_n));
  dff MemtoReg(.q(W_MemtoReg), .d(M_MemtoReg), .wen(1'b1), .clk(clk), .rst(~rst_n));
  dff RegWrite(.q(W_RegWrite), .d(M_RegWrite), .wen(1'b1), .clk(clk), .rst(~rst_n));
  dff Pcs(.q(W_Pcs), .d(M_Pcs), .wen(1'b1), .clk(clk), .rst(~rst_n));

endmodule

/*

MEM_WBRegister MEM_WB(
  .M_Destination(M_Destination),
  .M_MemData(M_MemData),
  .M_ALUout(M_ALUout),
  .M_Nxt_Pc(M_Nxt_Pc),
  .M_hlt(M_hlt),
  .M_MemtoReg(M_MemtoReg),
  .M_RegWrite(M_RegWrite),
  .M_Pcs(M_Pcs),
  .W_Destination(W_Destination),
  .W_MemData(W_MemData),
  .W_ALUout(W_ALUout),
  .W_Nxt_Pc(W_Nxt_Pc),
  .W_hlt(W_hlt),
  .W_MemtoReg(W_MemtoReg),
  .W_RegWrite(W_RegWrite),
  .W_Pcs(W_Pcs),
);
*/