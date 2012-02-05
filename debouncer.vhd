library ieee;
use ieee.std_logic_1164.all;
use ieee.NUMERIC_STD.all;

-- Debouncer where signal has to be stable for n number of clock cycles
-- before output is set to input signal.
-- With default value of cycles, debouncer occupies 15 slices in
-- xc3s700an FPGA.
entity debouncer is
	generic(
		-- How many clock cycles to wait for transition (2^N cycles).
		N: integer := 20	-- On 50MHz clock about 21ms.
	);
	port( 
		clk,sw: in std_logic;
		db_level, db_tick: out std_logic
	);
end entity debouncer;

architecture RTL of debouncer is
	type state_type is (zero, wait1, one, wait0);
	signal state_reg, state_next: state_type := zero;
	signal c_enable, c_set: std_logic;
	signal counter: unsigned(N-1 downto 0);
begin

	-- State
	process(clk)
	begin
		if rising_edge(clk) then
			state_reg <= state_next;
		end if;
	end process;
	
	-- Down counter
	process(clk, c_enable, c_set)
	begin
		if rising_edge(clk) then
			if (c_enable = '1') then
				counter <= counter - 1;
			elsif (c_set = '1') then
				counter <= (others => '1');
			end if;
		end if;	
	end process;
	
	-- Control path
	process(state_reg, sw, counter)
	begin
		-- Default values
		db_tick <= '0';
		db_level <= '0';
		c_enable <= '0';
		c_set <= '0';
		state_next <= state_reg;
		
		case state_reg is
			when zero =>
				db_level <= '0';
				if (sw = '1') then
					state_next <= wait1;
					c_set <= '1';
				end if;
				
			when wait1 =>
				db_level <= '0';
				if (sw = '1') then
					c_enable <= '1';
					if (counter = 0) then
						state_next <= one;
						db_tick <= '1';
					end if;
				else
					state_next <= zero;
				end if;
				
			when one =>
				db_level <= '1';
				if (sw = '0') then
					state_next <= wait0;
					c_set <= '1';
				end if;
				
			when wait0 =>
				db_level <= '1';
				if (sw = '0') then
					c_enable <= '1';
					if (counter = 0) then
						state_next <= zero;
					end if;
				else
					state_next <= one;
				end if;
			end case;
	end process;

end architecture RTL;
