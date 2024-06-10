module instruction_memory
  #(
    parameter N = 32,
    parameter A = 10,
    parameter SIZE = 1024 // 32kB
    )
   (
    input logic [A-1:0]  addr,
    output logic [N-1:0] data
    );

   wire [9:0]           addr_;

   assign addr_ = addr[9:0]/4;


   reg [31:0]           instMemory [0:SIZE-1];

   assign data = instMemory[addr_];

    initial begin
        $readmemh("/Users/akash/Documents/Scripts/Digital/risc-v/out/dump", instMemory);
        $display("foo");
    end


endmodule // instruction_memory
