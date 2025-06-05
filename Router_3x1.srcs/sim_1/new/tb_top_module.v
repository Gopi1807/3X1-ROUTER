`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.01.2025 16:10:53
// Design Name: 
// Module Name: tb_top_module
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


`timescale 1ns / 1ps

module tb_top_module;

    // Inputs to the top module
    reg clk;
    reg resetn;
    reg read_enb_0;
    reg read_enb_1;
    reg read_enb_2;
    reg [7:0] data_in;
    reg pkt_valid;

    // Outputs from the top module
    wire [7:0] data_out_0;
    wire [7:0] data_out_1;
    wire [7:0] data_out_2;
    wire valid_out_0;
    wire valid_out_1;
    wire valid_out_2;
    wire err;
    wire busy;

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Clock with 10 ns period
    end

    // DUT instantiation
    top_module uut (
        .clk(clk),
        .resetn(resetn),
        .read_enb_0(read_enb_0),
        .read_enb_1(read_enb_1),
        .read_enb_2(read_enb_2),
        .data_in(data_in),
        .pkt_valid(pkt_valid),
        .data_out_0(data_out_0),
        .data_out_1(data_out_1),
        .data_out_2(data_out_2),
        .valid_out_0(valid_out_0),
        .valid_out_1(valid_out_1),
        .valid_out_2(valid_out_2),
        .err(err),
        .busy(busy)
    );

    // Stimulus
    initial begin
        // Initialize inputs
        resetn = 0;
        read_enb_0 = 0;
        read_enb_1 = 0;
        read_enb_2 = 0;
        data_in = 0;
        pkt_valid = 0;

        // Reset the system
        #10 resetn = 1;
        #10;

        // Test Case 1: Send a valid packet to FIFO 0
        data_in = 8'b0000_1010; // Address 0
        pkt_valid = 1;
        #10 pkt_valid = 0; // End of packet
        #20;

        // Test Case 2: Read from FIFO 0
        read_enb_0 = 1;
        #20 read_enb_0 = 0;
        #20;

        // Test Case 3: Send a valid packet to FIFO 1
        data_in = 8'b0001_1100; // Address 1
        pkt_valid = 1;
        #10 pkt_valid = 0; // End of packet
        #20;

        // Test Case 4: Read from FIFO 1
        read_enb_1 = 1;
        #20 read_enb_1 = 0;
        #20;

        // Test Case 5: Send a valid packet to FIFO 2
        data_in = 8'b0010_1111; // Address 2
        pkt_valid = 1;
        #10 pkt_valid = 0; // End of packet
        #20;

        // Test Case 6: Read from FIFO 2
        read_enb_2 = 1;
        #20 read_enb_2 = 0;
        #20;

        // Test Case 7: FIFO Full Condition
        // Simulate filling up FIFO 0
        repeat(16) begin
            data_in = 8'b0000_0001; // Address 0
            pkt_valid = 1;
            #10 pkt_valid = 0;
            #10;
        end
        #20;

        // Test Case 8: Error Handling (FIFO Full)
        data_in = 8'b0000_1111; // Address 0
        pkt_valid = 1;
        #10 pkt_valid = 0; // End of packet
        #20;

        // Test Case 9: Reset during operation
        resetn = 0;
        #10 resetn = 1;
        #20;

        // Test Case 10: Check valid_out signals
        read_enb_0 = 1;
        #10 read_enb_0 = 0;
        read_enb_1 = 1;
        #10 read_enb_1 = 0;
        read_enb_2 = 1;
        #10 read_enb_2 = 0;
        #20;

        // End simulation
        $stop;
    end

    // Monitor outputs
    initial begin
        $monitor("Time=%0t | data_out_0=%b, data_out_1=%b, data_out_2=%b | valid_out_0=%b, valid_out_1=%b, valid_out_2=%b | err=%b | busy=%b",
                 $time, data_out_0, data_out_1, data_out_2, valid_out_0, valid_out_1, valid_out_2, err, busy);
    end

endmodule

