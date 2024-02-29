
module Add_Sub_16bit (
  input [15:0] A, 
  input [15:0] B, //Input values
  input sub, // add-sub indicator
  output [15:0] Sum, //sum output
  output Ovfl //To indicate overflow
);
	wire [3:0] GG, GP, Ovfls;
 	wire [3:0] C;
	wire [15:0] pre_sat_sum;

	CLA4 cla1(.A(A[3:0]), .B(B[3:0]), .Cin(sub), .S(pre_sat_sum[3:0]), .GG(GG[0]), .GP(GP[0]), .Ovfl(Ovfls[0]));
  	CLA4 cla2(.A(A[7:4]), .B(B[7:4]), .Cin(C[0]), .S(pre_sat_sum[7:4]), .GG(GG[1]), .GP(GP[1]), .Ovfl(Ovfls[1]));
  	CLA4 cla3(.A(A[11:8]), .B(B[11:8]), .Cin(C[1]), .S(pre_sat_sum[11:8]), .GG(GG[2]), .GP(GP[2]), .Ovfl(Ovfls[2]));
  	CLA4 cla4(.A(A[15:12]), .B(B[15:12]), .Cin(C[2]), .S(pre_sat_sum[15:12]), .GG(GG[3]), .GP(GP[3]), .Ovfl(Ovfls[3]));

	wire XGG, XGP, XOvfl;
	CLA4 cla5(.A(GP), .B(GG), .Cin(sub), .S(C), .GG(XGG), .GP(XGP), .Ovfl(XOvfl));

	assign Sum = (Ovfls[3]) ? (pre_sat_sum[15] ? 16'h7FFF : 16'h8000) : pre_sat_sum;
	assign Ovfl = Ovfls[3];
endmodule