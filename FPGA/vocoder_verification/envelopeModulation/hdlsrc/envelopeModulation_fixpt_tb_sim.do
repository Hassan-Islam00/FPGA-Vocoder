onerror {quit -f}
onbreak {quit -f}
vsim -voptargs=+acc work.envelopeModulation_fixpt_tb

add wave sim:/envelopeModulation_fixpt_tb/u_envelopeModulation_fixpt/clk
add wave sim:/envelopeModulation_fixpt_tb/u_envelopeModulation_fixpt/reset
add wave sim:/envelopeModulation_fixpt_tb/u_envelopeModulation_fixpt/clk_enable
add wave sim:/envelopeModulation_fixpt_tb/u_envelopeModulation_fixpt/tMod_re
add wave sim:/envelopeModulation_fixpt_tb/u_envelopeModulation_fixpt/tMod_im
add wave sim:/envelopeModulation_fixpt_tb/u_envelopeModulation_fixpt/tCarr_re
add wave sim:/envelopeModulation_fixpt_tb/u_envelopeModulation_fixpt/tCarr_im
add wave sim:/envelopeModulation_fixpt_tb/u_envelopeModulation_fixpt/validIn
add wave sim:/envelopeModulation_fixpt_tb/u_envelopeModulation_fixpt/ce_out
add wave sim:/envelopeModulation_fixpt_tb/u_envelopeModulation_fixpt/yOut_re
add wave sim:/envelopeModulation_fixpt_tb/yOut_re_ref
add wave sim:/envelopeModulation_fixpt_tb/u_envelopeModulation_fixpt/yOut_im
add wave sim:/envelopeModulation_fixpt_tb/yOut_im_ref
add wave sim:/envelopeModulation_fixpt_tb/u_envelopeModulation_fixpt/validOut
add wave sim:/envelopeModulation_fixpt_tb/validOut_ref
run -all
quit -f
