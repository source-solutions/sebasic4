#! /bin/sh

fuse -mse --rom-spec-se-0 bin/boot.rom --rom-spec-se-1 bin/basic.rom --snapshot fuse/unodos3.szx --divmmc-file fuse/fat-16.hdf
