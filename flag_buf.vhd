library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


-- Generig one word data buffer with flag for new data received.
entity flag_buf is
	generic(W: integer := 8);	-- Data width
	port(
		clk, rst: in std_logic;
		clr_flag, set_flag: in std_logic;	-- For clearing and setting flag
		din: in std_logic_vector(W-1 downto 0);	-- Data input
		dout: out std_logic_vector(w-1 downto 0);	-- Data output
		flag: out std_logic	-- Flag indicating whether new data has arrived
	);
end flag_buf;

architecture arch of flag_buf is
	signal buf_reg, buf_next : std_logic_vector(W-1 downto 0);
	signal flag_reg, flag_next : std_logic;
begin
	
	FF_register:process (clk, rst) is
	begin
		if rst = '1' then
			buf_reg <= (others => '0');
			flag_reg <= '0';
		elsif rising_edge(clk) then
			buf_reg <= buf_next;
			flag_reg <= flag_next;
		end if;
	end process FF_register;
	
	-- Next state
	next_state:process(buf_reg, flag_reg, set_flag, clr_flag, din) is
	begin
		buf_next <= buf_reg;
		flag_next <= flag_reg;
		if set_flag = '1' then
			buf_next <= din;
			flag_next <= '1';
		elsif clr_flag = '1' then
			flag_next <= '0';
		else
		end if;
	end process next_state;
	
	-- Output
	dout <= buf_reg;
	flag <= flag_reg;

end arch;

