----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity DWC_core is
    Port (
        clk :       in STD_LOGIC; 
        rst :       in STD_LOGIC; 
        EEC_in:     in STD_LOGIC_VECTOR (31 downto 0); 
        en:         in STD_LOGIC; 
        
        Hi_Wk:      out STD_LOGIC_VECTOR (31 downto 0);     
        Hi_ready:   out STD_LOGIC; 
        Lo_Wk:      out STD_LOGIC_VECTOR (31 downto 0);
        Lo_ready:   out STD_LOGIC;
		end_DWT:    out STD_LOGIC
        );
end DWC_core;

architecture Behavioral of DWC_core is

    component Conv_sym is
    generic (
        size_data_max : integer := 8;  -- Número de entradas
        coef_0:  STD_LOGIC_VECTOR (31 downto 0) := X"FFFFFC51";     
        coef_1:  STD_LOGIC_VECTOR (31 downto 0) := X"00000B70";
        coef_2:  STD_LOGIC_VECTOR (31 downto 0) := X"FFFFF5E8";     
        coef_3:  STD_LOGIC_VECTOR (31 downto 0) :=  X"FFFFFF8E";
        coef_4:  STD_LOGIC_VECTOR (31 downto 0) :=  X"000002FE";     
        coef_5:  STD_LOGIC_VECTOR (31 downto 0) :=  X"0000007E";
        coef_6:  STD_LOGIC_VECTOR (31 downto 0) :=  X"FFFFFF7A";     
        coef_7:  STD_LOGIC_VECTOR (31 downto 0) :=  X"FFFFFFD5"
    );
    Port (
        clk :       in STD_LOGIC; 
        rst :       in STD_LOGIC; 
        EEC_in:     in STD_LOGIC_VECTOR (31 downto 0); 
        en:         in STD_LOGIC; 
        Wk:         out STD_LOGIC_VECTOR (31 downto 0);
        ready:      out STD_LOGIC;                           
        end_convul: out STD_LOGIC 
    );
    end component;

-- General Signals 
   SIGNAL   clks, rsts:     STD_LOGIC:='0';
   
-- Signals HI level
   SIGNAL   EEC_ins, Hi_Wks:                       STD_LOGIC_VECTOR (31 downto 0);
   SIGNAL   Hi_ready_s, ens, Hi_end_convuls:       STD_LOGIC:='0';
-- Signals Lo level
   SIGNAL   Lo_Wks:                       STD_LOGIC_VECTOR (31 downto 0);
   SIGNAL   Lo_ready_s, Lo_end_convuls:       STD_LOGIC:='0';
  
  
	--***************** test
	constant MEM_SIZE : integer := 16;  
	type t_Memory is array (0 to MEM_SIZE-1) of std_logic_vector(31 downto 0);
    signal memoria : t_Memory;
    -- Internal signals
    signal write_ptr : integer range 0 to MEM_SIZE-1 := 0;  -- Write pointer
    signal mem_full_flag : STD_LOGIC := '0'; -- Flag to indicate memory is full
	--*************  
  
  
    
begin

    Convula_Hig: Conv_sym
    generic map(
        size_data_max  => 8,  -- Número de entradas
        coef_0 => X"FFFFFC51",     
        coef_1 => X"00000B70",
        coef_2 => X"FFFFF5E8",     
        coef_3 =>  X"FFFFFF8E",
        coef_4 =>  X"000002FE",     
        coef_5 =>  X"0000007E",
        coef_6 =>  X"FFFFFF7A",     
        coef_7 =>  X"FFFFFFD5"
    )
    port map(
        clk     => clk, 
        rst     => rst, 
        EEC_in  => EEC_in, --read_std2
        en      => en,
        Wk      => Hi_Wks,   --WHik
        ready   => Hi_ready_s, 
        end_convul=> Hi_end_convuls
    );
    
    Hi_Wk       <= Hi_Wks;
    Hi_ready    <= Hi_ready_s; 
    
    --******************************
  
    
    Convula_Lo: Conv_sym
    generic map(
        size_data_max  => 8,  -- Número de entradas
        coef_0 => X"FFFFFFFA",     
        coef_1 => X"00000020",
        coef_2 => X"0000001F",     
        coef_3 =>  X"FFFFFFA0",
        coef_4 =>  X"FFFFFFE4",     
        coef_5 =>  X"00000A00",
        coef_6 =>  X"00000B70",     
        coef_7 =>  X"000003B0"
    )
    port map(
        clk     => clk, 
        rst     => rst, 
        EEC_in  => EEC_in, 
        en      => en,
        Wk      => Lo_Wks,   
        ready   => Lo_ready_s, 
        end_convul=> Lo_end_convuls
    );  
    
    --Lo_Wk <= Lo_Wks;
    Lo_ready <=  Lo_ready_s;
    Lo_Wk <= Lo_Wks; -- OR Hi_Wks;
    end_DWT <= Hi_end_convuls or Lo_end_convuls;
    
    
   --*******************************************************
   -- PRUEBA DE PRE ALMACENAMIENTO DE COEFICIENTES DWT
    process(clk, rst)
    begin
        if rst = '1' then
            write_ptr <= 0;              
            mem_full_flag <= '0';        
        elsif rising_edge(clk) then
            if (Lo_ready_s = '1') and  (mem_full_flag = '0') then
                memoria(write_ptr) <= Lo_Wks;
                if write_ptr < MEM_SIZE-1 then
                    write_ptr <= write_ptr + 1;
                else
                    mem_full_flag <= '1'; 
                end if;
            end if;
        end if;
    end process;
   --*******************************************************    
    
end Behavioral;
