
module SERIAL_module(
    // CPU interface
    inout [7:0] data,
    input ncs,
    input nwr,
    input nrd,
    input nrst,
    input [3:0] addr,
    input cpuclk,    // 4MHz

    // Peripheral interface
    input rxd_serial,
    output reg txd_serial,
    output reg rts_serial,
    output intr_out);

    reg [7:0] rxdata;
    reg [4:0] rxstate;
    reg [7:0] receiveddata;

    reg [7:0] txdata;
    reg [3:0] bitstosend;

    reg [7:0] bauddivtx;
    reg [7:0] bauddivrx;
    reg receiving;
    wire cpuwrite;
    wire cpuread;
    reg got_wr;
    reg got_rd;
    reg intr_enabled;
    reg intr_pending;
    assign intr_out = intr_pending & intr_enabled;

    wire ncs2;
    assign ncs2 = ncs | ((addr != 8)&&(addr != 9));

    assign cpuwrite = ncs2 | nwr;
    assign cpuread  = ncs2 | nrd;

    wire[7:0] regstatus;
    assign regstatus[7:2] = 6'b0;
    assign regstatus[1] = |bitstosend;  // TX Busy
    assign regstatus[0] = intr_pending;     // RX Ready

    assign data = cpuread ? 8'bz : (addr[0] ? receiveddata : regstatus);

    initial begin
        receiving = 0;
        got_wr = 0;
        got_rd = 0;
        intr_enabled = 0;
        intr_pending = 0;
        txd_serial = 1;
        rts_serial = 1;
        rxstate = 0;
    end

    always @(posedge cpuclk) begin

        if (!nrst) begin
            receiving = 0;
            got_wr = 0;
            got_rd = 0;
            intr_enabled = 0;
            intr_pending = 0;
            txd_serial = 1;
            rts_serial = 1;
            rxstate = 0;
        end
        else begin
            if (!cpuwrite) begin
              if (!got_wr) begin
                if (addr[0]) begin    // Data to TX
                    txdata = data;
                    bitstosend = 10;
                end else begin
                    rts_serial = ~data[0];
                    intr_enabled = data[1];
                end

                got_wr <= 1;
              end
            end
            else begin
                got_wr <= 0; 
            end

            if (!cpuread) begin
                got_rd <= 1;
            end
            else begin
                if (got_rd) begin
                    
                    if (addr[0]) intr_pending = 0;  // Clear RX Intr.

                    got_rd <= 0;
                end
            end
        end

        if (bauddivrx < (receiving ? 207 : 30) )    // Divider is 208 for 19200 BPS @ 4MHz
            bauddivrx = bauddivrx + 1;
        else begin
            bauddivrx = 0;

    // RXSTATE    0   0   0   1   2   3   4   5   6   7   8   9  10  11
    //          IDL IDL STA STA STA  D0  D1  D2  D3  D4  D5  D6  D7 STO
            case (rxstate)
                0: if (!rxd_serial) rxstate = 1;
                1: if (!rxd_serial) rxstate = 2; else rxstate = 0;
                2: if (!rxd_serial) begin
                        rxstate = rxstate + 1;
                        receiving = 1; 
                   end
                   else rxstate = 0;

                3,
                4,
                5,
                6,
                7,
                8,
                9,
               10: begin
                        rxdata = rxdata >> 1;
                        rxdata[7] = rxd_serial;
                        rxstate = rxstate + 1;
                   end

               11: begin    
                        receiveddata = rxdata;
                        intr_pending = 1;
                        receiving = 0;
                        rxstate = 0; 
                   end
            endcase
        end

        if (bitstosend) begin
            if (bauddivtx)
                bauddivtx = bauddivtx - 1;
            else begin

                bauddivtx = 207;    // Divider is 208 for 19200 BPS @ 4MHz
                case (bitstosend)
                    10: txd_serial = 0; // Start
                    1: txd_serial = 1;  // Stop
                    default: begin
                                // 9,8,7,6,5,4,3,2 - word bits
                                txd_serial = txdata[0];
                                txdata = txdata >> 1;
                             end
                endcase
                bitstosend = bitstosend - 1;
            end
        end 
            else bauddivtx = 0;

    end

endmodule
