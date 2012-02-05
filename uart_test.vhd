library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Simple test for UART interface. When a button is pressed, reads an uart
-- message from fifo, displays it on led and echoes it back.
entity uart_test is
	port(
		clk, rst: in std_logic;
		btn: in std_logic;
		rx: in std_logic;
		tx: out std_logic;
		led: out std_logic_vector(7 downto 0)
	);
end uart_test;

architecture arch of uart_test is
	signal tx_full, rx_empty: std_logic;
	signal rec_data: std_logic_vector(7 downto 0);
	signal btn_tick: std_logic;
begin
	-- UART
	uart_unit : entity work.uart
		port map(clk      => clk,
			     rst      => rst,
			     rd_uart  => btn_tick,
			     wr_uart  => btn_tick,
			     rx       => rx,
			     w_data   => rec_data,
			     tx_full  => tx_full,
			     rx_empty => rx_empty,
			     r_data   => rec_data,
			     tx       => tx);
			     
	-- Debouncer
	btn_unit : entity work.debouncer
		generic map(N => 20)
		port map(clk      => clk,
			     sw       => btn,
			     db_level => open,
			     db_tick  => btn_tick);

	led <= rec_data;
end arch;

