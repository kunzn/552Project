
module ReadDecoder_4_16(input [3:0] RegId, output [15:0] Wordline);

  wire [15:0] shift0;
  wire [15:0] shift1;
  wire [15:0] shift2;
  wire [15:0] shift4;

  assign shift0 = {{15{1'b0}}, 1'b1};

  assign shift1 = RegId[0] ? shift0 << 1 : shift0;

  assign shift2 = RegId[1] ? shift1 << 2 : shift1;

  assign shift4 = RegId[2] ? shift2 << 4 : shift2;

  assign Wordline = RegId[3] ? shift4 << 8 : shift4;

endmodule