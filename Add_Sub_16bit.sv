
module Add_Sub_16bit (
  input [15:0] A, 
  input [15:0] B, //Input values
  input sub, // add-sub indicator
  output [15:0] Sum, //sum output
  output Ovfl //To indicate overflow
);
	logic [3:0] carry;

	FA fa0(.A(A[0]), .B((sub) ? ~B[0] : B[0]), .Cin(sub), .S(Sum[0]), .Cout(carry[0]));
  	FA fa1(.A(A[1]), .B((sub) ? ~B[1] : B[1]), .Cin(carry[0]), .S(Sum[1]), .Cout(carry[1]));
  	FA fa2(.A(A[2]), .B((sub) ? ~B[2] : B[2]), .Cin(carry[1]), .S(Sum[2]), .Cout(carry[2]));
  	FA fa3(.A(A[3]), .B((sub) ? ~B[3] : B[3]), .Cin(carry[2]), .S(Sum[3]), .Cout(carry[3]));

	assign Ovfl = carry[3] ^ carry[2];
endmodule