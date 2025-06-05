`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.01.2025 15:27:36
// Design Name: 
// Module Name: FIFO
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module FIFO (
    input clk,
    input resetn,
    input write_enb,
    input soft_reset,
    input read_enb,
    input [7:0] data_in,
    input lfd_state, // Indicates a header byte
    output reg empty,
    output reg [8:0] data_out, // 9 bits wide to include the header flag
    output reg full
);

    reg [8:0] fifo_mem[15:0]; // 9-bit wide memory
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
            // Write operation
            if (write_enb && !full) begin
                if (lfd_state) begin
                    // Write header byte with 9th bit set
                    fifo_mem[write_ptr] <= {1'b1, data_in};
                end else begin
                    // Write normal byte with 9th bit cleared
                    fifo_mem[write_ptr] <= {1'b0, data_in};
                end
                write_ptr <= write_ptr + 1;
                counter <= counter + 1;
                empty <= 0;
                if (counter == 15) full <= 1;
            end

            // Read operation
            if (read_enb && !empty) begin
                data_out <= fifo_mem[read_ptr];
                read_ptr <= read_ptr + 1;
                counter <= counter - 1;
                full <= 0;
                if (counter == 0) empty <= 1;
            end else if (empty) begin
                data_out <= 9'bz; // High-impedance state
            end

            // Timeout logic
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


   
  
  
   
      
  
