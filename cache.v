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
output miss
);

wire [5:0] tag, index;
wire [3:0] offset;
wire [63:0] BlockEnable, shift1, shift2, shift3, shift4, shift5;
wire [7:0] MetaDataOut1, MetaDataOut2, MetaDataIn1, MetaDataIn2, MetaDataOut_1, MetaDataOut_2;
wire [15:0] DataOut1, DataOut2, CacheDataIn1, CacheDataIn2, next_addr, memory_write_addr;
wire [7:0] WordEnable, shift1_we, shift2_we;
wire hit1, hit2, write_en_data_1, write_en_data_2, data_write_block, write_hit, write_hit_1, write_hit_2;
wire read_state, nxt_write_stage;
wire [2:0] curr_word_count, nxt_word_count;

// Flop Mem Addr 4
CLA4 cla4_word_count(.A({1'b0, curr_word_count}), .B(4'b0001), .Cin(1'b0), .Sum(nxt_word_count), .Ovfl(), .Cout());
//CLA4 cla4_mem_count (.A({1'b0, curr_read_cnt}), .B(4'b0001), .Cin(1'b0), .Sum(nxt_read_cnt), .Ovfl(), .Cout());
dff dff_word_count[2:0](.q(curr_word_count), .d(nxt_word_count), .wen(write_data_array), .clk(clk), .rst(rst));

assign memory_write_addr = {memory_address[15:4], curr_word_count, 1'b0};

// Abstract info from instruction
assign tag = (write_data_array) ? memory_write_addr[15:10] : write_tag_array ? next_addr[15:10] : addr[15:10];
assign index = (write_data_array) ? memory_write_addr[9:4] : write_tag_array ? next_addr[9:4] : addr[9:4];
assign offset = (write_data_array) ? memory_write_addr[3:0] : write_tag_array ? next_addr[3:0] : addr[3:0];

dff og_address[15:0](.q(next_addr), .d(addr), .wen(~fsm_busy), .clk(clk), .rst(rst));

//assign read_state = (read | write_enable) & ~write_state;
//assign nxt_write_stage = write_tag_array ? 1'b0 : read_state;
//dff write_state_(.q(write_state), .d(nxt_write_stage), .wen(~fsm_busy | write_tag_array), .clk(clk), .rst(rst));

DataArray DataArray_1(.clk(clk), .rst(rst), .DataIn(CacheDataIn1), .Write(write_en_data_1), .BlockEnable(BlockEnable), .WordEnable(WordEnable), .DataOut(DataOut1));
DataArray DataArray_2(.clk(clk), .rst(rst), .DataIn(CacheDataIn2), .Write(write_en_data_2), .BlockEnable(BlockEnable), .WordEnable(WordEnable), .DataOut(DataOut2));

MetaDataArray MetaDataArray_1(.clk(clk), .rst(rst), .DataIn(MetaDataIn1), .Write((write_tag_array) | hit1 | hit2), .BlockEnable(BlockEnable), .DataOut(MetaDataOut1));
MetaDataArray MetaDataArray_2(.clk(clk), .rst(rst), .DataIn(MetaDataIn2), .Write((write_tag_array) | hit1 | hit2), .BlockEnable(BlockEnable), .DataOut(MetaDataOut2));

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

assign hit1 = ~(|(MetaDataOut1[7:2] ^ tag)) & MetaDataOut1[1]; //& ~write_enable;
assign hit2 = ~(|(MetaDataOut2[7:2] ^ tag)) & MetaDataOut2[1];// & ~write_enable;

//dff hit1_(.q(hit_1), .d(hit1), .wen(read_state), .clk(clk), .rst(rst));
//dff hit2_(.q(hit_2), .d(hit2), .wen(read_state), .clk(clk), .rst(rst));


//dff meta_data_[7:0](.q(MetaDataOut_1), .d(MetaDataOut1), .wen(read_state), .clk(clk), .rst(rst));
//dff meta_data2_[7:0](.q(MetaDataOut_2), .d(MetaDataOut2), .wen(read_state), .clk(clk), .rst(rst));

assign miss = ~(hit1 | hit2);

// Write

// Choose which block to write to
assign data_write_block = MetaDataOut1[0] ? 1'b0 : 1'b1;
//dff block(.q(write_block), .d(data_write_block), .wen(read_state), .clk(clk), .rst(rst));
  
assign write_hit = (hit1 | hit2) & write_enable;
//dff write_hit_(.q(write_hit_2), .d(write_hit), .wen(read_state), .clk(clk), .rst(rst));

// Only write when enable is high
assign write_en_data_1 = ~data_write_block & (write_data_array | write_hit); 
assign write_en_data_2 = data_write_block & (write_data_array | write_hit);

// write_en_data_1 should only go high when we are writing in the data - should update tag bit, if we are reading in the data due to a miss write -
// IF write hit: LRU
// IF writing from mem and true write: just set tag
// IF writing from mem and not true write: set all tag, valid, LRU
//assign MetaDataIn1 = (write_hit) ? {MetaDataOut1[7:1], 1'b1} : (write_en_data_1 & write_enable) ? {tag, 2'b00} : write_en_data_1 ? {tag,2'b10} : (write_en_data_2 | hit2) ? {MetaDataOut1[7:1],1'b1} : hit1 ? {MetaDataOut1[7:1],1'b0} : MetaDataOut1;
//assign MetaDataIn2 = (write_hit) ? {MetaDataOut2[7:1], 1'b1} : (write_en_data_2 & write_enable) ? {tag, 2'b00} : write_en_data_2 ? {tag,2'b10} : (write_en_data_1 | hit1) ? {MetaDataOut2[7:1],1'b1} : hit2 ? {MetaDataOut2[7:1],1'b0} : MetaDataOut2;
assign MetaDataIn1 = (write_en_data_1 & write_enable) ? {tag, 2'b11} : (write_en_data_1) ? {tag, 2'b10} : (write_en_data_2 | hit2) ? {MetaDataOut1[7:1],1'b1} : hit1 ? {MetaDataOut1[7:1],1'b0} : MetaDataOut1;
assign MetaDataIn2 = (write_en_data_2 & write_enable) ? {tag, 2'b11} : (write_en_data_2) ? {tag, 2'b10} : (write_en_data_1 | hit1) ? {MetaDataOut2[7:1],1'b1} : hit2 ? {MetaDataOut2[7:1],1'b0} : MetaDataOut2;


assign CacheDataIn1 = write_en_data_1 ? (write_hit) ? data_write : memory_data_out : DataOut1;
assign CacheDataIn2 = write_en_data_2 ? (write_hit) ? data_write : memory_data_out : DataOut2;

// Assign outputs, miss only high when reading (and miss) - ignore data word output if writing
 // & ~write_enable;\

assign data_word = hit1 ? DataOut1 : hit2 ? DataOut2 : 16'b0; // Is memory_data_out what we want at this point

endmodule