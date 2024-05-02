module Shifter2 (Shift_Out, Shift_In, Shift_Val, Mode);
  input [15:0] Shift_In; // This is the input data to perform shift operation on
  input [3:0] Shift_Val; // Shift amount (used to shift the input data)
  input Mode; // To indicate 0=SLL or 1=SRA
  output [15:0] Shift_Out; // Shifted output data

  wire [15:0] mux1,mux2,mux3,mux4;

  assign mux1 = (Mode & Shift_Val[0])? {Shift_In[15],Shift_In[15:1]} : Shift_Val[0] ? {Shift_In[14:0],1'b0} : Shift_In;
  assign mux2 = (Mode & Shift_Val[1])? {{2{mux1[15]}},mux1[15:2]} : Shift_Val[1] ? {mux1[13:0],{2{1'b0}}} : mux1;
  assign mux3 = (Mode & Shift_Val[2])? {{4{mux2[15]}},mux2[15:4]} : Shift_Val[2] ? {mux2[11:0],{4{1'b0}}} : mux2;
  assign mux4 = (Mode & Shift_Val[3])? {{8{mux3[15]}},mux3[15:8]} : Shift_Val[3] ? {mux3[7:0],{8{1'b0}}} : mux3;

  assign Shift_Out = mux4;

endmodule

module ReadDecoder_4_16(input [3:0] RegId, output [15:0] Wordline);
  //shift to create decoder
  Shifter2 shifter(.Shift_Out(Wordline), .Shift_In({15'b0,1'b1}), .Shift_Val(RegId), .Mode(1'b0));
endmodule

module WriteDecoder_4_16(input [3:0] RegId, input WriteReg, output [15:0] Wordline);
  // get wordline
  wire [15:0] dst;
  Shifter2 shifter(.Shift_Out(dst), .Shift_In({15'b0,1'b1}), .Shift_Val(RegId), .Mode(1'b0));
  assign Wordline = WriteReg ? dst : 16'b0;

endmodule

module BitCell(input clk, input rst, input D, input WriteEnable, input ReadEnable1, 
	input ReadEnable2, inout Bitline1, inout Bitline2);
  wire q;

  dff ff(.q(q), .d(D), .wen(WriteEnable), .clk(clk), .rst(rst));

  assign Bitline1 = ReadEnable1 ? q : 1'bz;
  assign Bitline2 = ReadEnable2 ? q : 1'bz;
endmodule

module Register(input clk, input rst, input [15:0] D, input WriteReg, input ReadEnable1, 
	input ReadEnable2, inout [15:0] Bitline1, inout [15:0] Bitline2);
  // each register is made up of 16 bit cells
  BitCell bits[15:0](.clk(clk), .rst(rst), .D(D), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1), .Bitline2(Bitline2));
endmodule

module RegisterFile(input clk, input rst, input [3:0] SrcReg1, input [3:0] SrcReg2, 
	input [3:0] DstReg, input WriteReg, input [15:0] DstData, inout [15:0] SrcData1, inout [15:0] SrcData2);

  wire [15:0] ReadEnable1, ReadEnable2, Write, Bitline1, Bitline2;

  assign SrcData1 = ((SrcReg1 == DstReg) & WriteReg) ? DstData : Bitline1;
  assign SrcData2 = ((SrcReg2 == DstReg) & WriteReg) ? DstData : Bitline2;

  // instantiate decoders
  ReadDecoder_4_16 src1(.RegId(SrcReg1), .Wordline(ReadEnable1));
  ReadDecoder_4_16 src2(.RegId(SrcReg2), .Wordline(ReadEnable2));

  //16 registers
  WriteDecoder_4_16 dst(.RegId(DstReg), .WriteReg(WriteReg), .Wordline(Write));
  Register registers[15:0](.clk(clk), .rst(rst), .D(DstData), .WriteReg(Write), .ReadEnable1(ReadEnable1), 
	.ReadEnable2(ReadEnable2), .Bitline1(Bitline1), .Bitline2(Bitline2));
endmodule