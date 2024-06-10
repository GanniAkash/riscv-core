
module data_memory
  #(
    parameter N = 32,
    parameter A = 10,
    parameter SIZE = 1024 //16kB
    )
   (
    input logic          clk, we, rst,
    input logic [A-1:0]  addr,
    input logic [N-1:0]  data,
    output logic [N-1:0] rdata
    );

   reg [31:0]             memory [0:SIZE-1];

   wire [9:0]           addr_;

   assign addr_ = addr[9:0]/4;

   always_ff @(posedge clk or posedge rst) begin
      if (rst) begin
      end
      if (we) begin
         // memory[addr_] <= data[7:0];
         // memory[addr_+1] <= data[15:8];
         // memory[addr_+2] <= data[23:16];
         // memory[addr_+3] <= data[31:24];
         memory[addr_] <= data;
      end
   end

   // assign rdata = {memory[addr_+3], memory[addr_+2], memory[addr_+1], memory[addr_]};
   assign rdata = memory[addr_];

endmodule // data_memory
