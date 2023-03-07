## Project Status Log

**Week 2/27 - 3/5** <br />
**Group:** Project Proposal, ISA <br />
**HQ:** Fully implemented and validated FP_adder.sv. Still working on fixing bugs. 256 edge case tests PASSED. <br />
**HZ:** Expanded 16-bit ISA CPU to 32 bit CPU and verified that previous operations still work as expected. Rewrite assembler to translate Assembly language to our defined 32 bit machine language.<br />
**JQ:** Fully implemented and validated fp_mul.sv, supporting any FP, denormalized FP, or combined operations with minimal error on LSB cause by convertions between shortread and logic. 23 extreme value tests, 1000 random tests, and 256 corner case tests PASSED. <br />
&emsp;Decided to loosen test constraints in the following 3 cases: <br />
1. allow -2 ~ +2 difference (on the LSBs of M) due to shortrealtobits and bitstoshortreal error <br />
2. also allow the difference between 2^(-126) and 2^−126 × (1 − 2^−23) due to same conversion error <br />
3. also have to let 00000000011111111111111111111111 * 00111111100000000000000000000001 and other 7 similar combinations PASS, because modelsim round the former value to 00000000100000000000000000000000 and the later to perfect 1, which introduced a new 100% error - our answer to the above example, 00000000001111111111111111111111, is more precise per the IEEE definition <br />
**QL:** Explored with the camera utility. Understood how cameras could zoom in, zoom out, adjust explosures to capture from computer screens, white boards, or plain paper.<br />

**Week 3/6 - 3/12** <br />
**Group:** <br />
**HQ:** <br />
**HZ:** <br />
**JQ:** <br />
**QL:** <br />

**Week 3/13 - 3/19** <br />
**Group:** <br />
**HQ:** <br />
**HZ:** <br />
**JQ:** <br />
**QL:** <br />

**Week 3/20 - 3/26** <br />
**Group:** <br />
**HQ:** <br />
**HZ:** <br />
**JQ:** <br />
**QL:** <br />

**Week 3/27 - 4/2** <br />
**Group:** <br />
**HQ:** <br />
**HZ:** <br />
**JQ:** <br />
**QL:** <br />

**Week 4/3 - 4/9** <br />
**Group:** <br />
**HQ:** <br />
**HZ:** <br />
**JQ:** <br />
**QL:** <br />

**Week 4/10 - 4/16** <br />
**Group:** <br />
**HQ:** <br />
**HZ:** <br />
**JQ:** <br />
**QL:** <br />

**Week 4/17 - 4/23** <br />
**Group:** <br />
**HQ:** <br />
**HZ:** <br />
**JQ:** <br />
**QL:** <br />

**Week 4/24 - 4/30** <br />
**Group:** <br />
**HQ:** <br />
**HZ:** <br />
**JQ:** <br />
**QL:** <br />

**Week 5/1 - 5/7** <br />
**Group:** <br />
**HQ:** <br />
**HZ:** <br />
**JQ:** <br />
**QL:** <br />

**Week 5/8 - 5/14** <br />
**Group:** <br />
**HQ:** <br />
**HZ:** <br />
**JQ:** <br />
**QL:** <br />
