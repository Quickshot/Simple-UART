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
	type state_type is (idle, start, data, stop);
	signal state_reg, state_next : state_type;
	signal s_reg, s_next: unsigned(3 downto 0);
	signal n_reg, n_next: unsigned(2 downto 0);
	signal b_reg, b_next: std_logic_vector(7 downto 0);
	signal tx_reg, tx_next: std_logic;
begin

	state_and_data:process (clk) is
	begin	
		if rising_edge(clk) then
			if rst = '1' then
				state_reg <= idle;
				s_reg <= (others => '0');
				n_reg <= (others => '0');
				b_reg <= (others => '0');
				tx_reg <= '1';	-- Idle => output high
			else
				state_reg <= state_next;
				s_reg <= s_next;
				n_reg <= n_next;
				b_reg <= b_next;
				tx_reg <= tx_next;
			end if;
		end if;
	end process state_and_data;
	
	logic_and_data_path:process (state_reg, s_reg, n_reg, b_reg, s_tick, tx_reg, tx_start, din) is
	begin
		state_next <= state_reg;
		s_next <= s_reg;
		n_next <= n_reg;
		b_next <= b_reg;
		tx_next <= tx_reg;
		tx_done_tick <= '0';
		
		case state_reg is
			when idle => 
				tx_next <= '1';
				if tx_start = '1' then
					state_next <= start;
					s_next <= (others => '0');
					b_next <= din;
				end if;
			when start => 
				tx_next <= '0';
				if s_tick = '1' then
					if s_reg = 15 then
						state_next <= data;
						s_next <= (others => '0');
						n_next <= (others => '0');
					else
						s_next <= s_reg + 1;
					end if;
				end if;
			when data => 
				tx_next <= b_reg(0);
				if s_tick = '1' then
					if s_reg = 15 then
						s_next <= (others => '0');
						b_next <= '0' & b_reg(7 downto 1);
						if n_reg= (DBIT-1) then
							state_next <= stop;
						else
							n_next <= n_reg + 1;
						end if;
					else
						s_next <= s_reg + 1;
					end if;
				end if;
			when stop => 
				tx_next <= '1';
				if s_tick = '1' then
					if s_reg = (SB_TICK-1) then
						state_next <= idle;
						tx_done_tick <= '1';
					else
						s_next <= s_reg + 1;
					end if;
				end if;
		end case;
	end process logic_and_data_path;
	
	-- Output
	tx <= tx_reg;
	
end arch;

