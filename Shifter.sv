module Shifter (Shift_Out, Shift_In, Shift_Val, Mode);
input [15:0] Shift_In; // This is the input data to perform shift operation on
input [3:0] Shift_Val; // Shift amount (used to shift the input data)
input Mode; // To indicate 0=SLL or 1=SRA
output [15:0] Shift_Out; // Shifted output data

  logic [15:0] shift1;
  logic [15:0] shift2;
  logic [15:0] shift4;

  assign shift1 = Shift_Val[0] ? (Mode ? {Shift_In[15], Shift_In[15:1]} : {Shift_In[14:0], 1'b0}) : Shift_In;

  assign shift2 = Shift_Val[1] ? (Mode ? {{2{shift1[15]}}, shift1[15:2]} : {shift1[13:0], 2'b00}) : shift1;

  assign shift4 = Shift_Val[2] ? (Mode ? {{4{shift2[15]}}, shift2[15:4]} : {shift2[11:0], 4'b0000}) : shift2;

  assign Shift_Out = Shift_Val[3] ? (Mode ? {{8{shift4[15]}}, shift4[15:8]} : {shift4[7:0], 8'b00000000}) : shift4;


endmodule

