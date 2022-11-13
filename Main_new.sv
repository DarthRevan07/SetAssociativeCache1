module Main_new
#(
    parameter n=7,//tagsize=total number of bits-number of offset bits-number of index bits+2(valid+dirty)
    parameter numberOfSets=8,
    bitsForSet=3,
    numberOfWays=4,
    blockSize=16,
    offsetBits=4,
    numberOfBlocksInMemory=256,
    totalBitForAddress=12,
    linecount = 524
);
reg [27:0] memoryAddress;
reg [13:0] writeData;
reg readEnable,writeEnable;

// n=6;
reg[n-1:0] tagArrayInCache [numberOfSets-1:0][numberOfWays-1:0]; //n-1 bits for address + 1 dirty bit(5) + 1 valid bit(6)
// 8 rows for sets 4 columns for ways 
integer dataInCache [numberOfSets-1:0] [numberOfWays-1:0] [blockSize-1:0];
// 8 rows for sets 4 columns for ways and 16 for block size, so 16 bytes(integer)
integer Memory[numberOfBlocksInMemory-1:0] [blockSize-1:0];
// 4096 bytes of memory, each block is of size 16 bytes.
integer counter[numberOfSets-1:0][numberOfWays-1:0];
reg hitmiss;

// reg [11:0] memoryAddress=12'b000000100010;//Memory[2][2]
// Memory[2][2]=14;
// integer writeData;
reg[(n-2)-1:0] tagNumber;
// tagNumber=memoryAddress [11:7];
reg[(n-2)-1:0] hittag;
reg[n-1:0] temp;
integer set_number;
integer offset,way_number;
integer blockNumberInMemory;
integer missmaxcount;
integer addressToMemory;
integer empty;
integer data;
integer position;
integer readmiss;
integer readhit;
integer writehit;
integer writemiss;
integer way_number_temp;
integer hitrate;
integer file;
integer statusi;
//setting initial values
initial begin
    readmiss=0;
    readhit=0;
    writehit=0;
    writemiss=0;
    file = $fopen("res1.txt", "r");
    for(integer i=0; i<numberOfSets; i=i+1) begin
        for(integer j=0; j<numberOfWays;j++) begin
            tagArrayInCache[i][j]=0;
            counter[i][j]=0;
            for(integer k=0;k<blockSize;k=k+1)begin
                dataInCache[i][j][k]=0;
            end
        end
    end
    for(integer i=0; i<numberOfBlocksInMemory; i=i+1) begin
        for(integer j=0; j<blockSize;j++) begin
            Memory[i][j] = 0;
        end
    end
end
always @* begin
    

//taking input(incompolete)...............................................................................................................
// reg readEnable=1'b1;
// reg writeEnable=1'b0;
// reg [11:0] memoryAddress=12'b000000100010;//Memory[2][2]
// Memory[2][2]=14;
// integer writeData;
//........................................................................................................................................
for (integer z = 0; z<linecount; z = z + 1 ) begin

    statusi = $fscanf(file, "%b%b%b \n", memoryAddress[27:0], writeData[13:0], readEnable);
    writeEnable = ~readEnable;
//checking hit miss
// reg[4:0] tagNumber;
tagNumber=memoryAddress [totalBitForAddress-1:offsetBits+bitsForSet];
// reg[4:0] hittag;
set_number=memoryAddress[offsetBits+bitsForSet-1:offsetBits];
// integer offset,way_number;
blockNumberInMemory=memoryAddress[totalBitForAddress-1:offsetBits];

hitmiss=1'b0;  
empty=-1;
for(integer i=numberOfWays-1;i>=0;i=i-1) begin
  if(tagNumber==tagArrayInCache[set_number][i] [(n-2)-1:0] && tagArrayInCache[set_number][i] [n-1]==1'b1) begin
    hitmiss=1'b1;
    hittag=tagArrayInCache[set_number][i];//may be redundant
    way_number=i;
    way_number_temp=i;
  end
  if(tagArrayInCache[set_number][i][n-1]==1'b0) begin
    empty=i;
  end
end
//hit miss complete
for(integer i=0;i<numberOfWays;i=i+1) begin
    counter[set_number][i]=counter[set_number][i]+1;
end
offset=memoryAddress[offsetBits-1:0];

if(hitmiss==1'b1) begin//for hit
    if(readEnable==1'b1) begin
        data = dataInCache[set_number][way_number][offset];
        readhit=readhit+1;
        
    end
    if(writeEnable==1'b1) begin
        dataInCache[set_number][way_number][offset]=writeData;
        tagArrayInCache[set_number][way_number] [n-2]=1'b1;//setting dirty bit to 1
        data = dataInCache[set_number][way_number][offset];
        writehit=writehit+1;
    end
    counter[set_number][way_number]=0;
end

else begin//for miss
    //first we check if any block is empty
    way_number=empty;
    if(empty<0) begin
            //in this case, we will replace a block
            // integer position;
        missmaxcount=-1;
        for(integer i=0;i<numberOfWays;i=i+1) begin
            if(missmaxcount<counter[set_number][i])begin
                missmaxcount=counter[set_number][i];
                way_number=i;
            end
        end
        temp=tagArrayInCache[set_number][way_number]; 
        //check if the bit at postion 5 is 1
        if(temp[n-2]==1'b1) begin //dirty bit is set
            addressToMemory=(temp[(n-2)-1:0])*numberOfSets+set_number; //convert 11-4 bit of previous address(stored in tag) to integer
            for(integer i=0;i<blockSize;i=i+1)begin
                Memory[addressToMemory][i]=dataInCache[set_number][way_number][i];//update in memory
            end
        end
    end
    for(integer i=0;i<blockSize;i=i+1)begin
        dataInCache[set_number][way_number][i]=Memory[blockNumberInMemory][i];
    end
    tagArrayInCache[set_number][way_number][n-1]=1'b1;//setting validbit
    tagArrayInCache[set_number][way_number][n-2]=1'b0;//setting dirty bit
    tagArrayInCache[set_number][way_number][(n-2)-1:0]=memoryAddress[totalBitForAddress-1:offsetBits+bitsForSet];//setting tag in cache                
    if(writeEnable==1'b1)begin//for write
        dataInCache[set_number][way_number][offset]=writeData;
        tagArrayInCache[set_number][way_number][n-2]=1'b1;//setting dirty bit
        data = dataInCache[set_number][way_number][offset];
        writemiss=writemiss+1;
    end
    if(readEnable==1'b1) begin//for read
        data=dataInCache[set_number][way_number][offset];
        readmiss=readmiss+1;
    end
    for(integer i=0;i<numberOfWays;i=i+1)begin
        counter[set_number][i]=counter[set_number][i]+1;
    end
    counter[set_number][way_number]=0;
    
        // way_number=postion;        
        
end
end
$fclose(file);
hitrate = (readhit + writehit)*100/(readhit + writehit + readmiss + writemiss);
$display("Hitrate: ", hitrate, "%");
end
endmodule