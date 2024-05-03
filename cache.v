module cache(
input clk, 
input rst, 
input[15:0] memory_address, 
input[15:0] memory_data_out,
input write_data_array,
input write_tag_array,
input [15:0] addr,
input write_enable, 
input fsm_busy,
input read,
input [15:0] data_write,
output [15:0] data_word,
output miss,
output write_state
);

wire [5:0] tag, index;
wire [3:0] offset;
wire [63:0] BlockEnable, shift1, shift2, shift3, shift4, shift5;
wire [7:0] MetaDataOut1, MetaDataOut2, MetaDataIn1, MetaDataIn2, MetaDataOut_1, MetaDataOut_2;
wire [15:0] DataOut1, DataOut2, CacheDataIn1, CacheDataIn2, next_addr;
wire [7:0] WordEnable, shift1_we, shift2_we;
wire hit1, hit2, write_en_data_1, write_en_data_2, data_write_block, write_hit, write_hit_1, write_hit_2;
wire read_state, nxt_write_stage;

// Abstract info from instruction
assign tag = (fsm_busy) ? memory_address[15:10] : write_tag_array | write_state ? next_addr[15:10] : addr[15:10];
assign index = (fsm_busy) ? memory_address[9:4] : write_tag_array | write_state ? next_addr[9:4] : addr[9:4];
assign offset = (fsm_busy) ? memory_address[3:0] : write_tag_array | write_state  ? next_addr[3:0] : addr[3:0];

dff og_address[15:0](.q(next_addr), .d(addr), .wen(~fsm_busy), .clk(clk), .rst(rst));

assign read_state = (read | write_enable) & ~write_state;
assign nxt_write_stage = write_tag_array ? 1'b0 : read_state;
dff write_state_(.q(write_state), .d(nxt_write_stage), .wen(~fsm_busy | write_tag_array), .clk(clk), .rst(rst));

DataArray DataArray_1(.clk(clk), .rst(rst), .DataIn(CacheDataIn1), .Write(write_en_data_1), .BlockEnable(BlockEnable), .WordEnable(WordEnable), .DataOut(DataOut1));
DataArray DataArray_2(.clk(clk), .rst(rst), .DataIn(CacheDataIn2), .Write(write_en_data_2), .BlockEnable(BlockEnable), .WordEnable(WordEnable), .DataOut(DataOut2));

MetaDataArray MetaDataArray_1(.clk(clk), .rst(rst), .DataIn(MetaDataIn1), .Write(write_tag_array | hit_1), .BlockEnable(BlockEnable), .DataOut(MetaDataOut1));
MetaDataArray MetaDataArray_2(.clk(clk), .rst(rst), .DataIn(MetaDataIn2), .Write(write_tag_array | hit_2), .BlockEnable(BlockEnable), .DataOut(MetaDataOut2));

// Read
// Deciding Block Enable from Index
assign shift1 = index[0] ? {63'b0, 1'b1} << 1 : {63'b0, 1'b1};
assign shift2 = index[1] ? shift1 << 2 : shift1;
assign shift3 = index[2] ? shift2 << 4 : shift2;
assign shift4 = index[3] ? shift3 << 8 : shift3;
assign shift5 = index[4] ? shift4 << 16 : shift4;
assign BlockEnable = index[5] ? shift5 << 32 : shift5;

// Deciding Word Enable from Offset
assign shift1_we = offset[1] ? {7'b0, 1'b1} << 1 : {7'b0, 1'b1};
assign shift2_we = offset[2] ? shift1_we << 2 : shift1_we;
assign WordEnable = offset[3] ? shift2_we << 4 : shift2_we;

assign hit1 = (read_state) ? ~(|(MetaDataOut1[7:2] ^ tag)) & MetaDataOut1[1] : 1'b0; //& ~write_enable;
assign hit2 = (read_state) ? ~(|(MetaDataOut2[7:2] ^ tag)) & MetaDataOut2[1] : 1'b0;// & ~write_enable;

dff hit1_(.q(hit_1), .d(hit1), .wen(read_state), .clk(clk), .rst(rst));
dff hit2_(.q(hit_2), .d(hit2), .wen(read_state), .clk(clk), .rst(rst));


dff meta_data_[7:0](.q(MetaDataOut_1), .d(MetaDataOut1), .wen(read_state), .clk(clk), .rst(rst));
dff meta_data2_[7:0](.q(MetaDataOut_2), .d(MetaDataOut2), .wen(read_state), .clk(clk), .rst(rst));

assign miss = (read_state) ? ~(hit1 | hit2) : 1'b0;

// Write

// Choose which block to write to
assign data_write_block = ~MetaDataOut1[1] ? 1'b0  : ~MetaDataOut2[1] ? 1'b1 : MetaDataOut1[0] ? 1'b0 : 1'b1;
dff block(.q(write_block), .d(data_write_block), .wen(read_state), .clk(clk), .rst(rst));

assign write_hit = read_state ? ((hit1 | hit2) & write_enable) : 1'b0;
dff write_hit_(.q(write_hit_2), .d(write_hit), .wen(read_state), .clk(clk), .rst(rst));

// Only write when enable is high
assign write_en_data_1 = ~write_block & (write_data_array | write_hit_2); 
assign write_en_data_2 = write_block & (write_data_array | write_hit_2);

assign MetaDataIn1 = write_en_data_1 ? {tag,2'b10} : (write_en_data_2 | hit_2) ? {MetaDataOut_1[7:1],1'b1} : hit_1 ? {MetaDataOut_1[7:1],1'b0} : MetaDataOut_1;
assign MetaDataIn2 = write_en_data_2 ? {tag,2'b10} : (write_en_data_1 | hit_1) ? {MetaDataOut_2[7:1],1'b1} : hit_2 ? {MetaDataOut_2[7:1],1'b0} : MetaDataOut_2;

assign CacheDataIn1 = write_en_data_1 ? (write_hit_1) ? data_write : memory_data_out : DataOut1;
assign CacheDataIn2 = write_en_data_2 ? (write_hit_2) ? data_write : memory_data_out : DataOut2;

// Assign outputs, miss only high when reading (and miss) - ignore data word output if writing
 // & ~write_enable;\

assign data_word = hit1 & read_state ? DataOut1 : hit2 & read_state ? DataOut2 : 16'b0; // Is memory_data_out what we want at this point

endmodule