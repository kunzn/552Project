module PC_control(C, I, F, PC_in, PC_out);

  input [2:0] C; //condition
  input [8:0] I; // offset, immediate and signed
  input [2:0] F; // flag
  input [15:0] PC_in;
  output[15:0] PC_out;

  wire [15:0] PC_Add_Out , PC_Add_Out2;
  wire Ovfl;
  
  Add_Sub_16bit adder(.A(PC_in), .B(16'h0002), .sub(1'b0), .Sum(PC_Add_Out), .Ovfl(Ovfl));
  Add_Sub_16bit adder2(.A(PC_Add_Out), .B({{6{I[8]}}, I, 1'b0}), .sub(1'b0), .Sum(PC_Add_Out2), .Ovfl(Ovfl));
  assign PC_out = &(C) ? PC_Add_Out2 : |(C ^ F) ? PC_Add_Out : PC_Add_Out2;
 // {{6I[8]}, I, 1'b0}
endmodule