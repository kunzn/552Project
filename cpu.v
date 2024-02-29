module cpu(clk, rst_n, hlt, pc);

input clk, rst_n; // System clock & Active low reset. A low on this resets the processor and causes execution to start at address 0x0000
output hlt; 
output pc[15:0]; // PC value over the course of program execution

// when processor encounters the HLT instruction, 
//it will assert this signal once it is finished processing the instruction prior to the HLT

wire [15:0] curr_pc, next_pc; //keep track of PC, PC+4

wire[15:0] ALUout; //output of ALU



endmodule

