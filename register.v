module router_reg(
    input clock,
    input resetn,
    input pkt_valid,
    input [7:0] data_in,
    input fifo_full,
    input rst_int_reg,
    input detect_add,
    input ld_state,
    input laf_state,
    input full_state,
    input lfd_state,
    output reg parity_done,
    output reg low_pkt_valid,
    output reg err,
    output reg [7:0] dout
);

    reg [7:0] header_byte;
    reg header_latched;
    reg prev_parity_done;

    // Reset and sequential logic
    always @(posedge clock or negedge resetn) begin
        if (!resetn) begin
            // Reset all outputs and internal registers
            parity_done <= 0;
            low_pkt_valid <= 0;
            err <= 0;
            dout <= 8'b0;
            header_byte <= 8'b0;
            header_latched <= 0;
            prev_parity_done <= 0;
        end else begin
            // Load first data state
            if (ld_state && !fifo_full && !pkt_valid) begin
                parity_done <= 1;
            end else if (laf_state && low_pkt_valid && !prev_parity_done) begin
                parity_done <= 1;
            end
            prev_parity_done <= parity_done;

            // Handle low_pkt_valid based on rst_int_reg
            if (rst_int_reg) begin
                low_pkt_valid <= 0;
            end else if (ld_state && !pkt_valid) begin
                low_pkt_valid <= 1;
            end else begin
                low_pkt_valid <= 0;
            end

            // Latch the header byte when detect_add and pkt_valid are high
            if (detect_add && pkt_valid && !header_latched) begin
                header_byte <= data_in;
                header_latched <= 1;
            end

            // Handle dout assignment
            if (lfd_state && header_latched) begin
                dout <= header_byte;
            end else if (ld_state) begin
                dout <= data_in;
            end

            // Set error flag during FIFO full condition
            if (fifo_full && !pkt_valid && ld_state) begin
                err <= 1;
            end else begin
                err <= 0;
            end
        end
    end
endmodule
