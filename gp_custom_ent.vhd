-------------------------------------------------------------------------------
-- File         : gp_custom_ent.vhd
-- Description  : entity for general-purpose custom module for NIOS exercise
-- Author       : Sabih Gerez, University of Twente
-- Creation date: September 6, 2015
-------------------------------------------------------------------------------
-- $Rev: 1$
-- $Author: gerezsh$
-- $Date: Thu Sep 29 11:57:46 CEST 2022$
-- $Log$
-------------------------------------------------------------------------------

-- This file was auto-generated as a prototype implementation of a module
-- created in component editor.  It ties off all outputs to ground and
-- ignores all inputs.  It needs to be edited to make it do something
-- useful.
-- 
-- This file will not be automatically regenerated.  You should check it in
-- to your version control system if you want to keep it.

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity gp_custom is
  port (
    clk           : in  std_logic                     := '0';             
    --         clock.clk
    resetn        : in  std_logic                     := '0';             
    --    reset_sink.reset_n
    avs_addr      : in  std_logic_vector(5 downto 0)  := (others => '0'); 
    --  avalon_slave.address
    avs_read      : in  std_logic                     := '0';             
    --              .read
    avs_readdata  : out std_logic_vector(31 downto 0);                    
    --              .readdata
    avs_write     : in  std_logic                     := '0';             
    --              .write
    avs_writedata : in  std_logic_vector(31 downto 0) := (others => '0'); 
    --              .writedata
    siso_req      : out std_logic;                                        
    --      siso_req.export
    siso_ready    : out std_logic;                                        
    --    siso_ready.export
    siso_data_in  : in  std_logic_vector(15 downto 0) := (others => '0'); 
    --  siso_data_in.export
    siso_data_out : out std_logic_vector(15 downto 0);                    
    -- siso_data_out.export
    clk_out       : out std_logic;                                        
    --       clk_out.export
    stop_sim      : out std_logic                                         
    --      stop_sim.export
  );
end entity gp_custom;

