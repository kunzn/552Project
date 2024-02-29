module ALU (
  input [15:0] ALU_In1, ALU_In2,
  input [3:0] Opcode,
  output [15:0] ALU_Out,
  output Error // Just to show overflow
);
  reg sub;
  reg shifter_mode;
  reg inter_in2;

  wire adder_output;
  wire red_output;
  wire paddsb_output;
  wire shifter_output;
  wire paddsb_output;

  // add: rs + rt 
  Add_Sub_16bit adder(.A(ALU_In1), .B(ALU_In2), .sub(sub), .Sum(adder_output), .Ovfl());
  Red reduction(.A(ALU_In1), .B(ALU_In2), .Sum(red_output));

  // rs + 4 bit_immediate
  Shifter shift(.Shift_In(ALU_In1), .Shift_Val(ALU_In2[3:0]), .Mode(Opcode[1:0]), .Shift_Out(shifter_output))
  PSA_16bit paddsb(.A(ALU_In1), .B(ALU_In2), .Sum(paddsb_output), .Error());

  always @(*) 
  begin
    case(Opcode)
    4'b0000: 
      sub = 0;
      ALU_Out = adder_output;
    4'b0001: 
      sub = 1;
      ALU_Out = adder_output;
    4'b0010:
      ALU_Out = ALU_In1 ^ ALU_In2;
    4'b0011:
      ALU_Out = red_output;
    4'b0100:
      ALU_Out = shifter_output;
    4'b0101:
      ALU_Out = shifter_output;
    4'b0110:
      ALU_Out = shifter_output;
    4'b0111:
      ALU_Out = paddsb_output;
    4'b1000:
    4'b1001:
    4'b1010:
    4'b1011:
    4'b1100:
    4'b1101:
    4'b1110:
    4'b1111:
    default: 
  endcase
endmodule

