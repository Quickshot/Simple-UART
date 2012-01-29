library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity mod_m_counter is
	generic(
		N: integer := 8;	--Number of bits
		M: integer := 163	--mod-M
	);
	port(
		clk, reset: in std_logic;
		tick: out std_logic
	);
end mod_m_counter;

architecture arch of mod_m_counter is
	signal r_reg : unsigned(N-1 downto 0);
	signal r_next : unsigned(N-1 downto 0);
	
begin
	reg:process (clk, reset) is
	begin
		if reset = '1' then
			r_reg <= (others => '0');
		elsif rising_edge(clk) then
			r_reg <= r_next;
		end if;
	end process reg;
	
	--Next state logic
	r_next <= (others => '0') when r_reg=(M-1) else r_reg+1;	

end arch;

