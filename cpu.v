module cpu(clk, rst_n, hlt, pc);

input clk, rst_n; // System clock & Active low reset. A low on this resets the processor and causes execution to start at address 0x0000
output hlt; 
output pc[15:0]; // PC value over the course of program execution

// when processor encounters the HLT instruction, 
//it will assert this signal once it is finished processing the instruction prior to the HLT

reg [15:0] curr_pc, next_pc; //keep track of PC, PC+4
reg read_DMem, WriteReg;

reg [3:0] opcode, destination, operand1. operand2, SrcData1, SrcData2;
wire [15:0] instruction;

reg [15:0] ALU_In2, Opcode, ALU_Out, Error;

IMemory iMemory(.data_out(instruction), data_in(16'b0), .addr(curr_pc), .enable(1'b1), wr(1'b0), .clk(clk), .rst(~rst_n));

DMemory dMemory(data_out, data_in, addr, .enable(read_DMem), wr, .clk(clk), .rst(~rst_n));

RegisterFile registerFile(.clk(clk), .rst(~rst_n), .SrcReg1(operand1), .SrcReg2(operand2), .DstReg(), .WriteReg(WriteReg), .DstData(), .SrcData1(SrcData1), .SrcData2(SrcData2));

ALU alu(.ALU_In1(SrcData1), .ALU_In2(ALU_In2), .Opcode(opcode), .ALU_Out(), .Error());

assign opcode = instruction[15:12];
assign destination = instruction[11:8];
assign operand1 = instruction[7:4];
assign operand2 = instruction[3:0];

always @(*) 
  begin
    RegDst = 0;
    
    case(Opcode)
    4'b0000: begin  // ADD
      ALU_In2 = 
      end
    4'b0001: begin // SUB
      sub = 1;
      Adder_In_2 = ALU_In2;
      ALU_Return = adder_output;
      V = adder_ovfl;
      Z = ~(|adder_output);
      N = adder_output[15];
      end
    4'b0010: begin // XOR
      ALU_Return = ALU_In1 ^ ALU_In2;
      Z = ~(|ALU_Return);
      end
    4'b0011: begin // RED
      ALU_Return = red_output;
      end
    4'b0100: begin // SLL
      ALU_Return = shifter_output;
      Z = ~(|ALU_Return);
      end
    4'b0101: begin // SRA
      ALU_Return = shifter_output;
      Z = ~(|ALU_Return);
      end
    4'b0110: begin // ROR
      ALU_Return = shifter_output;
      end
    4'b0111: begin // PADDSB
      ALU_Return = paddsb_output;
      end   
    4'b1000: begin// LW
      sub = 0;
      Adder_In_2 = ALU_In2 << 1;
      ALU_Return = adder_output;
      end 
    4'b1001: begin// SW
      sub = 0;
      Adder_In_2 = ALU_In2 << 1;
      ALU_Return = adder_output;
      end 
    4'b1010: begin// LLB
	// Nothing happens??
      end 
    4'b1011: begin// LHB
	// Nothing happens??
      end 
    4'b1100: begin// B
      end 
    4'b1101: begin// BR
      end 
    4'b1110: begin// PCS
      end 
    4'b1111: begin// HLT
      end 
    default: begin
      end 
    endcase
  end


endmodule

