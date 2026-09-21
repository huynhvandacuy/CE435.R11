//============================================================================================================================
// This lab demonstrates how an object can be copied or compared against another object using do_copy and do_compare
// Steps to compile and run:
// Siemens:
//   vlog trans.sv
//   vsim -c top -do "run -a, quit"
//
// Cadence:
//   xrun -c -uvm trans.sv
//   xrun -uvm -top worklib.top
//============================================================================================================================

import uvm_pkg::*;

`include "uvm_macros.svh"

typedef enum {INT, IO, FLOAT, LDST} inst_t;

//============================================================================================================================
// Transaction class
//============================================================================================================================
class packet extends uvm_sequence_item;

  `uvm_object_utils(packet)
  
  string    my_name;
  rand bit [7:0] opcode;
  rand inst_t    itype;
  
  //
  // NEW
  //
  function new(string name = "packet");
    super.new(name);
    my_name = name;
  endfunction

	// ===================================================
  // This function returns the string representation of
  // the inst_t
	// ===================================================
  function string get_itype(inst_t it);
    case (it)
      INT: return "INT";
      IO : return "IO";
      LDST: return "LDST";
      FLOAT: return "FLOAT";
      default: return "NOOP";
    endcase
  endfunction

	// ===================================================
	// This function is invoked in the following scenario:
	// des_obj.copy(src_obj);
	// ===================================================
	function void do_copy(uvm_object rhs);
		packet der_type;
		super.do_copy(rhs);
		$cast(der_type,rhs);
    // When performing a copy operation, we make a change in the opcode field.
    // This results in an opcode mismatch when we compare the original object
    // and its copy
		// Todo: assign der_type.opcode to opcode
    itype    = der_type.itype;
	endfunction

	// ===================================================
	// This function is invoked in the following scenario:
	// des_obj.compare(src_obj);
	// ===================================================
	virtual function bit do_compare(uvm_object rhs, uvm_comparer comparer);
		packet der_type;
		do_compare = super.do_compare(rhs,comparer);
		$cast(der_type,rhs);
		do_compare &= comparer.compare_field_int("opcode",opcode,der_type.opcode,8);
	endfunction

	// ===================================================
	// This function is invoked in the following scenario:
	// obj.print()
	// ===================================================
  function void do_print(uvm_printer printer);
    super.do_print(printer);
    printer.print_field("opcode",opcode,$bits(opcode));
    printer.print_string("inst type",get_itype(itype));
  endfunction

  //
  // Constraint block
  //
	constraint packet_c {
	}
   
endclass

//============================================================================================================================
// Test layer
//============================================================================================================================
class demo_test extends uvm_test;

  `uvm_component_utils(demo_test)
  
  string my_name;
  
  //
  // NEW
  //
  function new(string name, uvm_component parent);
    super.new(name,parent);
    my_name = name;
  endfunction
  
  //
  // RUN phase
  //
  task run_phase(uvm_phase phase);
    packet pkt;
    packet dup_pkt;

    // Raise the objection count by 1
		phase.raise_objection(this,"Objection raised by demo_test");

    for (int ii=0; ii<2; ii++) begin
      // Create an instance of pkt
      pkt = packet::type_id::create($psprintf("pkt_id_%0d",ii+1)); // Create the pkt
      // Create an instance of dup_pkt
      dup_pkt = packet::type_id::create($psprintf("dup_pkt_id_%0d",ii+1)); // Create the dup_pkt
      // Randomize pkt
      assert(pkt.randomize());
      // Todo: copy pkt into dup_pkt using dst_obj.copy(src_obj)
      // Print pkt
      pkt.print();
      // Print dup_pkt
      dup_pkt.print();
      // Todo: compare dup_pkt against pkt using dst_obj.compare(src_obj)
      // The compare function returns 1 if data matches in do_compare
      // If the comparison passes, print the following message
      //   `uvm_info(my_name,"Packets matched",UVM_NONE)
      // If the comparison fails, print the following error message
      //   `uvm_error(my_name,"Packets did not match")
    end

    // Lower objection count by 1. Simulation finishes when reaching 0
		phase.drop_objection(this,"Objection dropped by demo_test");
  endtask
  
endclass

//============================================================================================================================
// TOP
//============================================================================================================================
module top;

  initial begin
    // Run test
    run_test("demo_test");
  end

endmodule


