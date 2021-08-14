module data_send(
	input	clk,
	input	rst_n,
	
	input	[31:0]	fx_cnt, //频率值
	input	[31:0]	gate_cnt, //时钟值
	input	data_ready, //锁存器存到值，EN
	
	input	uart_tx_done, //空闲EN，忙碌DIS
	output	reg [7:0]uart_tx_data, //发给串口的8位数据
	output 	reg uart_tx_en //使能串口模块
);

reg		data_ready_d0; //上升沿检测
reg		data_ready_d1; //
reg		[4:0]	send_state/* synthesis preserve*/; //发送状态机
wire	pos_data_ready;

assign pos_data_ready = (~data_ready_d1) & data_ready_d0;  

//采输data_ready信号的上升沿
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		data_ready_d0 <= 0;
		data_ready_d1 <= 0;
	end
	else begin
		data_ready_d0 <= data_ready;
        data_ready_d1 <= data_ready_d0;
	end
end


always @(posedge clk or negedge rst_n) begin
	if(!rst_n) begin
		send_state <= 4'b0;
		uart_tx_en <= 0;
		uart_tx_data <= 8'h00;
	end
	else if(pos_data_ready) begin
		uart_tx_en <= 0;
		send_state <= 4'b0;
	end
	else if(send_state == 0 && uart_tx_done) begin	//包头
		uart_tx_en <= 1;
		uart_tx_data <= 8'ha5;
		send_state <= 1;
	end
	else if(send_state == 1) begin
		uart_tx_en <= 0;
		send_state <= 2;
	end
	else if(send_state == 2 && uart_tx_done) begin
		uart_tx_en <= 1;
		uart_tx_data <= fx_cnt[31:24];
		send_state <= 3;
	end
	else if(send_state == 3) begin
		uart_tx_en <= 0;
		send_state <= 4;
	end
	else if(send_state == 4 && uart_tx_done) begin
		uart_tx_en <= 1;
		uart_tx_data <= fx_cnt[23:16];
		send_state <= 5;
	end
	else if(send_state == 5) begin
		uart_tx_en <= 0;
		send_state <= 6;
	end
	else if(send_state == 6 && uart_tx_done) begin
		uart_tx_en <= 1;
		uart_tx_data <= fx_cnt[15:8];
		send_state <= 7;
	end
	else if(send_state == 7) begin
		uart_tx_en <= 0;
		send_state <= 8;
	end
	else if(send_state == 8 && uart_tx_done) begin
		uart_tx_en <= 1;
		uart_tx_data <= fx_cnt[7:0];
		send_state <= 9;
	end
	else if(send_state == 9) begin
		uart_tx_en <= 0;
		send_state <= 10;
	end
	else if(send_state == 10 && uart_tx_done) begin
		uart_tx_en <= 1;
		uart_tx_data <= gate_cnt[31:24];
		send_state <= 11;
	end
	else if(send_state == 11) begin
		uart_tx_en <= 0;
		send_state <= 12;
	end
	else if(send_state == 12 && uart_tx_done) begin
		uart_tx_en <= 1;
		uart_tx_data <= gate_cnt[23:16];
		send_state <= 13;
	end
	else if(send_state == 13) begin
		uart_tx_en <= 0;
		send_state <= 14;
	end
	else if(send_state == 14 && uart_tx_done) begin
		uart_tx_en <= 1;
		uart_tx_data <= gate_cnt[15:8];
		send_state <= 15;
	end
	else if(send_state == 15) begin
		uart_tx_en <= 0;
		send_state <= 16;
	end
	else if(send_state == 16 && uart_tx_done) begin
		uart_tx_en <= 1;
		uart_tx_data <= gate_cnt[7:0];
		send_state <= 17;
	end
	else if(send_state == 17) begin
		uart_tx_en <= 0;
		send_state <= 18;
	end
	else if(send_state == 18 && uart_tx_done) begin	//累加和校验
		uart_tx_en <= 1;
		uart_tx_data <= fx_cnt[7:0] + fx_cnt[15:8] + fx_cnt[23:16] + fx_cnt[31:24] + gate_cnt[7:0] + gate_cnt[15:8] + gate_cnt[23:16] + gate_cnt[31:24];
		send_state <= 19;
	end
	else if(send_state == 19) begin
		uart_tx_en <= 0;
		send_state <= 20;
	end
	else if(send_state == 20 && uart_tx_done) begin	//包尾
		uart_tx_en <= 1;
		uart_tx_data <= 8'h5a;
		send_state <= 21;
	end
	else if(send_state == 21) begin
		uart_tx_en <= 0;
		send_state <= 22;
	end
end

endmodule
