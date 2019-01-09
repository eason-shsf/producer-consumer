/***********************************************
* scoreboard 
***********************************************/
class pc_scoreboard extends uvm_scoreboard;
	`uvm_component_utils(pc_scoreboard);

  uvm_blocking_get_port #(producer_item) exp_port;
  uvm_blocking_get_port #(consumer_item) act_port;	
	producer_item tr_exp;
	consumer_item tr_act;
	bit result;
	
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction	
	
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		exp_port = new("exp_port", this);
		act_port = new("act_port", this);		
	endfunction
	
	task run_phase(uvm_phase phase);
		forever
		begin
			exp_port.get(tr_exp);
			act_port.get(tr_act);
			result = tr_exp.compare(tr_act);
			if (result)
				$display("Compare SUCCESSFULLY");
			else
            	`uvm_warning("WARNING", "Compare FAILED")
			$display("The expected data is");
			tr_exp.print();
			$display("The actual data is");
			tr_act.print();	
		end
	endtask		
endclass : pc_scoreboard

class pc_virtual_sequencer extends uvm_sequencer;
  `uvm_component_utils(pc_virtual_sequencer)
  
  uvm_sequencer_base u_producer_sequencer;
  uvm_sequencer_base u_consumer_sequencer;
  
  function new(string name="pc_virtual_sequencer", uvm_component parent);
    super.new(name, parent);
  endfunction
    
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction
endclass

/***********************************************
* environment 
***********************************************/
class pc_env extends uvm_env;
    `uvm_component_utils(pc_env);
    
    producer_agent u_producer_agent; 
    consumer_agent u_consumer_agent;  
    pc_scoreboard  u_pc_scoreboard; 
  	pc_virtual_sequencer u_pc_virtual_sequencer;
  
    uvm_tlm_analysis_fifo #(producer_item) producer_agt_2_scb_fifo;
    uvm_tlm_analysis_fifo #(consumer_item) consumer_agt_2_scb_fifo;
     
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
     	u_producer_agent    = producer_agent::type_id::create("u_producer_agent", this);
		u_consumer_agent    = consumer_agent::type_id::create("u_consumer_agent", this);
		u_pc_scoreboard = pc_scoreboard::type_id::create("u_pc_scoreboard", this);
        u_pc_virtual_sequencer = pc_virtual_sequencer::type_id::create("u_pc_virtual_sequencer", this);
		producer_agt_2_scb_fifo = new("producer_agt_2_scb_fifo", this);
		consumer_agt_2_scb_fifo = new("consumer_agt_2_scb_fifo", this);    
    endfunction

    function void connect_phase(uvm_phase phase);
		u_producer_agent.ap.connect(producer_agt_2_scb_fifo.analysis_export);
		u_consumer_agent.ap.connect(consumer_agt_2_scb_fifo.analysis_export);
		u_pc_scoreboard.exp_port.connect(producer_agt_2_scb_fifo.blocking_get_export);
		u_pc_scoreboard.act_port.connect(consumer_agt_2_scb_fifo.blocking_get_export);
      
      	u_pc_virtual_sequencer.u_producer_sequencer = u_producer_agent.u_producer_sequencer;
        u_pc_virtual_sequencer.u_consumer_sequencer = u_consumer_agent.u_consumer_sequencer;
	endfunction
endclass : pc_env