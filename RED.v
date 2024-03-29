
module RED (
  input [15:0] A, 
  input [15:0] B, //Input values
  output [15:0] Sum //sum output
);
	wire [6:0] C, Ovfls;
	wire [8:0] LSB_SUM, MSB_SUM;

	CLA4 claLSB1(.A(A[3:0]), .B(B[3:0]), .Cin(1'b0), .Sum(LSB_SUM[3:0]), .Ovfl(Ovfls[0]), .Cout(C[0]));
  	CLA4 claLSB2(.A(A[7:4]), .B(B[7:4]), .Cin(C[0]), .Sum(LSB_SUM[7:4]), .Ovfl(Ovfls[1]), .Cout(C[1]));

  	CLA4 claMSB1(.A(A[11:8]), .B(B[11:8]), .Cin(1'b0), .Sum(MSB_SUM[3:0]), .Ovfl(Ovfls[2]), .Cout(C[2]));
  	CLA4 claMSB2(.A(A[15:12]), .B(B[15:12]), .Cin(C[2]), .Sum(MSB_SUM[7:4]), .Ovfl(Ovfls[3]), .Cout(C[3]));

	wire [15:0] final_SUM;

  	CLA4 claFin1(.A(LSB_SUM[3:0]), .B(MSB_SUM[3:0]), .Cin(1'b0), .Sum(final_SUM[3:0]), .Ovfl(Ovfls[4]), .Cout(C[4]));
  	CLA4 claFin2(.A(LSB_SUM[7:4]), .B(MSB_SUM[7:4]), .Cin(C[4]), .Sum(final_SUM[7:4]), .Ovfl(Ovfls[5]), .Cout(C[5]));
	CLA4 claFin3(.A({3'b0, C[1]}), .B({3'b0, C[3]}), .Cin(C[5]), .Sum(final_SUM[11:8]), .Ovfl(Ovfls[6]), .Cout(C[6]));

	assign Sum = final_SUM[9] ? {6'b111111, final_SUM[9:0]} : {6'b000000, final_SUM[9:0]};
endmodule