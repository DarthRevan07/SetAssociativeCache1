module TagCompare
(
    input reg[13:0] tagArrayInCache [7:0] [3:0],
    input reg[2:0] set,
    input reg[11:0] memoryAddress,
    output reg hitmiss, //1 for hit, 0 for miss 
    output reg [1:0] way,
);




