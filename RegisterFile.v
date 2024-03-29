module RegisterFile(
    input clk,
    input rst,
    input [3:0] SrcReg1,
    input [3:0] SrcReg2,
    input [3:0] DstReg,
    input WriteReg,
    input [15:0] DstData,
    inout [15:0] SrcData1,
    inout [15:0] SrcData2
);

    wire[15:0] read_wordline_1, read_wordline_2, write_wordline;
    wire[15:0] bitline1, bitline2;

    ReadDecoder_4_16 read1(.RegId(SrcReg1), .Wordline(read_wordline_1));
    ReadDecoder_4_16 read2(.RegId(SrcReg2), .Wordline(read_wordline_2));
    WriteDecoder_4_16 write1(.RegId(DstReg), .WriteReg(WriteReg), .Wordline(write_wordline));

    Register registers [15:0] (
        .clk(clk),
        .rst(rst),
        .D(DstData),
        .WriteReg(write_wordline),
        .ReadEnable1(read_wordline_1),
        .ReadEnable2(read_wordline_2),
        .Bitline1(bitline1),
        .Bitline2(bitline2)
    );

    assign SrcData1 = bitline1;
    assign SrcData2 = bitline2;

endmodule
