module fre_measure_top(
	input	clk_sys,
	input	rst_n,
	input	clk_fx,
	output	uart_tx
);

wire	[31:0]	fx_cnt;
wire	[31:0]	gate_cnt;

wire	data_ready;
wire	uart_tx_done;
wire	uart_tx_en;
wire	[7:0]	uart_tx_data;

fre_measure fre_measure_u(
	.clk(clk_sys),
	.rst_n(rst_n),
	.clk_fx(clk_fx),
	.read_fx_cnt(fx_cnt),
	.read_gate_cnt(gate_cnt),
	.read_over(data_ready)
);

uart_tx_path uart_tx_path_u(
	.clk_i(clk_sys),
	.uart_tx_data_i(uart_tx_data),
	.uart_tx_en_i(uart_tx_en),
	.uart_tx_o(uart_tx),
	.uart_tx_done_o(uart_tx_done)
);

data_send data_send_u(
	.clk(clk_sys),
	.rst_n(rst_n),
	.fx_cnt(fx_cnt),
	.gate_cnt(gate_cnt),
	.data_ready(data_ready),
	.uart_tx_done(uart_tx_done),
	.uart_tx_data(uart_tx_data),
	.uart_tx_en(uart_tx_en)
);

endmodule
