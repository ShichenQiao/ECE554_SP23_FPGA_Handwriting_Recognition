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
Machine Learning (ML) has been a skyrocketing field in Computer Science in recent years. As computer hardware engineers, we are enthusiastic in hardware implementations of popular software ML architectures to optimize their performance, reliability, and resource consumptions.</br></br>
In this project, we designed a real-time handwritten letter and digit recognition device on Altera DE1 FPGA Kit. More specifically, we implemented and validated three different ML architectures - linear classification, a 784-64-10 fully connected neural network (NN), and a LeNet-like CNN with ReLU activation layers and 36 classes. The training processes were done in software using Python scripts, and obtained kernels and weights are stored in hex files and loaded into our FPGA’s SRAM units. The classification processes were programmed in assembly language specifically designed for our original, 32-bit, floating point instruction set architecture (ISA). Image processing, matrix multiplications, and user interfaces were all managed by a 5-stage MIPS processor designed by us in System Verilog. Various engineering standards, such as IEEE-754 32-bit Floating Point Standard, Video Graphics Array (VGA) display protocol, Universal Asynchronous Receiver-Transmitter (UART) protocol, and Inter-Integrated Circuit (I2C) protocols were all practiced to achieve our project goals.</br></br>
This report documents high-level design block diagrams, interfaces between each System Verilog modules, the implementation details of our software and firmware components, utilized engineering standards, potential impacts on our society, final demonstration, and individual contributions of this senior capstone project.</br></br>
