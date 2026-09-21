//============================================================================================================================
//
// vlog config.sv
// vsim -c top +UVM_TESTNAME=default_test -do "run -a; quit"
// vsim -c top +UVM_TESTNAME=derived_test -do "run -a; quit"
// Cadence:
// xrun -c -uvm config.sv
// xrun -uvm -top worklib.top +UVM_TESTNAME=default_test
// xrun -uvm -top worklib.top +UVM_TESTNAME=derived_test
//
// This example shows how a configuration object is used to influence a test scenario
//
//============================================================================================================================

import uvm_pkg::*;

`include "uvm_macros.svh"

//============================================================================================================================
// Transaction class
//============================================================================================================================
class packet extends uvm_sequence_item;

  `uvm_object_utils(packet)
  
  string  my_name;
  
  rand int   addr;
  rand int   data;
  rand int   mode;
  
  //
  // NEW
  //
  function new(string name = "packet");
    super.new(name);
    my_name = name;
  endfunction
   
  //
  // PRINT
  //
  function void do_print(uvm_printer printer);
    super.do_print(printer);
    printer.print_field("addr",addr,$bits(addr));
    printer.print_field("data",data,$bits(data));
  endfunction

  // 
  // CONSTRAINT
  //
  constraint default_c {
    soft mode == 0;
    (mode == 0) -> { addr inside {[32'h100:32'h200]} };
    (mode == 1) -> { addr inside {[32'h2000:32'h4000]} };
  };
   
endclass

//============================================================================================================================
// Configuration class
//============================================================================================================================
class tst_cfg extends uvm_object;
  `uvm_object_utils(tst_cfg)

  string  my_name;
	rand int num_loops;
	rand int mode;

  //
  // NEW
  //
  function new(string name = "tst_cfg");
    super.new(name);
    my_name = name;
  endfunction
  
  //
  // CONSTRAINT
  //
	constraint tst_cfg_c {
		soft num_loops inside {[2:4]};
    soft mode == 0;
	}

endclass

//============================================================================================================================
// Environment layer
//============================================================================================================================
class env extends uvm_env;

  `uvm_component_utils(env)
  
  string  my_name;
	tst_cfg tb_cfg;
  
  //
  // NEW
  //
  function new(string name, uvm_component parent);
    super.new(name,parent);
    my_name = name;
  endfunction
  
  //
  // RUN
  //
  task run();
    packet pkt;
	  int loc_num_loops;

    // Retrieve the handle to the configuration object
		if( !uvm_config_db#(tst_cfg)::get(this,"","tb_cfg",tb_cfg) ) begin
			`uvm_error(my_name,"Could not get tb_cfg")
		end
    // Get the num_loops
		loc_num_loops = tb_cfg.num_loops;
    
    // Generate a new packet and print num_loops times
		for (int ii=0; ii<loc_num_loops; ii++) begin
  		// Create an instance of packet
      pkt = packet::type_id::create($psprintf("pkt%0d",ii));
      // Randomize the packet based on the value of mode
			assert(pkt.randomize() with {mode == tb_cfg.mode;});
      // Print the packet
      `uvm_info(my_name,$psprintf("Printing packet pkt%0d",ii),UVM_NONE)
      pkt.print();
		end

  endtask

endclass

//============================================================================================================================
// Base test
// This base test main purpose is to create the environment. It also creates a configuration object and places it in the
// resource database. Any derived test then can manipulate the configuration for a specific test scenario.
//============================================================================================================================
class base_test extends uvm_test;

  string my_name;

	env env0;
	tst_cfg tb_cfg;
	
  //
  // NEW
  //
	function new(string name, uvm_component parent);
		super.new(name,parent);
		my_name = name;
	endfunction
  
  //
  // BUILD
  //
  function void build;
    // Create the environment
    env0 = env::type_id::create("env0",this);
    // Create the configuration object
    tb_cfg = tst_cfg::type_id::create("tb_cfg");
  endfunction
  
  //
  // CONNECT
  //
  function void connect;
    // Randomize tb_cfg: num_loops
		assert(tb_cfg.randomize());
    `uvm_info(my_name,$psprintf("num_loops = %0d",tb_cfg.num_loops),UVM_NONE)
    // Place the tb_cfg handle in the resource database
		uvm_config_db#(tst_cfg)::set(this,"*","tb_cfg",tb_cfg);
	endfunction

endclass

//============================================================================================================================
// Default test 
//============================================================================================================================
class default_test extends base_test;

	`uvm_component_utils(default_test)
	
	string my_name;
	
  //
  // NEW
  //
	function new(string name, uvm_component parent);
		super.new(name,parent);
		my_name = name;
	endfunction
  
  //
  // CONNECT
  //
  function void connect;
    super.connect();
	endfunction

  //
  // RUN
  //
  task run_phase(uvm_phase phase);
    // Raise the objection count by 1
    phase.raise_objection(this,"Objection raised by demo_test");

    #10ns;

    // Lower objection count by 1. Simulation finishes when reaching 0
    phase.drop_objection(this,"Objection dropped by demo_test");
  endtask
	
endclass

//============================================================================================================================
// Derived test 
//============================================================================================================================
class derived_test extends default_test;

	`uvm_component_utils(derived_test)
	
	string my_name;
	
  //
  // NEW
  //
	function new(string name, uvm_component parent);
		super.new(name,parent);
		my_name = name;
	endfunction
  
  //
  // CONNECT
  //
  function void connect;
    super.connect();
    `uvm_info(my_name,"Assign num_loops to 1",UVM_NONE)
    // Todo: for this test case, we want to override the following in tb_cfg:
    // num_loops = 1
    // mode == 1
	endfunction

endclass

//============================================================================================================================
// TOP
//============================================================================================================================
module top;

  initial begin
    run_test();
  end

endmodule
