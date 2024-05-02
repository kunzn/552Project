
module cache_fill_FSM(clk, rst_n, miss_detected, miss_address, fsm_busy, write_data_array, write_tag_array,memory_address, memory_data_valid);
input clk, rst_n;
input miss_detected; // active high when tag match logic detects a miss
input [15:0] miss_address; // address that missed the cache
output fsm_busy; // asserted while FSM is busy handling the miss (can be used as pipeline stall signal)
output write_data_array; // write enable to cache data array to signal when filling with memory_data
output write_tag_array; // write enable to cache tag array to signal when all words are filled in to data array
output [15:0] memory_address; // address to read from memory
input memory_data_valid; // active high indicates valid data returning on memory bus

// Words are 2 bytes so 
// 6 tag, 6 index, 4 bits offset
// 16 different slots to write to
  wire [2:0] curr_word_count, nxt_word_count;
  wire [1:0] curr_mem_latency, nxt_mem_latency;
  wire state;
  //wire read_from_mem, nxt_read_from_mem;

  // Adders to add one to counters
  CLA4 cla4_word_count(.A({1'b0, curr_word_count}), .B(4'b0001), .Cin(1'b0), .Sum(nxt_word_count), .Ovfl(), .Cout());
  //CLA4 cla4_mem_count(.A({2'b0, curr_mem_latency}), .B(4'b0001), .Cin(1'b0), .Sum(nxt_mem_latency), .Ovfl(), .Cout());

  dff dff_word_count[2:0](.q(curr_word_count), .d(nxt_word_count), .wen(memory_data_valid), .clk(clk), .rst(~rst_n));
  //dff dff_mem_count[1:0](.q(curr_mem_latency), .d(nxt_mem_latency), .wen(read_from_mem), .clk(clk), .rst(~rst_n));

  // Records state, switches from 0->1 on miss, and 1->0 when done writing
  dff dff_state(.q(state), .d(~state), .wen(miss_detected | write_tag_array), .clk(clk), .rst(~rst_n));
  // Checks if the memory_data_valid after state transition
  //dff dff_mem_en(.q(read_from_mem), .d(nxt_read_from_mem), .wen(1'b1), .clk(clk), .rst(~rst_n));

 // assign nxt_read_from_mem = (~state) ? 1'b0 : memory_data_valid ? 1'b1 : read_from_mem; 

  assign fsm_busy = state;
  assign write_data_array = memory_data_valid & fsm_busy; // write to cache when mem_latency is fully read
  assign write_tag_array = &(curr_word_count) & memory_data_valid; // all 8 words have been read
  assign memory_address = {miss_address[15:4], curr_word_count, 1'b0};

endmodule