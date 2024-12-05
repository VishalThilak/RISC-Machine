module datapath_tb();
reg clk, loada, loadb, asel, bsel, loadc, loads, write, err;
reg [2:0] readnum, writenum;
reg [1:0] shift, ALUop;
reg [3:0] vsel;
reg [15:0] mdata, sximm8, sximm5;
reg [7:0] PC;

wire Z_out, N, V;
wire [15:0] datapath_out;

datapath DUT(clk, readnum, vsel, loada, loadb, shift, asel, bsel, ALUop, loadc, loads, writenum, write, mdata,sximm8, PC, sximm5, Z_out,N, V, datapath_out);

initial begin
    clk = 1'b0; #5; err = 1'b0;

    forever begin
        clk = 1'b1; #5;
        clk = 1'b0; #5;
    end
end

initial begin

    //Mov operation with immediate value check for each register
    #10;
    vsel=4'b1000; writenum = 3'b000; write = 1'b1; mdata = 16'b 0000_0000_0000_0001;

    repeat(7) begin
    #10;
    //increments data_in and writenum by 1 each time
    writenum = writenum + 3'b001; mdata = mdata + 16'b 0000_0000_0000_0001;
    end
    
    //checking if R0 equals 1
    if(DUT.REGFILE.R0 !=  16'b 0000_0000_0000_0001)begin
            $display("ERROR ** output is %b, expected %b", DUT.REGFILE.R0 , 16'b 0000_0000_0000_0001);
            err = 1'b1;
    end
    
    //checking if R1 equals 2
    if(DUT.REGFILE.R1 !=  16'b 0000_0000_0000_0010)begin
            $display("ERROR ** output is %b, expected %b", DUT.REGFILE.R1 , 16'b 0000_0000_0000_0010);
            err = 1'b1;
    end

    //checking if R2 equals 3
    if(DUT.REGFILE.R2 !=  16'b 0000_0000_0000_0011)begin
            $display("ERROR ** output is %b, expected %b", DUT.REGFILE.R2 , 16'b 0000_0000_0000_0011);
            err = 1'b1;
    end

    //checking if R3 equals 4
    if(DUT.REGFILE.R3 !=  16'b 0000_0000_0000_0100)begin
            $display("ERROR ** output is %b, expected %b", DUT.REGFILE.R3 , 16'b 0000_0000_0000_0100);
            err = 1'b1;
    end

    //checking if R4 equals 5
    if(DUT.REGFILE.R4 !=  16'b 0000_0000_0000_0101)begin
            $display("ERROR ** output is %b, expected %b", DUT.REGFILE.R4 , 16'b 0000_0000_0000_0101);
            err = 1'b1;
    end

    //checking if R5 equals 6
    if(DUT.REGFILE.R5 != 16'b 0000_0000_0000_0110)begin
            $display("ERROR ** output is %b, expected %b", DUT.REGFILE.R5 , 16'b 0000_0000_0000_0110);
            err = 1'b1;
    end

    //checking if R6 equals 7
    if(DUT.REGFILE.R6 !=  16'b 0000_0000_0000_0111)begin
            $display("ERROR ** output is %b, expected %b", DUT.REGFILE.R6 , 16'b 0000_0000_0000_0111);
            err = 1'b1;
    end

    //checking if R7 equals 8
    if(DUT.REGFILE.R7 !=  16'b 0000_0000_0000_1000)begin
            $display("ERROR ** output is %b, expected %b", DUT.REGFILE.R7 , 16'b 0000_0000_0000_1000);
            err = 1'b1;
    end

    /////////////////////////////////////test specific operations;//////////////////////////////////////////////////////////////////////////////

    //test 1: MOV R0, #7
    //        MOV R1, #2
    //        SUB R2, R1, R0, should be -5

    //test MOV RO, #7 (store 7 in R0. when readnum is R0 data_out should be 7)
    #10;
    vsel= 4'b0100; writenum = 3'b000; write = 1'b1; sximm8 = 16'b 0000_0000_0000_0111; 
    #10;

      $display("checking value in R0");
    if(DUT.REGFILE.R0 !=  16'b 0000_0000_0000_0111)begin
            $display("ERROR ** output is %b, expected %b", DUT.REGFILE.R0 , 16'b 0000_0000_0000_0111);
            err = 1'b1;
    end

    //test MOV R1, #2 (store 2 in R1. when readnum is R1 data_out should be 2)
    writenum = 3'b001; sximm8 = 16'b 0000_0000_0000_0010; vsel = 4'b0100;
    #10
    
    $display("checking value in R1");
    if(DUT.REGFILE.R1!=  16'b 0000_0000_0000_0010)begin
            $display("ERROR ** output is %b, expected %b", DUT.REGFILE.R1 , 16'b 0000_0000_0000_0010);
            err = 1'b1;
    end



    //test SUB R2, R1, R0
    readnum = 3'b001; loada = 1'b1; loadb = 1'b0; 
    #10;

    readnum = 3'b000; loada = 1'b0; loadb = 1'b1; shift = 2'b00;
    #10;

    ALUop = 2'b01; asel = 1'b0; bsel = 1'b0; shift = 2'b00; loadc = 1'b1; loads = 1'b1;
    #10;
    
    vsel = 4'b0001; write = 1'b1; writenum = 3'b010;
    #10;

    $display("checking value in R2");
    if(DUT.REGFILE.R2 != 16'b1111_1111_1111_1011)begin
        $display("ERROR ** output is %b, expected %b", DUT.REGFILE.R2, 16'b1111_1111_1111_1011);
        err = 1'b1;
    end

    $display("checking value in Z_out status bit");
    if(Z_out != 1'b0)begin
            $display("ERROR ** output is %b, expected %b", Z_out, 1'b0);
            err = 1'b1;
    end

    $display("checking value in N status bit");
    if(N != 1'b1)begin
            $display("ERROR ** output is %b, expected %b", N, 1'b1);
            err = 1'b1;
    end
    
    $display("checking value in V status bit");
    if(V != 1'b0)begin
            $display("ERROR ** output is %b, expected %b", V, 1'b0);
            err = 1'b1;
    end

    //test 2: MOV R3, #10
    //        MOV R4, #5
    //        ADD R5, R3, R4, LSL#1 should be 10 + (5 * 2) = 20

    //test MOV R3, #10
    vsel= 4'b0100; writenum = 3'b011; write = 1'b1; sximm8 = 16'b0000_0000_0000_1010;
    #10;

    $display("checking value in R3");
    if(DUT.REGFILE.R3 !=  16'b0000_0000_0000_1010)begin
            $display("ERROR ** output is %b, expected %b", DUT.REGFILE.R3 , 16'b0000_0000_0000_1010);
            err = 1'b1;
    end

    //test MOV R4, #5
    writenum = 3'b100; sximm8 = 16'b0000_0000_0000_0101; vsel = 4'b0100;
    #10

    if(DUT.REGFILE.R4!=  16'b 0000_0000_0000_0101)begin
            $display("ERROR ** output is %b, expected %b", DUT.REGFILE.R4 , 16'b 0000_0000_0000_0101);
            err = 1'b1;
    end

    //test ADD R5, R3, R4, LSL#1
    readnum = 3'b011; loada = 1'b1; loadb = 1'b0; 
    #10;

    readnum = 3'b100; loada = 1'b0; loadb = 1'b1;  shift = 2'b01;
    #10;

    ALUop = 2'b00; asel = 1'b0; bsel = 1'b0; shift = 2'b01; loadc = 1'b1; loads = 1'b1;
    #10;
    
    vsel = 4'b0001; write = 1'b1; writenum = 3'b101;
    #10;

    $display("checking value in R5");
    if(DUT.REGFILE.R5 != 16'b 0000_0000_0001_0100)begin
        $display("ERROR ** output is %b, expected %b", DUT.REGFILE.R5, 16'b 0000_0000_0001_1110);
        err = 1'b1;
    end

    $display("checking value in Z_out status bit");
    if(Z_out != 1'b0)begin
            $display("ERROR ** output is %b, expected %b", Z_out, 1'b0);
            err = 1'b1;
    end

    $display("checking value in N status bit");
    if(N != 1'b0)begin
            $display("ERROR ** output is %b, expected %b", N, 1'b0);
            err = 1'b1;
    end
    
    $display("checking value in V status bit");
    if(V != 1'b0)begin
            $display("ERROR ** output is %b, expected %b", V, 1'b0);
            err = 1'b1;
    end

    //test 3:
    //      MOV R6, #7
    //      AND R7, R6, R5

    vsel = 4'b0100; writenum = 3'b110; write = 1'b1; sximm8 = 16'b0000_0000_0000_0111;
    #10;

    //checking if R6 equals 4
    $display("checking value in R6");
    if(DUT.REGFILE.R6 !=  16'b0000_0000_0000_0111)begin
            $display("ERROR ** output is %b, expected %b", DUT.REGFILE.R6, 16'b0000_0000_0000_0111);
            err = 1'b1;
    end
  
    readnum = 3'b110; loada = 1'b1; loadb = 1'b0; 
    #10;

    readnum = 3'b101; loada = 1'b0; loadb = 1'b1; 
    #10;

    ALUop = 2'b10; loadc = 1'b1; asel = 1'b0; bsel = 1'b0; shift = 2'b00;
    #10; 

    vsel = 4'b0001; write = 1'b1; writenum = 3'b111;
    #10;

    //checking if R7
    $display("checking value in R7");
    if(DUT.REGFILE.R7 !=  16'b0000_0000_0000_0100)begin
            $display("ERROR ** output is %b, expected %b", DUT.REGFILE.R7, 16'b0000_0000_0000_0100);
            err = 1'b1;
    end 

    //test 4:
    // NEG R7

    loadb = 'b1; readnum = 3'b111;
    #10;
    ALUop = 2'b11; loadc = 1'b1; bsel = 1'b0; shift = 2'b00; loads = 1'b1;
    #10; 
    vsel = 4'b0000; write = 1'b1; writenum = 3'b111;
    #10
    
    //checking if R3 equals 16'b1111_1111_1111_0111 the negation of 16'b0000_0000_0000_1000
    $display("checking value in R7");
    if(DUT.REGFILE.R7 !=  16'b1111_1111_1111_1011)begin
            $display("ERROR ** output is %b, expected %b", DUT.REGFILE.R7, 16'b1111_1111_1111_1011);
            err = 1'b1;
    end

    //test 5
    // MOV R2, #32 with mdata
    #10;
    vsel= 4'b1000; writenum = 3'b010; write = 1'b1; sximm8 = 16'b 0000_0000_0000_0111; mdata = 16'b 0000_0000_0010_0000;
    #10;
    $display("checking value in R2");
    if(DUT.REGFILE.R2 !=  16'b 0000_0000_0010_0000)begin
            $display("ERROR ** output is %b, expected %b", DUT.REGFILE.R2, 16'b 0000_0000_0010_0000);
            err = 1'b1;
    end

    //test 6
    // MOV R4, with PC = 8'b1000_0001
    #10;
    vsel= 4'b0010; writenum = 3'b100; write = 1'b1; mdata = 16'b 0000_0000_0000_0111; sximm8 = 16'b 0000_0000_1110_0000; PC = 8'b1000_0001;
    #10;
     $display("checking value in R4");
    if(DUT.REGFILE.R4 !=  16'b 0000_0000_1000_0001)begin
            $display("ERROR ** output is %b, expected %b", DUT.REGFILE.R4, 16'b 0000_0000_1000_0001);
            err = 1'b1;
    end


    //test 7
    // MOV R5, with previous value C
    #10;
    vsel= 4'b0001; writenum = 3'b101; write = 1'b1; mdata = 16'b 0000_0000_0000_0111; sximm8 = 16'b 0000_0000_1110_0000; PC = 8'b1110_0001;
    #10;
     $display("checking value in R5");
    if(DUT.REGFILE.R5 !=  16'b 0000_0000_1000_0001)begin
            $display("ERROR ** output is %b, expected %b", DUT.REGFILE.R5, 16'b 0000_0000_1000_0001);
            err = 1'b1;
    end

    // end of testbench   
    //display PASSED if no error, else display FAILED 
    if(~err) $display("PASSED");
    else $display ("FAILED");
    #10;
    $stop;
end

endmodule
