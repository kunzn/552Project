module FA(
  input 	A,B,Cin,
  output	S,Cout		
);

	wire a_xor_b, a_and_b, pre_cout;
	
	assign a_xor_b = A ^ B;
	assign a_and_b = A & B;
	assign pre_cout = a_xor_b & Cin;
	assign S = Cin ^ a_xor_b;
	assign Cout = pre_cout | a_and_b;
	
endmodule