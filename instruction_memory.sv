module instruction_memory
  #(
    parameter N = 32,
    parameter A = 32,
    parameter SIZE = 32768*4 // 32kB
    )
   (
    input logic [A-1:0]  addr,
    output logic [N-1:0] data
    );

   wire [16:0]           addr_;

   assign addr_ = addr[16:0];


   reg [7:0]           memory [0:SIZE-1];


   assign data = {memory[addr_+3], memory[addr_+2], memory[addr_+1], memory[addr_]};


endmodule // instruction_memory
