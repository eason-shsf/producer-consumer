class producer_base_sequence extends uvm_sequence #(producer_item);
  `uvm_object_utils(producer_base_sequence)
  `uvm_declare_p_sequencer(producer_sequencer)
  
  function new(string name = "producer_base_sequence");
    super.new(name);
  endfunction
  
  task send_tr(input producer_item item);
    start_item(item);
    finish_item(item);
  endtask
  
  task body();
  endtask
endclass


class consumer_base_sequence extends uvm_sequence #(consumer_item);
  `uvm_object_utils(consumer_base_sequence)
  `uvm_declare_p_sequencer(consumer_sequencer)
  
  function new(string name = "consumer_base_sequence");
    super.new(name);
  endfunction
  
  task send_tr(input consumer_item item);
    start_item(item);
    finish_item(item);
  endtask
  
  task body();
  endtask
endclass


class pc_smoke_sequence extends uvm_sequence ;
  `uvm_object_utils(pc_smoke_sequence)
  `uvm_declare_p_sequencer(pc_virtual_sequencer)
  producer_base_sequence u_producer_base_sequence;
  consumer_base_sequence u_consumer_base_sequence;
  
  producer_item u_producer_item;
  function new(string name = "pc_smoke_sequence");
    super.new(name);
    u_producer_item    = producer_item::type_id::create("u_producer_item");
    u_producer_base_sequence    = producer_base_sequence::type_id::create("u_producer_base_sequence");
    u_consumer_base_sequence    = consumer_base_sequence::type_id::create("u_consumer_base_sequence");
  endfunction
	
  task body();
    starting_phase.raise_objection(this);
    u_producer_base_sequence.start(p_sequencer.u_producer_sequencer);
    u_consumer_base_sequence.start(p_sequencer.u_consumer_sequencer);
    
    u_producer_base_sequence.send_tr(u_producer_item);
    
    $display("Hello world");
    starting_phase.drop_objection(this);
  endtask
	
endclass