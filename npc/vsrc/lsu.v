module lsu(
	input  clk,
	input  [31:0] raddr,
	input  ren,
	output [31:0] val,
	input  [31:0] waddr,
	input  [31:0] wdata,
	input  wen,
	input  [7:0] wmask,
	output valid,
	input  [6:0] opcode,
	input  [2:0] funct3
);

	reg state_load;
	reg [31:0] rdata;

	always @(posedge clk) begin
		if (ren) begin
			rdata <= pmem_read(raddr);
			state_load <= 1;
		end
		else begin
			state_load <= 0;
			if (wen) begin
				pmem_write(waddr, wdata, wmask);
			end
		end
	end

	assign valid = state_load;

	MuxKeyInternal #(5, 10, 32, 1) calculate_val(
		.out(val),
		.key({funct3, opcode}),
		.default_out(32'b0),
		.lut({
			10'b0000000011, (rdata & 32'hff) | {{24{rdata[7]}}, 8'h0},    //lb
			10'b0010000011, (rdata& 32'hffff) | {{16{rdata[15]}}, 16'h0}, //lh
			10'b0100000011, rdata,                                        //lw
			10'b1000000011, rdata & 32'hff,                               //lbu
			10'b1010000011, rdata & 32'hffff                              //lhu
		})
	);

endmodule
