module fsm(
input clk,resetn,pkt_valid,
input parity_done,
input soft_reset_0,soft_reset_1,soft_reset_2,
input fifo_full,
input low_pkt_valid,
input fifo_empty_0,fifo_empty_1,fifo_empty_2,
input  data_in,
output detect_add,
output Id_state,
output laf_state,
output full_state,
output write_enb_reg,
output rst_int_reg,
output lfd_state);


parameter DECODE_ADDRESS = 3'b000,
          WAIT_TILL_EMPTY = 3'b001,
          LOAD_FIRST_DATA = 3'b010,
          LOAD_DATA = 3'b011,
          FIF0_FULL_STATE = 3'b100,
          LOAD_AFTER_FULL = 3'b101,
          LOAD_PARITY = 3'b110,
          CHECK_PARITY_ERROR = 3'b111;


reg [1:0] state,next_state;

always@(posedge clock or negedge resetn)
if(!rst_n)
            state <= IDLE;
        else
            state <= next_state;
    end 
 
always @(state or pkt_valid or data_in or fifo_empty_0 or fifo_empty_1 or fifo_empty_2) begin
next_state = DECODE_ADDRESS;
    if (state == DECODE_ADDRESS) begin
        if ((pkt_valid & (data_in[1:0] == 2'b00) & fifo_empty_0) |
            (pkt_valid & (data_in[1:0] == 2'b01) & fifo_empty_1) |
            (pkt_valid & (data_in[1:0] == 2'b10) & fifo_empty_2)) begin
       
            next_state = LOAD_FIRST_DATA;
        end
        else if ((pkt_valid & (data_in[1:0] == 2'b00) & !fifo_empty_0) |
                 (pkt_valid & (data_in[1:0] == 2'b01) & !fifo_empty_1) |
                 (pkt_valid & (data_in[1:0] == 2'b10) & !fifo_empty_2)) 
        begin
            next_state = WAIT_TILL_EMPTY;
        end
    end
 
    if (state == WAIT_TILL_EMPTY ) begin
        
         if ((fifo_empty_0 && (addr == 0)) ||
             (fifo_empty_1 && (addr == 1)) ||
             (fifo_empty_2 && (addr == 2)) begin
                       
            next_state = LOAD_FIRST_DATA;
        end 
      else 
         begin 
          next_state = WAIT_TILL_EMPTY;
    end
   end

   if (state == LOAD_FIRST_DATA) begin
      next_state = LOAD_DATA;
    end
 
   if (state == LOAD_DATA ) begin
       next_state = LOAD_DATA;
       if(fifo_full) begin
          next_state = FIFO_FULL_STATE;
            end
       if(!fifo_full && !pkt_valid) begin
          next_state = LOAD_PARITY ;
             end
   end
         if(state==FIFO_FULL_STATE) begin
           next_state = FIFO_FULL_STATE;
          if(!fifo_full) begin
          next_state= LOAD_AFTER_FULL;
          end
end
if(state == LOAD_AFTER_FULL) begin
if (!parity_done && !low_pkt_valid)begin
 next_state = LOAD_DATA;
end
 if (!parity_done && low_pkt_valid)begin
 next_state = LOAD_PARITY; 
end
if (parity_done) begin
next_state = DECODE_ADDRESS;
end
end  

if(state == LOAD_PARITY) begin
 next_state == LOAD_PARITY;
end

if(state == CHECK_PARITY_ERROR) begin
if(fifo_full) begin
next_state == FIFO_FULL_STATE;
end
if(!fifo_full) begin
next_state == DECODE_ADDRESS;
end
end
endmodule
                