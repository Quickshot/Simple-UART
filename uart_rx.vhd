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
		rx_done_tick: out std_logic;
		dout: out std_logic_vector(7 downto 0)
	);
end uart_rx;

architecture arch of uart_rx is
	type state_type is (idle, start, data, stop);
	signal state_reg, state_next: state_type;
	signal s_reg, s_next: unsigned(3 downto 0);	-- For oversamling
	signal n_reg, n_next: unsigned(2 downto 0);	-- Data bit being processed
	signal b_reg, b_next : std_logic_vector(7 downto 0);	-- Received data
	
begin
	-- state and data registers
	process (clk) is
	begin
		if rising_edge(clk) then
			if reset = '1' then
				state_reg <= idle;
				s_reg <= (others => '0');
				n_reg <= (others => '0');
				b_reg <= (others => '0');
			else
				state_reg <= state_next;
				s_reg <= s_next;
				n_reg <= n_next;
				b_reg <= b_next;
			end if;
		end if;
	end process;
	
	-- next state logic and data path
	data_path:process (state_reg, s_reg, n_reg, b_reg, s_tick, rx) is
	begin
		state_next <= state_reg;
		s_next <= s_reg;
		n_next <= n_reg;
		b_next <= b_reg;
		rx_done_tick <= '0';
		
		case state_reg is
			when idle => 
				if rx='0' then
					state_next <= start;
					s_next <= (others => '0');
				end if;
			when start => 
				if (s_tick = '1') then
					if s_reg = 7 then
						state_next <= data;
						s_next <= (others => '0');
						n_next <= (others => '0');
					else
						s_next <= s_reg+1;
					end if;
				end if;
			when data => 
				if s_tick = '1' then
					if s_reg = 15 then
						s_next <= (others => '0');
						b_next <= rx & b_reg(7 downto 1);
						if n_reg = (DBIT-1) then
							state_next <= stop;
						else
							n_next <= n_reg + 1;
						end if;
					else
						s_next <= s_reg + 1;
					end if;
				end if;
			when stop => 
				if s_tick = '1' then
					if s_reg = (SB_TICK-1) then
						state_next <= idle;
						rx_done_tick <= '1';
					else
						s_next <= s_reg + 1;
					end if;
				end if;
		end case;
	end process data_path;
	
	dout <= b_reg;

end arch;

