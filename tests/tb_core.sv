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

   time         runTime = 0;
   integer      co = 0;

   task read_file;
      file = $fopen("out/dump", "r");
      if (file == 0) begin
         $display("Error opening the file");
         $stop;
      end

      while(!$feof(file)) begin
         $fscanf(file, "%h %h", addr_, word);
         core.inst_mem.memory[addr_] = word[7:0];
         core.inst_mem.memory[addr_+1] = word[15:8];
         core.inst_mem.memory[addr_+2] = word[23:16];
         core.inst_mem.memory[addr_+3] = word[31:24];
         runTime = runTime + 30;
         co = co + 1;
      end
      $fclose(file);
      runTime = runTime + 60;
   endtask // read_file

   initial begin
      read_file;
   end

   initial begin
      $dumpfile("out/output.vcd");
      $monitor("%h", core.regs.x2);
      $dumpvars(0, tb_core);
      rst = 1'b1;
      #1
        rst = 1'b0;
      clk = 0;

      while (core.regs.x2 != 1234 || core.regs.x3 != 69)  begin
         #2 clk = ~clk;
      end

      $finish;
   end // initial begin

   initial begin
      #500000;
      $finish;
   end

endmodule; // tb_core
