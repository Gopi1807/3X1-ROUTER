module fsm(
    input clk,
    input resetn,
    input pkt_valid,
    input parity_done,
    input soft_reset_0, soft_reset_1, soft_reset_2,
    input fifo_full,
    input low_pkt_valid,
    input fifo_empty_0, fifo_empty_1, fifo_empty_2,
    input [1:0] data_in, 

    output reg detect_add,
    output reg Id_state,
    output reg laf_state,
    output reg full_state,
    output reg write_enb_reg,
    output reg rst_int_reg,
    output reg lfd_state,
    output reg busy
);

    
    parameter IDLE              = 3'b000,
              DECODE_ADDRESS    = 3'b001,
              WAIT_TILL_EMPTY   = 3'b010,
              LOAD_FIRST_DATA   = 3'b011,
              LOAD_DATA         = 3'b100,
              FIFO_FULL_STATE   = 3'b101,
              LOAD_AFTER_FULL   = 3'b110,
              LOAD_PARITY       = 3'b111,
              CHECK_PARITY_ERROR = 3'b1000; 

    reg [3:0] state, next_state;

    
    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            state <= IDLE;
        end else if (soft_reset_0 || soft_reset_1 || soft_reset_2) begin
            state <= DECODE_ADDRESS; 
        end else begin
            state <= next_state;
        end
    end

    
    always @(*) begin
        
        next_state = state;
        detect_add = 0;
        Id_state = 0;
        laf_state = 0;
        full_state = 0;
        write_enb_reg = 0;
        rst_int_reg = 0;
        lfd_state = 0;
        busy = 0;

        case (state)
            IDLE: begin
                if (pkt_valid) begin
                    next_state = DECODE_ADDRESS;
                end
            end

            DECODE_ADDRESS: begin
                detect_add = 1;
                if ((pkt_valid && (data_in == 2'b00) && fifo_empty_0) ||
                    (pkt_valid && (data_in == 2'b01) && fifo_empty_1) ||
                    (pkt_valid && (data_in == 2'b10) && fifo_empty_2)) begin
                    next_state = LOAD_FIRST_DATA;
                end else if ((pkt_valid && (data_in == 2'b00) && !fifo_empty_0) ||
                             (pkt_valid && (data_in == 2'b01) && !fifo_empty_1) ||
                             (pkt_valid && (data_in == 2'b10) && !fifo_empty_2)) begin
                    next_state = WAIT_TILL_EMPTY;
                end
            end

            WAIT_TILL_EMPTY: begin
                busy = 1;
                if ((fifo_empty_0 && (data_in == 2'b00)) ||
                    (fifo_empty_1 && (data_in == 2'b01)) ||
                    (fifo_empty_2 && (data_in == 2'b10))) begin
                    next_state = LOAD_FIRST_DATA;
                end
            end

            LOAD_FIRST_DATA: begin
                lfd_state = 1;
                write_enb_reg = 1;
                busy = 1;
                next_state = LOAD_DATA;
            end

            LOAD_DATA: begin
                write_enb_reg = 1;
                if (fifo_full) begin
                    next_state = FIFO_FULL_STATE;
                end else if (!fifo_full && !pkt_valid) begin
                    next_state = LOAD_PARITY;
                end
            end

            FIFO_FULL_STATE: begin
                full_state = 1;
                busy = 1;
                if (!fifo_full) begin
                    next_state = LOAD_AFTER_FULL;
                end
            end

            LOAD_AFTER_FULL: begin
                laf_state = 1;
                write_enb_reg = 1;
                busy = 1;
                if (parity_done) begin
                    next_state = DECODE_ADDRESS;
                end else if (low_pkt_valid) begin
                    next_state = LOAD_PARITY;
                end else begin
                    next_state = LOAD_DATA;
                end
            end

            LOAD_PARITY: begin
                write_enb_reg = 1;
                busy = 1;
                next_state = CHECK_PARITY_ERROR;
            end

            CHECK_PARITY_ERROR: begin
                rst_int_reg = 1;
                busy = 1;
                if (fifo_full) begin
                    next_state = FIFO_FULL_STATE;
                end else begin
                    next_state = DECODE_ADDRESS;
                end
            end

            default: begin
                next_state = IDLE; 
            end
        endcase
    end
endmodule
