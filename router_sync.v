module router_synchronizer (
    input clk,
    input resetn,
    input detect_add,
    input [1:0] data_in,
    input write_enb_reg,
    input full_0, full_1, full_2,
    input empty_0, empty_1, empty_2,
    input read_enb_0, read_enb_1, read_enb_2,
    output reg fifo_full,
    output reg vld_out_0, vld_out_1, vld_out_2,
    output reg write_enb,
    output reg soft_reset_0, soft_reset_1, soft_reset_2
);

    reg [4:0] counter_0, counter_1, counter_2; // 5-bit counters for 30 clock cycles

    // FIFO Full Signal
    always @(*) begin
        case (data_in)
            2'b00: fifo_full = full_0;
            2'b01: fifo_full = full_1;
            2'b10: fifo_full = full_2;
            default: fifo_full = 0;
        endcase
    end

    // Valid Output Signals
    always @(*) begin
        vld_out_0 = ~empty_0;
        vld_out_1 = ~empty_1;
        vld_out_2 = ~empty_2;
    end

    // Write Enable Signal
    always @(*) begin
        write_enb = write_enb_reg;
    end

    // Soft Reset Logic for FIFO 0
    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            soft_reset_0 <= 0;
            counter_0 <= 0;
        end else begin
            if (vld_out_0 && !read_enb_0) begin
                counter_0 <= counter_0 + 1;
                if (counter_0 >= 30) begin
                    soft_reset_0 <= 1;
                    counter_0 <= 0;
                end
            end else begin
                soft_reset_0 <= 0;
                counter_0 <= 0;
            end
        end
    end

    // Soft Reset Logic for FIFO 1
    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            soft_reset_1 <= 0;
            counter_1 <= 0;
        end else begin
            if (vld_out_1 && !read_enb_1) begin
                counter_1 <= counter_1 + 1;
                if (counter_1 >= 30) begin
                    soft_reset_1 <= 1;
                    counter_1 <= 0;
                end
            end else begin
                soft_reset_1 <= 0;
                counter_1 <= 0;
            end
        end
    end

    // Soft Reset Logic for FIFO 2
    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            soft_reset_2 <= 0;
            counter_2 <= 0;
        end else begin
            if (vld_out_2 && !read_enb_2) begin
                counter_2 <= counter_2 + 1;
                if (counter_2 >= 30) begin
                    soft_reset_2 <= 1;
                    counter_2 <= 0;
                end
            end else begin
                soft_reset_2 <= 0;
                counter_2 <= 0;
            end
        end
    end
endmodule
