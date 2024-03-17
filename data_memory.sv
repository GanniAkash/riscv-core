module data_memory
  #(
    parameter N = 32,
    parameter A = 32,
    parameter SIZE = 4096 //4kB
    )
   (
    input logic          clk, we, rst,
    input logic [A-1:0]  addr,
    input logic [N-1:0]  data,
    output logic [N-1:0] rdata
    );

   reg [N-1:0]           memory [0:SIZE-1];

   always_ff @(posedge clk or posedge rst) begin
      if (rst) begin
      end
      if (we) begin
         memory[addr] <= data;
      end
   end

   assign rdata = memory[addr];

endmodule // data_memory
