`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: College of Engineering Trivandrum
// Student: Bristo C J
// 
// Create Date: 10.11.2023 00:45:07
// Design Name: i2C_protocol_1.1
// Module Name: tb
// Project Name: i2C protocol
// Target Devices: none
// Tool Versions: 2021.1
// Description: i2C Protocol simulation using verilog 
//////////////////////////////////////////////////////////////////////////////////
module tb();
reg clk=1'b0,rst,ack=1'b1,rw,newd;
wire sda,scl,done;
reg [7:0] wdata;
wire [7:0] rdata;
reg [6:0] addr; 

//reset gen
task reset;
    begin
        rst=1'b1;
        #10
        rst=1'b0;
    end
endtask

//write function
task write;
    begin
        newd = 1'b1;
        addr = $random;
        rw = 1'b0;
        wdata = $random;
        #1000;
    end
endtask

//read function
task read;
    begin
        newd = 1'b1;
        rw = 1'b1;
        addr = $random;
        #1000;
    end
endtask



//instantiating module
main main1(clk,rst,ack,rw,scl,newd,sda,wdata,addr,rdata,done);

initial begin
clk=1'b0;
ack=1'b1;
end

//clk gen
always #1 clk=~clk;

initial begin
    reset();
    write();
    #20 
    read();
    $finish();
end

initial begin
$monitor("sda = %b,scl = %b",&sda,&scl);
end

endmodule
