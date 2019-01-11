
class consumer_item extends uvm_sequence_item;
  rand logic [15 : 0] rdata;
  rand int delay;
  function new(string name = "consumer_item");
        super.new(name);
    endfunction

  `uvm_object_utils_begin(consumer_item)
      `uvm_field_int(rdata, UVM_ALL_ON)
  `uvm_object_utils_end
endclass 

class consumer_sequencer extends uvm_sequencer #(consumer_item);
  `uvm_component_utils(consumer_sequencer)
  
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction
endclass : consumer_sequencer



class consumer_driver extends uvm_driver #(consumer_item);
  `uvm_component_utils(consumer_driver)

    virtual consumer_if u_consumer_if; 
	virtual sys_if u_sys_if;
    consumer_item tr; 
    
    function new(string name, uvm_component parent);
        super.new(name, parent); 
    endfunction
   
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db #(virtual consumer_if)::get(null, "*", "consumer_if", u_consumer_if))
            `uvm_info("DATA_DRIVER", "uvm_config_db::get failed!", UVM_HIGH)
		if (!uvm_config_db #(virtual sys_if)::get(null, "*", "sys_if", u_sys_if))
            `uvm_info("DATA_DRIVER", "uvm_config_db::get failed!", UVM_HIGH)
    endfunction

    task reset_check();
        forever begin
          @(posedge u_consumer_if.rclk);

          if (!sys_if.rrst_n) begin
                u_consumer_if.rpop = 'b0; 
            end
        end
    endtask

    task recv_data(ref consumer_item tr);
        forever begin
            @(posedge u_consumer_if.rclk); 
            
          if (sys_if.rrst_n & !u_consumer_if.rempty) begin 
                seq_item_port.get_next_item(tr); 
                #1;
            repeat (tr.delay) @(posedge u_consumer_if.rclk); 
                u_consumer_if.rpop     = 'b1;
            	tr.rdata = u_consumer_if.rdata; 
                seq_item_port.item_done();
				`uvm_info(get_type_name(), $sformatf(" consumer_item: \n%s", this.tr.sprint()), UVM_LOW)
            end
        end
    endtask
    
    task run_phase(uvm_phase phase);
        fork
            reset_check();
            recv_data();
        join 
    endtask 
endclass : consumer_driver

class consumer_monitor extends uvm_monitor;
    `uvm_component_utils(consumer_monitor)
    
    virtual consumer_if u_consumer_if; 
	virtual sys_if u_sys_if;
  	uvm_analysis_port #(consumer_item) ap;
    consumer_item tr;

    function new(string name, uvm_component parent);
        super.new(name, parent); 
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("consumer_monitor_ap", this);
        if (!uvm_config_db #(virtual consumer_if)::get(null, "*", "consumer_if", u_consumer_if))
            `uvm_fatal(get_type_name(), "failed to get consumer_if")
		if (!uvm_config_db #(virtual sys_if)::get(null, "*", "sys_if", u_sys_if))
            `uvm_fatal(get_type_name(), "failed to get sys_if")
    endfunction

    task run_phase(uvm_phase phase);
	forever 
		begin
			@(posedge u_sys_if.rclk)	
			tr = consumer_item::type_id::create("tr");
          if (u_sys_if.rrst_n & !u_consumer_if.rempty & u_consumer_if.rpop)
			begin
                tr.rdata = u_consumer_if.rdata;	
                ap.write(tr);
				`uvm_info(get_type_name(), $sformatf(" consumer_item: \n%s", this.tr.sprint()), UVM_LOW)
			end
		end 
    endtask
endclass : consumer_monitor

/***********************************************
* agent 
***********************************************/

class consumer_agent extends uvm_component;
    `uvm_component_utils(consumer_agent)
    
  	uvm_analysis_port #(consumer_item) ap; 
    
	
	consumer_sequencer u_consumer_sequencer;
	consumer_driver    u_consumer_driver;
	consumer_monitor   u_consumer_monitor;
	
	
    function new(string name, uvm_component parent);
        super.new(name, parent); 
    endfunction

    function void build_phase(uvm_phase phase);
        u_consumer_driver     = consumer_driver   ::type_id::create("consumer_driver", this); 
        u_consumer_sequencer  = consumer_sequencer::type_id::create("consumer_sequencer", this); 
        u_consumer_monitor    = consumer_monitor  ::type_id::create("consumer_monitor", this);
    endfunction


    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
      u_consumer_driver.seq_item_port.connect(u_consumer_sequencer.seq_item_export);
        ap = u_consumer_monitor.ap; 
    endfunction
endclass : consumer_agent 

