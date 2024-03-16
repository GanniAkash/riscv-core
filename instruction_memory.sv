module instruction_memory
  #(
    parameter N = 32,
    parameter A = 32,
    parameter SIZE = 2**32 // 4GB
    )
   (
    input logic [A-1:0]  addr,
    output logic [N-1:0] data
    );

   reg [N-1:0]           memory [SIZE-1];
   logic [31:0]          addr_;
   logic [31:0]          word;
   reg [31:0]            file;


   assign data = memory[addr];

   task read_file;
      addr_ = 0;
      file = $fopen("out/dump", "r");
      if (file == 0) begin
         $display("Error opening the file");
         $stop;
      end

      while(!$feof(file)) begin
         $fscanf(file, "%h", word);
         memory[addr_] = word;
         addr_ = addr_ + 4;
      end
      $fclose(file);
   endtask // read_file

   initial begin
      read_file;
   end

endmodule; // instruction_memory
