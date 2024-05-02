
module I_cache(
input clk, 
input rst, 
input memory_address, 
input memory_data_out,
input write_data_array,
input [15:0] addr,
input write_enable, 
input [15:0] data_write,
output fsm_busy,
output [15:0] data_word,
output miss
);

wire [5:0] tag, index;
wire [3:0] offset;
wire [63:0] BlockEnable, shift1, shift2, shift3, shift4, shift5;
wire [7:0] MetaDataOut1, MetaDataOut2, MetaDataIn1, MetaDataIn2;
wire [15:0] DataOut1, DataOut2;
wire [ 7:0] WordEnable, shift1_we, shift2_we;
wire hit1, hit2, write_en_data_1, write_en_data_2. miss;

wire [15:0] memory_address, memory_data_out, cache_data_out;
wire miss_detected, fsm_busy, write_data_array, write_tag_array, memory_data_valid;

//memory4c iMemory(.data_out(memory_data_out), .data_in(16'b0), .addr(memory_address), .enable((miss & ~fsm_busy) | (memory_data_valid & ~write_tag_array)), .wr(1'b0), .clk(clk), .rst(~rst_n), .data_valid(memory_data_valid));
//cache_fill_FSM icache_fsm(.clk(clk), .rst_n(rst_n), .miss_detected(miss & ~fsm_busy), .miss_address(addr), .fsm_busy(fsm_busy), .write_data_array(write_data_array), .write_tag_array(write_tag_array) , .memory_address(memory_address), .memory_data_valid(memory_data_valid));

assign tag = (fsm_busy) ? memory_address[15:0] : addr[15:10];
assign index = (fsm_busy) ? memory_address[9:4] : addr[9:4];
assign offset = (fsm_busy) ? memory_address[3:0] : addr[3:0];

assign shift1 = index[0] ? {63'b0, 1'b1} << 1 : {63'b0, 1'b1};
assign shift2 = index[1] ? shift1 << 2 : shift1;
assign shift3 = index[2] ? shift2 << 4 : shift2;
assign shift4 = index[3] ? shift3 << 8 : shift3;
assign shift5 = index[4] ? shift4 << 16 : shift4;
assign BlockEnable = index[5] ? shift5 << 32 : shift5;

assign shift1_we = offset[1] ? {7'b0, 1'b1} << 1 : {7'b0, 1'b1};
assign shift2_we = offset[2] ? shift1_we << 2 : shift1_we;
assign WordEnable = offset[3] ? shift2_we << 4 : shift2_we;

DataArray DataArray_1(.clk(clk), .rst(rst), .DataIn(CacheDataIn1), .Write(write_en_data_1), .BlockEnable(BlockEnable), .WordEnable(WordEnable), .DataOut(DataOut1));
DataArray DataArray_2(.clk(clk), .rst(rst), .DataIn(CacheDataIn2), .Write(write_en_data_2), .BlockEnable(BlockEnable), .WordEnable(WordEnable), .DataOut(DataOut2));

MetaDataArray MetaDataArray_1(.clk(clk), .rst(rst), .DataIn(MetaDataIn1), .Write(1'b1), .BlockEnable(BlockEnable), .DataOut(MetaDataOut1));
MetaDataArray MetaDataArray_2(.clk(clk), .rst(rst), .DataIn(MetaDataIn2), .Write(1'b1), .BlockEnable(BlockEnable), .DataOut(MetaDataOut2));

assign hit1 = ~(|(MetaDataOut1[7:2] ^ tag)) & MetaDataOut1[1]; //& ~write_enable;
assign hit2 = ~(|(MetaDataOut2[7:2] ^ tag)) & MetaDataOut2[1];// & ~write_enable;

// update LRU depending on which is read
assign MetaDataIn1 = write_en_data_1 ? {tag[15:10], 2'b10} : (write_en_data_2 | hit2) ? {MetaDataOut1[7:1], 1'b1} : hit1 ? {MetaDataOut1[7:1], 1'b0} : MetaDataOut1[7:0];
assign MetaDataIn2 = write_en_data_2 ? {tag[15:10], 2'b10} : (write_en_data_1 | hit1) ? {MetaDataOut2[7:1], 1'b1} : hit2 ? {MetaDataOut2[7:1], 1'b0} : MetaDataOut2[7:0];

assign CacheDataIn1 = write_en_data_1 ? memory_data_out : DataOut1;
assign CacheDataIn2 = write_en_data_2 ? memory_data_out : DataOut2;

// Choose which block to write to
assign data_write_block = ~MetaDataOut1[1] ? 1'b0  : ~MetaDataOut2[1] ? 1'b1 : MetaDataOut1[0] ? 1'b0 : 1'b1;
// Only write when enable is high
assign write_en_data_1 = ~data_write_block & write_data_array;
assign write_en_data_2 = data_write_block & write_data_array;

// Assign outputs, miss only high when reading (and miss) - ignore data word output if writing
assign miss = ~(hit1 | hit2);// & ~write_enable;
assign data_word = hit1 ? DataOut1 : hit2 ? DataOut2 : write_tag_array ? memory_data_out : 16'b0;

endmodule