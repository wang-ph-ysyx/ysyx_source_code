import "DPI-C" function int pmem_read(input int raddr);
import "DPI-C" function void pmem_write(
	  input int waddr, input int wdata, input byte wmask);
module npc(
	input  clock,
	input  reset,

  output [15:0] externalPins_gpio_out,	
  input  [15:0] externalPins_gpio_in,	
  output [7:0]  externalPins_gpio_seg_0,	
                externalPins_gpio_seg_1,	
                externalPins_gpio_seg_2,	
                externalPins_gpio_seg_3,	
                externalPins_gpio_seg_4,	
                externalPins_gpio_seg_5,	
                externalPins_gpio_seg_6,	
                externalPins_gpio_seg_7,	
  input         externalPins_ps2_clk,	
                externalPins_ps2_data,	
  output [7:0]  externalPins_vga_r,	
                externalPins_vga_g,	
                externalPins_vga_b,	
  output        externalPins_vga_hsync,	
                externalPins_vga_vsync,	
                externalPins_vga_valid,	
  input         externalPins_uart_rx,	
  output        externalPins_uart_tx	
);

reg         io_master_awready;
wire        io_master_awvalid;
wire [31:0] io_master_awaddr;
wire [3:0]  io_master_awid;
wire [7:0]  io_master_awlen;
wire [2:0]  io_master_awsize;
wire [1:0]  io_master_awburst;

reg         io_master_wready;
wire        io_master_wvalid;
wire [31:0] io_master_wdata;
wire [3:0]  io_master_wstrb;
wire        io_master_wlast;

wire        io_master_bready;
reg         io_master_bvalid;
wire [1:0]  io_master_bresp;
wire [3:0]  io_master_bid;

reg         io_master_arready;
wire        io_master_arvalid;
wire [31:0] io_master_araddr;
wire [3:0]  io_master_arid;
wire [7:0]  io_master_arlen;
wire [2:0]  io_master_arsize;
wire [1:0]  io_master_arburst;

wire        io_master_rready;
reg         io_master_rvalid;
wire [1:0]  io_master_rresp;
reg  [31:0] io_master_rdata;
wire        io_master_rlast;
wire [3:0]  io_master_rid;

wire [31:0] kbd_rdata;

// addr range
localparam MEM_BASE    = 32'h80000000;
localparam MEM_END     = 32'h88000000;
localparam VGA_BASE    = 32'ha1000000;
localparam VGA_END     = 32'ha1200000;
localparam KBD_ADDR    = 32'ha0000060;
localparam SERIAL_PORT = 32'ha00003f8;
localparam RTC_LOW     = 32'ha0000048;
localparam RTC_HIGH    = 32'ha000004c;

wire waddr_in_mem    = (write_addr >= MEM_BASE) & (write_addr < MEM_END);
wire waddr_in_vga    = (write_addr >= VGA_BASE) & (write_addr < VGA_END);
wire waddr_in_serial = (write_addr == SERIAL_PORT);
wire raddr_in_mem     = (io_master_araddr >= MEM_BASE) & (io_master_araddr < MEM_END);
wire raddr_in_mem_reg = (read_addr >= MEM_BASE) & (read_addr < MEM_END);
wire raddr_in_kbd     = (io_master_araddr == KBD_ADDR);
wire raddr_in_time    = (io_master_araddr == RTC_LOW) | (io_master_araddr == RTC_HIGH);


// write
reg  [31:0] write_addr;

assign io_master_bid = 0;
assign io_master_bresp = 0;
assign io_master_wlast = 1;

always @(posedge clock) begin
// io_master_awready
	if (reset) io_master_awready <= 1;
	else if (io_master_awready & io_master_awvalid) 
		io_master_awready <= 0;
	else if (io_master_bvalid & io_master_bready)
		io_master_awready <= 1;

// write_addr
	if (io_master_awready & io_master_awvalid)
		write_addr <= io_master_awaddr;

// io_master_wready
	if (reset) io_master_wready <= 0;
	else if (io_master_wvalid & io_master_wready)
		io_master_wready <= 0;
	else if (io_master_awvalid & io_master_awready)
		io_master_wready <= 1;

// pmem_write & write_wstrb
	if (io_master_wvalid & io_master_wready & (waddr_in_mem | waddr_in_serial)) begin
		pmem_write(write_addr, io_master_wdata, {4'b0, io_master_wstrb});
	end

// io_master_bvalid
	if (reset) io_master_bvalid <= 0;
	else if (io_master_bvalid & io_master_bready)
		io_master_bvalid <= 0;
	else if (io_master_wvalid & io_master_wready)
		io_master_bvalid <= 1;
end


//read
reg  [31:0] read_addr;
reg  [7:0]  read_len;

assign io_master_rid = 0;
assign io_master_rresp = 0;
assign io_master_rlast = (read_len == 0);

always @(posedge clock) begin
// io_master_arready
	if (reset) io_master_arready <= 1;
	else if (io_master_arready & io_master_arvalid)
		io_master_arready <= 0;
	else if (io_master_rready & io_master_rvalid & (read_len == 0))
		io_master_arready <= 1;

// read_addr
	if (io_master_arready & io_master_arvalid)
		read_addr <= io_master_araddr + 4;
	else if (io_master_rready & io_master_rvalid)
		read_addr <= read_addr + 4;

// read_len
	if (io_master_arready & io_master_arvalid)
		if (io_master_arburst == 2'b01)
			read_len <= io_master_arlen;
		else read_len <= 0;
	else if (io_master_rvalid & io_master_rready & (read_len != 0))
		read_len <= read_len - 1;

// io_master_rvalid
	if (reset) io_master_rvalid <= 0;
	else if (io_master_rvalid & io_master_rready)
		if (read_len != 0) io_master_rvalid <= 1;
		else io_master_rvalid <= 0;
	else if (io_master_arvalid & io_master_arready)
		io_master_rvalid <= 1;

// io_master_rdata
	if (io_master_arvalid & io_master_arready) begin
		if (raddr_in_mem | raddr_in_time)
			io_master_rdata <= pmem_read(io_master_araddr);
		else if (raddr_in_kbd)
			io_master_rdata <= kbd_rdata;
	end
	else if (io_master_rvalid & io_master_rready & raddr_in_mem_reg & (read_len != 0))
		io_master_rdata <= pmem_read(read_addr);
end

	vga my_vga(
		.clock(clock),
		.reset(reset),
		.waddr(write_addr),
		.wdata(io_master_wdata),
		.wvalid(io_master_wvalid & io_master_wready & waddr_in_vga),
		.vga_r(externalPins_vga_r),
		.vga_g(externalPins_vga_g),
		.vga_b(externalPins_vga_b),
		.vga_hsync(externalPins_vga_hsync),
		.vga_vsync(externalPins_vga_vsync),
		.vga_valid(externalPins_vga_valid)
	);

	ps2 my_ps2(
		.clock(clock),
		.reset(reset),
		.rvalid(io_master_arvalid & io_master_arready & raddr_in_kbd),
		.raddr(io_master_araddr),
		.rdata(kbd_rdata),
		.ps2_clk(externalPins_ps2_clk),
		.ps2_data(externalPins_ps2_data)
	);

  ysyx_23060236 cpu (	
    .clock             (clock),
    .reset             (reset),
    .io_interrupt      (1'h0),
    .io_master_awready (io_master_awready),
    .io_master_awvalid (io_master_awvalid),
    .io_master_awid    (io_master_awid),
    .io_master_awaddr  (io_master_awaddr),
    .io_master_awlen   (io_master_awlen),
    .io_master_awsize  (io_master_awsize),
    .io_master_awburst (io_master_awburst),
    .io_master_wready  (io_master_wready),
    .io_master_wvalid  (io_master_wvalid),
    .io_master_wdata   (io_master_wdata),
    .io_master_wstrb   (io_master_wstrb),
    .io_master_wlast   (io_master_wlast),
    .io_master_bready  (io_master_bready),
    .io_master_bvalid  (io_master_bvalid),
    .io_master_bid     (io_master_bid),
    .io_master_bresp   (io_master_bresp),
    .io_master_arready (io_master_arready),
    .io_master_arvalid (io_master_arvalid),
    .io_master_arid    (io_master_arid),
    .io_master_araddr  (io_master_araddr),
    .io_master_arlen   (io_master_arlen),
    .io_master_arsize  (io_master_arsize),
    .io_master_arburst (io_master_arburst),
    .io_master_rready  (io_master_rready),
    .io_master_rvalid  (io_master_rvalid),
    .io_master_rid     (io_master_rid),
    .io_master_rdata   (io_master_rdata),
    .io_master_rresp   (io_master_rresp),
    .io_master_rlast   (io_master_rlast),
    .io_slave_awready  (/* unused */),
    .io_slave_awvalid  (1'h0),	
    .io_slave_awid     (4'h0),	
    .io_slave_awaddr   (32'h0),	
    .io_slave_awlen    (8'h0),	
    .io_slave_awsize   (3'h0),	
    .io_slave_awburst  (2'h0),	
    .io_slave_wready   (/* unused */),
    .io_slave_wvalid   (1'h0),	
    .io_slave_wdata    (32'h0),	
    .io_slave_wstrb    (4'h0),	
    .io_slave_wlast    (1'h0),	
    .io_slave_bready   (1'h0),	
    .io_slave_bvalid   (/* unused */),
    .io_slave_bid      (/* unused */),
    .io_slave_bresp    (/* unused */),
    .io_slave_arready  (/* unused */),
    .io_slave_arvalid  (1'h0),	
    .io_slave_arid     (4'h0),	
    .io_slave_araddr   (32'h0),	
    .io_slave_arlen    (8'h0),	
    .io_slave_arsize   (3'h0),	
    .io_slave_arburst  (2'h0),	
    .io_slave_rready   (1'h0),	
    .io_slave_rvalid   (/* unused */),
    .io_slave_rid      (/* unused */),
    .io_slave_rdata    (/* unused */),
    .io_slave_rresp    (/* unused */),
    .io_slave_rlast    (/* unused */)
	);

endmodule
