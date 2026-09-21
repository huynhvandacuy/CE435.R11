//=============================================================
// Siemens:
// vlog sv_queue.sv
// vsim -c top -do "run -a, quit"
// Cadence:
// xrun -c -uvm sv_queue.sv
// xrun -uvm -top worklib.top
//=============================================================
//
// This lab is used to demonstrate how a FIFO is implemented using SV queues
//
class env;

  integer aqueue[$];

  function void push_fifo(integer ii);
    // todo: push data into the FIFO
  endfunction
		
  function integer pop_fifo;
    // todo: pop and return the data from the FIFO
  endfunction
		
	function void print_queue;
		// Use aqueue.size() for your loop 
    // todo: call pop and print the FIFO
	endfunction
	
endclass

module top;
	env env0;
	
  initial begin
		env0 = new;
    for (int ii=0; ii<10; ii++) begin
      env0.push_fifo(ii);
    end
		env0.print_queue();
	end
		
endmodule
