/*
$Id$


 DVBSNOOP

 a dvb sniffer  and mpeg2 stream analyzer tool
 http://dvbsnoop.sourceforge.net/

 (c) 2001-2006   Rainer.Scherg@gmx.de (rasc)


*/


#ifndef _BIOP_TAG_TAP
#define _BIOP_TAG_TAP


u_long  BIOP_TAG_dispatch (int v, u_char *b);
int     BIOP_TAP (int v, const char *str, u_char *b);


#endif


