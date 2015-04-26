module SRAM_tb(
	//Host side
	clk,
	reset,
	WriteRAM,
	ReadRAM,     //= Play (by Tommy's module)
	//DataWrite,   //data to be written in
	DataRead,      //data to be read out
	//
	SRAM_ADDR,
	SRAM_DQ,
	SRAM_OE,
	SRAM_WE,
	SRAM_CE,
	SRAM_LB,
	SRAM_UB
);

input  clk, reset, WriteRAM, ReadRAM;
output [15:0] DataRead;

output [19:0] SRAM_ADDR;
inout  [15:0] SRAM_DQ;
output SRAM_WE, SRAM_CE, SRAM_OE, SRAM_LB, SRAM_UB;

wire [15:0] Dataread;
wire write, read;
reg enable, next_enable;
reg [20:0] addr, next_addr;
reg [15:0] DataWrite, next_DataWrite, next_DataRead;

SRAM sram(.clk(clk), .reset(reset), .enable(enable), .WriteRAM(write), .ReadRAM(read), .addr(addr), .DataWrite(DataWrite),
		  .DataRead(Dataread), .SRAM_ADDR(SRAM_ADDR), .SRAM_DQ(SRAM_DQ), .SRAM_OE(SRAM_OE), .SRAM_WE(SRAM_WE), .SRAM_CE(SRAM_CE),
		  .SRAM_LB(SRAM_LB), .SRAM_UB(SRAM_UB));

assign DataRead = (read)? Dataread: 16'b0;
assign write = WriteRAM;
assign read  = ReadRAM;


always@(*) begin
	next_DataWrite = DataWrite;
	next_DataRead  = DataRead;
	next_addr	   = addr;
	next_enable    = enable;
	if(WriteRAM = 1'b1 && enable == 1'b1) begin
		if(addr < 20'd100) begin
			next_DataWrite = addr;
			next_addr = addr + 20'b1;
		end
		else begin
			next_enable = 1'b0;
			next_addr = 20'b0;
		end
	end
    else 
    if(ReadRAM = 1'b1 && enable == 1'b1) begin
    	if(addr < 20'd100) begin
    		//next_DataRead = addr;
    		next_addr = addr + 20'b1;
    	end
    	else begin
    		next_enable = 1'b0;
    		next_addr = 20'b0;
    	end
    end
    else 
    if(WriteRAM == 1'b0 && ReadRAM == 1'b0) begin
    	next_addr = 20'b0;
    	next_enable = 1'b1;
    end
   	else begin
   		next_DataWrite = DataWrite;
		next_DataRead  = DataRead;
		next_addr	   = addr;
		next_enalbe    = enable;
	end
end


always@(posedge clk or posedge reset) begin
	if(reset) begin
		enalbe = 1'b1;
		addr = 20'b0;
		DataWrite = 16'b0;
		DataRead  = 16'b0;
	end
	else begin
		enable = next_enable;
		addr = next_addr;
		DataWrite = next_DataWrite;
		DataRead  = next_DataRead;
	end
end

