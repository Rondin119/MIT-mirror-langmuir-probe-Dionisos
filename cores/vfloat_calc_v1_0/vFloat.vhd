-------------------------------------------------------------------------------
-- Module to calculate the vFloat for MLP bias setting
-- This module must be used in conjuction with a divider core and a bram
-- generator core.
-- Started on March 2nd by Charlie Vincent
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vFloatCalc is
  generic (
    Temp_guess   : integer := 1280;
    iSat_guess   : integer := -6400;
    vFloat_guess : integer := 0);
  port (
    adc_clk        : in std_logic;      -- adc input clock
    clk_rst        : in std_logic;      -- reset input
    iSat           : in std_logic_vector(19 downto 0);  -- Floating Voltage input
    Temp           : in std_logic_vector(19 downto 0);  -- Temperature input
    BRAMret        : in std_logic_vector(15 downto 0);  -- data returned by BRAM
    LP_current        : in std_logic_vector(13 downto 0);  -- Voltage input
    LB_Voltage          : in std_logic_vector(13 downto 0);  -- Third bias voltage in cycle
    clk_en         : in std_logic;      -- Clock Enable to set period start
    divider_tdata  : in std_logic_vector(31 downto 0);
    divider_tvalid : in std_logic;

    divisor_tdata   : out std_logic_vector(15 downto 0);
    divisor_tvalid  : out std_logic;
    dividend_tdata  : out std_logic_vector(15 downto 0);
    dividend_tvalid : out std_logic;
    BRAM_addr       : out std_logic_vector(13 downto 0);  -- BRAM address out
    vFloat          : out std_logic_vector(19 downto 0);  -- Saturation current
    Div_result      : out std_logic_vector(31 downto 0);
    data_valid      : out std_logic);

end entity vFloatCalc;

architecture Behavioral of vFloatCalc is

  signal exp_count       : integer range 0 to 31 := 0;
  signal exp_en          : std_logic             := '0';
  signal exp_ret         : signed(13 downto 0)   := (others => '0');
  signal index           : std_logic             := '0';
  signal waitBRAM        : std_logic             := '0';  -- Signal to indicate when
                                        -- to wait for the bram return
  signal storeSig        : signed(13 downto 0)   := (others => '0');
  signal storeSig2       : signed(19 downto 0)   := (others => '0');
  signal vFloat_mask     : integer range -524288 to 524288 := 0;
  signal vFloat_proxy    : signed(19 downto 0)   := to_signed(vFloat_guess, 20);
  signal Sig1_hold : signed(13 downto 0)   := (others => '0');
   signal Sig2_hold : signed(19 downto 0)   := (others => '0');
   signal multip_hold : signed(35 downto 0)   := to_signed(0, 36);
  signal addr_mask_store : std_logic_vector(13 downto 0) := (others => '0');
  signal int_store       : integer := 0;
  signal rem_store       : integer := 0;
  signal reset_proxy     : std_logic := '0';
  signal calc_switch : std_logic := '0';

  signal output_trigger : std_logic := '0';

begin  -- architecture Behavioral

  index <= divider_tvalid;
  --vFloat <= "0000" & BRAMret;
  vFloat <= std_logic_vector(vFloat_proxy);

  -- purpose: Process to do core reset
  -- type   : sequential
  -- inputs : adc_clk, clk_rst, iSat_guess
  -- outputs: iSat
  reset_proc : process (adc_clk) is
  begin  -- process reset_proc
    if rising_edge(adc_clk) then        -- rising clock edge
      if clk_rst = '1' then             -- synchronous reset (active high)
        vFloat_proxy <= to_signed(vFloat_guess, 20);
      else
        if (output_trigger = '1') and (reset_proxy = '0') then
          vFloat_proxy <= to_signed(vFloat_mask,vFloat_proxy'length);
        end if;
      end if;
    end if;
  end process reset_proc;


  -- purpose: Process to Ensure calculations done from an enable pulse before the clear pulse are suppresed
  -- type   : sequential
  -- inputs : adc_clk, clk_rst, iSat_guess
  -- outputs: Temp
  reset_clear : process (adc_clk) is
  begin  -- process reset_proc
    if rising_edge(adc_clk) then        -- rising clock edge
      if clk_rst = '1' then             -- synchronous reset (active high)
      -- Ensure calculations done from an enable pulse before the clear pulse are suppresed
        reset_proxy <= '1';
      elsif (clk_en = '1') then
        reset_proxy <= '0';
      end if;
    end if;
  end process reset_clear;

  -- purpose: Process to calculate Saturation current
  -- type   : combinational
  -- inputs : adc_clk
  -- outputs: saturation current
  vFloat_proc : process (adc_clk) is
  begin
    if rising_edge(adc_clk) then
      if exp_en = '1' then
if calc_switch = '1' then
          vFloat_mask <= to_integer(Sig1_hold) - to_integer(multip_hold(35 downto 12));
else
  vFloat_mask <= to_integer(Sig1_hold) - to_integer(multip_hold(35 downto 10));
  end if;
        data_valid     <= '1';
        output_trigger <= '1';
      else
        data_valid     <= '0';
        output_trigger <= '0';
      end if;
    end if;
  end process vFloat_proc;



-- purpose: Process to calculate Saturation current
  -- type   : combinational
  -- inputs : adc_clk
  -- outputs: saturation current
  vFloat_proc_2 : process (adc_clk) is
  begin
    if rising_edge(adc_clk) then
          multip_hold <= Sig2_hold * signed(BRAMret);

      end if;

  end process vFloat_proc_2;








  -- purpose: Process to calcualte the difference between 0 bias and temperature
  -- type   : sequential
  -- inputs : adc_clk, waitBRAM, storeSig, storeSig2
  -- outputs: difference_hold
  difference_proc : process (adc_clk) is
  begin  -- process difference_proc
    if rising_edge(adc_clk) then        -- rising clock edge
      if waitBRAM = '1' then            -- synchronous reset (active high)
        Sig1_hold <= storeSig;
        Sig2_hold <= storeSig2;
      end if;
    end if;
  end process difference_proc;

  -- purpose: process to set the divisor and dividend for the divider
  -- type   : combinational
  -- inputs : adc_clk
  -- outputs: divisor, dividend, tUser
  div_proc : process (adc_clk) is
    variable divisor_mask : signed(13 downto 0) := (others => '0');
  begin  -- process diff_proc
    if rising_edge(adc_clk) then
      if clk_en = '1' then
        -- Setting the variables to go into the division
        divisor_mask := to_signed(to_integer(signed(iSat)), 14);
        if divisor_mask /= to_signed(0, 14) then
          divisor_tdata <= "00" & std_logic_vector(divisor_mask);
        else
          divisor_tdata <= "00" & std_logic_vector(to_signed(iSat_guess, 14));
        end if;
        dividend_tdata  <= "00" & std_logic_vector(shift_right(signed(LP_current), 0));
        --dividend_tdata  <= "00" & std_logic_vector(signed(Current));
        dividend_tvalid <= '1';
        divisor_tvalid  <= '1';
        --storeSig        <= shift_right(signed(LB_Voltage), 2);
        storeSig        <= signed(LB_Voltage);
        storeSig2       <= signed(Temp);
      else
        -- making them zero otherwise, though strictly this should not be
        -- necessary as we're sending a tvalid signal
        dividend_tvalid <= '0';
        divisor_tvalid  <= '0';
      end if;
    end if;
  end process div_proc;

  -- purpose: process to set the BRAM address for data data retrieval.
  -- type   : combinational
  -- inputs : adc_clk
  -- outputs: BRAM_addr, waitBRAM
  BRAM_proc : process (adc_clk) is
    variable divider_int : integer range -8191 to 8191 := 0;
    variable divider_rem : integer range -4095 to 4095 := 0;
    variable addr_mask   : integer range 0 to 16383    := 0;
  begin  -- process BRAM_proc
    if rising_edge(adc_clk) then
      if index = '1' then
        -- Extracting the integer part and the fractional part returned by the
        -- divider core to use in the bram address mapping
        
        divider_rem := to_integer(signed(divider_tdata(11 downto 0)));
        divider_int := to_integer(signed(divider_tdata(25 downto 12)));
       
       -- Test purposes only
        --divider_rem := 0;
        --divider_int := 0;



        Div_result  <= divider_tdata;
        int_store   <= divider_int;
        rem_store   <= divider_rem;
        case divider_int is
          when -1 =>
            addr_mask   := 0;
            calc_switch <= '0';
          when 0 =>
            addr_mask    := 4095 + (divider_rem*2);
            if addr_mask <= 4095 then
              calc_switch <= '0';
            else
              calc_switch <= '1';
            end if;
          when 1 =>
            addr_mask   := 8191 + (divider_rem*2);
            calc_switch <= '1';
          when 2 =>
            addr_mask   := 12288 + (divider_rem*2);
            calc_switch <= '1';
          when others =>
            if divider_int < -1 then
              addr_mask   := 0;
              calc_switch <= '1';
            elsif divider_int >= 3 then
              addr_mask   := 16383;
              calc_switch <= '1';
            end if;
        end case;
        addr_mask_store <= std_logic_vector(to_unsigned(addr_mask, 14));
        BRAM_addr       <= std_logic_vector(to_unsigned(addr_mask, 14));
        waitBRAM        <= '1';
      else
        waitBRAM <= '0';
      end if;
    end if;
  end process BRAM_proc;

  -- purpose: process to collect bram data after address is set by division module
  -- type   : combinational
  -- inputs : adc_clk
  -- outputs: exp_ret, exp_en
  collect_proc : process (adc_clk) is
  begin  -- process collect_proc
    -- Setting a collection tick to get the right block ram memory back once
    -- the address has been assigned.
    if rising_edge(adc_clk) then
      if waitBRAM = '1' then
        exp_count <= exp_count + 1;
      end if;
      if exp_count = 1 then
        exp_count <= exp_count + 1;
      elsif exp_count = 2 then
        exp_count <= exp_count + 1;
        elsif exp_count = 3 then
        exp_en <= '1';
      end if;
      if exp_en = '1' then
        exp_count <= 0;
        exp_en    <= '0';
      end if;
    end if;
  end process collect_proc;

end architecture Behavioral;
