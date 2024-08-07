module ysyx_23060236_RegisterFile #(ADDR_WIDTH = 4, DATA_WIDTH = 32) (
  input clock,
	input reset,
  input [DATA_WIDTH-1:0] wdata,
  input [ADDR_WIDTH-1:0] waddr,
	output [DATA_WIDTH-1:0] rdata1,
	input [ADDR_WIDTH-1:0] raddr1,
	output [DATA_WIDTH-1:0] rdata2,
	input [ADDR_WIDTH-1:0] raddr2,
  input wen,
	input valid
);

  reg  [DATA_WIDTH-1:0] rf [2**ADDR_WIDTH-1:1];
  wire [DATA_WIDTH-1:0] rf_read [2**ADDR_WIDTH-1:0];
	assign rf_read[0]  = 0;
	assign rf_read[1]  = rf[1];
	assign rf_read[2]  = rf[2];
	assign rf_read[3]  = rf[3];
	assign rf_read[4]  = rf[4];
	assign rf_read[5]  = rf[5];
	assign rf_read[6]  = rf[6];
	assign rf_read[7]  = rf[7];
	assign rf_read[8]  = rf[8];
	assign rf_read[9]  = rf[9];
	assign rf_read[10] = rf[10];
	assign rf_read[11] = rf[11];
	assign rf_read[12] = rf[12];
	assign rf_read[13] = rf[13];
	assign rf_read[14] = rf[14];
	assign rf_read[15] = rf[15];

  always @(posedge clock) begin
		if (valid & wen & (waddr != 0)) begin
			rf[waddr] <= wdata;
		end
  end

	assign rdata1 = rf_read[raddr1];
	assign rdata2 = rf_read[raddr2];

endmodule
