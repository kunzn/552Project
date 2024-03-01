module PC_control(C, I, F, PC_in, PC_out);

  input [2:0] C; //condition
  input [8:0] I; // offset, immediate and signed
  input [2:0] F; // flag
  input [15:0] PC_in;
  output[15:0] PC_out;

  wire [15:0] PC_Add_Out;
  wire Ovfl;
  Add_Sub_16bit adder(.A(PC_in << 1), .B({6'b0, I, 1'b0}), .sub(1'b0), .Sum(PC_Add_Out), .Ovfl(Ovfl));
  assign PC_out = &(C) ? PC_Add_Out : |(C ^ F) ? PC_in << 1 : PC_Add_Out;

endmodule