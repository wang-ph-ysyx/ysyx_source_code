module ysyx_23060236_lsu(
	input  clock,
	input  reset,

	output [31:0] lsu_araddr,
	output        lsu_arvalid,
	output [2:0]  lsu_arsize,
	input         lsu_arready,
	input  [31:0] lsu_rdata,
	input  [1:0]  lsu_rresp,
	input         lsu_rvalid,
	output        lsu_rready,

	output [31:0] lsu_awaddr,
	output        lsu_awvalid,
	output [2:0]  lsu_awsize,
	input         lsu_awready,
	output [31:0] lsu_wdata,
	output [3:0]  lsu_wstrb,
	output        lsu_wvalid,
	input         lsu_wready,
	input  [1:0]  lsu_bresp,
	input         lsu_bvalid,
	output        lsu_bready,

	input  [3:0]  rd,
	input  [31:0] exu_val,
	input  [31:0] csr_val,
	input  [2:0]  funct3,
	input  [31:0] lsu_data,
	input  [3:0]  wmask,
	input         lsu_ren,
	input         lsu_wen,
	input  [31:0] pc,
	input  [31:0] csr_wdata,
	input  [11:0] csr_imm,
	input  csr_enable,
	input  jal_enable,
	input  reg_wen,
	input  inst_ecall,

	output reg [31:0] pc_next,
	output reg [31:0] wb_val,
	output reg reg_wen_next,
	output reg [3:0]  rd_next,
	output reg csr_enable_next,
	output reg [11:0] csr_imm_next,
	output reg [31:0] csr_wdata_next,
	output reg inst_ecall_next,

	input  lsu_valid,
	output lsu_ready,
	output wb_valid
);

	wire [31:0] snpc;
	assign snpc = pc + 4;
	reg  [31:0] lsu_addr;
	reg  [31:0] lsu_data_reg;
	reg  [3:0]  wmask_reg;
	reg  [2:0]  funct3_reg;

	always @(posedge clock) begin
		if (lsu_valid & lsu_ready) begin
			reg_wen_next    <= reg_wen;
			rd_next         <= rd;
			csr_enable_next <= csr_enable;
			csr_imm_next    <= csr_imm;
			csr_wdata_next  <= csr_wdata;
			inst_ecall_next <= inst_ecall;
			pc_next         <= pc;
			lsu_addr        <= exu_val;
			lsu_data_reg    <= lsu_data;
			funct3_reg      <= funct3;
			wmask_reg       <= wmask;
			wb_val <= jal_enable ? snpc : 
								csr_enable ? csr_val  :
								exu_val;
		end
		else if (lsu_rvalid & lsu_rready) begin
			wb_val <= lsu_val_tmp;
		end
	end

	ysyx_23060236_Reg #(1, 1) reg_lsu_ready(
		.clock(clock),
		.reset(reset),
		.din(lsu_ready & ~lsu_valid | ~lsu_ready & wb_valid),
		.dout(lsu_ready),
		.wen(1)
	);

	ysyx_23060236_Reg #(1, 0) reg_wb_valid(
		.clock(clock),
		.reset(reset),
		.din(~wb_valid & (lsu_valid & lsu_ready & ~lsu_ren & ~lsu_wen | lsu_rvalid & lsu_rready | lsu_bvalid & lsu_bready)),
		.dout(wb_valid),
		.wen(1)
	);

	wire [31:0] lsu_val_tmp;
	wire [31:0] lsu_val_shift;

	assign lsu_arsize = {1'b0, funct3_reg[1:0]};
	assign lsu_awsize = {1'b0, funct3_reg[1:0]};
	assign lsu_rready = 1;
	assign lsu_bready = 1;
	assign lsu_araddr = lsu_addr;
	assign lsu_awaddr = lsu_addr;
	assign lsu_wstrb  = wmask_reg << lsu_awaddr[1:0];
	assign lsu_wdata  = lsu_data_reg << {lsu_awaddr[1:0], 3'b0};
	assign lsu_val_shift = lsu_rdata >> {lsu_araddr[1:0], 3'b0};

	assign lsu_val_tmp = (funct3_reg == 3'b000) ? (lsu_val_shift & 32'hff) | {{24{lsu_val_shift[7]}}, 8'h0} :     //lb  
                       (funct3_reg == 3'b001) ? (lsu_val_shift & 32'hffff) | {{16{lsu_val_shift[15]}}, 16'h0} : //lh
                       (funct3_reg == 3'b010) ? lsu_val_shift :                                                 //lw
                       (funct3_reg == 3'b100) ? lsu_val_shift & 32'hff :                                        //lbu
                       (funct3_reg == 3'b101) ? lsu_val_shift & 32'hffff :                                      //lhu
											 32'b0;

	ysyx_23060236_Reg #(1, 0) reg_lsu_arvalid(
		.clock(clock),
		.reset(reset),
		.din(lsu_arvalid & ~lsu_arready | ~lsu_arvalid & lsu_ren & lsu_valid & lsu_ready),
		.dout(lsu_arvalid),
		.wen(1)
	);

	ysyx_23060236_Reg #(1, 0) reg_lsu_awvalid(
		.clock(clock),
		.reset(reset),
		.din(lsu_awvalid & ~lsu_awready | ~lsu_awvalid & lsu_wen & lsu_valid & lsu_ready),
		.dout(lsu_awvalid),
		.wen(1)
	);

	ysyx_23060236_Reg #(1, 0) reg_lsu_wvalid(
		.clock(clock),
		.reset(reset),
		.din(lsu_wvalid & ~lsu_wready | ~lsu_wvalid & lsu_wen & lsu_valid & lsu_ready),
		.dout(lsu_wvalid),
		.wen(1)
	);

endmodule
