----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 

----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_signed.all;

entity Conv_sym is
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
        Wk:         out STD_LOGIC_VECTOR (31 downto 0);     -- Hi_Wk    
        ready:      out STD_LOGIC;                           -- Hi_ready
        end_convul: out STD_LOGIC
--        Lo_Wk:      out STD_LOGIC_VECTOR (31 downto 0);
--        Lo_ready:   out STD_LOGIC
        );
end Conv_sym;

architecture Behavioral of Conv_sym is
    

    type coef is array (0 to 7) of std_logic_vector(31 downto 0);    
    signal  sig_conv:   coef; 
    signal  Lo_sig_conv:   coef; 
    signal  Hi_coef:    coef; 
    signal  Lo_coef:    coef;
    
     --**************************************************************************
    --  HI COEF DWT
    --**************************************************************************
    -- type signal_in is array (0 to 15) of std_logic_vector(31 downto 0);
    -- constant size_data_max : integer :=8;
    signal  WHikt:        std_logic_vector(63 downto 0);
    signal  size_data:   integer :=0;
    signal  Hi_EEC_in_reg: std_logic_vector(31 downto 0);
    signal  HiM_1, HiM_2, HiM_3, HiM_4: std_logic_vector(31 downto 0);
    signal  Hipar:        boolean := false;
    signal  Hiready_s :   STD_LOGIC := '0';
    type state_type is (st1_wait, st2_op1, st2_op2, st2_op3, st2_op4, st2_op5, st2_op6, st2_op7, st2_op8, st2_op9, st2_op10, st4_end);
    signal state, next_state : state_type;
    signal Hi_Wk_s:         STD_LOGIC_VECTOR (31 downto 0);
    --**************************************************************************
    
    
     --**************************************************************************
    --  LO COEF DWT
    --**************************************************************************
--    constant    Lo_size_data_max:   integer :=8;
--    signal  Lo_Wkt:                 std_logic_vector(63 downto 0);
--    signal  Lo_size_data:           integer :=0;
--    signal  Lo_EEC_in_reg:          std_logic_vector(31 downto 0);
--    signal  Lo_M_1, Lo_M_2, Lo_M_3, Lo_M_4: std_logic_vector(31 downto 0);
--    signal  Lo_par:                 boolean := false;
--    signal  Lo_ready_s :            STD_LOGIC := '0';
--    type Lo_state_type is (Lo_st1_wait, Lo_st2_op1, Lo_st2_op2, Lo_st2_op3, Lo_st2_op4, Lo_st2_op5, Lo_st2_op6, Lo_st2_op7, Lo_st2_op8, Lo_st2_op9, Lo_st2_op10, Lo_st4_end);
--	signal Lo_state, Lo_next_state : Lo_state_type;
--	signal Lo_Wk_s:                STD_LOGIC_VECTOR (31 downto 0);
    --**************************************************************************
    
    
    --***************** test
    constant MEM_SIZE : integer := 16;  
    type t_Memory is array (0 to MEM_SIZE-1) of std_logic_vector(31 downto 0);
    signal memoria : t_Memory;
    -- Internal signals
    signal write_ptr : integer range 0 to MEM_SIZE-1 := 0;  -- Write pointer
    signal mem_full_flag : STD_LOGIC := '0'; -- Flag to indicate memory is full
    --*************
    
-- HI COEFF
-- 11111111111111111111.110001010001 --> FFFFF.C51
-- 00000000000000000000.101101110000 --> 00000.B70
-- 11111111111111111111.010111101000 --> FFFFF.5E8
-- 11111111111111111111.111110001110 --> FFFFF.F8E
-- 00000000000000000000.001011111110 --> 00000.2FE
-- 00000000000000000000.000001111110 --> 00000.07E
-- 11111111111111111111.111101111010 --> FFFFF.F7A
-- 11111111111111111111.111111010101 --> FFFFF.FD5 
--    -0.2303778133088965
--     0.7148465705529157
--    -0.6308807679298589
--    -0.027983769416859854
--     0.18703481171909309
--     0.030841381835560764
--    -0.0328830116668852
--    -0.010597401785069032

-- LO COEFF
--  111111111111111111.111111111010 11 --> FFFFF.FFA
--  000000000000000000.000000100000 11 --> 00000.020
--  000000000000000000.000000011111 01 --> 00000.01F
--  111111111111111111.111110100000 10 --> FFFFF.FA0
--  111111111111111111.111111100100 01 --> FFFFF.FE4
--  000000000000000000.101000000000 00 --> 00000.A00
--  000000000000000000.101101110000 00 --> 00000.B70
--  000000000000000000.001110110000 00 --> 00000.3B0
--
--  -0.01059740178507 
--   0.03288301166689
--   0.03084138183556 
--  -0.18703481171909 
--  -0.02798376941686
--   0.63088076792986
--   0.71484657055292
--   0.23037781330890]

--                

begin
   
    -- Hi pass filter dB4 coefficients
    Hi_coef(0) <= X"FFFFFC51";     Hi_coef(1) <= X"00000B70";
    Hi_coef(2) <= X"FFFFF5E8";     Hi_coef(3) <= X"FFFFFF8E";
    Hi_coef(4) <= X"000002FE";     Hi_coef(5) <= X"0000007E";
    Hi_coef(6) <= X"FFFFFF7A";     Hi_coef(7) <= X"FFFFFFD5";
    
    -- Lo pass filter dB4 coefficients
    Lo_coef(0) <= X"FFFFFFFA";     Lo_coef(1) <= X"00000020";
    Lo_coef(2) <= X"0000001F";     Lo_coef(3) <= X"FFFFFFA0";
    Lo_coef(4) <= X"FFFFFFE4";     Lo_coef(5) <= X"00000A00";
    Lo_coef(6) <= X"00000B70";     Lo_coef(7) <= X"000003B0";
    
    
    --**************************************************************************
    --  HI COEF DWT
    --**************************************************************************   
    --  Calculation
    --conv_proc: process(clk)
    --begin
    --if rising_edge(clk) then
    WHikt <=    sig_conv(0)*coef_0+
                sig_conv(1)*coef_1+
                sig_conv(2)*coef_2+
                sig_conv(3)*coef_3+ 
                sig_conv(4)*coef_4+
                sig_conv(5)*coef_5+
                sig_conv(6)*coef_6+
                sig_conv(7)*coef_7;
    --end if;
    --end process;
    
    Hi_Wk_s <= WHikt(43 downto 12);
    Wk <= Hi_Wk_s;  --Hi_Wk

    eec_reg: process (clk)
    begin
    if rising_edge (clk) then
    if rst = '1' then
         Hi_EEC_in_reg <= (others =>'0');
    else
        Hi_EEC_in_reg <= EEC_in;
    end if;    
    end if;
    end process;
      
    shift_proc: process(clk)
    begin
    if rising_edge(clk) then
    if rst = '1' then
        sig_conv(0) <= (others => '0');    sig_conv(1) <= (others => '0');
        sig_conv(2) <= (others => '0');    sig_conv(3) <= (others => '0');
        sig_conv(4) <= (others => '0');    sig_conv(5) <= (others => '0');
        sig_conv(6) <= (others => '0');    sig_conv(7) <= (others => '0');
        end_convul <= '0';
        HiM_1    <= (others => '0');    HiM_2    <= (others => '0');
        HiM_3    <= (others => '0');    HiM_4    <= (others => '0');
    else
        if state = st1_wait then
            sig_conv(0) <= (others => '0');    sig_conv(1) <= (others => '0');
            sig_conv(2) <= (others => '0');    sig_conv(3) <= (others => '0');
            sig_conv(4) <= (others => '0');    sig_conv(5) <= (others => '0');
            sig_conv(6) <= (others => '0');    sig_conv(7) <= (others => '0');
            end_convul <= '0';
            HiM_1    <= (others => '0');    HiM_2    <= (others => '0');
            HiM_3    <= (others => '0');    HiM_4    <= (others => '0');
        elsif state = st2_op1 then
            sig_conv(4) <= Hi_EEC_in_reg;      
            sig_conv(3) <= Hi_EEC_in_reg; 
            end_convul <= '0';
            HiM_1    <= (others => '0');    HiM_2    <= (others => '0');
            HiM_3    <= (others => '0');    HiM_4    <= (others => '0');
        elsif state = st2_op2 then
            sig_conv(5) <= Hi_EEC_in_reg;      
            sig_conv(2) <= Hi_EEC_in_reg; 
            end_convul <= '0';
            HiM_1    <= (others => '0');    HiM_2    <= (others => '0');
            HiM_3    <= (others => '0');    HiM_4    <= (others => '0');
        elsif state = st2_op3 then
            sig_conv(6) <= Hi_EEC_in_reg;      
            sig_conv(1) <= Hi_EEC_in_reg; 
            end_convul <= '0';
            HiM_1    <= (others => '0');    HiM_2    <= (others => '0');
            HiM_3    <= (others => '0');    HiM_4    <= (others => '0');
        elsif state = st2_op4 then   
            sig_conv(7) <= Hi_EEC_in_reg;      
            sig_conv(0) <= Hi_EEC_in_reg; 
            end_convul <= '0';
            HiM_1    <= (others => '0');    HiM_2    <= (others => '0');
            HiM_3    <= (others => '0');    HiM_4    <= (others => '0');
        elsif state = st2_op5 then     
            sig_conv(0) <= sig_conv(1);     sig_conv(1) <= sig_conv(2);
            sig_conv(2) <= sig_conv(3);     sig_conv(3) <= sig_conv(4);       
            sig_conv(4) <= sig_conv(5);     sig_conv(5) <= sig_conv(6);
            sig_conv(6) <= sig_conv(7);     sig_conv(7) <= Hi_EEC_in_reg;  
            HiM_1    <= sig_conv(7);          HiM_2    <= sig_conv(6); 
            HiM_3    <= sig_conv(5);          HiM_4    <= sig_conv(4); 
            size_data <= size_data + 1;
            end_convul <= '0';     
        elsif state = st2_op6 then   
            sig_conv(0) <= sig_conv(1);     sig_conv(1) <= sig_conv(2);
            sig_conv(2) <= sig_conv(3);     sig_conv(3) <= sig_conv(4);       
            sig_conv(4) <= sig_conv(5);     sig_conv(5) <= sig_conv(6);
            sig_conv(6) <= sig_conv(7);     sig_conv(7) <= sig_conv(7); 
                 end_convul <= '0';      
         elsif state = st2_op7 then   
            sig_conv(0) <= sig_conv(1);     sig_conv(1) <= sig_conv(2);
            sig_conv(2) <= sig_conv(3);     sig_conv(3) <= sig_conv(4);       
            sig_conv(4) <= sig_conv(5);     sig_conv(5) <= sig_conv(6);
            sig_conv(6) <= sig_conv(7);     sig_conv(7) <= HiM_1; 
            end_convul <= '0';
        elsif state = st2_op8 then    
            sig_conv(0) <= sig_conv(1);     sig_conv(1) <= sig_conv(2);
            sig_conv(2) <= sig_conv(3);     sig_conv(3) <= sig_conv(4);       
            sig_conv(4) <= sig_conv(5);     sig_conv(5) <= sig_conv(6);
            sig_conv(6) <= sig_conv(7);     sig_conv(7) <= HiM_2; 
            end_convul <= '0';
        elsif state = st2_op9 then  
            sig_conv(0) <= sig_conv(1);     sig_conv(1) <= sig_conv(2);
            sig_conv(2) <= sig_conv(3);     sig_conv(3) <= sig_conv(4);       
            sig_conv(4) <= sig_conv(5);     sig_conv(5) <= sig_conv(6);
            sig_conv(6) <= sig_conv(7);     sig_conv(7) <= HiM_3;     
            end_convul <= '0';
         elsif state = st2_op10 then 
            sig_conv(0) <= sig_conv(1);     sig_conv(1) <= sig_conv(2);
            sig_conv(2) <= sig_conv(3);     sig_conv(3) <= sig_conv(4);       
            sig_conv(4) <= sig_conv(5);     sig_conv(5) <= sig_conv(6);
            sig_conv(6) <= sig_conv(7);     sig_conv(7) <= HiM_4;     
            
            end_convul <= '0';
        elsif state = st4_end then
            end_convul <= '1';
            HiM_1    <= (others => '0');    HiM_2    <= (others => '0');
            HiM_3    <= (others => '0');    HiM_4    <= (others => '0');
        end if;
    end if;
    end if;    
    end process;
    

   SYNC_PROC: process (clk)
   begin
      if (clk'event and clk = '1') then
         if rst = '1' then
            state <= st1_wait;
         else
            state <= next_state;
         end if;
      end if;
   end process;
   
   NEXT_STATE_DECODE: process (clk) 
 begin
   --next_state <= state;  
   if(rising_edge(clk)) then
   if(rst = '1') then
        next_state <= st1_wait;
   else
   case (state) is
      when st1_wait =>
         if en = '1' then
            next_state <= st2_op1;
         end if;
            
      when st2_op1 =>
         next_state <= st2_op2;
      when st2_op2 =>
         next_state <= st2_op3;
      when st2_op3 =>
         next_state <= st2_op4;
      when st2_op4 =>
         next_state <= st2_op5;
         
      when st2_op5 =>
         if size_data < (size_data_max - 5) then
            next_state <= st2_op5;
         else
            next_state <= st2_op6;
         end if;
      
      when st2_op6 =>
         next_state <= st2_op7;
      when st2_op7 =>
         next_state <= st2_op8;
      when st2_op8 =>
         next_state <= st2_op9;
      when st2_op9 =>
         next_state <= st2_op10;   
      when st2_op10 =>
         next_state <= st4_end;  
      when st4_end =>
         next_state <= st1_wait;  
      when others =>
         next_state <= st1_wait;
      end case;
      end if;
      end if;
   end process; 

-- NEXT_STATE_DECODE: process (state, en, size_data) 
-- begin
--   next_state <= state;  
--   case (state) is
--      when st1_wait =>
--         if en = '1' then
--            next_state <= st2_op1;
--         end if;
            
--      when st2_op1 =>
--         next_state <= st2_op2;
--      when st2_op2 =>
--         next_state <= st2_op3;
--      when st2_op3 =>
--         next_state <= st2_op4;
--      when st2_op4 =>
--         next_state <= st2_op5;
         
--      when st2_op5 =>
--         if size_data < (size_data_max - 5) then
--            next_state <= st2_op5;
--         else
--            next_state <= st2_op6;
--         end if;
      
--      when st2_op6 =>
--         next_state <= st2_op7;
--      when st2_op7 =>
--         next_state <= st2_op8;
--      when st2_op8 =>
--         next_state <= st2_op9;
--      when st2_op9 =>
--         next_state <= st2_op10;   
--      when st2_op10 =>
--         next_state <= st4_end;  
--      when st4_end =>
--         next_state <= st1_wait;  
--      when others =>
--         next_state <= st1_wait;
--      end case;
--   end process; 
   
   
   --************ Ready control  *******
   process(clk, rst)
   begin
   if (clk'event and clk = '1') then
    if rst = '1' then
        Hiready_s <= '0';
        Hipar <= false;
    else
        if ( (state = st2_op4) or (state = st2_op5) or (state = st2_op6) or (state = st2_op7) or (state = st2_op8)
        or (state = st2_op9) or (state = st2_op10) )then
            if Hipar = false then
                Hiready_s <= '1';   
                Hipar <= true;
            else
                Hiready_s <= '0';
                Hipar <= false;
            end if;
        else
            Hiready_s <= '0'; Hipar <= false;
        end if;
    end if;
   end if;
   end process;
   
   ready <= Hiready_s;  --Hi_ready
   --**************************************************************************
      
   --*******************************************************
   -- PRUEBA DE PRE ALMACENAMIENTO DE COEFICIENTES DWT
    process(clk, rst)
    begin
        if rising_edge(clk) then
          if rst = '1' then
             write_ptr <= 0;              
             mem_full_flag <= '0';        
          else
            if (Hiready_s = '1') and  (mem_full_flag = '0') then
                memoria(write_ptr) <= Hi_Wk_s;
                if write_ptr < MEM_SIZE-1 then
                    write_ptr <= write_ptr + 1;
                else
                    mem_full_flag <= '1'; 
                end if;
            end if;
          end if;
        end if;   
    end process;
   --*******************************************************
   
   
   
--    --**************************************************************************
--    --  Lo COEF DWT
--    --**************************************************************************   
--    --  Calculation
--    Lo_Wkt <= Lo_sig_conv(0)*Lo_coef(0)+Lo_sig_conv(1)*Lo_coef(1)+Lo_sig_conv(2)*Lo_coef(2)+Lo_sig_conv(3)*Lo_coef(3)+ Lo_sig_conv(4)*Lo_coef(4)+Lo_sig_conv(5)*Lo_coef(5)+
--    Lo_sig_conv(6)*Lo_coef(6)+Lo_sig_conv(7)*Lo_coef(7);
--    Lo_Wk_s <= Lo_Wkt(43 downto 12);
--    -- Lo_Wk <= Lo_Wk_s;

--    Lo_eec_reg: process (clk)
--    begin
--    if rising_edge (clk) then
--        Lo_EEC_in_reg <= EEC_in;
--    end if;
--    end process;
      
--    Lo_shift_proc: process(clk)
--    begin
--    if rising_edge(clk) then
--    if rst = '1' then
--        Lo_sig_conv(0) <= (others => '0');    Lo_sig_conv(1) <= (others => '0');
--        Lo_sig_conv(2) <= (others => '0');    Lo_sig_conv(3) <= (others => '0');
--        Lo_sig_conv(4) <= (others => '0');    Lo_sig_conv(5) <= (others => '0');
--        Lo_sig_conv(6) <= (others => '0');    Lo_sig_conv(7) <= (others => '0');
--    else
--        if Lo_state = Lo_st1_wait then
--            Lo_sig_conv(0) <= (others => '0');    Lo_sig_conv(1) <= (others => '0');
--            Lo_sig_conv(2) <= (others => '0');    Lo_sig_conv(3) <= (others => '0');
--            Lo_sig_conv(4) <= (others => '0');    Lo_sig_conv(5) <= (others => '0');
--            Lo_sig_conv(6) <= (others => '0');    Lo_sig_conv(7) <= (others => '0');
         
--        elsif Lo_state = Lo_st2_op1 then
--            Lo_sig_conv(4) <= Lo_EEC_in_reg;      
--            Lo_sig_conv(3) <= Lo_EEC_in_reg; 
            
--        elsif Lo_state = Lo_st2_op2 then
--            Lo_sig_conv(5) <= Lo_EEC_in_reg;      
--            Lo_sig_conv(2) <= Lo_EEC_in_reg; 
            
--        elsif Lo_state = Lo_st2_op3 then
--            Lo_sig_conv(6) <= Lo_EEC_in_reg;      
--            Lo_sig_conv(1) <= Lo_EEC_in_reg; 
            
--        elsif Lo_state = Lo_st2_op4 then   
--            Lo_sig_conv(7) <= Lo_EEC_in_reg;      
--            Lo_sig_conv(0) <= Lo_EEC_in_reg; 
        
--        elsif Lo_state = Lo_st2_op5 then     
--            Lo_sig_conv(0) <= Lo_sig_conv(1);     Lo_sig_conv(1) <= Lo_sig_conv(2);
--            Lo_sig_conv(2) <= Lo_sig_conv(3);     Lo_sig_conv(3) <= Lo_sig_conv(4);       
--            Lo_sig_conv(4) <= Lo_sig_conv(5);     Lo_sig_conv(5) <= Lo_sig_conv(6);
--            Lo_sig_conv(6) <= Lo_sig_conv(7);     Lo_sig_conv(7) <= Lo_EEC_in_reg;  
--            Lo_M_1         <= Lo_sig_conv(7);     Lo_M_2    <= Lo_sig_conv(6); 
--            Lo_M_3         <= Lo_sig_conv(5);     Lo_M_4    <= Lo_sig_conv(4); 
--            Lo_size_data <= Lo_size_data + 1;
                 
--        elsif Lo_state = Lo_st2_op6 then   
--            Lo_sig_conv(0) <= Lo_sig_conv(1);     Lo_sig_conv(1) <= Lo_sig_conv(2);
--            Lo_sig_conv(2) <= Lo_sig_conv(3);     Lo_sig_conv(3) <= Lo_sig_conv(4);       
--            Lo_sig_conv(4) <= Lo_sig_conv(5);     Lo_sig_conv(5) <= Lo_sig_conv(6);
--            Lo_sig_conv(6) <= Lo_sig_conv(7);     Lo_sig_conv(7) <= Lo_sig_conv(7); 
                       
--         elsif Lo_state = Lo_st2_op7 then   
--            Lo_sig_conv(0) <= Lo_sig_conv(1);     Lo_sig_conv(1) <= Lo_sig_conv(2);
--            Lo_sig_conv(2) <= Lo_sig_conv(3);     Lo_sig_conv(3) <= Lo_sig_conv(4);       
--            Lo_sig_conv(4) <= Lo_sig_conv(5);     Lo_sig_conv(5) <= Lo_sig_conv(6);
--            Lo_sig_conv(6) <= Lo_sig_conv(7);     Lo_sig_conv(7) <= Lo_M_1; 
            
--        elsif Lo_state = Lo_st2_op8 then    
--            Lo_sig_conv(0) <= Lo_sig_conv(1);     Lo_sig_conv(1) <= Lo_sig_conv(2);
--            Lo_sig_conv(2) <= Lo_sig_conv(3);     Lo_sig_conv(3) <= Lo_sig_conv(4);       
--            Lo_sig_conv(4) <= Lo_sig_conv(5);     Lo_sig_conv(5) <= Lo_sig_conv(6);
--            Lo_sig_conv(6) <= Lo_sig_conv(7);     Lo_sig_conv(7) <= Lo_M_2; 
            
--        elsif Lo_state = Lo_st2_op9 then  
--            Lo_sig_conv(0) <= Lo_sig_conv(1);     Lo_sig_conv(1) <= Lo_sig_conv(2);
--            Lo_sig_conv(2) <= Lo_sig_conv(3);     Lo_sig_conv(3) <= Lo_sig_conv(4);       
--            Lo_sig_conv(4) <= Lo_sig_conv(5);     Lo_sig_conv(5) <= Lo_sig_conv(6);
--            Lo_sig_conv(6) <= Lo_sig_conv(7);     Lo_sig_conv(7) <= Lo_M_3;     
            
--         elsif Lo_state = Lo_st2_op10 then 
--            Lo_sig_conv(0) <= Lo_sig_conv(1);     Lo_sig_conv(1) <= Lo_sig_conv(2);
--            Lo_sig_conv(2) <= Lo_sig_conv(3);     Lo_sig_conv(3) <= Lo_sig_conv(4);       
--            Lo_sig_conv(4) <= Lo_sig_conv(5);     Lo_sig_conv(5) <= Lo_sig_conv(6);
--            Lo_sig_conv(6) <= Lo_sig_conv(7);     Lo_sig_conv(7) <= Lo_M_4;     
            
--        elsif Lo_state = Lo_st4_end then
--        end if;
--    end if;
--    end if;    
--    end process;
    

--   Lo_SYNC_PROC: process (clk)
--   begin
--      if (clk'event and clk = '1') then
--         if rst = '1' then
--            Lo_state <= Lo_st1_wait;
--         else
--            Lo_state <= Lo_next_state;
--         end if;
--      end if;
--   end process;
   
-- Lo_NEXT_STATE_DECODE: process (Lo_state, en, Lo_size_data) 
-- begin
--   Lo_next_state <= Lo_state;  
--   case (Lo_state) is
--      when Lo_st1_wait =>
--         if en = '1' then
--            Lo_next_state <= Lo_st2_op1;
--         end if;
            
--      when Lo_st2_op1 =>
--         Lo_next_state <= Lo_st2_op2;
--      when Lo_st2_op2 =>
--         Lo_next_state <= Lo_st2_op3;
--      when Lo_st2_op3 =>
--         Lo_next_state <= Lo_st2_op4;
--      when Lo_st2_op4 =>
--         Lo_next_state <= Lo_st2_op5;
         
--      when Lo_st2_op5 =>
--         if Lo_size_data < (Lo_size_data_max - 5) then
--            Lo_next_state <= Lo_st2_op5;
--         else
--            Lo_next_state <= Lo_st2_op6;
--         end if;
      
--      when Lo_st2_op6 =>
--         Lo_next_state <= Lo_st2_op7;
--      when Lo_st2_op7 =>
--         Lo_next_state <= Lo_st2_op8;
--      when Lo_st2_op8 =>
--         Lo_next_state <= Lo_st2_op9;
--      when Lo_st2_op9 =>
--         Lo_next_state <= Lo_st2_op10;   
--      when Lo_st2_op10 =>
--         Lo_next_state <= Lo_st4_end;  
--      when Lo_st4_end =>
--         Lo_next_state <= Lo_st1_wait;  
--      when others =>
--         Lo_next_state <= Lo_st1_wait;
--      end case;
--   end process; 
   
   
--   --************ Ready control  *******
--   process(clk)
--   begin
--   if rst = '1' then
--        Lo_ready_s <= '0';
--        Lo_par <= false;
--   else
--   if (clk'event and clk = '1') then
--        if ( (Lo_state = Lo_st2_op4) or (Lo_state = Lo_st2_op5) or (Lo_state = Lo_st2_op6) or (Lo_state = Lo_st2_op7) or (Lo_state = Lo_st2_op8)
--        or (Lo_state = Lo_st2_op9) or (Lo_state = Lo_st2_op10) )then
--            if Lo_par = false then
--                Lo_ready_s <= '1';   
--                Lo_par <= true;
--            else
--                Lo_ready_s <= '0';
--                Lo_par <= false;
--            end if;
--        else
--            Lo_ready_s <= '0'; Lo_par <= false;
--        end if;
--   end if;
--   end if;
--   end process;
   
--   Lo_ready <= Lo_ready_s;
--   --**************************************************************************  
   
--   -- Hi_Wk <= Hi_Wk_s;
--   -- Lo_Wk <= Lo_Wk_s;
   
--   -- Hi_Wk <= Hi_Wk_s;
--   Lo_Wk <= Lo_Wk_s OR Hi_Wk_s;

end Behavioral;
