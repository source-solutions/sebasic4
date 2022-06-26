rm fat-16.hdf
hdfmonkey create --fat16 fat-16.hdf 4MB CHLOEHD
hdfmonkey mkdir fat-16.hdf SYSTEM
hdfmonkey mkdir fat-16.hdf PROGRAMS
hdfmonkey mkdir fat-16.hdf PROGRAMS/2019
hdfmonkey mkdir fat-16.hdf PROGRAMS/HELP
hdfmonkey mkdir fat-16.hdf PROGRAMS/RUNBASIC
hdfmonkey mkdir fat-16.hdf PROGRAMS/VDPTEST
hdfmonkey put fat-16.hdf ./chloehd/SYSTEM/* /SYSTEM
hdfmonkey put fat-16.hdf ./chloehd/PROGRAMS/2019/* /PROGRAMS/2019
hdfmonkey put fat-16.hdf ./chloehd/PROGRAMS/HELP/* /PROGRAMS/HELP
hdfmonkey put fat-16.hdf ./chloehd/PROGRAMS/RUNBASIC/* /PROGRAMS/RUNBASIC
hdfmonkey put fat-16.hdf ./chloehd/PROGRAMS/VDPTEST/* /PROGRAMS/VDPTEST
mv fat-16.hdf ../../../fuse/fat-16.hdf
