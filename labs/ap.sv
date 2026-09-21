//===================================================================================
// Siemens:
// vlog ap.sv
// vsim -c top -do "run -a"
// Cadence:
// xrun -c -uvm ap.sv
// xrun -uvm -top worklib.top
//
// This is an example demonstrating how ports are connected directly without the use
// of a fifo.
//===================================================================================
import uvm_pkg::*;

`include "uvm_macros.svh"

//===================================================================================
// Transaction class
//===================================================================================
class tpl_tlm extends uvm_sequence_item;

  `uvm_object_utils(tpl_tlm)
  
  rand bit [31:0] addr;
  
  //
  // NEW
  //
  function new(string name = "a");
    super.new(name);
  endfunction
  
  //
  // This function is called when the following code executes
  //   dst_obj.copy(src_obj)
  //
  function void do_copy(uvm_object rhs);
    tpl_tlm tmp;
    $cast(tmp,rhs);
    addr = tmp.addr;
  endfunction
  
  //
  // This function is called when the following code executes
  //   ref_obj.compare(act_obj)
  //
  function bit do_compare(uvm_object rhs,uvm_comparer comparer);
    tpl_tlm  der_type;
    do_compare = super.do_compare(rhs,comparer);
    $cast(der_type,rhs);
    do_compare &= (addr==der_type.addr);
  endfunction

  //
  // This function is called when the following code executes
  //   obj.print()
  //
  function void do_print(uvm_printer printer);
    super.do_print(printer);
    printer.print_field("addr",addr,$bits(addr));
  endfunction
  
endclass

//===================================================================================
// The producer component responsible for generating new packets
//===================================================================================
class producer extends uvm_component;

  `uvm_component_utils(producer)

  string my_name;  
  
  // This is a one to many connection port and is to be connected to both
  // consumer_1 and consumer_2
  uvm_analysis_port #(tpl_tlm) ap; 
  
  //
  // NEW
  //
  function new(string name, uvm_component parent);
    super.new(name,parent);
    my_name = name;
    ap = new("AP",this);
  endfunction
  
  //
  // BUILD phase
  //
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction
  
  //
  // RUN phase
  //
  task run_phase(uvm_phase phase);
    tpl_tlm an_obj;
    for (int i=0; i<2; i++) begin
      an_obj = tpl_tlm::type_id::create($psprintf("tpl_tlm_id_%0d",i));
      assert(an_obj.randomize());
      `uvm_info(my_name,$psprintf("Generating tpl_tlm_id_%0d addr=%x",i,an_obj.addr),UVM_NONE)

      // send packet to consumer_1 ap_imp_1 and consumer_2 ap_imp_2
      ap.write(an_obj);
    end
  endtask
  
endclass

//===================================================================================
// The consumer component responsible for receiving the packets from producer
//===================================================================================
class consumer_1 extends uvm_component;

  `uvm_component_utils(consumer_1)

  string my_name;  
  
  // This is to be connected to the producer ap
  uvm_analysis_imp #(tpl_tlm,consumer_1) ap_imp_1;
  
  //
  // NEW
  //
  function new(string name, uvm_component parent);
    super.new(name,parent);
    my_name = name;
    ap_imp_1 = new("AP_IMP_1",this);
  endfunction
  
  //
  // BUILD phase
  //
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction
  
	// 
  // When a packet arrives as a result of the ap.write(pkt), the write function is called and the pkt
  // is passed as the function argument
  //
  function void write(tpl_tlm an_obj);
    `uvm_info(my_name,$psprintf("received packet %s addr = %x",an_obj.get_name(),an_obj.addr),UVM_NONE)
  endfunction
  
endclass

//===================================================================================
// The consumer component responsible for receiving the packets from producer
//===================================================================================
class consumer_2 extends uvm_component;

  `uvm_component_utils(consumer_2)

  string my_name;  
  
  // This is to be connected to the producer ap
  uvm_analysis_imp #(tpl_tlm,consumer_2) ap_imp_2;
  
  //
  // NEW
  //
  function new(string name, uvm_component parent);
    super.new(name,parent);
    my_name = name;
    // Todo: Instantiate port ap_imp_2
  endfunction
  
	// 
  // When a packet arrives as a result of the ap.write(pkt), the write function is called and the pkt
  // is passed as the function argument
  //
  // Todo: implement the write method that prints out the name and addr of the received packet
  
endclass

//===================================================================================
// The environment layer
//===================================================================================
class env extends uvm_env;

  `uvm_component_utils(env)
  
  string my_name;  
  producer p0;
  consumer_1 c1;
  consumer_2 c2;
  
  //
  // NEW
  //
  function new(string name, uvm_component parent);
    super.new(name,parent);
    my_name = name;
  endfunction
  
  //
  // BUILD phase
  //
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    p0 = producer::type_id::create("producer_0",this);
    c1 = consumer_1::type_id::create("consumer_1",this);
    c2 = consumer_2::type_id::create("consumer_2",this);
  endfunction
  
  //
  // CONNECT phase
  //
  function void connect_phase(uvm_phase phase);
    p0.ap.connect(c1.ap_imp_1);
    //Todo: connect p0.ap port to c2.ap_imp_2
  endfunction
  
endclass

//===================================================================================
// The test layer
//===================================================================================
class demo_test extends uvm_test;

  `uvm_component_utils(demo_test)
  
  string my_name;
  env env0;
  
  //
  // NEW
  //
  function new(string name, uvm_component parent);
    super.new(name,parent);
    my_name = "demo_test";
  endfunction
  
  //
  // BUILD phase
  //
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env0 = env::type_id::create("ap_env",this);
  endfunction
  
  //
  // RUN phase
  //
  task run_phase(uvm_phase phase);
     
    // Raise the objection count by 1
    phase.raise_objection(this,"Objection raised by demo_test");

    #1;

    // Lower objection count by 1. Simulation finishes when reaching 0
    phase.drop_objection(this,"Objection dropped by demo_test");
  endtask
  
endclass

//===================================================================================
// TOP
//===================================================================================
module top;

  initial begin
    run_test("demo_test");
  end
    
endmodule

