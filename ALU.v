module ALU (
  input [3:0] ALU_In1, ALU_In2,
  input [1:0] Opcode,
  output [3:0] ALU_Out,
  output Error // Just to show overflow
);
  wire [3:0] Sum;
  wire Ovfl;

  addsub_4bit addr(.A(ALU_In1), .B(ALU_In2), .sub(Opcode[0]), .Sum(Sum), .Ovfl(Ovfl));
  
  wire [3:0] A_and_B;
  assign A_and_B = ALU_In1 & ALU_In2;

  assign ALU_Out = (Opcode[1] & Opcode[0]) ? (ALU_In1 ^ ALU_In2) : (Opcode[1]) ? ~A_and_B : Sum;
  assign Error = (~Opcode[1]) ? Ovfl : 0;

endmodule

