library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_tx is
	generic(
		DBIT: integer := 8;	-- Data bits
		SB_TICK: integer := 16	-- Stop bit ticks
	);
	port(
		clk, rst: in std_logic;
		tx_start: in std_logic;
		s_tick: in std_logic;
		din: in std_logic_vector(7 downto 0);
		tx_done_tick: out std_logic;
		tx: out std_logic
	);
end uart_tx;

architecture arch of uart_tx is

begin


end arch;

