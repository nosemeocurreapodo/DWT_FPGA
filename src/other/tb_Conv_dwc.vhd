----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 

----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use STD.textio.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;       

entity tb_DWC_core is
end tb_DWC_core;

architecture Behavioral of tb_DWC_core is
    
    component DWC_core is
    Port (
        clk :       in STD_LOGIC; 
        rst :       in STD_LOGIC; 
        EEC_in:     in STD_LOGIC_VECTOR (31 downto 0); 
        en:         in STD_LOGIC; 
        
        Hi_Wk:      out STD_LOGIC_VECTOR (31 downto 0);     
        Hi_ready:   out STD_LOGIC; 
        
        end_DWT:    out STD_LOGIC;
        Lo_Wk:      out STD_LOGIC_VECTOR (31 downto 0);
        Lo_ready:   out STD_LOGIC
    );
    end component;
    
    type eec_array is array (0 to 15) of std_logic_vector(31 downto 0);
    signal  eec_test:               eec_array;
    signal  clks, rsts, ens:        STD_LOGIC := '0'; 
    signal  EEC_ins, Wks,Lo_Wk_s:   STD_LOGIC_VECTOR (31 downto 0); 
    constant    period:             time := 100ns;
    
    constant C_FILE_NAME_RD :       string := "datos32_fix32_20Q16.bin";
    type INTEGER_FILE is file of integer;
    file fptrrd:                    INTEGER_FILE;
    
    signal read_std:                std_logic_vector(31 downto 0);
    -- signal read_std2:               std_logic_vector(31 downto 0);
    signal data:                    integer := 1;
    signal  Hi_ready_s, Lo_ready_s, end_DWT_s: STD_LOGIC := '0'; 
   --       
    
    
  
begin

    process
    begin 
        clks <= '0';
        wait for period/2;    
        clks <= '1';
        wait for period/2; 
    end process;
    

--  read_file_process : process
--    variable statrd : FILE_OPEN_STATUS;
--    variable varint_data    :integer := 1;
--    begin
--        wait for 20 ns;
--        file_open(statrd, fptrrd, C_FILE_NAME_RD, read_mode);

--        while (not endfile(fptrrd)) loop
--            wait until clks = '1';
                
--            read(fptrrd, varint_data);
--            data  <= varint_data;
--            read_std <= std_logic_vector(to_signed(varint_data, 32));
--        end loop;
--        wait until rising_edge(clks);
--        file_close(fptrrd);
--        wait;
--    end process;   
    
--    read_std2(31 downto 24) <= read_std(7 downto 0);
--    read_std2(23 downto 16) <= read_std(15 downto 8);
--    read_std2(15 downto 8) <= read_std(23 downto 16);
--    read_std2(7 downto 0) <= read_std(31 downto 24);   
    
    eec_test(0) <= x"00001000";     eec_test(1) <= x"00002000";
    eec_test(2) <= x"00003000";     eec_test(3) <= x"00004000";
    eec_test(4) <= x"00005000";     eec_test(5) <= x"00006000";
    eec_test(6) <= x"00007000";     eec_test(7) <= x"00008000";
    eec_test(8) <= x"00009000";     eec_test(9) <= x"0000A000";
    
    process
    begin
        EEC_ins <= x"00000000";
        rsts <= '1';    wait for period*2;
        rsts <= '0';    wait for period*2;
        ens <= '1';
        EEC_ins <= eec_test(0); wait for period;
        EEC_ins <= eec_test(1); wait for period;
        EEC_ins <= eec_test(2); wait for period;
        EEC_ins <= eec_test(3); wait for period;
        EEC_ins <= eec_test(4); wait for period;
        EEC_ins <= eec_test(5); wait for period;
        EEC_ins <= eec_test(6); wait for period;
        EEC_ins <= eec_test(7); wait for period;
        EEC_ins <= eec_test(8); wait for period;
        wait;
    end process;
    
 ------------------

        
           
    dut: DWC_core
    port map(
        clk     => clks, 
        rst     => rsts, 
        EEC_in  => EEC_ins, 
        en      => ens,
        Hi_Wk   => Wks,   
        Hi_ready=> Hi_ready_s,
        end_DWT => end_DWT_s,
        Lo_Wk   => Lo_Wk_s,
        Lo_ready=> Lo_ready_s
    );
    
    
        


end Behavioral;
