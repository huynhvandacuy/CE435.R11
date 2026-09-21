//============================================================================================================================
// fork/join_none lab
// Steps to compile and run:
// Siemens:
//   vlog fork_join_none.sv
//   vsim -c top -do "run -a; quit"
//
// Cadence:
//   xrun -c -uvm fork_join_none.sv
//   xrun -uvm -top worklib.top
//============================================================================================================================
module top;

  bit clk;
  bit [15:0] counter;
  bit [2:0] incr;
  bit reset;

  //
  // Clock generator
  //
  initial begin
    clk = 0;
    counter = 0;
    incr = 2;
    forever begin
      #20ns clk = ~clk;
    end
  end

  //
  // Verify that reset is asserted after 3 clocks
  //
  task check_reset;
    repeat (3) @(posedge clk);
    if (reset == 1) begin
      $display("PASSED");
    end else begin
      $display("FAILED");
    end
  endtask

  //
  // Print counter values. When the counter reaches 16, call check_reset
  //
  function void print_counter;
    $display("counter = %0d",counter);
    // Todo: complete the code that does the following
    // When the counter reaches 16, use the fork/join_none construct 
    // to call task check_reset
  endfunction

  //
  // Increment counter by incr
  //
  always @(negedge clk) begin
    counter <= counter + incr;
  end

  //
  // When counter reaches 16, assert reset to 1 for 1 clock
  //
  always @(posedge clk) begin
    if (counter == 16'h10) begin
      repeat (2) @(negedge clk);
      reset = 1;
      repeat (1) @(negedge clk);
      reset = 0;
      repeat (4) @(negedge clk);
      $finish;
    end
  end

  //
  // Each time counter changes, call print_counter
  //
  always @(counter) begin
    print_counter;
  end

endmodule
  
