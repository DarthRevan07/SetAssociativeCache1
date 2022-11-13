`timescale 1ns / 1ns
`include "Main_new.sv"

module Main_new_tb;

//reg hitmiss;
// reg [13:0] tagArrayInCache [7:0] [3:0];
// reg integer set;
// reg [4:0] tag;
// wire [4:0] tagout;
// reg [11:0] memoryAddress[100:0];
// reg [31:0] writeData[100:0];
// reg readEnable[100:0], writeEnable[100:0];
// integer i, enable;
// integer file, statusi;
// reg clk;
wire integer readhit, readmiss, writehit, writemiss;
Main_new uut();
initial begin
    $dumpfile("Main_new_tb.vcd");
    $dumpvars(0, Main_new_tb);
    #10;
end
endmodule