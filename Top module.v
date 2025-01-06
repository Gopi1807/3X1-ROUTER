`timescale 1ns / 1ps


module top_module(
    input clk,
    input resetn,
    input read_enb_0,
    input read_enb_1,
    input read_enb_2,
    input [7:0] data_in,
    input pkt_valid,
    output [7:0] data_out_0,
    output [7:0] data_out_1,
    output [7:0] data_out_2,
    output valid_out_0,
    output valid_out_1,
    output valid_out_2,
    output err,
    output busy
);

    wire detect_add, write_enb, fifo_full;
    wire [7:0] dout;
    wire low_pkt_valid, parity_done;
    wire ld_state, laf_state, full_state, lfd_state;
    wire soft_reset_0, soft_reset_1, soft_reset_2;
    wire empty_0, empty_1, empty_2;
    wire full_0, full_1, full_2;

    // FSM Instance
    fsm fsm_instance(
        .clk(clk),
        .resetn(resetn),
        .pkt_valid(pkt_valid),
        .parity_done(parity_done),
        .soft_reset_0(soft_reset_0),
        .soft_reset_1(soft_reset_1),
        .soft_reset_2(soft_reset_2),
        .fifo_full(fifo_full),
        .low_pkt_valid(low_pkt_valid),
        .fifo_empty_0(empty_0),
        .fifo_empty_1(empty_1),
        .fifo_empty_2(empty_2),
        .data_in(data_in),
        .detect_add(detect_add),
        .Id_state(),
        .laf_state(laf_state),
        .full_state(full_state),
        .write_enb_reg(write_enb),
        .rst_int_reg(),
        .lfd_state(lfd_state),
        .busy(busy)
    );

    // Router Register Instance
    router_reg register(
        .clock(clk),
        .resetn(resetn),
        .pkt_valid(pkt_valid),
        .data_in(data_in),
        .fifo_full(fifo_full),
        .rst_int_reg(),
        .detect_add(detect_add),
        .ld_state(ld_state),
        .laf_state(laf_state),
        .full_state(full_state),
        .lfd_state(lfd_state),
        .parity_done(parity_done),
        .low_pkt_valid(low_pkt_valid),
        .err(err),
        .dout(dout)
    );

    // Router Synchronizer Instance
    router_synchronizer synchronizer(
        .detect_add(detect_add),
        .data_in(data_in[1:0]),
        .write_enb_reg(write_enb),
        .clk(clk),
        .resetn(resetn),
        .read_enb_0(read_enb_0),
        .read_enb_1(read_enb_1),
        .read_enb_2(read_enb_2),
        .empty_0(empty_0),
        .empty_1(empty_1),
        .empty_2(empty_2),
        .full_0(full_0),
        .full_1(full_1),
        .full_2(full_2),
        .vld_out_0(valid_out_0),
        .vld_out_1(valid_out_1),
        .vld_out_2(valid_out_2),
        .write_enb(write_enb),
        .fifo_full(fifo_full),
        .soft_reset_0(soft_reset_0),
        .soft_reset_1(soft_reset_1),
        .soft_reset_2(soft_reset_2)
    );

    // FIFO Instances
    FIFO FIFO_0(
        .clk(clk),
        .resetn(resetn),
        .write_enb(write_enb),
        .soft_reset(soft_reset_0),
        .read_enb(read_enb_0),
        .data_in(dout),
        .lfd_state(lfd_state),
        .empty(empty_0),
        .data_out(data_out_0),
        .full(full_0)
    );

    FIFO FIFO_1(
        .clk(clk),
        .resetn(resetn),
        .write_enb(write_enb),
        .soft_reset(soft_reset_1),
        .read_enb(read_enb_1),
        .data_in(dout),
        .lfd_state(lfd_state),
        .empty(empty_1),
        .data_out(data_out_1),
        .full(full_1)
    );

    FIFO FIFO_2(
        .clk(clk),
        .resetn(resetn),
        .write_enb(write_enb),
        .soft_reset(soft_reset_2),
        .read_enb(read_enb_2),
        .data_in(dout),
        .lfd_state(lfd_state),
        .empty(empty_2),
        .data_out(data_out_2),
        .full(full_2)
    );

endmodule
