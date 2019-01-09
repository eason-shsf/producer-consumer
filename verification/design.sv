// Code your design here
// Code your design here
module fifo(
	input wclk,
  	input wrstn,
  	input rclk,
  	input rrstn,
  	
  	input wpush,
  	input[15:0] wdata,
  	output reg wfull,
  	
  	input rpop,
  	output reg [15:0] rdata,
  	output reg rempty
);
  
bit[15:0] data_q[$];

initial begin
	fork 
		forever begin
			@(posedge wclk);
			if(~wrstn) data_q.delete();
			else begin
			  if(wpush & !wfull) data_q.push_back(wdata);
			end
		end
		forever begin
			@(posedge wclk);
			if(wrstn) begin
			  if(data_q.size() >= 16) wfull = 1;
			  else wfull = 0;			
			end
		end		
	join_none

end

initial begin
	fork 
	  forever begin
		@(posedge rclk);
		if(~rrstn) data_q.delete();
		else begin
			if(rpop & !rempty) rdata = data_q.pop_front();
		end
	  end
	  
	  forever begin
		@(posedge rclk);
		if(rrstn) begin
			if(data_q.size() <= 0 ) rempty = 1;
			else rempty = 0;
		end
	  end	
	join_none
end
endmodule