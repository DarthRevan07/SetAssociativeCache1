module readModule
#(
    input Memory[255:0][15:0];
    input hitmiss;
);

//for read


if(hitmiss==1'b1) begin
    integer a=//convert bit 6-4 to decimal
    integer b=//convert way to decimal
    integer c=//convert offset to decimal 
    data <= dataInCache[a][b][c];
end

else begin
    //in this case, we will replace a block
    //checking if dirty bit is 1
    integer a=//convert bit 6-4 to decimal
    integer b=//convert way to decimal
    reg[6:0] temp=tagArrayInCache[a][b]; 
    //check if the bit at postion 5 is 1
    if(temp[5]==1'b1) begin //dirty bit is set
        integer a=//convert bit 6-4 to decimal
        integer b=//convert way to decimal
        integer addressToMemory= //convert 11-4 bit of previous address(stored in tag) to integer
        for(integer i=0;i<16;i++){
            Memory[addressToMemory][i]=dataInCache[a][position][i];//update in memory
        }
    end
    integer addressFromMemory=// convert 11-4 bit of current tag(where we need to read from)
    for(integer i=0;i<16;i++){
        dataInCache[a][position][i]=Memory[addressFromMemory][i];
    }
end
endmodule
    

