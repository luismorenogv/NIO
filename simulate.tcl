# -----------------------------------------------------------------------------
# File         : simulate.tcl
# Description  : script to launch a NIOS-based simulation
# Author       : Sabih Gerez, University of Twente
# Creation date: August 26, 2015
# -----------------------------------------------------------------------------
# $Rev: 2$
# $Author: gerezsh$
# $Date: Thu Sep 29 13:19:37 CEST 2022$
# $Log$
# -----------------------------------------------------------------------------


quietly set L_STRING "
 -L altera_ver \
 -L lpm_ver \
 -L sgate_ver \
 -L altera_mf_ver \
 -L altera_lnsim_ver \
 -L cyclonev_ver \
 -L cyclonev_hssi_ver \
 -L cyclonev_pcie_hip_ver \
 -L altera \
 -L lpm \
 -L sgate \
 -L altera_mf \
 -L altera_lnsim \
 -L cyclonev \
 -L error_adapter_0 \
 -L avalon_st_adapter \
 -L rsp_mux_001 \
 -L rsp_mux \
 -L rsp_demux \
 -L cmd_mux_002 \
 -L cmd_mux \
 -L cmd_demux_001 \
 -L cmd_demux \
 -L router_004 \
 -L router_002 \
 -L router_001 \
 -L router \
 -L jtag_uart_0_avalon_jtag_slave_agent_rsp_fifo \
 -L jtag_uart_0_avalon_jtag_slave_agent \
 -L nios2_gen2_data_master_agent \
 -L jtag_uart_0_avalon_jtag_slave_translator \
 -L nios2_gen2_data_master_translator \
 -L cpu \
 -L rst_controller \
 -L irq_mapper \
 -L mm_interconnect_0 \
 -L on_chip_ra \
 -L nios2_gen2 \
 -L jtag_uart_0 "

proc start_sim { design } {
  global L_STRING
  eval vsim $L_STRING "work.$design"
}

proc start_sim_post { design sdf_file } {
  global L_STRING
  eval vsim  +notimingchecks -noglitch \
    -sdftyp /nios_system/gp_custom_0=synopsys_out/$sdf_file $L_STRING "work.$design"
}
