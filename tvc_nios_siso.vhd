-------------------------------------------------------------------------------
-- File         : tvc_nios_siso.vhd
-- Description  : TVC for NIOS_SISO exercise
-- Author       : Sabih Gerez, University of Twente
-- Creation date: August 7, 2015 (deriverd from LEON version)
-------------------------------------------------------------------------------
-- $Rev: 1$
-- $Author: gerezsh$
-- $Date: Thu Sep 29 11:57:47 CEST 2022$
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
use ieee.std_logic_textio.all;
use std.textio.all;

entity tvc_nios_siso is
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
end entity tvc_nios_siso;

architecture file_io of tvc_nios_siso is
  -- input file
  file in_file: text open Read_mode is in_file_name;
  -- output file
  file out_file: text open Write_mode is out_file_name;
begin
  stimuli: process (tvc_clk)
    variable inline, outline: line;
    variable good: boolean;
    variable input, output: integer;
    variable time_out_counter: integer := 0;
  begin
    if falling_edge(tvc_clk)
    then
      -- handle simulation stop request
      if stop_sim = '1'
      then
        file_close(out_file);
        assert false
          report "OK! Simulation stopped by NIOS software"
          severity failure;
      end if;

      -- handle output
      if siso_ready = '1'
      then
        output := to_integer(signed(siso_data_out));
        write(outline, output);
        writeline(out_file, outline);
      end if; -- siso_ready

      -- handle input signal, take it from file
      if siso_req = '1'
      then
        if endfile(in_file)
        then
          file_close(out_file);
          assert false
            report "OK! Simulation stopped at end of input file." 
            severity failure;
        end if;

        readline(in_file, inline);
        read(inline, input, good);
        if not good
        then
          file_close(out_file);
          assert false
            report "Error during input file processing." severity failure;
        end if;

        -- encode input as a 2's complement signal
        siso_data_in <= std_logic_vector(to_signed(input, 16));
        time_out_counter := 0;
      else
        siso_data_in <= (others => '0');
        time_out_counter := time_out_counter + 1;
        if (time_out_counter > 1000000)
        then
          file_close(out_file);
          assert false
            report "Time out while waiting for siso_req!" severity failure;
        end if;
      end if; -- siso_req = '1'
    end if; -- falling_edge(tvc_clk)
  end process stimuli;


end architecture file_io; -- of tvc_nios_siso
