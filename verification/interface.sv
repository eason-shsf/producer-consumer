/***********************************************
* interface 
***********************************************/


interface sys_if;
  logic wclk,rclk,wrst_n,rrst_n;
endinterface : sys_if

interface producer_if(input logic wclk, input logic wrst_n);
  logic wpush;
  logic wfull;
  logic [15:0] wdata;
  
  modport mp_slv
  (
  	input wclk,
    input wrst_n,
    input wpush,
    output wfull,
    input wdata
  );
  
    modport mp_mst
  (
  	input wclk,
    input wrst_n,
    output wpush,
    input wfull,
    output wdata
  );
  
    modport mp_mon
  (
  	input wclk,
    input wrst_n,
    input wpush,
    input wfull,
    input wdata
  );
endinterface : producer_if


interface consumer_if(input logic rclk, input logic rrst_n);
  logic rpop;
  logic rempty;
  logic [15:0] rdata;
  
  modport mp_slv
  (
  	input rclk,
    input rrst_n,
    input rpop,
    output rempty,
    output rdata
  );
  
    modport mp_mst
  (
  	input rclk,
    input rrst_n,
    output rpop,
    input rempty,
    input rdata
  );
  
    modport mp_mon
  (
  	input rclk,
    input rrst_n,
    input rpop,
    input rempty,
    input rdata
  );
endinterface : consumer_if

