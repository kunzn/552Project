module control_signals(
  input[15:0] instruction,
  output RegWrite_Out, 
  output ALUSrc_Out,
  output PCSrc_Out,
  output MemWrite_Out,
  output MemtoReg_Out,
  output MemRead_Out,
  output br_Out,
  output pcs_Out,
  output hlt_Out,
  output load_byte_Out,
  output sw_Out
);
  //control signals
  reg RegWrite, ALUSrc, PCSrc, MemWrite, MemtoReg, MemRead, br, pcs, hlt, load_byte, sw;
  
  assign RegWrite_Out = RegWrite; 
  assign ALUSrc_Out = ALUSrc;
  assign PCSrc_Out = PCSrc;
  assign MemWrite_Out = MemWrite;
  assign MemtoReg_Out = MemtoReg;
  assign MemRead_Out = MemRead;
  assign br_Out = br;
  assign pcs_Out = pcs;
  assign hlt_Out = hlt;
  assign load_byte_Out = load_byte; 
  assign sw_Out = sw;
  
   

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
    hlt = 0;
    load_byte = 0; 
    sw = 0;
    case(instruction[15:12])
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
	  ALUSrc = 1;
      end 
    4'b1011: begin// LHB
      load_byte = 1;
      MemtoReg = 1;
      RegWrite = 1;
	  ALUSrc = 1;
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
      hlt = 1;
      end 
    default: begin
      end 
    endcase
  end

//reg [15:0] ALUSrcMux, MemtoRegMux, PCSrcMux; 
endmodule