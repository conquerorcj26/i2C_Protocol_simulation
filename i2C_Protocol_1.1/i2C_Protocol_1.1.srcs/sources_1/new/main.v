`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: College of Engineering Trivandrum
// Student: Bristo C J
// 
// Create Date: 10.11.2023 00:45:07
// Design Name: i2C_protocol_1.1
// Module Name: main
// Project Name: i2C protocol
// Target Devices: none
// Tool Versions: 2021.1
// Description: i2C Protocol simulation using verilog 
//////////////////////////////////////////////////////////////////////////////////
module main
  (
 input clk,rst,ack,rw,scl,newd,  //newd = 1:whenever a new data is incoming
 inout sda,  //in-write, out-read
 input [7:0] wdata,   //8 bit write data
 input [6:0] addr,  //7 bit address of slave
 output reg [7:0] rdata,  //8 bit read data
 output reg done // done indicator
  );
  
 reg sda_en = 0; //1(write):sda=dat 0(read):sda=z
 reg sclt, sdat;  //temporary in-program usage
 reg [7:0] rdatat;  //read data temp storage
 reg [7:0] addrt;  //8-bit  7-bit : + addr 1-bit : mode
 
 reg [3:0] state;  //13 states
 
 parameter 
 idle = 0,  //initial stage
 start = 1,  //start operation
 check_rw = 2,  //check rw signal
 wsend_addr = 3,  //send address for write
 waddr_ack = 4,  //write address acknowledgment
 wsend_data = 5,  //send data for write
 wdata_ack = 6,  //write data acknowledgment
 wstop = 7,  //stop write
 rsend_addr = 8,  //send address for read
 raddr_ack = 9,  //read address acknowledgment
 rsend_data = 10,  //send data for read
 rdata_ack = 11,  //read data acknowledgment
 rstop = 12 ;  //stop read
  
 reg sclk_wr = 0; //Actual slower clock (except when start-writing,stop-writing,stop-reading)
 integer i,count = 0;
    
  //Slower clock generation
  always@(posedge clk)
    begin
      if(count <= 9) 
        begin
           count <= count + 1;     
        end
      else
         begin
           count  <= 0; 
           sclk_wr  <= ~sclk_wr;
         end	      
    end
  
  
  //FSM
  always@(posedge sclk_wr, posedge rst)
    begin 
      if(rst == 1'b1)
         begin
           sclt  <= 1'b0;
           sdat  <= 1'b0;
           donet <= 1'b0;
         end
       else begin
         case(state)
           idle : 
           begin
              sdat <= 1'b0;
              done <= 1'b0;
              sda_en  <= 1'b1;
              sclt <= 1'b1;
              sdat <= 1'b1;
             if(newd == 1'b1) 
                state  <= start;
             else 
                state  <= idle;         
           end
         
            start: 
            begin
              sdat  <= 1'b0;
              sclt  <= 1'b1;
              state <= check_rw;
              addrt <= {addr,rw};
            end
            
            check_rw: begin //addr remain same for both write and read
              if(rw)
                 begin
                 state <= rsend_addr;
                 sdat <= addrt[0];
                 i <= 1;
                 end 
               else
                 begin
                 state <= wsend_addr;
                 sdat <= addrt[0];
                 i <= 1;
                 end  
            end
         
         //write state
         
           wsend_addr : begin                
                      if(i <= 7) begin
                      sdat  <= addrt[i];
                      i <= i + 1;
                      end
                      else
                        begin
                          i <= 0;
                          state <= waddr_ack; 
                        end   
                    end
         
         
           waddr_ack : begin
             if(ack) begin
               state <= wsend_data;
               sdat  <= wdata[0];
               i <= i + 1;
               end
             else
               state <= waddr_ack;
           end
         
         wsend_data : begin
           if(i <= 7) begin
              i     <= i + 1;
              sdat  <= wdata[i]; 
           end
           else begin
              i     <= 0;
              state <= wdata_ack;
           end
         end
         
          wdata_ack : begin
             if(ack) begin
               state <= wstop;
               sdat <= 1'b0;
               sclt <= 1'b1;
               end
             else begin
               state <= wdata_ack;
             end 
            end
         
              
         
         wstop: begin
              sdat  <=  1'b1;
              state <=  idle;
              done <=  1'b1;  
         end
         
         //read state
         
         
          rsend_addr : begin
                     if(i <= 7) begin
                      sdat  <= addrt[i];
                      i <= i + 1;
                      end
                      else
                        begin
                          i <= 0;
                          state <= raddr_ack; 
                        end   
                    end
         
         
           raddr_ack : begin
             if(ack) begin
               state  <= rsend_data;
               sda_en <= 1'b0;
             end
             else
               state <= raddr_ack;
           end
         
         rsend_data : begin
                   if(i <= 7) begin
                         i <= i + 1;
                         state <= rsend_data;
                         rdata[i] <= sda;
                      end
                      else
                        begin
                          i <= 0;
                          sda_en <= 1'b1;
                          state <= rdata_ack; 
                        end         
         end
         
         rdata_ack : begin
             if(ack) begin
               state <= rstop;
               sdat <= 1'b0;
               sclt <= 1'b1;
               end
             else begin
               state <= rdata_ack;
             end 
            end
        
         
         
         rstop: begin
              sdat  <=  1'b1;
              state <=  idle;
              done  <=  1'b1;  
              end
         
         
         default : state <= idle;
         
          	 endcase
          end
  end
  
 assign scl = (( state == start) || ( state == wstop) || ( state == rstop)) ? sclt : sclk_wr;
 assign sda = (sda_en == 1'b1) ? sdat : 1'bz;
endmodule
