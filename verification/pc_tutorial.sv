// static connection 

module tb;
  reg wclk, wrst_n, rclk, rrst_n;
  
  fifo u_fifo(
  	.wclk(wclk), .wrstn(wrst_n),
	.rclk(rclk), .rrstn(rrst_n),
	... 
  );

  initial begin
	wrst_n = 0;
	#100;
	wrst_n = 1;
	... 
  end
endmodule 


// static connection - package
interface sys_if;
  logic wclk,rclk,wrst_n,rrst_n;
endinterface : sys_if
module tb;
  sys_if u_sys_if;
  
  fifo u_fifo(
	.sys_if(u_sys_if)
	... 
  );

  initial begin
	u_sys_if.wrst_n = 0;
	#100;
	u_sys_if.wrst_n = 1;
	... 
  end
endmodule 

// dynamic connection 

interface sys_if;
  logic wclk,rclk,wrst_n,rrst_n;
endinterface : sys_if

class producer_driver;
 virtual sys_if u_sys_if;
 task run;
 forever @(posedge u_sys_if.wclk)
 begin … end
 endtask
endclass

module tb;
  sys_if u_sys_if;
  
  fifo u_fifo( .sys_if(u_sys_if) ... );
  driver drv; 
  initial begin
	...
	uvm_test_top.env.agt.drv.u_sys_if = u_sys_if;
	...
  end
endmodule 

// dynamic connection - decouple

interface sys_if;
  logic wclk,rclk,wrst_n,rrst_n;
endinterface : sys_if

class producer_driver extends uvm_driver #(producer_item);
	... 
 virtual sys_if u_sys_if;
 function void build_phase(uvm_phase phase);
    super.build_phase(phase);
	if (!uvm_config_db #(virtual sys_if)::get(null, "*", "sys_if", u_sys_if))
		`uvm_fatal(get_type_name(), "failed to get sys_if")
 endfunction
	...
endclass

module tb;
  sys_if u_sys_if;
  fifo u_fifo( .sys_if(u_sys_if) ... );
  initial begin
	...
	uvm_config_db #(virtual sys_if)::set(null, "*", "sys_if", u_sys_if);
	...
  end
endmodule 