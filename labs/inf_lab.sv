`timescale 1ns / 10ps
//===================================================================================
// This lab requires the student to complete the following tasks:
// - Create a task do_reset inside the interface module
// - Create a clock generator inside the interface module
// - Create an interface instance inside top
// - Call task do_reset inside top
//
// Compile and run the lab:
// ========================
// Siemens:
// vlog inf_lab.sv
// vsim -c top -do "run -a; quit"
// Cadence:
// xrun -c -uvm inf_lab.sv
// xrun -uvm -top worklib.top
//===================================================================================

import uvm_pkg::*;

`include "uvm_macros.svh"
//============================================================================================================================
// Clock Reset interface
//============================================================================================================================
interface clk_rst_if (output logic clk, output logic rst);

  // This task will assert rst for num number of clocks
  task do_reset (integer num);
    `uvm_info("clk_rst_if","Asserting reset",UVM_NONE)
	  //Todo: Complete task named do_reset(interger num)
    `uvm_info("clk_rst_if","Deasserting reset",UVM_NONE)
  endtask
                  
	// Wait for num clocks
  task do_wait (integer num);
    repeat (num) @(posedge clk);
  endtask
                  
	//Todo: Create a clock generator with period of 20ps
  // Note the default time unit is 1ps
	initial begin
	end 

endinterface

//===================================================================================
// TOP
//===================================================================================
module top;

  wire   clk;
  wire   rst;
   
  //Todo: Create an interface instance

  initial begin
    //Todo: Call do_reset for 5 clocks
    #2us;
    $finish;
  end
    
endmodule
