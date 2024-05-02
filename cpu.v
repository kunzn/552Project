module cpu(clk, rst_n, hlt, pc);

input clk, rst_n; // System clock & Active low reset. A low on this resets the processor and causes execution to start at address 0x0000
output hlt; 
output [15:0] pc; // PC value over the course of program execution

// when processor encounters the HLT instruction, 
//it will assert this signal once it is finished processing the instruction prior to the HLT
 
wire [15:0] br_pc; //keep track of PC, PC+4

wire MemWrite2, MemRead2, RegWrite2; // control signals
wire [15:0] ALUSrcMux, MemtoRegMux, PCSrcMux, nxt_pc, next_instr;
wire [2:0] F;
wire Ovfl;
wire [3:0] D_Opcode, D_Destination, D_Operand1, D_Operand2, SrcReg1, SrcReg2, X_Operand1, X_Operand2_Mux, X_Operand2_Fw, X_Destination, X_Opcode, M_Destination, W_Destination;
wire [3:0] D_Haz_opcode, D_Haz_Destination, D_Haz_Operand1, D_Haz_Operand2, X_Haz_Destination;
wire [15:0] D_Operand1_Out, D_Operand2_Out, X_Operand1_Out, X_Operand2_Out, M_WriteData, X_ALU_In1, X_ALU_In2; // used to pull instruction
wire [15:0] D_Haz_Operand1_Out, D_Haz_Operand2_Out, D_Haz_Nxt_Pc;
wire [15:0] M_MemData, M_Data_In, W_MemData, X_ALUout, instruction, M_ALUout, W_ALUout; // stores intruction from mem

//control signals
wire D_RegWrite, D_ALUSrc, PCSrc, D_MemWrite, D_MemtoReg, D_MemRead, br, D_Pcs, D_hlt, D_load_byte, D_sw;
wire D_Haz_RegWrite, D_Haz_ALUSrc, D_Haz_MemWrite, D_Haz_MemtoReg, D_Haz_MemRead, D_Haz_Pcs, D_Haz_hlt, D_Haz_load_byte, D_Haz_sw;
wire X_RegWrite, X_ALUSrc, X_MemWrite, X_MemtoReg, X_MemRead, X_Pcs, X_hlt, X_load_byte, X_sw;
wire M_RegWrite, M_ALUSrc, M_MemWrite, M_MemtoReg, M_MemRead, M_Pcs, M_hlt, M_load_byte, M_sw;
wire W_RegWrite, W_ALUSrc, W_MemWrite, W_MemtoReg, W_MemRead, W_Pcs, W_hlt, W_load_byte, W_sw;

wire X_Stall_RegWrite, X_Stall_MemWrite, X_Stall_MemtoReg, X_Stall_MemRead, X_Stall_Pcs, X_Stall_hlt, X_Stall_load_byte, X_Stall_sw;
wire [3:0] X_Stall_Destination;
wire [15:0] X_Stall_ALUout, X_Stall_WriteData, X_Stall_Nxt_Pc;

wire W_RegWrite2, M_MemRead2, M_MemWrite2;
//IF/ID
wire [15:0] ID_Instruction, D_Nxt_Pc, X_Nxt_Pc, M_Nxt_Pc, W_Nxt_Pc;

wire [15:0] D_memory_address, D_cache_data_out, D_data_in, D_memory_data_out;
wire D_miss, D_fsm_busy, D_write_tag_array, D_memory_data_valid, D_memory_wr, D_memory_enable, D_write_enable, write_tag_array;
wire [15:0] Mem_In, Mem_Addr;
wire Mem_En, Mem_Wr, memory_data_valid;

// Hazard Detection & Forwarding
wire X_X_forward_op1, X_X_forward_op2, M_X_forward_op1, M_X_forward_op2, M_M_forward, Ld_Stall;
wire cond_met;

// Ex-to-Ex forwarding
assign X_X_forward_op1 = (M_RegWrite ? (M_Destination ? (M_Destination == X_Operand1 | (X_load_byte & (M_Destination == X_Destination))? 1'b1 : 1'b0) : 1'b0) : 1'b0);
assign X_X_forward_op2 = (M_RegWrite ? (M_Destination ? ((M_Destination == X_Operand2_Fw & ~X_ALUSrc)? 1'b1 : 1'b0) : 1'b0) : 1'b0);

// Mem-Ex Forwarding
assign M_X_forward_op1 = (W_RegWrite ? (W_Destination ? (~X_X_forward_op1 ? (W_Destination == X_Operand1 ? 1'b1 : 1'b0) : 1'b0) : 1'b0) : 1'b0);
assign M_X_forward_op2 = (W_RegWrite ? (W_Destination ? (~X_X_forward_op2 ? ((W_Destination == X_Operand2_Fw & ~X_ALUSrc) ? 1'b1 : 1'b0) : 1'b0) : 1'b0) : 1'b0);

// Mem-Mem Forwarding
assign M_M_forward = (W_RegWrite ? (W_Destination ? (~M_load_byte ? (W_Destination == M_Destination ? 1'b1 : 1'b0) : 1'b0) : 1'b0) : 1'b0);

// Load to Use Stall
assign Ld_Stall = (X_MemRead & ~X_MemWrite ? (X_Destination ? ((X_Destination == SrcReg1) | ((X_Destination == SrcReg2) & ~D_MemWrite & ~D_ALUSrc) ? 1'b1 : 1'b0) : 1'b0) : 1'b0);


//IF Stage  --- Initialize iCache, cache controller, iMem
wire [15:0] I_memory_address, memory_data_out, I_cache_data_out, I_data_in, I_memory_data_out;
wire I_miss, I_fsm_busy, I_write_tag_array, I_memory_data_valid, I_memory_wr, I_memory_enable, write_state, write_state2;

// MODIFICATIONS: cache fsm, icachem Memory enable depends on cache misses. PC stays the same when fsm busy. Instruction depends on what we read from cache or memory if cache miss else 0 for nop after cache miss. ;
assign I_data_in = 16'b0;
assign I_memory_wr = 1'b0;
assign I_memory_enable = (I_miss & ~I_fsm_busy) | (I_memory_data_valid & ~I_write_tag_array);
//memory4c iMemory(.data_out(memory_data_out), .data_in(I_data_in), .addr(I_memory_address), .enable(I_memory_enable), .wr(1'b0), .clk(clk), .rst(~rst_n), .data_valid(memory_data_valid));

// Main memory initialization 
// Trigger a Write and you get a hit: Write Enable for both mem and Cache
// Trigger a Write and get a miss, trigger miss protocol

// Arbitration : if both caches trigger a miss either write or read only one can go through
// fsm1_busy  & miss2 ? stick fsm busy //store dache inputs// ? fsm_busy2 & miss1 : stick fsm2 busy and store icache inputs// otherwise miss1 && miss2 pick one;
// memory_data_out, memory_data_valid

//memory4c iMemory(.data_out(memory_data_out), .data_in(M_Data_In), .addr(D_memory_address), .enable(D_memory_enable), .wr(D_write_enable), .clk(clk), .rst(~rst_n), .data_valid(memory_data_valid));
memory4c iMemory(.data_out(memory_data_out), .data_in(Mem_In), .addr(Mem_Addr), .enable(Mem_En), .wr(Mem_Wr), .clk(clk), .rst(~rst_n), .data_valid(memory_data_valid));

// Prioritize ICache misses?
assign Mem_In = D_fsm_busy | D_write_enable ? D_data_in : (I_miss | I_fsm_busy) ? I_data_in :  16'b0;
assign Mem_Addr = D_fsm_busy | D_write_enable ? D_memory_address : (I_miss | I_fsm_busy) ? I_memory_address : 16'b0;
assign Mem_En = D_fsm_busy | D_write_enable ? M_MemRead : (I_miss | I_fsm_busy) ? I_memory_enable : 1'b0;
assign Mem_Wr = D_fsm_busy | D_write_enable ? D_write_enable : (I_miss | I_fsm_busy) ? I_memory_wr : 1'b0;

assign I_memory_data_out = (I_fsm_busy) ? memory_data_out : 16'b0;
assign D_memory_data_out = (D_fsm_busy) ? memory_data_out : 16'b0;

assign I_memory_data_valid = (I_fsm_busy) ? memory_data_valid : 1'b0;
assign D_memory_data_valid = (D_fsm_busy) ? memory_data_valid : 1'b0;

// I Cache
cache_fill_FSM icache_fsm(.clk(clk), .rst_n(rst_n), .miss_detected(I_miss & ~I_fsm_busy), .miss_address(pc), .memory_address(I_memory_address), .fsm_busy(I_fsm_busy), .write_data_array(I_write_data_array), .write_tag_array(I_write_tag_array), .memory_data_valid(I_memory_data_valid));
cache icache(
	.clk(clk), 
	.rst(~rst_n), 
	.memory_address(I_memory_address), 
	.memory_data_out(I_memory_data_out), 
	.addr(pc), 
	.read(1'b1),
	.write_data_array(I_write_data_array), 
	.write_tag_array(I_write_tag_array), 
	.write_enable(1'b0), 
	.data_write(I_memory_data_out), 
	.fsm_busy(I_fsm_busy), 
	.data_word(I_cache_data_out), 
	.miss(I_miss),
	.write_state(write_state));

Add_Sub_16bit adder(.A(pc), .B(16'h0002), .sub(1'b0), .Sum(nxt_pc), .Ovfl(Ovfl));

//IF/ID registers {instruction, pc + 4}
assign next_instr = (cond_met & PCSrc) ? 16'b0 : Ld_Stall | D_fsm_busy ? ID_Instruction : I_cache_data_out;
dff IF_ID_Instruction[15:0](.q(ID_Instruction), .d(next_instr), .wen(1'b1), .clk(clk), .rst(~rst_n));
dff IF_ID_PC_ADD[15:0](.q(D_Nxt_Pc), .d(nxt_pc), .wen(1'b1), .clk(clk), .rst(~rst_n));


//ID Stage
RegisterFile registerFile(.clk(clk), .rst(~rst_n), .SrcReg1(SrcReg1), .SrcReg2(SrcReg2), .DstReg(W_Destination), .WriteReg(W_RegWrite2), .DstData(MemtoRegMux), .SrcData1(D_Operand1_Out), .SrcData2(D_Operand2_Out));
control_signals control(
  .instruction(ID_Instruction), 
  .RegWrite_Out(D_RegWrite), 
  .ALUSrc_Out(D_ALUSrc),
  .PCSrc_Out(PCSrc),
  .MemWrite_Out(D_MemWrite),
  .MemtoReg_Out(D_MemtoReg),
  .MemRead_Out(D_MemRead),
  .br_Out(br),
  .pcs_Out(D_Pcs),
  .hlt_Out(D_hlt),
  .load_byte_Out(D_load_byte),
  .sw_Out(D_sw)
);
PC_control pc_control(.C(D_Destination[3:1]), .I(ID_Instruction[8:0]), .F(F), .PC_in(D_Nxt_Pc), .PC_out(br_pc), .Br(br), .rs_addr(D_Operand1_Out), .cond_met(cond_met)); //manages branching

assign D_Opcode = ID_Instruction[15:12];
assign D_Destination = ID_Instruction[11:8];
assign D_Operand1 = ID_Instruction[7:4];
assign D_Operand2 = ID_Instruction[3:0]; 

assign SrcReg1 = D_load_byte ? D_Destination : D_Operand1; 
assign SrcReg2 = D_sw ? D_Destination : D_Operand2;

assign D_Haz_RegWrite = Ld_Stall ? 1'b0 : D_fsm_busy ? X_RegWrite : D_RegWrite;
assign D_Haz_ALUSrc = Ld_Stall ? 1'b0 : D_fsm_busy ? X_ALUSrc : D_ALUSrc;
assign D_Haz_MemWrite = Ld_Stall ? 1'b0 : D_fsm_busy ? X_MemWrite : D_MemWrite;
assign D_Haz_MemtoReg = Ld_Stall ? 1'b0 : D_fsm_busy ? X_MemtoReg : D_MemtoReg;
assign D_Haz_MemRead = Ld_Stall ? 1'b0 : D_fsm_busy ? X_MemRead : D_MemRead;
assign D_Haz_Pcs = Ld_Stall ? 1'b0 : D_fsm_busy ? X_Pcs : D_Pcs;
assign D_Haz_hlt = Ld_Stall ? 1'b0 : D_fsm_busy ? X_hlt : D_hlt;
assign D_Haz_load_byte = Ld_Stall ? 1'b0 : D_fsm_busy ? X_load_byte : D_load_byte;
assign D_Haz_sw = Ld_Stall ? 1'b0 : D_fsm_busy ? X_sw : D_sw;

assign D_Haz_opcode = Ld_Stall ? 4'b0 : D_fsm_busy ? X_Opcode : D_Opcode;
assign D_Haz_Destination = Ld_Stall ? 4'b0 : D_fsm_busy ? X_Destination :  D_Destination;
assign D_Haz_Operand1 = Ld_Stall ? 4'b0 : D_fsm_busy ? X_Operand1 : D_Operand1;
assign D_Haz_Operand2 = Ld_Stall ? 4'b0 : D_fsm_busy ? X_Operand2_Mux : D_Operand2;

assign D_Haz_Operand1_Out = Ld_Stall ? 16'b0 : D_fsm_busy ? X_Operand1_Out : D_Operand1_Out;
assign D_Haz_Operand2_Out = Ld_Stall ? 16'b0 : D_fsm_busy ? X_Operand2_Out : D_Operand2_Out;

assign D_Haz_Nxt_Pc = Ld_Stall ? 16'b0 : D_fsm_busy ? X_Nxt_Pc : D_Nxt_Pc;


//ID/EX Registers
ID_EXRegister ID_EX(
  .clk(clk),
  .rst_n(rst_n),
  .D_Operand1(D_Haz_Operand1),
  .D_Operand2_Mux(D_Haz_Operand2),
  .D_Operand2_Fw(D_Haz_Operand2),
  .D_Destination(D_Haz_Destination),
  .D_Opcode(D_Haz_opcode),
  .D_Operand1_Out(D_Haz_Operand1_Out),
  .D_Operand2_Out(D_Haz_Operand2_Out),
  .D_Nxt_Pc(D_Haz_Nxt_Pc),
  .D_hlt(D_Haz_hlt),
  .D_ALUSrc(D_Haz_ALUSrc),
  .D_MemtoReg(D_Haz_MemtoReg),
  .D_MemRead(D_Haz_MemRead),
  .D_MemWrite(D_Haz_MemWrite),
  .D_RegWrite(D_Haz_RegWrite),
  .D_Pcs(D_Haz_Pcs),
  .D_load_byte(D_Haz_load_byte),
  .D_sw(D_Haz_sw),
  .X_Operand1(X_Operand1),
  .X_Operand2_Mux(X_Operand2_Mux),
  .X_Operand2_Fw(X_Operand2_Fw),
  .X_Destination(X_Destination),
  .X_Opcode(X_Opcode),
  .X_Operand1_Out(X_Operand1_Out),
  .X_Operand2_Out(X_Operand2_Out),
  .X_Nxt_Pc(X_Nxt_Pc),
  .X_hlt(X_hlt),
  .X_ALUSrc(X_ALUSrc),
  .X_MemtoReg(X_MemtoReg),
  .X_MemRead(X_MemRead),
  .X_MemWrite(X_MemWrite),
  .X_RegWrite(X_RegWrite),
  .X_Pcs(X_Pcs),
  .X_load_byte(X_load_byte),
  .X_sw(X_sw)
);

assign PCSrcMux = I_fsm_busy | D_fsm_busy ? pc : (cond_met & PCSrc) ? br_pc : &I_cache_data_out[15:12] ? pc : Ld_Stall ? pc : nxt_pc;

//EX Stage
ALU alu(.ALU_In1(X_ALU_In1), .ALU_In2(ALUSrcMux), .Opcode(X_Opcode), .ALU_Out(X_ALUout), .F(F), .rst(~rst_n), .clk(clk));

assign ALUSrcMux = X_load_byte ? {X_Operand1,X_Operand2_Mux} : X_ALUSrc ? {{12{X_Operand2_Mux[3]}},X_Operand2_Mux} : X_ALU_In2;
assign X_ALU_In1 = X_X_forward_op1 ? M_ALUout : M_X_forward_op1 ? MemtoRegMux : X_Operand1_Out;
assign X_ALU_In2 = X_X_forward_op2 ? M_ALUout : M_X_forward_op2 ? MemtoRegMux : X_Operand2_Out;


assign X_Stall_RegWrite = D_fsm_busy ? M_RegWrite : X_MemWrite;
assign X_Stall_MemWrite = D_fsm_busy ? X_MemWrite : X_MemWrite;
assign X_Stall_MemtoReg = D_fsm_busy ? M_MemtoReg : X_MemtoReg;
assign X_Stall_MemRead = D_fsm_busy ? M_MemRead : X_MemRead;
assign X_Stall_Pcs = D_fsm_busy ? M_Pcs : X_Pcs;
assign X_Stall_hlt = D_fsm_busy ? M_hlt : X_hlt;
assign X_Stall_load_byte = D_fsm_busy ? M_load_byte : X_load_byte;
assign X_Stall_sw = D_fsm_busy ? M_sw : X_sw;

assign X_Stall_Destination = D_fsm_busy ? M_Destination : X_Destination;

assign X_Stall_ALUout = D_fsm_busy ? M_ALUout : X_ALUout;
assign X_Stall_WriteData = D_fsm_busy ? M_WriteData : X_ALU_In2;

assign X_Stall_Nxt_Pc = D_fsm_busy ? M_Nxt_Pc : X_Nxt_Pc;

EX_MEMRegister EX_MEM( 
  .clk(clk),
  .rst_n(rst_n),
  .X_Destination(X_Destination),
  .X_ALUout(X_ALUout),
  .X_WriteData(X_ALU_In2),
  .X_Nxt_Pc(X_Nxt_Pc),
  .X_hlt(X_hlt),
  .X_MemtoReg(X_MemtoReg),
  .X_MemRead(X_MemRead),
  .X_MemWrite(X_MemWrite),
  .X_RegWrite(X_MemWrite),
  .X_Pcs(X_Pcs),
  .X_load_byte(X_load_byte),
  .X_sw(X_sw),
  .M_Destination(M_Destination),
  .M_ALUout(M_ALUout),
  .M_WriteData(M_WriteData),
  .M_Nxt_Pc(M_Nxt_Pc),
  .M_hlt(M_hlt),
  .M_MemtoReg(M_MemtoReg),
  .M_MemRead(M_MemRead),
  .M_MemWrite(M_MemWrite),
  .M_RegWrite(M_RegWrite),
  .M_Pcs(M_Pcs),
  .M_load_byte(M_load_byte),
  .M_sw(M_sw)
);

// MEM Stage
// pipelined cache write - pass directly into the cache. Hit? change in cache and mem ; else you want to take the dff cache write; 
dff write_enable(.q(flopped_write_enable), .d(M_MemWrite2), .wen(~D_fsm_busy), .clk(clk), .rst(~rst_n));


assign D_write_enable = D_fsm_busy ? 1'b0 : write_tag_array ? flopped_write_enable : M_MemWrite2;
assign M_Data_In = M_M_forward ? W_MemData : M_WriteData;
// Go high when M_MemWrite2 & miss, go back low once D_write_tag_array
// const assign write enable choosing flopped enable or the current value of M_MemWrite2 based on miss status
// D Cache
cache_fill_FSM dcache_fsm(.clk(clk), .rst_n(rst_n), .miss_detected(D_miss & ~D_fsm_busy & (M_MemRead | M_MemWrite2)), .miss_address(M_ALUout), .memory_address(D_memory_address), .fsm_busy(D_fsm_busy), .write_data_array(D_write_data_array), .write_tag_array(D_write_tag_array), .memory_data_valid(I_memory_data_valid));
cache dcache(
	.clk(clk), 
	.rst(~rst_n), 
	.memory_address(D_memory_address), 
	.memory_data_out(D_memory_data_out), 
	.addr(M_ALUout), 
	.read(M_MemRead), 
	.write_data_array(D_write_data_array), 
	.write_tag_array(D_write_tag_array), 
	.write_enable(D_write_enable), 
	.data_write(M_Data_In), 
	.fsm_busy(D_fsm_busy), 
	.data_word(M_MemData), 
	.miss(D_miss),
	.write_state(write_state2));

//assign M_MemData = (M_MemRead) ? D_cache_data_out : 16'b0;
//memory4c iMemory(.data_out(memory_data_out), .data_in(M_Data_In), .addr(D_memory_address), .enable(D_memory_enable), .wr(D_write_enable), .clk(clk), .rst(~rst_n), .data_valid(memory_data_valid));


// M_MemWrite2 needs to stall 
//I_cache dcache(.clk(clk), .rst(~rst_n), .instruction(M_ALUout), .write_enable(M_MemWrite2),.data_write(memory_data_out),.miss(miss_detected),.data_word(cache_data_out));
//memory4c dMemory(.data_out(M_MemData), .data_in(M_Data_In), .addr(), .enable(miss_detected), .wr(~miss_detected & M_MemWrite2), .clk(clk), .rst(~rst_n));

// MODIFICATIONS: cache fsm, icachem Memory enable depends on cache misses. PC stays the same when fsm busy. Instruction depends on what we read from cache or memory if cache miss else 0 for nop after cache miss. 

MEM_WBRegister MEM_WB(
  .clk(clk),
  .rst_n(rst_n),
  .M_Destination(M_Destination),
  .M_MemData(M_MemData),
  .M_ALUout(M_ALUout),
  .M_Nxt_Pc(M_Nxt_Pc),
  .M_hlt(M_hlt),
  .M_MemtoReg(M_MemtoReg),
  .M_RegWrite(M_RegWrite),
  .M_Pcs(M_Pcs),
  .W_Destination(W_Destination),
  .W_MemData(W_MemData),
  .W_ALUout(W_ALUout),
  .W_Nxt_Pc(W_Nxt_Pc),
  .W_hlt(W_hlt),
  .W_MemtoReg(W_MemtoReg),
  .W_RegWrite(W_RegWrite),
  .W_Pcs(W_Pcs)
);

assign MemtoRegMux = W_Pcs ? W_Nxt_Pc : W_MemtoReg ? W_ALUout : W_MemData;
assign hlt = W_hlt;

assign W_RegWrite2 = ~rst_n ? 1'b0 : W_RegWrite;
assign M_MemRead2 = ~rst_n ? 1'b0 : M_MemRead;
assign M_MemWrite2 = ~rst_n ? 1'b0 : M_MemWrite;

dff cur_pc[15:0](.q(pc), .d(PCSrcMux), .wen(1'b1), .clk(clk), .rst(~rst_n));

endmodule

