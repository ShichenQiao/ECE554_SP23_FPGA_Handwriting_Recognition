#!/usr/bin/perl

########################################################################
# Converts 24-bit color bmp file to a 9-bit color 3-3-3 .hex file for  #
# use with $readmemh.  Also outputs a .pgm image for checking purposes #
########################################################################
use Env;

$infile = $ARGV[0];

open(INFILE,'<:raw',"$infile") || die "ERROR: Can't open $infile for read\n";

my $data = '';
$numbytes = read(INFILE,$data,200000);

printf "read %d bytes from file\n",$numbytes;

my $unpack_str = sprintf "C%d",$numbytes;

printf "format string is %s\n",$unpack_str;

@bytes = unpack $unpack_str, $data;

my $size_encoded = $bytes[4]*256*256 + $bytes[3]*256 + $bytes[2];
if ($size_encoded == $numbytes) { 
  print "Good size encoded equals size read\n";
} else {
  print "ERR: size encoded does not match size read\n";
  exit(1);
}

my $image_start = $bytes[11]*256 + $bytes[10];
printf "image data starts at hex location %x\n",$image_start;

my $xdim = $bytes[19]*256 + $bytes[18];
my $ydim = $bytes[23]*256 + $bytes[22];
printf "image dimensions are %d x %d\n",$xdim,$ydim;

($basename,$junk) = split(/\./,$infile);
$PGMname = $basename.".pgm";
$HEXname = $basename.".hex";

open(OUTFILE, ">$PGMname") || die "ERROR: Can't write $PGMname\n";
open(OUTFILE2, ">$HEXname") || die "ERROR: Can't write $HEXname\n";
$ln = 0;

############################
# First two lines of .hex file are xdim and ydim
############################
printf OUTFILE2 "@%04x %03x\n",$ln++,$xdim;
printf OUTFILE2 "@%04x %03x\n",$ln++,$ydim;
print OUTFILE "P2\r";						# part of PGM header
printf OUTFILE "%d %d\r",$xdim,$ydim;		# part of PGM header
printf OUTFILE "511\r";						# 9-bit color
for ($y = $ydim-1; $y>=0; $y--) {				# for all the rows
  for ($x = 0; $x<$xdim; $x++) {   			# for all the columns
      $img_indx = $image_start+$y*$xdim*3+$x*3;
      $blue = $bytes[$img_indx];
	  $green = $bytes[$img_indx+1];
	  $red = $bytes[$img_indx+2];
	  if (($blue==16) && ($green==32) && ($red==64)) { 	# is transparent
	    $is_transparent = 1;
	  }
	  else {
		$is_transparent = 0;
	  }
	  
	  $red = $red&0x00E0;					# loose lower 5-bits
	  $pixel = $red<<1;
	  $green = $green&0x00E0;				# loose lower 5-bits
	  $pixel |= ($green>>2);
	  $blue = $blue>>5;						# loose lower 5-bits
	  $pixel |= $blue;
	  if (($pixel==136) && ($is_transparent==0)) {	# if mapped to transparent but shouldn't
		  $pixel==135;
		  print "it ";
	  }
      printf OUTFILE "%d ",$pixel;
	  printf OUTFILE2 "@%04x %03x\n",$ln,$pixel;
	  $ln++;
  }
  print OUTFILE "\r";
}
close(OUTFILE);
close(OUTFILE2);

$ROMname = "BMP_ROM_".$basename.".v";
open(OUTFILE3, ">$ROMname") || die "ERROR: Can't write $ROMname\n";

print OUTFILE3 "module BMP_ROM_$basename(clk,addr,dout);\n\n";
print OUTFILE3 "  input clk;     // 50MHz clock\n";
print OUTFILE3 "  input [15:0] addr;\n";
print OUTFILE3 "  output reg [8:0] dout;   // 9-bit color pixel out\n\n";
printf OUTFILE3 "  reg [8:0] rom[0:%d];\n\n",$ln-1;
print OUTFILE3 "  initial\n";
print OUTFILE3 "    \$readmemh(\"$HEXname\",rom);\n\n";
print OUTFILE3 "  always @(posedge clk)\n";
print OUTFILE3 "    dout <= rom[addr];\n\n";
print OUTFILE3 "endmodule\n";

close(OUTFILE3)





