library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_rx is
	generic(
		DBIT: integer := 8;	--Data bits
		SB_TICK: integer := 16 --Stop bit ticks
	);
	port(
		clk, reset: in std_logic;
		rx: in std_logic;
		s_tick: in std_logic;
		rx_done_tick: in std_logic;
		dout: out std_logic_vector(7 downto 0)
	);
end uart_rx;

architecture arch of uart_rx is
	type state_type is (idle, start, data, stop);
	signal state_reg, state_next: state_type;
	signal s_reg, s_next: unsigned(3 downto 0);
	signal n_reg, n_next: unsigned(2 downto 0);
	signal b_reg, b_next : std_logic_vector(7 downto 0);
	
begin


end arch;

