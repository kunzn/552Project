module PC_control(C, I, F, PC_in, PC_out);

input [2:0] C; //condition
input [8:0] I; // offset, immediate and signed
input [2:0] F; // flag
input [15:0] PC_in;
output[15:0] PC_out;


// 000 = Not Equal (Z=0)

// 001 = Equal (Z=1)

// 010 = Greater Than (Z = N = 0)

// 011 = Less Than (N = 1)

// 100 = Greater Than or Equal (Z = 1 or Z = N = 0)

// 101 = Less Than or Equal




endmodule