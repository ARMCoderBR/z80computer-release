module top(

  inout [7:0] data,
  input ncs,
  input nwr,
  input nrd,
  input nrst,
  input [3:0] addr,
  input cpuclk,
  output intr_out,
  ////
  output [5:0] led,
  ////
  inout ps2data,
  inout ps2clk,
  ////
  output dacser,
  output dacsclk,
  output dacrclk,
  ////
  input rxd_serial,
  output txd_serial,
  output rts_serial,
  ////
  output disk_mosi,
  output disk_sck,
  output disk_cs,
  input disk_miso,
  output disk_reset,

  /////////////////////////////////////////////
  input clk,
  input resetn,
  output       tmds_clk_n,
  output       tmds_clk_p,
  output [2:0] tmds_d_n,
  output [2:0] tmds_d_p
);

// addr mapping
// 0000: Video RAM Data (R/W)
// 0001: Video ADDR Low (W)
// 0010: Video ADDR High (W)
// 0011: Video control (W)
// 0100: Timer Status & Control(R/W)
// 0101: PS/2 RX Data (R)
// 0110: Sound REG Index (W)
// 0111: Sound REG Data (W)
// 1000: Serial Status & Control (R/W)
// 1001: Serial Data RX/TX (R/W)
// 1010: SPI Status & Control(R/W)
// 1011: SPI Data RX/TX (R/W)
// 1100
// 1101
// 1110
// 1111: FPGA Interrupt Status Reg (R)

    wire [7:0] status_reg;

    wire ps2_intr_out;
    wire timer_intr_out;
    wire serial_intr_out;

    assign status_reg[7:3] = 5'b0;
    assign status_reg[2] = serial_intr_out;
    assign status_reg[1] = timer_intr_out;
    assign status_reg[0] = ps2_intr_out;

    //assign intr_out = ps2_intr_out|timer_intr_out|serial_intr_out;    // Kraft80 V1
    assign intr_out = ~(ps2_intr_out|timer_intr_out|serial_intr_out);   // Kraft80 V2

    wire cpuread;
    reg got_rd;
    wire ncs2;
    assign ncs2 = ncs | (addr != 15);
    assign cpuread  = ncs2 | nrd;

    assign data = cpuread ? 8'bz : status_reg;

    always @(posedge cpuclk) begin

        if (!nrst) begin
            got_rd = 0;
        end
        else begin

            if (!cpuread) begin
                got_rd <= 1;
            end
            else begin
                if (got_rd) begin
                    got_rd <= 0;
                end
            end
        end
    end

SPI_module spi_1(
    .data(data),
    .ncs(ncs),
    .nwr(nwr),
    .nrd(nrd),
	.nrst(nrst),
    .addr(addr),
    .cpuclk(cpuclk),
    .disk_mosi(disk_mosi),
    .disk_sck(disk_sck),
    .disk_cs(disk_cs),
    .disk_miso(disk_miso),
    .disk_reset(disk_reset)
);

SERIAL_module serial_1(
    .data(data),
    .ncs(ncs),
    .nwr(nwr),
    .nrd(nrd),
	.nrst(nrst),
    .addr(addr),
    .cpuclk(cpuclk),
    .txd_serial(txd_serial),
    .rxd_serial(rxd_serial),
    .rts_serial(rts_serial),
    .intr_out(serial_intr_out)
);

TIMER_module timer_1 (
    .data(data),
    .ncs(ncs),
    .nwr(nwr),
    .nrd(nrd),
	.nrst(nrst),
    .addr(addr),
    .cpuclk(cpuclk),
    .intr_out(timer_intr_out)
);

SOUND_module test1 (.dacser(dacser),
                    .dacsclk(dacsclk),
                    .dacrclk(dacrclk),
                    .cpuclk(cpuclk),
                    .nrst(nrst),
                    .data(data),
                    .ncs(ncs),
                    .nwr(nwr),
                    .nrd(nrd),
                    .addr(addr));

PS2_module ps2_1 (
    .data(data),
    .ncs(ncs),
    .nwr(nwr),
    .nrd(nrd),
	.nrst(nrst),
    .addr(addr),
    .cpuclk(cpuclk),
    .ps2data(ps2data),
    .ps2clk(ps2clk),
    .intr_out(ps2_intr_out)
);

Gowin_rPLL u_pll (
  .clkin(clk),
  .clkout(clk_p5),
  .lock(pll_lock)
);

Gowin_CLKDIV u_div_5 (
    .clkout(clk_p),
    .hclkin(clk_p5),
    .resetn(pll_lock)
);

Reset_Sync u_Reset_Sync (
  .resetn(sys_resetn),
  .ext_reset(resetn & pll_lock),
  .clk(clk_p)
);
 
svo_hdmi svo_hdmi_inst (

  .data(data),
  .ncs(ncs),
  .nwr(nwr),
  .nrd(nrd),
  .nrst(nrst),
  .addr(addr),
  .led(led),
  .cpuclk(cpuclk),

	.clk(clk_p),
	.resetn(sys_resetn),

	// video clocks
	.clk_pixel(clk_p),
	.clk_5x_pixel(clk_p5),
	.locked(pll_lock),

	// output signals
	.tmds_clk_n(tmds_clk_n),
	.tmds_clk_p(tmds_clk_p),
	.tmds_d_n(tmds_d_n),
	.tmds_d_p(tmds_d_p)
);

endmodule

module Reset_Sync (
 input clk,
 input ext_reset,
 output resetn
);

    reg [3:0] reset_cnt = 0;
 
    always @(posedge clk or negedge ext_reset) begin

        if (~ext_reset)
            reset_cnt <= 4'b0;
        else
            reset_cnt <= reset_cnt + !resetn;
        end

    assign resetn = &reset_cnt;

endmodule
