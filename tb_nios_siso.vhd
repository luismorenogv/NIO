-------------------------------------------------------------------------------
-- File         : tb_nios_siso.vhd
-- Description  : testbench for NIOS_SISO system
-- Author       : Sabih Gerez, University of Twente
-- Creation date: August 7, 2015
-------------------------------------------------------------------------------
-- $Rev: 1$
-- $Author: gerezsh$
-- $Date: Thu Sep 29 11:57:47 CEST 2022$
-- $Log$
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity tb_nios_siso is
end entity tb_nios_siso;

architecture structural of tb_nios_siso is
  component nios_siso is
    port (
      clk_clk             : in  std_logic                     := 'X';
      rst_reset_n         : in  std_logic                     := 'X';
      siso_req_export     : out std_logic;
      siso_ready_export   : out std_logic;
      siso_data_in_export : in  std_logic_vector(15 downto 0) 
        := (others => 'X');
      siso_data_out_export: out std_logic_vector(15 downto 0);
      clk_out_export      : out std_logic;
      stop_sim_export     : out std_logic                                        
    );
  end component nios_siso;

  component tvc_nios_siso is
    generic (in_file_name: string := "siso_leon.in";
             out_file_name: string := "siso_leon.out");
    port (
      siso_req      : in  std_logic                     := '0';             
      --      siso_req.export
      siso_ready    : in  std_logic                     := '0';             
      --    siso_ready.export
      siso_data_in  : out std_logic_vector(15 downto 0);                    
      --  siso_data_in.export
      siso_data_out : in  std_logic_vector(15 downto 0) := (others => '0'); 
      -- siso_data_out.export
      stop_sim      : in  std_logic                     := '0';             
      --      stop_sim.export
      tvc_clk       : in  std_logic                     := '0'              
      --       tvc_clk.export
    );
  end component tvc_nios_siso;

  component altera_avalon_clock_source is
    generic (
      CLOCK_RATE : positive := 10;
      CLOCK_UNIT : positive := 1000000
    );
    port (
      clk : out std_logic   -- clk
    );
  end component altera_avalon_clock_source;

  component altera_avalon_reset_source is
    generic (
      ASSERT_HIGH_RESET    : integer := 1;
      INITIAL_RESET_CYCLES : integer := 0
    );
    port (
      reset : out std_logic;        -- reset_n
      clk   : in  std_logic := 'X'  -- clk
    );
  end component altera_avalon_reset_source;

  signal siso_data_in, siso_data_out: std_logic_vector(15 downto 0);
  signal clk, reset, siso_req, siso_ready, stop_sim, tvc_clk: std_logic;
begin
  clk_gen: component altera_avalon_clock_source
    generic map (
      CLOCK_RATE => 50000000,
      CLOCK_UNIT => 1
    )
    port map (
      clk => clk
    );

  rst_gen: component altera_avalon_reset_source
    generic map (
      ASSERT_HIGH_RESET    => 0,
      INITIAL_RESET_CYCLES => 50
    )
    port map (
      reset => reset,
      clk   => clk
    );

  nios_system: component nios_siso
    port map (
      clk_clk              => clk,
      rst_reset_n          => reset,
      siso_req_export      => siso_req,
      siso_ready_export    => siso_ready,
      siso_data_in_export  => siso_data_in,
      siso_data_out_export => siso_data_out,
      clk_out_export       => tvc_clk,
      stop_sim_export      => stop_sim
    );

  tvc: component tvc_nios_siso
    port map (
      siso_req      => siso_req,
      siso_ready    => siso_ready,
      siso_data_in  => siso_data_in,
      siso_data_out => siso_data_out,
      stop_sim      => stop_sim,
      tvc_clk       => tvc_clk
    );
end architecture structural;
