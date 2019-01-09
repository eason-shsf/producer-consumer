
class producer_item extends uvm_sequence_item;
  rand logic [15 : 0] wdata;
  rand int delay;
  function new(string name = "producer_item");
        super.new(name);
    endfunction

  `uvm_object_utils_begin(producer_item)
		`uvm_field_int(wdata, UVM_ALL_ON)
  `uvm_object_utils_end
endclass 


class producer_sequencer extends uvm_sequencer #(producer_item);
  `uvm_component_utils(producer_sequencer)
  
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction
endclass : producer_sequencer

class producer_driver extends uvm_driver #(producer_item);
  `uvm_component_utils(producer_driver)

    virtual producer_if u_producer_if; 
	virtual sys_if u_sys_if;
    producer_item tr; 
    
    function new(string name, uvm_component parent);
        super.new(name, parent); 
    endfunction
   
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db #(virtual producer_if)::get(null, "*", "producer_if", u_producer_if))
            `uvm_info("DATA_DRIVER", "uvm_config_db::get failed!", UVM_HIGH)
		if (!uvm_config_db #(virtual sys_if)::get(null, "*", "sys_if", u_sys_if))
            `uvm_info("DATA_DRIVER", "uvm_config_db::get failed!", UVM_HIGH)
    endfunction

    task reset_check();
        forever begin
            @(posedge u_producer_if.wclk);

            if (!sys_if.wrst_n) begin
                u_producer_if.wpush = 'b0; 
				u_producer_if.wdata = 'b0; 
            end
        end
    endtask

    task send_data();
        forever begin
            @(posedge u_producer_if.wclk); 
            
          if (sys_if.wrst_n & !u_producer_if.wfull) begin 
                seq_item_port.get_next_item(tr); 
                #1;
				repeat (tr.delay) @(posedge u_producer_if.wclk); 
                u_producer_if.wpush     = 'b1;
                u_producer_if.wdata = tr.wdata;
                $display("haha-----------");
                seq_item_port.item_done();
            end
        end
    endtask
    
    task run_phase(uvm_phase phase);
        fork
            reset_check();
            send_data();
        join 
    endtask 
endclass : producer_driver


      
class producer_monitor extends uvm_monitor;
    `uvm_component_utils(producer_monitor)
    
    virtual producer_if u_producer_if; 
	virtual sys_if u_sys_if;
  	uvm_analysis_port #(producer_item) ap;
    producer_item tr;

    function new(string name, uvm_component parent);
        super.new(name, parent); 
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("producer_monitor_ap", this);
        if (!uvm_config_db #(virtual producer_if)::get(null, "*", "producer_if", u_producer_if))
            `uvm_info("DATA_DRIVER", "uvm_config_db::get failed!", UVM_HIGH)
		if (!uvm_config_db #(virtual sys_if)::get(null, "*", "sys_if", u_sys_if))
            `uvm_info("DATA_DRIVER", "uvm_config_db::get failed!", UVM_HIGH)
    endfunction

    task run_phase(uvm_phase phase);
	forever 
		begin
			@(posedge u_sys_if.wclk)	
			tr = producer_item::type_id::create("tr");
			if (u_sys_if.wrst_n & !u_producer_if.wfull & u_producer_if.wpush)
			begin
                tr.wdata = u_producer_if.wdata;	
                ap.write(tr);
			end
		end 
    endtask
endclass : producer_monitor

/***********************************************
* agent 
***********************************************/

class producer_agent extends uvm_component;
    `uvm_component_utils(producer_agent)
    
  	uvm_analysis_port #(producer_item) ap; 
    
	
	producer_sequencer u_producer_sequencer;
	producer_driver    u_producer_driver;
	producer_monitor   u_producer_monitor;
	
	
    function new(string name, uvm_component parent);
        super.new(name, parent); 
    endfunction

    function void build_phase(uvm_phase phase);
        u_producer_driver     = producer_driver   ::type_id::create("producer_driver", this); 
        u_producer_sequencer  = producer_sequencer::type_id::create("producer_sequencer", this); 
        u_producer_monitor    = producer_monitor  ::type_id::create("producer_monitor", this);
    endfunction


    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        u_producer_driver.seq_item_port.connect(u_producer_sequencer.seq_item_export);
        ap = u_producer_monitor.ap; 
    endfunction
endclass : producer_agent 

