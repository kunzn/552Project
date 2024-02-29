
module Add_Sub_16bit (
  input [15:0] A, 
  input [15:0] B, //Input values
  input sub, // add-sub indicator
  output [15:0] Sum, //sum output
  output Ovfl //To indicate overflow
);
	wire [3:0] C, Ovfls;
	wire [15:0] pre_sat_sum;

	CLA4 cla1(.A(A[3:0]), .B((sub) ? ~B[3:0] : B[3:0]), .Cin(sub), .Sum(pre_sat_sum[3:0]), .Cout(C[0]), .Ovfl(Ovfls[0]));
  	CLA4 cla2(.A(A[7:4]), .B((sub) ? ~B[7:4] : B[7:4]), .Cin(C[0]), .Sum(pre_sat_sum[7:4]), .Cout(C[1]), .Ovfl(Ovfls[1]));
  	CLA4 cla3(.A(A[11:8]), .B((sub) ? ~B[11:8] : B[11:8]), .Cin(C[1]), .Sum(pre_sat_sum[11:8]), .Cout(C[2]), .Ovfl(Ovfls[2]));
  	CLA4 cla4(.A(A[15:12]), .B((sub) ? ~B[15:12] : B[15:12]), .Cin(C[2]), .Sum(pre_sat_sum[15:12]), .Cout(C[3]), .Ovfl(Ovfls[3]));

	assign Sum = (Ovfls[3]) ? (pre_sat_sum[15] ? 16'h7FFF : 16'h8000) : pre_sat_sum;
	assign Ovfl = Ovfls[3];
endmodule