module Main(
    output integer readhit,readmiss,writehit,writemiss
);

reg[6:0] tagArrayInCache [7:0][3:0]; //5 bits for address + 1 dirty bit(5) + 1 valid bit(6)
// 8 rows for sets 4 columns for ways 
integer dataInCache [7:0] [3:0] [15:0];
// 8 rows for sets 4 columns for ways and 16 for block size, so 16 bytes(integer)
integer Memory[255:0] [15:0];
// 4096 bytes of memory, each block is of size 16 bytes.
integer counter[7:0][3:0];
reg hitmiss;
reg [11:0] memoryAddress;
reg [31:0] writeData;
reg readEnable, writeEnable;
// reg [11:0] memoryAddress=12'b000000100010;//Memory[2][2]
// Memory[2][2]=14;
// integer writeData;
reg[4:0] tagNumber;
// tagNumber=memoryAddress [11:7];
reg[4:0] hittag;
reg[6:0] temp;
integer set_number;
integer statusi;
integer z;
integer offset,way_number;
integer blockNumberInMemory;
integer missmaxcount;
integer addressToMemory;
integer empty;
integer data;
integer position;
// integer readmiss;
// integer readhit;
// integer writehit;
// integer writemiss;
integer way_number_temp;
integer file;
reg integer hitrate;


//setting initial values
initial begin
    readmiss=0;
    readhit=0;
    writehit=0;
    writemiss=0;
    file = $fopen("result.txt", "r");
    for(integer i=0; i<8; i=i+1) begin
        for(integer j=0; j<4;j++) begin
            tagArrayInCache[i][j]=7'b0;
            counter[i][j]=0;
            for(integer k=0;k<16;k=k+1)begin
                dataInCache[i][j][k]=0;
            end
        end
    end
    for(integer i=0; i<256; i=i+1) begin
        for(integer j=0; j<16;j++) begin
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

//checking hit miss
// reg[4:0] tagNumber;
for (integer z = 0; z<1000; z = z + 1 ) begin

    statusi = $fscanf(file, "%b%b%b \n", memoryAddress[11:0], writeData[15:0], readEnable);
    writeEnable = ~readEnable;
tagNumber=memoryAddress [11:7];
// reg[4:0] hittag;
set_number=memoryAddress[6]*4+memoryAddress[5]*2+memoryAddress[4];
// integer offset,way_number;
blockNumberInMemory=memoryAddress[11]*128+memoryAddress[10]*64+memoryAddress[9]*32+memoryAddress[8]*16+memoryAddress[7]*8+memoryAddress[6]*4+memoryAddress[5]*2+memoryAddress[4];

hitmiss=1'b0;  
empty=-1;
for(integer i=3;i>=0;i=i-1) begin
  if(tagNumber==tagArrayInCache[set_number][i] [4:0] && tagArrayInCache[set_number][i] [6]==1'b1) begin
    hitmiss=1'b1;
    hittag=tagArrayInCache[set_number][i];//may be redundant
    way_number=i;
    way_number_temp=i;
  end
  if(tagArrayInCache[set_number][i][6]==1'b0) begin
    empty=i;
  end
end
//hit miss complete
for(integer i=0;i<4;i=i+1) begin
    counter[set_number][i]=counter[set_number][i]+1;
end
offset=memoryAddress[3]*8+memoryAddress[2]*4+memoryAddress[1]*2+memoryAddress[0];

if(hitmiss==1'b1) begin//for hit
    if(readEnable==1'b1) begin
        data = dataInCache[set_number][way_number][offset];
        readhit=readhit+1;
        
    end
    if(writeEnable==1'b1) begin
        dataInCache[set_number][way_number][offset]=writeData;
        tagArrayInCache[set_number][way_number] [5]=1'b1;//setting dirty bit to 1
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
        for(integer i=0;i<=3;i=i+1) begin
            if(missmaxcount<counter[set_number][i])begin
                missmaxcount=counter[set_number][i];
                way_number=i;
            end
        end
        temp=tagArrayInCache[set_number][way_number]; 
        //check if the bit at postion 5 is 1
        if(temp[5]==1'b1) begin //dirty bit is set
            addressToMemory=temp[4]*128+temp[3]*64+temp[2]*32+temp[1]*16+temp[0]*8+set_number; //convert 11-4 bit of previous address(stored in tag) to integer
            for(integer i=0;i<16;i=i+1)begin
                Memory[addressToMemory][i]=dataInCache[set_number][way_number][i];//update in memory
            end
        end
    end
    for(integer i=0;i<16;i=i+1)begin
        dataInCache[set_number][way_number][i]=Memory[blockNumberInMemory][i];
    end
    tagArrayInCache[set_number][way_number][6]=1'b1;//setting validbit
    tagArrayInCache[set_number][way_number][5]=1'b0;//setting dirty bit
    tagArrayInCache[set_number][way_number][4:0]=memoryAddress[11:7];//setting tag in cache                
    if(writeEnable==1'b1)begin//for write
        dataInCache[set_number][way_number][offset]=writeData;
        tagArrayInCache[set_number][way_number][5]=1'b1;//setting dirty bit
        data = dataInCache[set_number][way_number][offset];
        writemiss=writemiss+1;
    end
    if(readEnable==1'b1) begin//for read
        data=dataInCache[set_number][way_number][offset];
        readmiss=readmiss+1;
    end
    for(integer i=0;i<4;i=i+1)begin
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