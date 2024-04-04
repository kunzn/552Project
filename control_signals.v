module control_signals(
  input[3:0] opcode,
  input[3:0] destination,
  input[3:0] operand1, 
  input[3:0] operand2, 
  input[15:0] data_out, 
  input[15:0] ALU_Out, 
  input[15:0] SrcData1,
  input[15:0] SrcData2,
  input[15:0] instruction,
  input[15:0] pc,
  input[15:0] br_pc,
  input[2:0] F,
  input rst_n,
  output MemWrite2,
  output MemRead2,
  output RegWrite2,
  output[3:0] SrcReg1, 
  output[3:0] SrcReg2,
  output [15:0] ALUSrcMux,
  output [15:0] MemtoRegMux,
  output [15:0] PCSrcMux, 
  output [15:0] nxt_pc,
  output BR,
  output hlt
);

  reg RegWrite, ALUSrc, PCSrc, MemWrite, MemtoReg, MemRead, br, pcs, hlt_, load_byte, sw;

 // dff ID_EX_Control[10:0](.q(pc), .d(PCSrcMux), .wen(1'b1), .clk(clk), .rst(~rst_n));
  //dff EX_MEM_Control[10:0](.q(pc), .d(PCSrcMux), .wen(1'b1), .clk(clk), .rst(~rst_n));
 // dff MEM_WB_Control[10:0](.q(pc), .d(PCSrcMux), .wen(1'b1), .clk(clk), .rst(~rst_n));


always @(*) 
  begin
    RegWrite = 0;
    ALUSrc = 0;
    PCSrc = 0;
    MemWrite = 0;
    MemtoReg = 0; 
    MemRead = 0;
    br = 0;
    pcs = 0;
    hlt_ = 0;
    load_byte = 0; 
    sw = 0;
    case(opcode)
    4'b0000: begin  // ADD
      RegWrite = 1;
      MemtoReg = 1; 
      end
    4'b0001: begin // SUB
      RegWrite = 1;
      MemtoReg = 1; 
      end
    4'b0010: begin // XOR
      RegWrite = 1;
      MemtoReg = 1;
      end
    4'b0011: begin // RED
      RegWrite = 1;
      MemtoReg = 1; 
      end
    4'b0100: begin // SLL
      RegWrite = 1;
      ALUSrc = 1;
      MemtoReg = 1; 
      end
    4'b0101: begin // SRA
      RegWrite = 1;
      ALUSrc = 1;
      MemtoReg = 1; 
      end
    4'b0110: begin // ROR
      RegWrite = 1;
      ALUSrc = 1;
      MemtoReg = 1; 
      end
    4'b0111: begin // PADDSB
      RegWrite = 1;
      MemtoReg = 1; 
      end   
    4'b1000: begin// LW
      RegWrite = 1;
      ALUSrc = 1;
      MemRead = 1;
      MemtoReg = 0;
      end 
    4'b1001: begin// SW
      ALUSrc = 1;
      MemWrite = 1;
      MemtoReg = 1; //don't care
      MemRead = 1;
      sw = 1;
      end 
    4'b1010: begin// LLB
      load_byte = 1;
      MemtoReg = 1;
      RegWrite = 1;
      end 
    4'b1011: begin// LHB
      load_byte = 1;
      MemtoReg = 1;
      RegWrite = 1;
      end 
    4'b1100: begin// B
      PCSrc = 1;
      end 
    4'b1101: begin// BR
      PCSrc = 1;
      br = 1;
      end 
    4'b1110: begin// PCS
      pcs = 1;
      RegWrite = 1;
      end 
    4'b1111: begin// HLT
      hlt_ = 1;
      end 
    default: begin
      end 
    endcase
  end

//reg [15:0] ALUSrcMux, MemtoRegMux, PCSrcMux; 
assign ALUSrcMux = load_byte ? {instruction[7:0]} : ALUSrc ? {{12{operand2[3]}},operand2} : SrcData2;
assign MemtoRegMux = pcs ? PCSrcMux : MemtoReg ? ALU_Out : data_out;
assign PCSrcMux = hlt_ ? pc : PCSrc ? br_pc : nxt_pc;
assign SrcReg1 = load_byte ? destination : operand1; 
assign SrcReg2 = sw ? destination : operand2;
assign hlt = hlt_;
assign BR = br;

assign RegWrite2 = ~rst_n ? 1'b0 : RegWrite;
assign MemWrite2 = ~rst_n ? 1'b0 : MemWrite;
assign MemRead2 = ~rst_n ? 1'b0 : MemRead;
endmodule