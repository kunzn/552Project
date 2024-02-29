
module Add_Sub_16bit (
  input [15:0] A, 
  input [15:0] B, //Input values
  input sub, // add-sub indicator
  output [15:0] Sum, //sum output
  output Ovfl //To indicate overflow
);
	wire [3:0] GG, GP, Ovfl;

	CLA4 cla1(.A(A[3:0]), .B(B[3:0]), .Cin(sub), .Sum(Sum[3:0]), .GG(GG[0]), .GP(GP[0]), .Ovfl(Ovfl[0]);
  	CLA4 cla2(.A(A[7:4]), .B(B[7:4]), .Cin(sub), .Sum(Sum[7:4]), .GG(GG[1]), .GP(GP[1]), .Ovfl(Ovfl[1]);
  	CLA4 cla3(.A(A[11:8]), .B(B[11:8]), .Cin(sub), .Sum(Sum[11:0]), .GG(GG[2]), .GP(GP[2]), .Ovfl(Ovfl[2]);
  	CLA4 cla4(.A(A[15:12]), .B(B[15:12]), .Cin(sub), .Sum(Sum[15:12]), .GG(GG[3]), .GP(GP[3]), .Ovfl(Ovfl[3 ]);

	assign Ovfl = carry[3] ^ carry[2];
endmodule