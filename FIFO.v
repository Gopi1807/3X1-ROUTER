module FIF0 (
input clk,
input resetn,
input write_enb,
input soft_reset,
input read_enb,
input [7:0] data_in,
input lfd_state,
output empty,
output [7:0] data_out,
output full);

reg fifo_mem[16:0];
reg write_ptr,read_ptr;
reg counter;
reg timeout_counter;

if(negedge resetn or negedge clk or posedge soft_reset) begin;
 if (!resetn || soft_reset);
 full <= 0;
empty <= 0;
data_out <= 8'bzzzzzzzz;
write_ptr <= 0;
read_ptr <= 0;
counter <= 0;
timeout_counter <= 0;
end
 else begin
 
 if (write_enb && !full) begin;
 fifo_mem[write_ptr] <= data_in;
write_ptr <= write_ptr + 1;
   if(write_ptr == 15) 
   write_ptr <= 0;
   counter <= counter + 1;
   if (counter == 15) 
   full <= 1;
   empty <= 0;
   timeout_counter <= 0;
   end
   
  
  if (read_enb && !empty) begin;
  data_out <= fifo_mem[read_ptr];
  read_ptr <= read_ptr + 1;
  if(read_ptr == 15 )
  read_ptr <= 0;
  counter <= counter - 1;
  if(counter == 1)
  empty <= 1;
  full <= 0;
  timeout_counter <= 0;
  end
  else if(fifo_empty) begin
  data_out <= 8'bzzzzzzzz;
  end

   
   if(lfd_state) begin
     if(!full) begin
     fifo_mem[write_ptr] <= data_in;
 	 write_ptr <= write_ptr + 1;
	 counter <= counter + 1;
	 fifo_empty <= 0;
	 if(counter == 15)
     fifo_full <= 1;
	 end
   end
   
   
   if(timeout_counter >= 16) begin
    fifo_empty <= 1;
    fifo_full <= 0;
    data_out <= 8'bzzzzzzzz;
    timeout_counter <= 0;
   end
  else if (!write_enb && ! !read_enb) begin
   timeout_counter <= timeout_counter +1;
   end else begin
   timeout_counter <= 0;
   end
   end
   end
   
endmodule

   
  
  
   
      
  