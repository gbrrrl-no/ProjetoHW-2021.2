onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /cpu1/clk
add wave -noupdate /cpu1/reset
add wave -noupdate /cpu1/CTRL_/st_j
add wave -noupdate /cpu1/CTRL_/counter
add wave -noupdate /cpu1/CTRL_/state
add wave -noupdate /cpu1/CTRL_/funct
add wave -noupdate /cpu1/CTRL_/opcode
add wave -noupdate /cpu1/mux13/selector
add wave -noupdate -radix hexadecimal /cpu1/mux13/data_2
add wave -noupdate -radix hexadecimal /cpu1/mux13/data_out
add wave -noupdate -radix hexadecimal /cpu1/PC_/Saida
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {1050 ps} {2050 ps}
