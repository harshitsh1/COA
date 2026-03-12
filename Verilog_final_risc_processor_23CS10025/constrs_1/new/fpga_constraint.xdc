# System Clock: 100MHz
set_property -dict { PACKAGE_PIN E3    IOSTANDARD LVCMOS33 } [get_ports clk]
create_clock -period 10.00 -name sys_clk_pin -waveform {0.00 5.00} [get_ports clk]

# Reset Button (Active-High)
set_property -dict { PACKAGE_PIN N17   IOSTANDARD LVCMOS33 } [get_ports reset]

set_property PACKAGE_PIN J15 [get_ports {sw}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw}]

set_property PACKAGE_PIN H17 [get_ports {leds[0]}]
set_property PACKAGE_PIN K15 [get_ports {leds[1]}]
set_property PACKAGE_PIN J13 [get_ports {leds[2]}]
set_property PACKAGE_PIN N14 [get_ports {leds[3]}]
set_property PACKAGE_PIN R18 [get_ports {leds[4]}]
set_property PACKAGE_PIN V17 [get_ports {leds[5]}]
set_property PACKAGE_PIN U17 [get_ports {leds[6]}]
set_property PACKAGE_PIN U16 [get_ports {leds[7]}]
set_property PACKAGE_PIN V16 [get_ports {leds[8]}]
set_property PACKAGE_PIN T15 [get_ports {leds[9]}]
set_property PACKAGE_PIN U14 [get_ports {leds[10]}]
set_property PACKAGE_PIN T16 [get_ports {leds[11]}]
set_property PACKAGE_PIN V15 [get_ports {leds[12]}]
set_property PACKAGE_PIN V14 [get_ports {leds[13]}]
set_property PACKAGE_PIN V12 [get_ports {leds[14]}]
set_property PACKAGE_PIN V11 [get_ports {leds[15]}]

set_property IOSTANDARD LVCMOS33 [get_ports {leds[*]}]


set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]

