// Code your testbench here
// or browse Examples
import uvm_pkg::*;
`include "uvm_macros.svh"
`timescale 1ns/10ps
`include "interface.sv"
`include "producer.sv"
`include "consumer.sv"
`include "env.sv"
`include "pc_seq.sv"
`include "pc_tests.sv"
module tb;
  
  sys_if u_sys_if();
  producer_if u_producer_if(
    .wclk(u_sys_if.wclk),
    .wrst_n(u_sys_if.wrst_n)
  );
  consumer_if u_consumer_if(
    .rclk(u_sys_if.rclk),
    .rrst_n(u_sys_if.rrst_n)
  );

  	always 
		#5 u_sys_if.wclk = !u_sys_if.wclk;
		
	initial 
	begin
		u_sys_if.wclk = 1'b1;
		u_sys_if.wrst_n = 1'b0;
        repeat (3) @(posedge u_sys_if.wclk);
		#5
		u_sys_if.wrst_n = 1'b1;
	end
  
    always 
		#5 u_sys_if.rclk = !u_sys_if.rclk;
		
	initial 
	begin
		u_sys_if.rclk = 1'b1;
		u_sys_if.rrst_n = 1'b0;
      repeat (3) @(posedge u_sys_if.rclk);
		#5
		u_sys_if.rrst_n = 1'b1;
	end
  
  initial begin
    #20;
    //$finish();
  end
  fifo u_fifo(

  	.wclk(u_sys_if.wclk),
  	.wrstn(u_sys_if.wrst_n),
  	.rclk(u_sys_if.rclk),
  	.rrstn(u_sys_if.rrst_n),
  	
    .wpush(u_producer_if.wpush),
    .wdata(u_producer_if.wdata),
    .wfull(u_producer_if.wfull),
  	
  	.rpop(u_consumer_if.rpop),
  	.rdata(u_consumer_if.rdata),
  	.rempty(u_consumer_if.rempty)    
	
  );
  
initial 
begin
		uvm_config_db #(virtual sys_if)::set(null, "*", "sys_if", u_sys_if);
		uvm_config_db #(virtual producer_if)::set(null, "*", "producer_if", u_producer_if);
		uvm_config_db #(virtual consumer_if)::set(null, "*", "consumer_if", u_consumer_if);

	run_test("test_1");

end
endmodule 