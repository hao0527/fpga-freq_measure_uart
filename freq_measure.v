module fre_measure(
	input	clk,
	input	rst_n,
	input	clk_fx,
	output	reg	[31:0] read_fx_cnt,
	output	reg	[31:0] read_gate_cnt,
	output	reg	read_over
);

reg		[31:0]      gate_cnt;
reg		[31:0]      fx_cnt;
reg					timing;
reg			        capture;
reg			        start;
reg                 stop;
reg     [31:0]      delay_cnt;
reg                 fx_cnt_clear_flag;

always @(posedge clk_fx or negedge rst_n) begin
	if(!rst_n) begin
		timing <= 0;
		fx_cnt <= 0;
		stop <= 0;
	end
	else if(fx_cnt_clear_flag) begin
		fx_cnt_clear_flag <= 0;
		fx_cnt <= 0;
		stop <= 0;
	end
	else if(capture) begin	
		timing <= 0;
		stop <= 1;
		fx_cnt_clear_flag = 1;
	end
	else if(start) begin
		timing <= 1;
		fx_cnt <= fx_cnt + 1;
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		gate_cnt <= 0;
	else if(read_over)
		gate_cnt <= 0;
	else if(timing)
		gate_cnt <= gate_cnt + 1;
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		capture <= 0;
	end 
	else if((gate_cnt > 21_000_000) && start) begin
		capture <= 1;
	end
	else if(!start) begin
		capture <= 0;
	end
end

always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		start <= 0;
		delay_cnt <= 0;
		read_fx_cnt <= 0;
		read_gate_cnt <= 0;
		read_over <= 0;
	end
	else if(stop && !read_over) begin
		start <= 0;
		read_over <= 1;
		read_fx_cnt <= fx_cnt;
		read_gate_cnt <= gate_cnt;
	end
	//这个延时会影响最小测量频率，20ms的时候最小测量频率为100Hz，2s的时候最小测量频率为1Hz
	else if(delay_cnt == 1_000_000) begin	
		start <= 1;
		read_over <= 0;
		delay_cnt <= 0;
	end
	else if(!timing)
		delay_cnt <= delay_cnt + 1;
end

endmodule
