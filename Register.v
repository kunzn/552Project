module Register(
    input clk,
    input rst,
    input [15:0] D,
    input WriteReg,
    input ReadEnable1,
    input ReadEnable2,
    inout [15:0] Bitline1,
    inout [15:0] Bitline2
);
    BitCell bitcells[15:0] (
        .clk(clk),
        .rst(rst),
        .D(D),
        .WriteEnable(WriteReg),
        .ReadEnable1(ReadEnable1),
        .ReadEnable2(ReadEnable2),
        .Bitline1(Bitline1),
        .Bitline2(Bitline2)
    );

endmodule
