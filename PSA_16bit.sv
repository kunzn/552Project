module PSA_16bit (Sum, Error, A, B);
  input [15:0] A, B; // Input data values
  output [15:0] Sum; // Sum output
  output Error; // To indicate overflows

  wire [3:0] Ovfl;

  addsub_4bit add1(.A(A[3:0]), .B(B[3:0]), .sub(1'b0), .Sum(Sum[3:0]), .Ovfl(Ovfl[0]));
  addsub_4bit add2(.A(A[7:4]), .B(B[7:4]), .sub(1'b0), .Sum(Sum[7:4]), .Ovfl(Ovfl[1]));
  addsub_4bit add3(.A(A[11:8]), .B(B[11:8]), .sub(1'b0), .Sum(Sum[11:8]), .Ovfl(Ovfl[2]));
  addsub_4bit add4(.A(A[15:12]), .B(B[15:12]), .sub(1'b0), .Sum(Sum[15:12]), .Ovfl(Ovfl[3]));

  assign Error = | Ovfl;

endmodule