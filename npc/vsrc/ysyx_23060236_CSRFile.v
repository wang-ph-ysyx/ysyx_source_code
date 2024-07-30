module ysyx_23060236_CSRFile #(DATA_WIDTH = 32) (
	input  clock,
	input  reset,
	input  [11:0] imm,
	input  [DATA_WIDTH-1:0] wdata,
	output [DATA_WIDTH-1:0] rdata,
	input  enable,
	input  inst_ecall,
	input  inst_mret,
	input  [31:0] epc,
	output [31:0] jump,
	output        jump_en,
	input  valid
);

	wire [5:0] choose;
	reg [DATA_WIDTH-1:0] mepc   ;
	reg [DATA_WIDTH-1:0] mcause ;
	reg [DATA_WIDTH-1:0] mstatus;
	reg [DATA_WIDTH-1:0] mtvec  ;

	localparam MEPC      = 0;
	localparam MCAUSE    = 1;
	localparam MSTATUS   = 2;
	localparam MTVEC     = 3;
	localparam MVENDORID = 4;
	localparam MARCHID   = 5;

	assign choose[MEPC     ] = (imm == 12'h341);
	assign choose[MCAUSE   ] = (imm == 12'h342);
	assign choose[MSTATUS  ] = (imm == 12'h300);
	assign choose[MTVEC    ] = (imm == 12'h305);
	assign choose[MVENDORID] = (imm == 12'hf11);
	assign choose[MARCHID  ] = (imm == 12'hf12);

	always @(posedge clock) begin
		if (reset) begin
			mstatus <= 32'h1800;
		end
		else if (valid) begin
			if (enable) begin
				if (choose[MEPC   ]) mepc    <= wdata;
				if (choose[MCAUSE ]) mcause  <= wdata;
				if (choose[MSTATUS]) mstatus <= wdata;
				if (choose[MTVEC  ]) mtvec   <= wdata;
			end
			else if (inst_ecall) begin
				mepc   <= epc;
				mcause <= 32'd11;
			end
		end
	end

	assign rdata = choose[MEPC     ] ? mepc    :
                 choose[MCAUSE   ] ? mcause  :
                 choose[MSTATUS  ] ? mstatus :
                 choose[MTVEC    ] ? mtvec   :
                 choose[MVENDORID] ? 32'h79737978 :
                 choose[MARCHID  ] ? 32'h015fdf0c :
								 32'b0;

	assign jump = {32{inst_ecall}} & mtvec | {32{inst_mret}} & mepc;
	assign jump_en = inst_ecall | inst_mret;

endmodule
