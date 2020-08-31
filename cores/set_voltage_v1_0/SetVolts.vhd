-------------------------------------------------------------------------------
-- Module to set 3 different voltages levels for inital MLP demonstration
-- Started on March 26th by Charlie Vincent
--
-- Adjust variable is to lengthen period to a number that is indivisible by three
-- First two levels will be of length period, third level will be of length
-- period + adjust
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Module to set 3 different voltages levels for inital MLP demonstration
-- Started on March 26th by Charlie Vincent
--
-- Adjust variable is to lengthen period to a number that is indivisible by three
-- First two levels will be of length period, third level will be of length
-- period + adjust
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SetVolts is

  generic (
    period     : integer := 40;
    Temp_guess : integer := 320
    );
  port (
    adc_clk    : in std_logic;          -- adc input clock
    clk_rst    : in std_logic;          -- input clk reset
    period_in  : in std_logic_vector(31 downto 0);
    Temp       : in std_logic_vector(19 downto 0);  -- Temperature sets the voltage bias
    Temp_valid : in std_logic;
    Isat_temp  : in std_logic_vector(19 downto 0); -- user specified temperature to capture Isat
    Temp_min_op : in std_logic;

    store_en  : out std_logic;
    volt_out  : out std_logic_vector(13 downto 0);
    iSat_en   : out std_logic;
    vFloat_en : out std_logic;
    Temp_en   : out std_logic;
    volt1     : out std_logic_vector(13 downto 0);
    volt2     : out std_logic_vector(13 downto 0)
    );

end entity SetVolts;

architecture Behavioral of SetVolts is
  signal output_volts      : signed(13 downto 0)          := to_signed(-8*Temp_guess, 14);  -- mask for the output_volts voltage
  signal counter     : integer                      := 0;  -- counter for setting the voltage levels
  signal level       : integer range 0 to 2         := 0;  -- counter for registering the voltage levels
  signal TempMask    : unsigned(19 downto 0)        := to_unsigned(Temp_guess, 20);
  signal volt_ready  : std_logic_vector(1 downto 0) := (others => '0');
  signal volt1_proxy : signed(13 downto 0)          := to_signed(-8*Temp_guess, 14);
  signal volt2_proxy : signed(13 downto 0)          := to_signed(Temp_guess*3, 14);
  signal volt1_proxy_int : integer                  := 0;
  signal volt2_proxy_int : integer                  := 0;  

  signal TempMask_proxy : integer     := Temp_guess; 
  signal TempMask_proxy_un : unsigned(19 downto 0)  := (others => '0');
  signal period_mask : integer := period;


begin  -- architecture Behavioral
  -- Process to define the level period
  period_proc : process(adc_clk)
  begin
    if rising_edge(adc_clk) then
      if to_integer(unsigned(period_in)) > period then
        period_mask <= to_integer(unsigned(period_in));
      else
        period_mask <= period;
      end if;
    end if;
  end process;

  -- purpose: Process to check when temperature calculation is ready
  -- type   : combinational
  -- inputs : adc_clk
  -- outputs: TempMask
  temp_check_proc : process (adc_clk) is
  begin  -- process temp_check_proc
    if rising_edge(adc_clk) then
      if Temp_valid = '1' then
        if signed(Temp) > to_signed(0, Temp'length) then
          TempMask_proxy_un        <= unsigned(Temp);
         -- TempMask_proxy := shift_right(shift_left(TempMask_proxy, 5) - TempMask_proxy + unsigned(Temp), 5);
        --TempMask_proxy := unsigned(Temp);
        else
          --TempMask       <= to_unsigned(Temp_guess, TempMask'length);
          TempMask_proxy_un <= to_unsigned(Temp_guess, TempMask'length);
        end if;
      elsif (clk_rst = '1') then
          TempMask_proxy_un <= to_unsigned(Temp_guess, TempMask'length);
      end if;
    end if;
  end process temp_check_proc;


volt1_proxy_int_calc : process (adc_clk) is
  begin  -- process volt1_proxy_int_calc shift right and multiplication factor equal -8.51 assumes X50 amp
    if rising_edge(adc_clk) then
      if (unsigned(Isat_temp)>TempMask_proxy_un) and (Temp_min_op = '1') then
          volt1_proxy_int <= -136 * to_integer(shift_right(unsigned(Isat_temp),4));
      else
          volt1_proxy_int <= -136 * to_integer(shift_right(TempMask_proxy_un,4));
      end if;

    end if;
  end process volt1_proxy_int_calc;

volt2_proxy_int_calc : process (adc_clk) is
  begin  -- process volt2_proxy_int_calc shift right and multiplication factor equal 1.728 assumes X50 amp
    if rising_edge(adc_clk) then
      volt2_proxy_int <= 7 * to_integer(shift_right(TempMask_proxy_un,2));
    end if;
  end process volt2_proxy_int_calc;





volt1_proxy_calc : process (adc_clk) is
  begin  -- process volt1_proxy_calc
    if rising_edge(adc_clk) then

      volt1_proxy <= to_signed(volt1_proxy_int, 14);
    end if;
  end process volt1_proxy_calc;

volt2_proxy_calc : process (adc_clk) is
  begin  -- process volt2_proxy_calc
    if rising_edge(adc_clk) then
      volt2_proxy <= to_signed(volt2_proxy_int, 14);

    end if;
  end process volt2_proxy_calc;

  -- Process to advance bias counter
  level_proc : process(adc_clk)
  begin
    if rising_edge(adc_clk) then
      if clk_rst = '1' then             -- if this reset changes then tell Will
        level <= 0;
        counter <= 0;
      else
        counter <= counter + 1;
        if level = 2 then
          if counter = period_mask - 1 then
            counter <= 0;
            level   <= 0;
          end if;
        else
          if counter = period_mask - 1 then
            level   <= level + 1;
            counter <= 0;
          end if;  -- end of counter decision
        end if;
      end if;
    end if;  -- end of rising edge
  end process;

  -- purpose: Process to set when each calculation module is enabled when there is no delay
  -- type   : combinational
  -- inputs : adc_clk
  -- outputs: volt_ready
  en_calc_proc : process (adc_clk) is
  begin  -- process en_calc_proc
    if rising_edge(adc_clk) then
      if counter = period_mask - 3 then
        case level is
          when 0      => volt_ready <= "01";
          when 1      => volt_ready <= "10";
          when 2      => volt_ready <= "11";
          when others => null;
        end case;
      end if;
    end if;
  end process en_calc_proc;

  -- purpose: process to set which calculation to do
  -- type   : combinational
  -- inputs : adc_clk
  -- outputs: iSat_en, vFloat_en, Temp_en
  calc_proc : process (adc_clk) is
    variable change_en   : std_logic_vector(1 downto 0) := "00";
    variable iSat_mask   : std_logic                    := '0';
    variable vFloat_mask : std_logic                    := '0';
    variable Temp_mask   : std_logic                    := '0';
  begin  -- process calc_proc
    if rising_edge(adc_clk) then
      if clk_rst = '1' then
        change_en := "00";
        iSat_mask := '0';
        Temp_mask := '0';
        vFloat_mask := '0';
      else
      if volt_ready = "01" then
        if iSat_mask = '0' and change_en = "00" then
          iSat_en   <= '1';
          iSat_mask := '1';
          change_en := "01";
        else
          iSat_en   <= '0';
          iSat_mask := '0';
        end if;
      elsif volt_ready = "10" then
        if Temp_mask = '0' and change_en = "01" then
          Temp_en   <= '1';
          Temp_mask := '1';
          change_en := "10";
        else
          Temp_en   <= '0';
          Temp_mask := '0';
        end if;
      elsif volt_ready = "11" then
        if vFloat_mask = '0' and change_en = "10" then
          vFloat_en   <= '1';
          vFloat_mask := '1';
          change_en   := "00";
        else
          vFloat_en   <= '0';
          vFloat_mask := '0';
        end if;
      else
        Temp_en   <= '0';
        iSat_en   <= '0';
        vFloat_en <= '0';
      end if;
    end if;
    end if;
  end process calc_proc;





  
-- purpose: Process to set what points are stored 
-- type   : sequential
-- inputs : adc_clk, counter
-- outputs: store_en
  store_proc : process (adc_clk) is
  begin  -- process store_proc
    if rising_edge(adc_clk) then        -- rising clock edge
      if counter = period_mask - 3 then
        store_en <= '1';
      elsif counter = period_mask - 5 then
        store_en <= '1';
      elsif counter = period_mask - 7 then
        store_en <= '1';
      elsif counter = period_mask - 9 then
        store_en <= '1';
      elsif counter = period_mask - 11 then
        store_en <= '1';
      elsif counter = period_mask - 13 then
        store_en <= '1';
      else
        store_en <= '0';
      end if;
    --store_en <= '1';
    end if;
  end process store_proc;

-- Setting the output_mask 
  set_proc : process(adc_clk)
    variable outMask    : signed(13 downto 0) := to_signed(-8*Temp_guess, 14);
    variable level_prev : integer             := 0;
  begin
    if rising_edge(adc_clk) then
      if level_prev /= level then
        if level = 0 then
         outMask := volt1_proxy;
        elsif level = 1 then
         outMask := volt2_proxy;
        elsif level = 2 then
        outMask := to_signed(0, outMask'length);
        end if;
      end if;
      output_volts     <= outMask(13 downto 0);
      --output_volts     <= outMask(13 downto 0);  
      level_prev := level;
    end if;
  end process;

-- Sets the Output Voltage pin
Assign_output : process (adc_clk) is
  begin  -- process Assign_output
    if rising_edge(adc_clk) then        -- rising clock edge
  volt1    <= std_logic_vector(volt1_proxy(13 downto 0));
  volt2    <= std_logic_vector(volt2_proxy(13 downto 0));
  volt_out <= std_logic_vector(output_volts);

      -- rising clock edge
    end if;
  end process;

end architecture Behavioral;
