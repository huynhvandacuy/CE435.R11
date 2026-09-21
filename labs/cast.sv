//============================================================================================================================
// Casting lab
// Steps to compile and run:
// Siemens:
//   vlog cast.sv
//   vsim -c top -do "run -a; quit"
//
// Cadence:
//   xrun -c -uvm cast.sv
//   xrun -uvm -top worklib.top
//============================================================================================================================

module top;
  typedef struct packed {
    bit [31:0] addr;
    bit [31:0] data;
  } pkt_t;

  typedef struct packed {
    bit [2:0] opcode;
    bit       wr_rd;
    bit [2:0] priv;
  } inst_t;

  pkt_t pkt;
  bit [63:0] vec;
  bit [6:0]  inst;

  //
  // This task casts the input vector into struct inst_t, then prints the struct content
  //
  task print_fields(bit [6:0] vec);
    // Todo: Complete this task

    // Declare inst_t avariable named inst_pkt here

    // Cast vec into inst_pkt

    // Print vec, opcode, wr_rd, and priv
  endtask
  
  //
  // initial block
  //
  initial begin
    vec = {32'h00010111,32'h00010000};
    pkt = pkt_t'(vec); // casting vec into pkt
    $display("%x",pkt.addr);

    for (int ii=0; ii<5; ii++) begin
      inst = $urandom();
      print_fields(inst);
    end
  end
    
endmodule
  
