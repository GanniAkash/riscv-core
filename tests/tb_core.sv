`timescale 1ns / 1ps
`include "core.sv"

module tb_core;
   logic clk, rst;

   core core (
              .clk(clk),
              .rst(rst)
              );

   logic [31:0] addr_;
   logic [31:0] word;
   reg [31:0]   file;

   task read_file;
      addr_ = 4;
      file = $fopen("out/dump", "r");
      if (file == 0) begin
         $display("Error opening the file");
         $stop;
      end

      while(!$feof(file)) begin
         $fscanf(file, "%h", word);
         core.inst_mem.memory[addr_] = word;
         addr_ = addr_ + 4;
      end
      memory[addr_-4] = 32'bx;
      $fclose(file);
   endtask // read_file

   initial begin
      read_file;
   end


   initial begin
      $dumpfile("out/output.vcd");
      $dumpvars(0, tb_core);
      rst = 1'b1;
      #5
        rst = 1'b0;
      clk = 0;
      #200;
      $finish;
   end

   always #15 clk = ~clk;
endmodule; // tb_core
