/*
$Id$

   
 DVBSNOOP

 a dvb sniffer  and mpeg2 stream analyzer tool
 http://dvbsnoop.sourceforge.net/

 (c) 2001-2006   Rainer.Scherg@gmx.de (rasc)



*/

#ifndef __PESPACKET_H__
#define __PESPACKET_H__ 

void processPS_PES_packet (u_int pid, long pkt_nr, u_char *buf, int len);
void decodePS_PES_packet (u_char *b, u_int len, int pid);


#endif

