# FPGA Implementation of CNN Handwritten Character Recognition
## ECE554_SP23 Senior Capstone Design at UW-Madison
**Owned by Team Poor Handwriting:</br>**
&emsp; Supervisor (Instructor): Eric Hoffman</br>
&emsp; Team Lead: Shichen (Justin) Qiao</br>
&emsp; Hardware Architect: Lingkai (Harry) Zhao</br>
&emsp; RTL Design Engineer: Haining Qiu</br>
&emsp; Machine Learning Engineer: Qikun Liu</br>
<br/>
**Project Demo:</br>**
https://youtu.be/7T7qIo2IxYQ

**Summary</br>**
Machine Learning (ML) has been a skyrocketing field in Computer Science in recent years. As computer hardware engineers, we are enthusiastic about hardware implementations of popular software ML architectures to optimize their performance, reliability, and resource usage.</br></br>
Our project involved designing a real-time device for recognizing handwritten letters and digits using an Altera DE1 FPGA Kit. We implemented and validated three different ML architectures: linear classification, a 784-64-10 fully connected neural network (NN), and a LeNet-5 CNN with ReLU activation layers and 36 classes. The training processes were done in Python scripts, and the resulting kernels and weights were stored in hex files and loaded into the FPGA's SRAM units. We wrote assembly code for our custom 32-bit floating-point instruction set architecture (ISA) to perform classification and developed a 5-stage MIPS processor in SystemVerilog to manage image processing, matrix multiplications, and user interfaces. We followed various engineering standards, including IEEE-754 32-bit Floating Point Standard, Video Graphics Array (VGA) display protocol, Universal Asynchronous Receiver-Transmitter (UART) protocol, and Inter-Integrated Circuit (I2C) protocols to achieve our project goals.</br></br>
This report (https://github.com/ShichenQiao/ECE554_SP23_FPGA_Handwriting_Recognition/blob/main/ECE554_Final_Report.pdf) documents the high-level design block diagrams, interfaces between each System Verilog module, implementation details of our software and firmware components, and the potential impacts of our project on society. Additionally, we will provide a final demonstration and discuss each team member's contributions to this senior capstone project.</br></br>
