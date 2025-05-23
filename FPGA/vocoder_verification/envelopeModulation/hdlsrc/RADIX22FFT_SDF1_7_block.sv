// -------------------------------------------------------------
// 
// File Name: C:\Users\Hassa\Documents\GitHub\vocoder\MATLAB\MATLAB_CodeGen\codegen\envelopeModulation\hdlsrc\RADIX22FFT_SDF1_7_block.sv
// Created: 2024-03-28 20:55:43
// 
// Generated by MATLAB 23.2, MATLAB Coder 23.2 and HDL Coder 23.2
// 
// 
// -------------------------------------------------------------


import envelopeModulation_fixpt_pkg::* ;

// -------------------------------------------------------------
// 
// Module: RADIX22FFT_SDF1_7_block
// Source Path: envelopeModulation_fixpt/dsphdl.FFT/RADIX22FFT_SDF1_7
// Hierarchy Level: 2
// 
// -------------------------------------------------------------

`timescale 1 ns / 1 ns

module RADIX22FFT_SDF1_7_block
          (  input logic clk,
             input logic reset,
             input logic enb,
             input logic signed [18:0] din_7_1_re_dly  /* sfix19 */,
             input logic signed [18:0] din_7_1_im_dly  /* sfix19 */,
             input logic din_7_vld_dly,
             input logic [2:0] rd_7_Addr  /* ufix3 */,
             input logic rd_7_Enb,
             input logic signed [12:0] twdl_7_1_re  /* sfix13_En11 */,
             input logic signed [12:0] twdl_7_1_im  /* sfix13_En11 */,
             input logic twdl_7_1_vld,
             input logic proc_7_enb,
             input logic softReset,
             output logic signed [19:0] dout_7_1_re  /* sfix20 */,
             output logic signed [19:0] dout_7_1_im  /* sfix20 */,
             output logic dout_7_1_vld,
             output logic dinXTwdl_7_1_vld);


  logic signed [19:0] din_re;  /* sfix20 */
  logic signed [19:0] din_im;  /* sfix20 */
  logic signed [19:0] dinXTwdl_re;  /* sfix20 */
  logic signed [19:0] dinXTwdl_im;  /* sfix20 */
  logic x_vld;
  logic signed [19:0] wrData_im;  /* sfix20 */
  logic [2:0] wrAddr;  /* ufix3 */
  logic wrEnb;
  logic signed [19:0] x_im;  /* sfix20 */
  logic signed [19:0] wrData_re;  /* sfix20 */
  logic signed [19:0] x_re;  /* sfix20 */
  logic signed [20:0] Radix22ButterflyG1_btf1_re_reg;  /* sfix21 */
  logic signed [20:0] Radix22ButterflyG1_btf1_im_reg;  /* sfix21 */
  logic signed [20:0] Radix22ButterflyG1_btf2_re_reg;  /* sfix21 */
  logic signed [20:0] Radix22ButterflyG1_btf2_im_reg;  /* sfix21 */
  logic signed [19:0] Radix22ButterflyG1_x_re_dly1;  /* sfix20 */
  logic signed [19:0] Radix22ButterflyG1_x_im_dly1;  /* sfix20 */
  logic Radix22ButterflyG1_x_vld_dly1;
  logic signed [19:0] Radix22ButterflyG1_dinXtwdl_re_dly1;  /* sfix20 */
  logic signed [19:0] Radix22ButterflyG1_dinXtwdl_im_dly1;  /* sfix20 */
  logic signed [19:0] Radix22ButterflyG1_dinXtwdl_re_dly2;  /* sfix20 */
  logic signed [19:0] Radix22ButterflyG1_dinXtwdl_im_dly2;  /* sfix20 */
  logic Radix22ButterflyG1_dinXtwdl_vld_dly1;
  logic Radix22ButterflyG1_dinXtwdl_vld_dly2;
  logic signed [20:0] Radix22ButterflyG1_btf1_re_reg_next;  /* sfix21 */
  logic signed [20:0] Radix22ButterflyG1_btf1_im_reg_next;  /* sfix21 */
  logic signed [20:0] Radix22ButterflyG1_btf2_re_reg_next;  /* sfix21 */
  logic signed [20:0] Radix22ButterflyG1_btf2_im_reg_next;  /* sfix21 */
  logic signed [20:0] Radix22ButterflyG1_1;  /* sfix21 */
  logic signed [20:0] Radix22ButterflyG1_2;  /* sfix21 */
  logic signed [20:0] Radix22ButterflyG1_3;  /* sfix21 */
  logic signed [20:0] Radix22ButterflyG1_4;  /* sfix21 */
  logic signed [20:0] Radix22ButterflyG1_5;  /* sfix21 */
  logic signed [20:0] Radix22ButterflyG1_6;  /* sfix21 */
  logic signed [20:0] Radix22ButterflyG1_7;  /* sfix21 */
  logic signed [20:0] Radix22ButterflyG1_8;  /* sfix21 */
  logic signed [19:0] xf_re;  /* sfix20 */
  logic signed [19:0] xf_im;  /* sfix20 */
  logic xf_vld;
  logic signed [19:0] dinXTwdlf_re;  /* sfix20 */
  logic signed [19:0] dinXTwdlf_im;  /* sfix20 */
  logic dinxTwdlf_vld;
  logic signed [19:0] btf1_re;  /* sfix20 */
  logic signed [19:0] btf1_im;  /* sfix20 */
  logic signed [19:0] btf2_re;  /* sfix20 */
  logic signed [19:0] btf2_im;  /* sfix20 */
  logic btf_vld;


  assign din_re = {din_7_1_re_dly[18], din_7_1_re_dly};



  assign din_im = {din_7_1_im_dly[18], din_7_1_im_dly};



  Complex4Multiply_block5 u_MUL4 (.clk(clk),
                                  .reset(reset),
                                  .enb(enb),
                                  .din_re(din_re),  /* sfix20 */
                                  .din_im(din_im),  /* sfix20 */
                                  .din_7_vld_dly(din_7_vld_dly),
                                  .twdl_7_1_re(twdl_7_1_re),  /* sfix13_En11 */
                                  .twdl_7_1_im(twdl_7_1_im),  /* sfix13_En11 */
                                  .softReset(softReset),
                                  .dinXTwdl_re(dinXTwdl_re),  /* sfix20 */
                                  .dinXTwdl_im(dinXTwdl_im),  /* sfix20 */
                                  .dinXTwdl_7_1_vld(dinXTwdl_7_1_vld)
                                  );

  always_ff @(posedge clk or posedge reset)
    begin : intdelay_process
      if (reset == 1'b1) begin
        x_vld <= 1'b0;
      end
      else begin
        if (enb) begin
          x_vld <= rd_7_Enb;
        end
      end
    end



  SimpleDualPortRAM_generic #(.AddrWidth(3),
                              .DataWidth(20)
                              )
                            u_dataMEM_im_0_7 (.clk(clk),
                                              .enb(enb),
                                              .wr_din(wrData_im),
                                              .wr_addr(wrAddr),
                                              .wr_en(wrEnb),
                                              .rd_addr(rd_7_Addr),
                                              .dout(x_im)
                                              );

  SimpleDualPortRAM_generic #(.AddrWidth(3),
                              .DataWidth(20)
                              )
                            u_dataMEM_re_0_7 (.clk(clk),
                                              .enb(enb),
                                              .wr_din(wrData_re),
                                              .wr_addr(wrAddr),
                                              .wr_en(wrEnb),
                                              .rd_addr(rd_7_Addr),
                                              .dout(x_re)
                                              );

  // Radix22ButterflyG1
  always_ff @(posedge clk or posedge reset)
    begin : Radix22ButterflyG1_process
      if (reset == 1'b1) begin
        Radix22ButterflyG1_btf1_re_reg <= 21'sb000000000000000000000;
        Radix22ButterflyG1_btf1_im_reg <= 21'sb000000000000000000000;
        Radix22ButterflyG1_btf2_re_reg <= 21'sb000000000000000000000;
        Radix22ButterflyG1_btf2_im_reg <= 21'sb000000000000000000000;
        Radix22ButterflyG1_x_re_dly1 <= 20'sb00000000000000000000;
        Radix22ButterflyG1_x_im_dly1 <= 20'sb00000000000000000000;
        Radix22ButterflyG1_x_vld_dly1 <= 1'b0;
        xf_re <= 20'sb00000000000000000000;
        xf_im <= 20'sb00000000000000000000;
        xf_vld <= 1'b0;
        Radix22ButterflyG1_dinXtwdl_re_dly1 <= 20'sb00000000000000000000;
        Radix22ButterflyG1_dinXtwdl_im_dly1 <= 20'sb00000000000000000000;
        Radix22ButterflyG1_dinXtwdl_re_dly2 <= 20'sb00000000000000000000;
        Radix22ButterflyG1_dinXtwdl_im_dly2 <= 20'sb00000000000000000000;
        Radix22ButterflyG1_dinXtwdl_vld_dly1 <= 1'b0;
        Radix22ButterflyG1_dinXtwdl_vld_dly2 <= 1'b0;
        btf_vld <= 1'b0;
      end
      else begin
        if (enb) begin
          Radix22ButterflyG1_btf1_re_reg <= Radix22ButterflyG1_btf1_re_reg_next;
          Radix22ButterflyG1_btf1_im_reg <= Radix22ButterflyG1_btf1_im_reg_next;
          Radix22ButterflyG1_btf2_re_reg <= Radix22ButterflyG1_btf2_re_reg_next;
          Radix22ButterflyG1_btf2_im_reg <= Radix22ButterflyG1_btf2_im_reg_next;
          xf_re <= Radix22ButterflyG1_x_re_dly1;
          xf_im <= Radix22ButterflyG1_x_im_dly1;
          xf_vld <= Radix22ButterflyG1_x_vld_dly1;
          btf_vld <= Radix22ButterflyG1_dinXtwdl_vld_dly2;
          Radix22ButterflyG1_dinXtwdl_vld_dly2 <= Radix22ButterflyG1_dinXtwdl_vld_dly1;
          Radix22ButterflyG1_dinXtwdl_re_dly2 <= Radix22ButterflyG1_dinXtwdl_re_dly1;
          Radix22ButterflyG1_dinXtwdl_im_dly2 <= Radix22ButterflyG1_dinXtwdl_im_dly1;
          Radix22ButterflyG1_dinXtwdl_re_dly1 <= dinXTwdl_re;
          Radix22ButterflyG1_dinXtwdl_im_dly1 <= dinXTwdl_im;
          Radix22ButterflyG1_x_re_dly1 <= x_re;
          Radix22ButterflyG1_x_im_dly1 <= x_im;
          Radix22ButterflyG1_x_vld_dly1 <= x_vld;
          Radix22ButterflyG1_dinXtwdl_vld_dly1 <= proc_7_enb && dinXTwdl_7_1_vld;
        end
      end
    end

  assign dinxTwdlf_vld = ( ! proc_7_enb) && dinXTwdl_7_1_vld;
  assign Radix22ButterflyG1_1 = {Radix22ButterflyG1_x_re_dly1[19], Radix22ButterflyG1_x_re_dly1};
  assign Radix22ButterflyG1_2 = {Radix22ButterflyG1_dinXtwdl_re_dly2[19], Radix22ButterflyG1_dinXtwdl_re_dly2};
  assign Radix22ButterflyG1_btf1_re_reg_next = Radix22ButterflyG1_1 + Radix22ButterflyG1_2;
  assign Radix22ButterflyG1_3 = {Radix22ButterflyG1_x_re_dly1[19], Radix22ButterflyG1_x_re_dly1};
  assign Radix22ButterflyG1_4 = {Radix22ButterflyG1_dinXtwdl_re_dly2[19], Radix22ButterflyG1_dinXtwdl_re_dly2};
  assign Radix22ButterflyG1_btf2_re_reg_next = Radix22ButterflyG1_3 - Radix22ButterflyG1_4;
  assign Radix22ButterflyG1_5 = {Radix22ButterflyG1_x_im_dly1[19], Radix22ButterflyG1_x_im_dly1};
  assign Radix22ButterflyG1_6 = {Radix22ButterflyG1_dinXtwdl_im_dly2[19], Radix22ButterflyG1_dinXtwdl_im_dly2};
  assign Radix22ButterflyG1_btf1_im_reg_next = Radix22ButterflyG1_5 + Radix22ButterflyG1_6;
  assign Radix22ButterflyG1_7 = {Radix22ButterflyG1_x_im_dly1[19], Radix22ButterflyG1_x_im_dly1};
  assign Radix22ButterflyG1_8 = {Radix22ButterflyG1_dinXtwdl_im_dly2[19], Radix22ButterflyG1_dinXtwdl_im_dly2};
  assign Radix22ButterflyG1_btf2_im_reg_next = Radix22ButterflyG1_7 - Radix22ButterflyG1_8;
  assign dinXTwdlf_re = dinXTwdl_re;
  assign dinXTwdlf_im = dinXTwdl_im;
  assign btf1_re = Radix22ButterflyG1_btf1_re_reg[19:0];
  assign btf1_im = Radix22ButterflyG1_btf1_im_reg[19:0];
  assign btf2_re = Radix22ButterflyG1_btf2_re_reg[19:0];
  assign btf2_im = Radix22ButterflyG1_btf2_im_reg[19:0];



  SDFCommutator7_block u_SDFCOMMUTATOR_7 (.clk(clk),
                                          .reset(reset),
                                          .enb(enb),
                                          .din_7_vld_dly(din_7_vld_dly),
                                          .xf_re(xf_re),  /* sfix20 */
                                          .xf_im(xf_im),  /* sfix20 */
                                          .xf_vld(xf_vld),
                                          .dinXTwdlf_re(dinXTwdlf_re),  /* sfix20 */
                                          .dinXTwdlf_im(dinXTwdlf_im),  /* sfix20 */
                                          .dinxTwdlf_vld(dinxTwdlf_vld),
                                          .btf1_re(btf1_re),  /* sfix20 */
                                          .btf1_im(btf1_im),  /* sfix20 */
                                          .btf2_re(btf2_re),  /* sfix20 */
                                          .btf2_im(btf2_im),  /* sfix20 */
                                          .btf_vld(btf_vld),
                                          .softReset(softReset),
                                          .wrData_re(wrData_re),  /* sfix20 */
                                          .wrData_im(wrData_im),  /* sfix20 */
                                          .wrAddr(wrAddr),  /* ufix3 */
                                          .wrEnb(wrEnb),
                                          .dout_7_1_re(dout_7_1_re),  /* sfix20 */
                                          .dout_7_1_im(dout_7_1_im),  /* sfix20 */
                                          .dout_7_1_vld(dout_7_1_vld)
                                          );

endmodule  // RADIX22FFT_SDF1_7_block

