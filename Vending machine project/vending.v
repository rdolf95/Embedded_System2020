//Coffee Vending Machine

`timescale 1 ns / 100 ps
// State definition
`define NORMAL   2'b00
`define BUSY   	 2'b01
`define GIVE_CH  2'b10
`define ERROR    2'b11

module Coffee_Vending_machine(
//Input
	Clock,
	nReset,
	Input_Money,
	Req_Change,
	Click_Black,
	Click_Cream,
	Click_Cream_Sugar,
//Output	
	Money,
	Change,
	Coffee,
	Water,
	Cream,
	Sugar
	)		  ;
	
//Input
input		Clock;
input		nReset;
input 		Input_Money;
input		Req_Change;
input		Click_Black;
input		Click_Cream;
input		Click_Cream_Sugar;

//Output	
output	[4:0]	Money;
output	[4:0]	Change;
output		Coffee;
output		Water;
output		Cream;
output		Sugar;


reg	[4:0]	Money;
reg	[4:0]	Change;
reg		Coffee;
reg		Water;
reg		Cream;
reg		Sugar;
reg	[1:0]	CurrST;
reg	[1:0]	NextST;
wire 		Click;
reg		Busy;
reg 	TimeOver;	// TODO3
wire		Busy_CH;
wire		Enable_Buy;
reg	[1:0]   Time;
reg [1:0]   Time_Click;
reg [1:0]	Normal_Count;
reg [1:0]	Menu;		// TODO4

assign Click = Click_Black | Click_Cream | Click_Cream_Sugar;
assign Enable_Buy = (Money[4:0] >= 5'b0010)? 1'b1 : 1'b0;
assign Enable_CH =  (Money[4:0] != 5'b0000)? 1'b1 : 1'b0;
assign Busy_CH =   (Change[4:0] != 5'b0001)? 1'b1 : 1'b0;




always@(CurrST or nReset or Input_Money or Req_Change or Click or Busy or Busy_CH or Enable_Buy or Enable_CH or TimeOver)
begin
	case (CurrST)
	  `NORMAL	: begin
	               		if(~nReset)
	                	 begin
	               		     NextST = `NORMAL;
	                	 end
	               	  	else if(Click && Enable_Buy)
	                  	 begin
	                    	     NextST = `BUSY;
	                 	 end
	                 	else if((Req_Change || TimeOver) && Enable_CH)
	                 	 begin
	                    	     NextST = `GIVE_CH;
	                 	 end
	                 	else
	                 	  NextST = CurrST;
	                  end
	   `BUSY	: begin
	   			if(~nReset)
	                	 begin
	               		     NextST = `NORMAL;
	                	 end
	                	else if(~Busy)
	                	 begin
	                	     NextST = `NORMAL;
	                	 end
	                	else 
	                	 NextST = CurrST;
	                  end
	   `GIVE_CH	: begin
	   			if(~nReset)
	                	 begin
	               		     NextST = `NORMAL;
	                	 end
	                	else if(~Busy_CH)
	                	 begin
	                	     NextST = `NORMAL;
	                	 end
	                	else 
	                	 NextST = CurrST;
	                  end
	   default	:begin
	   			NextST = `NORMAL;
	   		 end
	 endcase
end

  always @(negedge nReset or posedge Clock)
  begin
    if (~nReset) 
      CurrST <= `NORMAL;
    else 
     begin
          CurrST <= NextST;
     end
  end 
  
  always @(negedge nReset or posedge Clock)
  begin
    if (~nReset) 
      begin
        Money  <= 5'b0;
        Change <= 5'b0;
      end
    else if(CurrST == `NORMAL)
      begin
        if(Input_Money && (Money != 5'b10000))
		 begin
       	 	Money  <= Money +5'b1;
		 end
       	else if(Click && Enable_Buy)
       	 Money  <= Money -5'b10;
       	else if(Req_Change|| TimeOver)
       	 begin
       	    Change <= Money;      
       	    Money  <= 5'b0;
       	 end
      end
    else if(CurrST == `GIVE_CH)
      begin
            //Change <= 5'b0;
			Change <= Change - 5'b1;  	// TODO2 : change가 1씩 감소하게 변경
			//TimeOver <= 1'b0;  
      end
  end
  
  always @(negedge nReset or posedge Clock)
  begin
    if (~nReset) 
      begin
	Coffee  <= 1'b0;
	Water   <= 1'b0;
	Cream	<= 1'b0;
	Sugar	<= 1'b0;
	Menu	<= 2'b00;
      end
    else if(NextST == `NORMAL)
      begin
        Coffee  <= 1'b0;
	Water   <= 1'b0;
	Cream	<= 1'b0;2.  Testbench
	Sugar	<= 1'b0;
	Menu	<= 2'b00;
      end
    else if((NextST == `BUSY) && (Menu == 2'b00))
      begin
        if(Click_Black)
          begin
            	Coffee  <= 1'b1;
		Water   <= 1'b1;
		Cream	<= 1'b0;
		Sugar	<= 1'b0;
		Menu 	<= 2'b01;
          end
        else if(Click_Cream)
          begin
            	Coffee  <= 1'b1;
		Water   <= 1'b1;
		Cream	<= 1'b1;
		Sugar	<= 1'b0;
		Menu 	<= 2'b10;
          end
        else if(Click_Cream_Sugar)
          begin
            	Coffee  <= 1'b1;
		Water   <= 1'b1;
		Cream	<= 1'b1;
		Sugar	<= 1'b1;
		Menu 	<= 2'b11;
          end
      end
    else if(NextST == `BUSY)
      begin
        if(Menu == 2'b01)
          begin
            	Coffee  <= 1'b1;
		Water   <= 1'b1;
		Cream	<= 1'b0;
		Sugar	<= 1'b0;
          end
        else if(Menu == 2'b10)
          begin
            	Coffee  <= 1'b1;
		Water   <= 1'b1;
		Cream	<= 1'b1;
		Sugar	<= 1'b0;
          end
        else if(Menu == 2'b11)
          begin
            	Coffee  <= 1'b1;
		Water   <= 1'b1;
		Cream	<= 1'b1;
		Sugar	<= 1'b1;
          end
      end
      
  end
  
  always @(negedge nReset or posedge Clock)
  begin
    if (~nReset) 
      begin
        Busy <= 1'b0;
      end
    else if((NextST == `BUSY) &&(CurrST == `NORMAL))
      begin
        Busy <= 1'b1;
      end
    else if(Time_Click == 2'b1)
      begin
        Busy <= 1'b0;
      end
  end 
  
always @(negedge nReset or posedge Clock)
  begin
    if (~nReset) 
      begin
        Time_Click <= 2'b00;
      end
    else if((NextST == `BUSY) &&(CurrST == `NORMAL))
      begin
        Time_Click <= 2'b01;
      end
    else if((CurrST == `BUSY) && (Time_Click != 2'b00))
      begin
        Time_Click <= Time_Click - 2'b1;
      end
  end

//todo3
always @(negedge nReset or posedge Clock)
  begin
    if (~nReset) 
      begin
        Normal_Count <= 2'b00;
		TimeOver <= 1'b0;	// Timeover 초기화
      end
	else if((CurrST != `NORMAL) && (NextST == `NORMAL))
	 begin
		 Normal_Count <= 2'b10;
		 TimeOver <= 1'b0;
	 end
	else if(Input_Money)
	 begin
		 Normal_Count <= 2'b10;
		 TimeOver <= 1'b0;
	 end
	else if(Money == 5'b00000)
	 begin
		 Normal_Count <= 2'b10;
		 TimeOver <= 1'b0;
	 end
	else if(Normal_Count == 2'b00)
	 begin
		 TimeOver <= 1'b1;
		 Normal_Count <= 2'b10;
	 end
	else if((NextST == `NORMAL))
	 begin
		 Normal_Count <= Normal_Count - 2'b01;
	 end
  end

  
endmodule
