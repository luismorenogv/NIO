-------------------------------------------------------------------------------
-- File         : conf_tb_nios_siso_sec_soft.vhd
-- Description  : configuration for nios_siso "sec_soft" simulation
-- Author       : Sabih Gerez, University of Twente
-- Creation date: August 26, 2015
-------------------------------------------------------------------------------
-- $Rev: 1$
-- $Author: gerezsh$
-- $Date: Thu Sep 29 11:57:46 CEST 2022$
-- $Log$
-------------------------------------------------------------------------------

library on_chip_ra;

configuration conf_tb_nios_siso_sec_soft of tb_nios_siso is
  for structural
    for nios_system: nios_siso use entity work.nios_siso(rtl);
      for rtl
        for gp_custom_0: gp_custom use entity work.gp_custom(simple);
        end for;
        for on_chip_ra: nios_siso_on_chip_ra 
          use entity on_chip_ra.nios_siso_on_chip_ra(europa)
            generic map (INIT_FILE => "my_software/sec_soft.hex");
        end for;
      end for;
    end for;
    for tvc: tvc_nios_siso use entity work.tvc_nios_siso(file_io)
          generic map (in_file_name =>  "sec_soft.in",
                       out_file_name => "sec_soft.out");
    end for;
  end for;
end conf_tb_nios_siso_sec_soft;
