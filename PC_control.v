module PC_control(C, I, F, Br, rs_addr, PC_in, PC_out);

  input [2:0] C; //condition
  input [8:0] I; // offset, immediate and signed
  input [2:0] F; // flag NVZ
  input Br; // 1 if Br, 0 if B
  input [15:0] rs_addr;
  input [15:0] PC_in;
  output[15:0] PC_out;
  output cond_met;

  wire [15:0] PC_Add_Out , PC_Add_Out2;
  //reg [15:0] pc_out;
  wire Ovfl;
  
  
  Add_Sub_16bit adder2(.A(PC_in), .B({{6{I[8]}}, I, 1'b0}), .sub(1'b0), .Sum(PC_Add_Out2), .Ovfl(Ovfl));

  reg condition_met;
  always @(*) 
  begin
    case(C)
    3'b000: begin // Z = 0
	condition_met = (~F[0]) ? 1'b1 : 1'b0;
	end
    3'b001: begin // Z = 1
	condition_met = (F[0]) ? 1'b1 : 1'b0;
	end
    3'b010: begin // Z = N = 0
	condition_met = (~F[0] & ~F[2]) ? 1'b1 : 1'b0;
	end
    3'b011: begin // N = 1
	condition_met = (F[2]) ? 1'b1 : 1'b0;
	end
    3'b100: begin // Z = 1 or Z = N = 0
	condition_met = (F[0] | (~F[2] & ~F[0])) ? 1'b1 : 1'b0;
	end
    3'b101: begin // Z = 1 or N = 1
	condition_met = (F[2] | F[0]) ? 1'b1 : 1'b0;
	end
    3'b110: begin // V = 1
	condition_met = (F[1]) ? 1'b1 : 1'b0;
	end
    3'b111: begin // Unconditional
	condition_met = 1'b1 ;
	end
    default: begin
	condition_met = 1'b0;
      end 
    endcase
   end
  assign PC_out = condition_met ? (Br ? rs_addr : PC_Add_Out2) : PC_Add_Out;
endmodule
