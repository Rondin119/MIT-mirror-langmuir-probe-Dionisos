-------------------------------------------------------------------------------
-- Module to scale the input to values more easily worked with in a fractional sense
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Scale is
    port (
    adc_clk        : in std_logic;      -- adc input clock
    clk_rst        : in std_logic; 
    signal_to_scale        : in std_logic_vector(13 downto 0);  -- Floating Voltage input
    
    Scaled_signal       : out std_logic_vector(13 downto 0)
    );  -- BRAM address out


end entity Scale;

architecture Behavioral of Scale is
begin  -- architecture Behavioral
  -- purpose: This core applys a division by 1.28 which will translate the maximum bit number from 8191 to 6400. Thus 1 V on the ADC will result in a bit number of 6400. 
  --          The assosiated resolution of the system is found by dividing 6400 by the value represented by 1 V on the ADC and rounding to the nearist 2^n. These are inexact, but good approximations.
  -- type   : combinational
  -- inputs : adc_clk
  -- outputs: Scaled_signal, waitBRAM
  BRAM_proc : process (adc_clk) is
    variable Curr_mask : integer range -8191 to 8191 := 0;
    variable signal_mask : signed(18 downto 0) := (others => '0') ;
  begin  -- process BRAM_proc
    if rising_edge(adc_clk) then
    if clk_rst = '1' then
    Scaled_signal <= (others => '0');
    signal_mask := to_signed(0,signal_mask'length);
    Scaled_signal <= std_logic_vector(signal_mask(18 downto 5));    
    else
    Curr_mask := to_integer(signed(signal_to_scale));
    signal_mask := to_signed(Curr_mask*25,signal_mask'length);
    Scaled_signal <= std_logic_vector(signal_mask(18 downto 5));
    end if ;
    end if;
  end process BRAM_proc;

end architecture Behavioral;
