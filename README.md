# pic-clb-timer-implementation
This is a repository with the design files of a timer implemented on the Configurable Logic Block module of a PIC16F microcontroller.

- **design.clb**: the main CLB design file. Use the online CLB synthesizer tool (https://logic.microchip.com/clbsynthesizer/) and open this file to access the design.
- **bitstream.S**: the raw bitstream of the design.
- **clbtimer.S**: quick test program showcasing the application of the CLB timer. It's also a good reference on how to manually configure the Mmemory Scanner module to load a bitstream into the Configurable Logic Block module.
