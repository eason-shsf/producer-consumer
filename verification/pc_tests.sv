class top_test_base extends uvm_test;
    `uvm_component_utils(top_test_base)
    
    pc_env u_pc_env;

    function new(string name = "top_test_base", uvm_component parent);   
        super.new(name, parent); 
    endfunction

    function void build_phase(uvm_phase phase);
      u_pc_env = pc_env::type_id::create("u_pc_env", this); 
    endfunction

    //task init_vseq(top_vseq_base vseq);
    //    vseq.data_sqr_h = env_h.agent_1_h.data_sequencer_h;  
    //    vseq.rst_sqr_h  = env_h.agent_2_h.rst_sequencer_h; 
    //endtask
endclass : top_test_base

class test_1 extends top_test_base;
    `uvm_component_utils(test_1)

	//vseq_rst_data vseq_h;
  
  function new(string name = "test_1", uvm_component parent);   
        super.new(name, parent); 
    endfunction
    
    function void build_phase(uvm_phase phase);
      	super.build_phase(phase);
        //vseq_h = vseq_rst_data::type_id::create("vseq_h"); 
      uvm_config_db #(uvm_object_wrapper)::set(this,"u_pc_env.u_pc_virtual_sequencer.main_phase","default_sequence", pc_smoke_sequence::type_id::get());
    endfunction 

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        //init_vseq(vseq_h);
        //vseq_h.start(null);
     	#50;
        phase.drop_objection(this);
      	
    endtask    
endclass : test_1  

//uvm_fatal(get_type_name(), "build_phase(): xxx")
//uvm_info(get_type_name(), $sformat("build_phase(): cfg.sprint(): \n%s", this.cfg.sprint()), UVM_HIGH)
//+UVM_VERBOSITY=UVM_NONE
//+UVM_TESTNAME=xxx