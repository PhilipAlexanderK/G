#!/bin/bash

fname=sim
infile=output/${fname}.root
outfile=recon/${fname}
Gmacro=main.mac
Cmacro=PET_Geom
Rfile=recon/${fname}_df.Cdh
Rdout=recon/cstr_recon
Fatn=recon/atn.hdr
include_atn=1
is_list=0
infile_list=cstr_list.txt
just_recon=0
TE=60
TS=0

castor-GATEMacToGeom -m $Gmacro -o $Cmacro

if [ $include_atn == 1 ]; then

    if [ -f recon/atn.hdr ]; then 
        rm $Fatn
    fi

    echo "Recon with attenuation correction."
    echo ""

    touch $Fatn
    echo '!name of datafile := /home/vgate/MSFMC/recon/atn.img' >> $Fatn
    echo '!total number of images := 40' >> $Fatn
    echo 'imagedata byte order := LITTLEENDIAN' >> $Fatn
    echo 'number of dimensions := 3' >> $Fatn
    echo '!matrix size [1] := 64' >> $Fatn
    echo '!matrix size [2] := 64' >> $Fatn
    echo '!matrix size [3] := 40' >> $Fatn
    echo '!number format := short float' >> $Fatn
    echo '!number of bytes per pixel := 4' >> $Fatn
    echo 'scaling factor (mm/pixel) [1] := 6.770828' >> $Fatn
    echo 'scaling factor (mm/pixel) [2] := 6.770828' >> $Fatn
    echo 'scaling factor (mm/pixel) [3] := 5' >> $Fatn
    echo 'image duration (sec) := 1' >> $Fatn
    cp output/mumap-MuMap.raw recon/atn.img

    if [ $is_list == 1 ]; then
	    castor-GATERootToCastor -il $infile_list -m $Gmacro -s $Cmacro -o $outfile -vb 2 -atn $Fatn -src
        sed -ie "s/Start time (s): .*/Start time (s): $TS/g" recon/sim_df.Cdh 
        sed -ie "s/Duration (s): .*/Duration (s): $TE/g" recon/sim_df.Cdh
        castor-recon -df $Rfile -oit -1 -it 4:4 -vb 2 -dout $Rdout -atn $Fatn -conv gaussian,10,10,10::post
    else
    	castor-GATERootToCastor -i $infile -m $Gmacro -s $Cmacro -o $outfile -vb 2 -atn $Fatn -src
        castor-recon -df $Rfile -oit -1 -it 4:4 -vb 2 -dout $Rdout -atn $Fatn -conv gaussian,10,10,10::post
    fi
else
    castor-GATERootToCastor -i $infile -m $Gmacro -s $Cmacro -o $outfile -vb 2
    castor-recon -df $Rfile -oit -1 -it 4:4 -vb 2 -dout $Rdout -conv gaussian,10,10,10::post
fi

