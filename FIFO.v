module FIFO (
    input clk,
    input resetn,
    input write_enb,
    input soft_reset,
    input read_enb,
    input [7:0] data_in,
    input lfd_state, // Indicates a header byte
    output reg empty,
    output reg [8:0] data_out, 
    output reg full
);

    reg [8:0] fifo_mem[15:0]; 
    reg [3:0] write_ptr, read_ptr, counter;
    reg [3:0] timeout_counter;

    always @(negedge resetn or posedge clk or posedge soft_reset) begin
        if (!resetn || soft_reset) begin
            full <= 0;
            empty <= 1;
            data_out <= 9'b0;
            write_ptr <= 0;
            read_ptr <= 0;
            counter <= 0;
            timeout_counter <= 0;
        end else begin
            
            if (write_enb && !full) begin
                if (lfd_state) begin
        
                    fifo_mem[write_ptr] <= {1'b1, data_in};
                end else begin
                
                    fifo_mem[write_ptr] <= {1'b0, data_in};
                end
                write_ptr <= write_ptr + 1;
                counter <= counter + 1;
                empty <= 0;
                if (counter == 15) full <= 1;
            end


            if (read_enb && !empty) begin
                data_out <= fifo_mem[read_ptr];
                read_ptr <= read_ptr + 1;
                counter <= counter - 1;
                full <= 0;
                if (counter == 0) empty <= 1;
            end else if (empty) begin
                data_out <= 9'bz; // High-impedance state
            end

        
            if (timeout_counter >= 16) begin
                empty <= 1;
                full <= 0;
                data_out <= 9'bz;
                timeout_counter <= 0;
            end else if (!write_enb && !read_enb) begin
                timeout_counter <= timeout_counter + 1;
            end else begin
                timeout_counter <= 0;
            end
        end
    end
endmodule
