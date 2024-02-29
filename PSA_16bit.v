module PSA_16bit (Sum, Error, A, B);
  input [15:0] A, B; // Input data values
  output [15:0] Sum; // Sum output
  output Error; // To indicate overflows

  wire [3:0] Ovfl;
  wire [3:0] sum1, sum2, sum3, sum4;

  CLA4 add1(.A(A[3:0]), .B(B[3:0]), .sub(1'b0), .Sum(sum1), .Ovfl(Ovfl[0]));
  CLA4 add2(.A(A[7:4]), .B(B[7:4]), .sub(1'b0), .Sum(sum2), .Ovfl(Ovfl[1]));
  CLA4 add3(.A(A[11:8]), .B(B[11:8]), .sub(1'b0), .Sum(sum3), .Ovfl(Ovfl[2]));
  CLA4 add4(.A(A[15:12]), .B(B[15:12]), .sub(1'b0), .Sum(sum4), .Ovfl(Ovfl[3]));
  
  assign Sum[3:0] = Ovfl[0] ? sum1[3] ? 4'b0111 : 4'b1000 : Sum[3:0];
  assign Sum[7:4] = Ovfl[1] ? sum2[3] ? 4'b0111 : 4'b1000 : Sum[7:4];
  assign Sum[11:8] = Ovfl[2] ? sum3[3] ? 4'b0111 : 4'b1000 : Sum[11:8];
  assign Sum[15:12] = Ovfl[3] ? sum4[3] ? 4'b0111 : 4'b1000 : Sum[15:12];

  assign Error = | Ovfl;

endmodule