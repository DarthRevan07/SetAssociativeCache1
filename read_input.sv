module read_file;
reg [100:0] mem1[45:0];
reg [1:0] Cbits;
reg [11:0] word;
integer dataval;
integer i;
reg clk;

initial 
begin
    integer file;
    file = $fopenr("commands.txt");
    clk = 0;
end

always # 1 clk = ~clk;

initial begin 
    repeat (10) @ (posedge clk);
    while (!$feof(in)) begin
        @ (negedge clk);
        statusi = $fscanf(file, "%b %b %d\n", Cbits[1:0], word[11:0], dataval)
    end
    repeat (10) @ (posedge clk);
    $fclose(file);
    #100;
    $display(" CBITS ", Cbits)
    $display(" address", word)
    $display(" dataval", dataval)
end

endmodule
