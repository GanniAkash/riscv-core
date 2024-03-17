module instruction_memory
  #(
    parameter N = 32,
    parameter A = 32,
    parameter SIZE = 32768 // 32kB
    )
   (
    input logic [A-1:0]  addr,
    output logic [N-1:0] data
    );

   reg [N-1:0]           memory [0:SIZE-1];


   assign data = memory[addr];


endmodule // instruction_memory
