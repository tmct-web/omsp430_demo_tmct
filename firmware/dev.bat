echo off
path %PATH%;C:\dev\msp430-gcc\bin;C:\dev\msp430-gcc\include;C:\dev\GnuWin32\bin

echo "To start the mini-debugger..."
echo "1) Type 'cd .\tools\bin' to change the current folder."
echo "2) tclsh[Enter] to run tcl script console."
echo "3) After the TCL prompt,type 'source openmsp430-minidebug.tcl' to run debugger."

cmd /k
