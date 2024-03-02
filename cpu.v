module cpu(clk, rst_n, hlt, pc);

input clk, rst_n; // System clock & Active low reset. A low on this resets the processor and causes execution to start at address 0x0000
output hlt; 
output [15:0] pc; // PC value over the course of program execution

// when processor encounters the HLT instruction, 
//it will assert this signal once it is finished processing the instruction prior to the HLT
 
wire [15:0] br_pc; //keep track of PC, PC+4

reg RegWrite, ALUSrc, PCSrc, MemWrite, MemtoReg, MemRead, br, pcs, hlt_, load_byte, sw;
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

assign opcode = instruction[15:12];
assign destination = instruction[11:8];
assign operand1 = instruction[7:4];
assign operand2 = instruction[3:0];

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
	// Nothing happens??
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
assign PCSrcMux = hlt_ ? pc : br ? &(destination[3:1]) ? SrcData1 : |(destination[3:1] ^ F) ? nxt_pc : SrcData1 : PCSrc ? br_pc : nxt_pc;
assign SrcReg1 = load_byte ? destination : operand1; 
assign SrcReg2 = sw ? destination : operand2;
assign hlt = hlt_;

assign RegWrite2 = ~rst_n ? 1'b0 : RegWrite;
assign MemWrite2 = ~rst_n ? 1'b0 : MemWrite;
assign MemRead2 = ~rst_n ? 1'b0 : MemRead;

endmodule

