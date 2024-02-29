
module CLA4 (
  input [3:0] A, 
  input [3:0] B, //Input values
  input Cin, // add-sub indicator
  output [3:0] Sum, //sum output
  output Ovfl, //To indicate overflow
  output GG,
  output GP
);
	wire [3:0] carry;
	wire [3:0] p, g;
	wire [3:0] Cout;

	assign g = A & B;
	assign p = A ^ B;

	assign carry[0] = g[0] | (p[0] & Cin); 
	assign carry[1] = g[1] | (p[1] & g[0]) | (p[1] & p[0] & Cin);
	assign carry[2] = g[2] | (p[2] & g[1]) | (p[2] & p[1] & g[0]) | (p[2] & p[1] & p[0] & Cin);
	assign carry[3] = g[3] | (p[3] & g[2]) | (p[3] & p[2] & g[1]) | (p[3] & p[2] & p[1] & g[0]) | (p[3] & p[2] & p[1] & p[0] & Cin);

	FA fa0(.A(A[0]), .B(B[0]), .Cin(Cin), .S(Sum[0]), .Cout(Cout[0]));
  	FA fa1(.A(A[1]), .B(B[1]), .Cin(carry[0]), .S(Sum[1]), .Cout(Cout[1]));
  	FA fa2(.A(A[2]), .B(B[2]), .Cin(carry[1]), .S(Sum[2]), .Cout(Cout[2]));
  	FA fa3(.A(A[3]), .B(B[3]), .Cin(carry[2]), .S(Sum[3]), .Cout(Cout[3]));

	assign Ovfl = carry[3] ^ carry[2];
	assign GG = g[3] | (p[3] & g[2]) | (p[3] & p[2] & g[1]) | (p[3] & p[2] & p[1] & g[0]) | (p[3] & p[2] & p[1] & p[0]);
	assign GP = &p;
endmodule