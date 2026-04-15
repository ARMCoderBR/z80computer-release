module SPI_module(

    // CPU interface
    inout [7:0] data,
    input ncs,
    input nwr,
    input nrd,
    input nrst,
    input [3:0] addr,
    input cpuclk,    // 4MHz

    output disk_mosi,
    output reg disk_sck,
    output reg disk_cs,
    input disk_miso,
    output reg disk_reset);

    wire cpuwrite;
    wire cpuread;
    reg got_wr;
    reg got_rd;

    reg [7:0] data_tx;
    reg [7:0] data_rx;
    reg [4:0] byte_xfer_state;
    reg [7:0] sck_pulses_state;

    assign disk_mosi = data_tx[7];

    wire busy;
    assign busy = (|byte_xfer_state) | (|sck_pulses_state);

    wire ncs2;
    assign ncs2 = ncs | ((addr != 10) && (addr != 11));

    assign cpuwrite = ncs2 | nwr;
    assign cpuread  = ncs2 | nrd;

    reg [13:0] divider;

    wire [7:0] regstatus;
    assign regstatus[7:2] = 7'b0;
    assign regstatus[1] = disk_miso;
    assign regstatus[0] = busy;

    assign data = cpuread ? 8'bz : (addr[0] ? data_rx : regstatus);

    reg sent_1st_rising;

    initial begin
        divider = 0;
        got_wr = 0;
        got_rd = 0;
        data_tx = 0;
        disk_sck = 0;
        disk_cs = 1;
        disk_reset = 0;
        byte_xfer_state = 0;
        sck_pulses_state = 0;
    end

    always @(posedge cpuclk) begin

        if (!nrst) begin
            divider = 0;
            got_wr = 0;
            got_rd = 0;
            data_tx = 0;
            disk_sck = 0;
            disk_cs = 1;
            disk_reset = 0;
            byte_xfer_state = 0;
            sck_pulses_state = 0;
        end
        else begin

            if (divider != 9)          // 400 kHz to generate a 200kHz SPI SCK
                divider = divider + 1;
            else begin
                divider = 0;

            /////////////////////////////////////////////////////////////////

                if (sck_pulses_state) begin

                    sck_pulses_state = sck_pulses_state - 1; 
                    disk_sck = sck_pulses_state[0];
                end

                /////////////////////////////////////////////////////////////////

// byte_xfer_state           16  15  14  13  12  11  10   9   8   7   6   5   4   3   2   1   0
//
//                    SCK     0   1   0   1   0   1   0   1   0   1   0   1   0   1   0   1   0
//                    MOSI   D7  D7 xD6  D6 xD5  D5 xD4  D4 xD3  D3 xD2  D2 xD1  D1 xD0  D0
//                    MISO  xD7  D7 xD6  D6 xD5  D5 xD4  D4 xD3  D3 xD2  D2 xD1  D1 xD0  D0

                if (byte_xfer_state) begin

                    if (byte_xfer_state & 1) begin
                        data_rx = (data_rx << 1) | disk_miso;
                        sent_1st_rising = 1;
                        disk_sck = 1;
                    end
                    else begin
                        if (sent_1st_rising)
                            data_tx = data_tx << 1;
                        disk_sck = 0;
                    end

                    byte_xfer_state = byte_xfer_state - 1; 
                end
                else
                    disk_sck = 0;
            end

            if (!cpuwrite) begin

                if (!got_wr) begin

                    if (!busy) begin

                        if (addr[0]) begin    // Data to TX
                            data_tx = data;
                            byte_xfer_state = 16;
                            sent_1st_rising = 0;
                            divider = 0;
                        end else begin
                            disk_cs = ~data[0];
                            disk_reset = data[2];
                            if (data[1]) begin 
                                data_tx[7] = 1;
                                sck_pulses_state = 160;    // 80 SCKs to reset card interface 
                            end
                        end
                    end

                    got_wr <= 1;
                end
            end
            else
                got_wr <= 0;

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

endmodule
