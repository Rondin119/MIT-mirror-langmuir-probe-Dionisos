-------------------------------------------------------------------------------
-- Test bench for the SetVolts vhdl module
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

library UNISIM;
use UNISIM.vcomponents.all;

entity tb_mlp is
end entity tb_mlp;

architecture test_bench of tb_mlp is

  ----------------------------------------------------------------------------------------------
  -- Instantiating the Temp module
  component design_1_wrapper is
    port (
      adc_clk       : in std_logic;
      LB_Voltage    : in std_logic_vector(13 downto 0);
      LP_current : in std_logic_vector(13 downto 0);
      Temp_lower_lim : in std_logic_vector(31 downto 0);
      Temp_upper_lim : in std_logic_vector(31 downto 0);
      Period_in : in std_logic_vector(31 downto 0);
      clk_rst  : in std_logic;
      Isat_temp : in std_logic_vector(31 downto 0);
      temp_min_op  : in std_logic;


	  Isat_out : out std_logic_vector(19 downto 0);
	  Temp_out : out std_logic_vector(19 downto 0);
	  VFloat_out : out std_logic_vector(19 downto 0);
	  Volt_out_2 : out std_logic_vector(13 downto 0);
	  gen_out : out std_logic_vector(12 downto 0);
	  blk_out : out std_logic_vector(15 downto 0);
    save_data : out std_logic_vector(31 downto 0);
	  Temp_en_out : out std_logic;
	  vFloat_en_out : out std_logic;
	  iSat_en_out : out std_logic;
    temp_en : out std_logic;
    save_out : out std_logic
	        );
  end component design_1_wrapper;
  --------------------------------------------------------------------------------------------

  -- COMP_TAG_END ------ End COMPONENT Declaration ------------
  
  ----------------------------------------------------------------------------------------------------
  -- Signals for design_1_wrapper module

-- input signals
signal adc_clk       : std_logic                     := '0';
signal clk_rst       : std_logic                     := '0';
signal LB_Voltage : std_logic_vector(13 downto 0) := (others => '0');
signal LP_current : std_logic_vector(13 downto 0) := (others => '0');
signal Temp_lower_lim : std_logic_vector(31 downto 0) := (others => '0');
signal Temp_upper_lim : std_logic_vector(31 downto 0) := (others => '0');
signal Period_in : std_logic_vector(31 downto 0) := (others => '0');
signal Isat_temp : std_logic_vector(31 downto 0) := (others => '0');
signal temp_min_op       : std_logic                     := '0';

-- output signals
signal Isat : std_logic_vector(19 downto 0) := (others => '0');
signal save_data : std_logic_vector(31 downto 0) := (others => '0');
signal Temp : std_logic_vector(19 downto 0) := (others => '0');
signal VFloat : std_logic_vector(19 downto 0) := (others => '0');
signal Volt_out : std_logic_vector(13 downto 0) := (others => '0');
signal gen_out :std_logic_vector(12 downto 0) := (others => '0');
signal blk_out :std_logic_vector(15 downto 0) := (others => '0');
signal Temp_en_out       : std_logic                     := '0';
signal iSat_en_out       : std_logic                     := '0';
signal vFloat_en_out       : std_logic                     := '0';
signal temp_en       : std_logic                     := '0';
signal save_out       : std_logic                     := '0';

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
		Period_in  => Period_in,
    Isat_temp => Isat_temp,
    temp_min_op => temp_min_op,

		Isat_out  => Isat,
		Temp_out    =>  Temp,
		VFloat_out  => VFloat,
		Volt_out_2  => Volt_out,
		gen_out => gen_out,
		blk_out => blk_out,
		Temp_en_out => Temp_en_out,
		iSat_en_out => iSat_en_out,
		vFloat_en_out => vFloat_en_out,
    temp_en => temp_en,
    save_data => save_data,
    save_out => save_out
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
LB_Voltage <= std_logic_vector(to_signed(0,LB_Voltage'length));
LP_current <= std_logic_vector(to_signed(0,LP_current'length));
Temp_lower_lim <= std_logic_vector(to_signed(64,Temp_lower_lim'length));
Temp_upper_lim <= std_logic_vector(to_signed(640,Temp_upper_lim'length));
Period_in <= std_logic_vector(to_signed(51,Period_in'length));
LB_Voltage <= std_logic_vector(to_signed(261,LB_Voltage'length));
LP_current <= std_logic_vector(to_signed(86,LB_Voltage'length));
temp_min_op <= '1';
Isat_temp <= std_logic_vector(to_unsigned(320,Isat_temp'length));
wait for adc_clk_period;
clk_rst <= '0';
LB_Voltage <= std_logic_vector(to_signed(261,LB_Voltage'length));
LP_current <= std_logic_vector(to_signed(86,LB_Voltage'length));
wait for adc_clk_period*51;
LB_Voltage <= std_logic_vector(to_signed(115,LB_Voltage'length));
LP_current <= std_logic_vector(to_signed(-45,LB_Voltage'length));
wait for adc_clk_period*51;
LB_Voltage <= std_logic_vector(to_signed(139,LB_Voltage'length));
LP_current <= std_logic_vector(to_signed(-21,LB_Voltage'length));
wait for adc_clk_period*51;
LB_Voltage <= std_logic_vector(to_signed(1893,LB_Voltage'length));
LP_current <= std_logic_vector(to_signed(458,LB_Voltage'length));
wait for adc_clk_period*51;
LB_Voltage <= std_logic_vector(to_signed(-86,LB_Voltage'length));
LP_current <= std_logic_vector(to_signed(-287,LB_Voltage'length));
wait for adc_clk_period*51;
LB_Voltage <= std_logic_vector(to_signed(129,LB_Voltage'length));
LP_current <= std_logic_vector(to_signed(-23,LB_Voltage'length));
wait for adc_clk_period*51;
LB_Voltage <= std_logic_vector(to_signed(663,LB_Voltage'length));
LP_current <= std_logic_vector(to_signed(301,LB_Voltage'length));
wait for adc_clk_period*51;
LB_Voltage <= std_logic_vector(to_signed(42,LB_Voltage'length));
LP_current <= std_logic_vector(to_signed(-125,LB_Voltage'length));
wait for adc_clk_period*51;
LB_Voltage <= std_logic_vector(to_signed(130,LB_Voltage'length));
LP_current <= std_logic_vector(to_signed(-23,LB_Voltage'length));
wait for adc_clk_period*51;
LB_Voltage <= std_logic_vector(to_signed(322,LB_Voltage'length));
LP_current <= std_logic_vector(to_signed(129,LB_Voltage'length));
wait for adc_clk_period*51;
LB_Voltage <= std_logic_vector(to_signed(99,LB_Voltage'length));
LP_current <= std_logic_vector(to_signed(-63,LB_Voltage'length));
wait for adc_clk_period*51;
LB_Voltage <= std_logic_vector(to_signed(130,LB_Voltage'length));
LP_current <= std_logic_vector(to_signed(-25,LB_Voltage'length));
wait for adc_clk_period*51;
LB_Voltage <= std_logic_vector(to_signed(254,LB_Voltage'length));
LP_current <= std_logic_vector(to_signed(79,LB_Voltage'length));
wait for adc_clk_period*51;
LB_Voltage <= std_logic_vector(to_signed(110,LB_Voltage'length));
LP_current <= std_logic_vector(to_signed(-52,LB_Voltage'length));
wait for adc_clk_period*51;
LB_Voltage <= std_logic_vector(to_signed(130,LB_Voltage'length));
LP_current <= std_logic_vector(to_signed(-25,LB_Voltage'length));
wait for adc_clk_period*51;









  end process;

end architecture test_bench;
