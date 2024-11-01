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
output parity_done,
output low_pkt_valid,
output err,
output [7:0] dout);

reg prev_parity_done;
reg [7:0] header_byte;
reg header_latched;

//reset state

always@(posedge clk or negedge resetn)begin
if(!resetn) begin
  parity_done <= 0;
  low_pkt_valid <= 0;
  err <= 0;
  dout <= 0;
  header_byte <= 8'b0;
  header_latched <= 0;
  dout <= 8'b0;
  end
  
  // Loading First Data State with Valid Packet

  else if(posedge clk && posedge resetn) begin
      if(ld_state && !fifo_full && !pkt_valid) 
	   parity_done <= 1;
	   prev_parity_done <=0;
	  if(laf_state && low_pkt_valid && !prev_parity_done)
	  parity_done <=1;
	  
	  end
	  prev_parity_done <= parity_done;
	
	// FIFO Full State
  
  if(rst_int_reg) begin
   low_pkt_valid <= 0;
    else 
   low_pkt_valid <= 1;
   end
   
  if(detect_add) begin
   parity_done <= 0;
   else
   parity_done <=1;
   end
   
   if(ld_state && !pkt_valid)
    low_pkt_valid <=1;
    else
    low_pkt_valid <=0;
    end	
	  
	 // Latch the header byte when detect_add and pkt_valid are high
            if (detect_add && pkt_valid && !header_latched) begin
                header_byte <= data_in;
                header_latched <= 1;
            end

            // Handle dout assignment based on ld_state and header_latched
            if (lfd_state && header_latched) begin
                dout <= header_byte;
			end else if(ld_state) begin
			 dout <= data_in;
            end   
	   if (fifo_full && !pkt_valid && ld_state) begin
                err <= 1;
            end else begin
                err <= 0;
            end
end
endmodule