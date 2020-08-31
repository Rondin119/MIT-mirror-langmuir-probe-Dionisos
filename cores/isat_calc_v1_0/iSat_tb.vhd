-------------------------------------------------------------------------------
-- Test bench for the SetVolts vhdl module
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

library UNISIM;
use UNISIM.vcomponents.all;

entity tb_Temp is
end entity tb_Temp;

architecture test_bench of tb_Temp is

  ----------------------------------------------------------------------------------------------
  -- Instantiating the Temp module
  component design_1_wrapper is
    port (
      adc_clk       : in std_logic;
      LB_Voltage    : in std_logic_vector(13 downto 0);
      LP_current : in std_logic_vector(13 downto 0);
      Temp_lower_lim : in std_logic_vector(31 downto 0);
      Temp_upper_lim : in std_logic_vector(31 downto 0);
      clk_rst  : in std_logic;
      Vfloat : in std_logic_vector(19 downto 0);
	  Temp : in std_logic_vector(19 downto 0);
		clk_enable  : in std_logic;


	  ISat_out : out std_logic_vector(19 downto 0);
	  gen_out : out std_logic_vector(12 downto 0);
	  blk_out : out std_logic_vector(15 downto 0);
	  Div_result : out std_logic_vector(31 downto 0)
	        );
  end component design_1_wrapper;
  --------------------------------------------------------------------------------------------

  -- COMP_TAG_END ------ End COMPONENT Declaration ------------
  
  ----------------------------------------------------------------------------------------------------
  -- Signals for design_1_wrapper module

  -- input signals
  signal adc_clk       : std_logic                     := '0';
  signal clk_rst       : std_logic                     := '0';
  signal clk_enable       : std_logic                     := '0';  
  signal LB_Voltage : std_logic_vector(13 downto 0) := (others => '0');
signal LP_current : std_logic_vector(13 downto 0) := (others => '0');
signal Temp_lower_lim : std_logic_vector(31 downto 0) := (others => '0');
signal Temp_upper_lim : std_logic_vector(31 downto 0) := (others => '0');
signal Div_result : std_logic_vector(31 downto 0) := (others => '0');









-- output signals
signal Temp : std_logic_vector(19 downto 0) := (others => '0');
signal ISat_out : std_logic_vector(19 downto 0) := (others => '0');
signal VFloat : std_logic_vector(19 downto 0) := (others => '0');
signal gen_out :std_logic_vector(12 downto 0) := (others => '0');
signal blk_out :std_logic_vector(15 downto 0) := (others => '0');


  -- Clock periods
  constant adc_clk_period : time := 8 ns;

  -- Simulation signals


begin  -- architecture behaviour
  -- Instantiating test unit
  uut : design_1_wrapper
    port map (
      	adc_clk       => adc_clk,
      	clk_rst       => clk_rst,
		LB_Voltage  => LB_Voltage,
		LP_current  => LP_current,
		Temp_lower_lim  => Temp_lower_lim,
		Temp_upper_lim  => Temp_upper_lim,
		clk_enable => clk_enable,

		Temp  => Temp,
		ISat_out    =>  ISat_out,
		VFloat  => VFloat,
		gen_out => gen_out,
		blk_out => blk_out,
		Div_result => Div_result
			);

  
  -- Clock process definitions
  adc_clk_process : process
  begin
    adc_clk <= '0';
    wait for adc_clk_period/2;
    adc_clk <= '1';
    wait for adc_clk_period/2;
  end process;

 
  -- Stimulus process
  stim_proc : process
  begin

    clk_rst <= '1';
    LB_Voltage <= std_logic_vector(to_signed(-2054,LB_Voltage'length));
LP_current <= std_logic_vector(to_signed(-1500,LP_current'length));
Temp_lower_lim <= std_logic_vector(to_signed(1*64,Temp_lower_lim'length));
Temp_upper_lim <= std_logic_vector(to_signed(10*64,Temp_upper_lim'length));
VFloat <= std_logic_vector(to_signed(-5280,VFloat'length));
Temp <= std_logic_vector(to_signed(10*64,Temp'length));
wait for adc_clk_period;
clk_rst <= '0';
clk_enable <= '1';
wait for adc_clk_period;
clk_enable <= '0';
wait for adc_clk_period*300;
  end process;

end architecture test_bench;
