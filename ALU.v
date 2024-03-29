module ALU (
  input [15:0] ALU_In1, ALU_In2,
  input [3:0] Opcode,
  output [15:0] ALU_Out,
  output [2:0] F, // VNZ
  input rst,
  input clk
);
  reg sub;
  reg shifter_mode;
  reg inter_in2;
  reg [15:0] ALU_Return;
  reg [15:0] Adder_In_2, Adder_In_1;

  wire [15:0] adder_output;
  wire [15:0] red_output;
  wire [15:0] paddsb_output;
  wire [15:0] shifter_output;
  wire adder_ovfl;
  wire passdb_ovfl;
  reg V_en, N_en, Z_en, V, N, Z;

  dff V_flag(.q(F[2]), .d(V), .wen(V_en), .clk(clk), .rst(rst));
  dff N_flag(.q(F[1]), .d(N), .wen(N_en), .clk(clk), .rst(rst));
  dff Z_flag(.q(F[0]), .d(Z), .wen(Z_en), .clk(clk), .rst(rst));

  // add: rs + rt 
  Add_Sub_16bit adder(.A(Adder_In_1), .B(Adder_In_2), .sub(sub), .Sum(adder_output), .Ovfl(adder_ovfl));
  RED reduction(.A(ALU_In1), .B(ALU_In2), .Sum(red_output));

  // rs + 4 bit_immediate
  Shifter shift(.Shift_In(ALU_In1), .Shift_Val(ALU_In2[3:0]), .Mode(Opcode[1:0]), .Shift_Out(shifter_output));
  PSA_16bit paddsb(.A(ALU_In1), .B(ALU_In2), .Sum(paddsb_output), .Error(passdb_ovfl));

  assign ALU_Out = ALU_Return;

  always @(*) 
  begin
    ALU_Return = 16'b0;
    Adder_In_2 = 16'b0;
    Adder_In_1 = ALU_In1;
    sub = 0;
    V_en = 1'b0;
    N_en = 1'b0;
    Z_en = 1'b0;
    case(Opcode)
    4'b0000: begin  // ADD
      sub = 0;
      Adder_In_2 = ALU_In2;
      ALU_Return = adder_output;
      V = adder_ovfl;
      Z = ~(|adder_output);
      N = adder_output[15];
      V_en = 1'b1;
      N_en = 1'b1;
      Z_en = 1'b1;
      end
    4'b0001: begin // SUB
      sub = 1;
      Adder_In_2 = ALU_In2;
      ALU_Return = adder_output;
      V = adder_ovfl;
      Z = ~(|adder_output);
      N = adder_output[15];
      V_en = 1'b1;
      N_en = 1'b1;
      Z_en = 1'b1;
      end
    4'b0010: begin // XOR
      ALU_Return = ALU_In1 ^ ALU_In2;
      Z = ~(|ALU_Return);
      Z_en = 1'b1;
      end
    4'b0011: begin // RED
      ALU_Return = red_output;
      end
    4'b0100: begin // SLL
      ALU_Return = shifter_output;
      Z = ~(|ALU_Return);
      Z_en = 1'b1;
      end
    4'b0101: begin // SRA
      ALU_Return = shifter_output;
      Z = ~(|ALU_Return);
      Z_en = 1'b1;
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
      Adder_In_1 = ALU_In1 & 16'hFFFE;
      ALU_Return = adder_output;
      end 
    4'b1001: begin// SW
      sub = 0;
      Adder_In_2 = ALU_In2 << 1;
      Adder_In_1 = ALU_In1 & 16'hFFFE;
      ALU_Return = adder_output;
      end 
    4'b1010: begin// LLB
	// Nothing happens??
      ALU_Return = (ALU_In1 & 16'hFF00) | ALU_In2;
      end 
    4'b1011: begin// LHB
	// Nothing happens??
      ALU_Return = (ALU_In1 & 16'h00FF) | (ALU_In2 << 8);
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

