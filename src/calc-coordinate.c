/* calc-coordinate.c :  entry=calc_coordinate */
/* compiled by EusLisp 9.23( 1.1.0) for Linux64 created on ip-172-31-23-158(Mon Mar 13 06:38:31 PDT 2017) */
#include "eus.h"
#include "calc-coordinate.h"
#pragma init (register_calc_coordinate)
extern double fabs();
extern pointer fcallx();
static void init_ftab();
extern pointer loadglobal(),storeglobal();
static pointer module,*qv,codevec,quotevec;
extern pointer ___calc_coordinate();
extern pointer build_quote_vector();
static int register_calc_coordinate()
  { add_module_initializer("___calc-coordinate", ___calc_coordinate);}

static pointer F437callback_left();
static pointer F438callback_right();
static pointer F439callback_left_camerainfo();
static pointer F440callback_right_camerainfo();
static pointer F441calc_coordinate();

/*callback-left*/
static pointer F437callback_left(ctx,n,argv,env)
register context *ctx;
register int n; register pointer argv[]; pointer env;
{ register pointer *local=ctx->vsp, w, *fqv=qv;
  numunion nu;
	if (n!=1) maerror();
	local[0]= argv[0];
	storeglobal(fqv[0],local[0]);
	w = local[0];
	local[0]= w;
BLK510:
	ctx->vsp=local; return(local[0]);}

/*callback-right*/
static pointer F438callback_right(ctx,n,argv,env)
register context *ctx;
register int n; register pointer argv[]; pointer env;
{ register pointer *local=ctx->vsp, w, *fqv=qv;
  numunion nu;
	if (n!=1) maerror();
	local[0]= argv[0];
	storeglobal(fqv[1],local[0]);
	w = local[0];
	local[0]= w;
BLK511:
	ctx->vsp=local; return(local[0]);}

/*callback-left-camerainfo*/
static pointer F439callback_left_camerainfo(ctx,n,argv,env)
register context *ctx;
register int n; register pointer argv[]; pointer env;
{ register pointer *local=ctx->vsp, w, *fqv=qv;
  numunion nu;
	if (n!=1) maerror();
	local[0]= argv[0];
	storeglobal(fqv[2],local[0]);
	w = local[0];
	local[0]= w;
BLK512:
	ctx->vsp=local; return(local[0]);}

/*callback-right-camerainfo*/
static pointer F440callback_right_camerainfo(ctx,n,argv,env)
register context *ctx;
register int n; register pointer argv[]; pointer env;
{ register pointer *local=ctx->vsp, w, *fqv=qv;
  numunion nu;
	if (n!=1) maerror();
	local[0]= argv[0];
	storeglobal(fqv[3],local[0]);
	w = local[0];
	local[0]= w;
BLK513:
	ctx->vsp=local; return(local[0]);}

/*calc-coordinate*/
static pointer F441calc_coordinate(ctx,n,argv,env)
register context *ctx;
register int n; register pointer argv[]; pointer env;
{ register pointer *local=ctx->vsp, w, *fqv=qv;
  numunion nu;
	if (n!=0) maerror();
	local[0]= fqv[4];
	ctx->vsp=local+1;
	w=(*ftab[0])(ctx,1,local+0,&ftab[0],fqv[5]); /*ros::roseus*/
	local[0]= fqv[6];
	local[1]= loadglobal(fqv[7]);
	ctx->vsp=local+2;
	w=(*ftab[1])(ctx,2,local+0,&ftab[1],fqv[8]); /*ros::advertise*/
	local[0]= fqv[9];
	local[1]= loadglobal(fqv[10]);
	local[2]= (pointer)get_sym_func(fqv[11]);
	ctx->vsp=local+3;
	w=(*ftab[2])(ctx,3,local+0,&ftab[2],fqv[12]); /*ros::subscribe*/
	local[0]= fqv[13];
	local[1]= loadglobal(fqv[10]);
	local[2]= (pointer)get_sym_func(fqv[14]);
	ctx->vsp=local+3;
	w=(*ftab[2])(ctx,3,local+0,&ftab[2],fqv[12]); /*ros::subscribe*/
	ctx->vsp=local+0;
	w=(*ftab[3])(ctx,0,local+0,&ftab[3],fqv[15]); /*ros::time-now*/
	local[0]= w;
WHL515:
	if (loadglobal(fqv[2])==NIL) goto AND518;
	if (loadglobal(fqv[3])==NIL) goto AND518;
	goto WHX516;
AND518:
	ctx->vsp=local+1;
	w=(*ftab[3])(ctx,0,local+1,&ftab[3],fqv[15]); /*ros::time-now*/
	local[1]= w;
	local[2]= local[0];
	ctx->vsp=local+3;
	w=(*ftab[4])(ctx,2,local+1,&ftab[4],fqv[16]); /*ros::time-*/
	local[1]= w;
	local[2]= fqv[17];
	ctx->vsp=local+3;
	w=(pointer)SEND(ctx,2,local+1); /*send*/
	local[1]= w;
	local[2]= makeflt(1.0000000000000000000000e+01);
	ctx->vsp=local+3;
	w=(pointer)GREATERP(ctx,2,local+1); /*>*/
	if (w==NIL) goto IF519;
	local[1]= fqv[18];
	ctx->vsp=local+2;
	w=(*ftab[5])(ctx,1,local+1,&ftab[5],fqv[19]); /*warn*/
	w = NIL;
	ctx->vsp=local+1;
	local[0]=w;
	goto BLK514;
	goto IF520;
IF519:
	local[1]= NIL;
IF520:
	local[1]= makeint((eusinteger_t)1000L);
	{ eusinteger_t i,j;
		j=intval(makeint((eusinteger_t)100L)); i=intval(local[1]);
		local[1]=(makeint(i * j));}
	ctx->vsp=local+2;
	w=(*ftab[6])(ctx,1,local+1,&ftab[6],fqv[20]); /*unix:usleep*/
	ctx->vsp=local+1;
	w=(*ftab[7])(ctx,0,local+1,&ftab[7],fqv[21]); /*ros::spin-once*/
	goto WHL515;
WHX516:
	local[1]= NIL;
BLK517:
	w = local[1];
	local[0]= fqv[22];
	ctx->vsp=local+1;
	w=(*ftab[5])(ctx,1,local+0,&ftab[5],fqv[19]); /*warn*/
	local[0]= NIL;
	local[1]= NIL;
	local[2]= NIL;
	local[3]= NIL;
	local[4]= NIL;
	local[5]= NIL;
	local[6]= NIL;
	local[7]= NIL;
	local[8]= loadglobal(fqv[2]);
	local[9]= fqv[23];
	ctx->vsp=local+10;
	w=(pointer)SEND(ctx,2,local+8); /*send*/
	local[5] = w;
	local[8]= loadglobal(fqv[2]);
	local[9]= fqv[24];
	ctx->vsp=local+10;
	w=(pointer)SEND(ctx,2,local+8); /*send*/
	local[6] = w;
	local[8]= loadglobal(fqv[2]);
	local[9]= fqv[25];
	ctx->vsp=local+10;
	w=(pointer)SEND(ctx,2,local+8); /*send*/
	local[7] = w;
	local[8]= local[5];
	local[9]= local[6];
	local[10]= local[7];
	local[11]= NIL;
	ctx->vsp=local+12;
	w=(*ftab[8])(ctx,4,local+8,&ftab[8],fqv[26]); /*make-camera-from-ros-camera-info-aux*/
	local[0] = w;
	local[8]= loadglobal(fqv[3]);
	local[9]= fqv[23];
	ctx->vsp=local+10;
	w=(pointer)SEND(ctx,2,local+8); /*send*/
	local[5] = w;
	local[8]= loadglobal(fqv[3]);
	local[9]= fqv[24];
	ctx->vsp=local+10;
	w=(pointer)SEND(ctx,2,local+8); /*send*/
	local[6] = w;
	local[8]= loadglobal(fqv[3]);
	local[9]= fqv[25];
	ctx->vsp=local+10;
	w=(pointer)SEND(ctx,2,local+8); /*send*/
	local[7] = w;
	local[8]= local[7];
	local[9]= makeint((eusinteger_t)3L);
	local[10]= local[7];
	local[11]= makeint((eusinteger_t)3L);
	ctx->vsp=local+12;
	w=(pointer)ELT(ctx,2,local+10); /*elt*/
	local[10]= w;
	local[11]= local[7];
	local[12]= makeint((eusinteger_t)0L);
	ctx->vsp=local+13;
	w=(pointer)ELT(ctx,2,local+11); /*elt*/
	local[11]= w;
	ctx->vsp=local+12;
	w=(pointer)QUOTIENT(ctx,2,local+10); /*/*/
	local[10]= w;
	local[11]= makeflt(1.0000000000000000000000e+03);
	ctx->vsp=local+12;
	w=(pointer)TIMES(ctx,2,local+10); /***/
	local[10]= w;
	ctx->vsp=local+11;
	w=(pointer)SETELT(ctx,3,local+8); /*setelt*/
	local[8]= local[5];
	local[9]= local[6];
	local[10]= local[7];
	local[11]= NIL;
	ctx->vsp=local+12;
	w=(*ftab[8])(ctx,4,local+8,&ftab[8],fqv[26]); /*make-camera-from-ros-camera-info-aux*/
	local[1] = w;
	local[8]= local[0];
	local[9]= fqv[27];
	local[10]= local[1];
	ctx->vsp=local+11;
	w=(pointer)SEND(ctx,3,local+8); /*send*/
	local[8]= fqv[28];
	local[9]= loadglobal(fqv[29]);
	local[10]= (pointer)get_sym_func(fqv[30]);
	ctx->vsp=local+11;
	w=(*ftab[2])(ctx,3,local+8,&ftab[2],fqv[12]); /*ros::subscribe*/
	local[8]= fqv[31];
	local[9]= loadglobal(fqv[29]);
	local[10]= (pointer)get_sym_func(fqv[32]);
	ctx->vsp=local+11;
	w=(*ftab[2])(ctx,3,local+8,&ftab[2],fqv[12]); /*ros::subscribe*/
WHL521:
	ctx->vsp=local+8;
	w=(*ftab[9])(ctx,0,local+8,&ftab[9],fqv[33]); /*ros::ok*/
	if (w==NIL) goto WHX522;
	local[8]= NIL;
	storeglobal(fqv[0],local[8]);
	local[8]= NIL;
	storeglobal(fqv[1],local[8]);
	ctx->vsp=local+8;
	w=(*ftab[7])(ctx,0,local+8,&ftab[7],fqv[21]); /*ros::spin-once*/
	if (loadglobal(fqv[0])!=NIL) goto OR526;
	if (loadglobal(fqv[1])!=NIL) goto OR526;
	goto IF524;
OR526:
	if (loadglobal(fqv[0])==NIL) goto IF527;
	local[2] = loadglobal(fqv[0]);
	local[8]= local[2];
	goto IF528;
IF527:
	local[8]= NIL;
IF528:
	if (loadglobal(fqv[1])==NIL) goto IF529;
	local[3] = loadglobal(fqv[1]);
	local[8]= local[3];
	goto IF530;
IF529:
	local[8]= NIL;
IF530:
	if (local[2]==NIL) goto IF531;
	if (local[3]==NIL) goto IF531;
	local[8]= local[2];
	local[9]= fqv[34];
	local[10]= fqv[35];
	ctx->vsp=local+11;
	w=(pointer)SEND(ctx,3,local+8); /*send*/
	local[8]= w;
	local[9]= local[3];
	local[10]= fqv[34];
	local[11]= fqv[35];
	ctx->vsp=local+12;
	w=(pointer)SEND(ctx,3,local+9); /*send*/
	local[9]= w;
	ctx->vsp=local+10;
	w=(pointer)PLUS(ctx,2,local+8); /*+*/
	local[8]= w;
	storeglobal(fqv[36],w);
	local[8]= loadglobal(fqv[36]);
	ctx->vsp=local+9;
	w=(*ftab[10])(ctx,1,local+8,&ftab[10],fqv[37]); /*c-isnan*/
	if (w==NIL) goto IF533;
	local[8]= NIL;
	goto IF534;
IF533:
	local[8]= NIL;
IF534:
	local[8]= local[2];
	local[9]= fqv[38];
	ctx->vsp=local+10;
	w=(pointer)SEND(ctx,2,local+8); /*send*/
	local[4] = w;
	local[8]= local[2];
	local[9]= fqv[34];
	local[10]= fqv[35];
	local[11]= loadglobal(fqv[36]);
	ctx->vsp=local+12;
	w=(pointer)SEND(ctx,4,local+8); /*send*/
	local[8]= local[3];
	local[9]= fqv[34];
	local[10]= fqv[35];
	local[11]= loadglobal(fqv[36]);
	ctx->vsp=local+12;
	w=(pointer)SEND(ctx,4,local+8); /*send*/
	local[8]= local[2];
	local[9]= fqv[34];
	local[10]= fqv[39];
	ctx->vsp=local+11;
	w=(pointer)SEND(ctx,3,local+8); /*send*/
	local[8]= w;
	local[9]= local[2];
	local[10]= fqv[34];
	local[11]= fqv[35];
	ctx->vsp=local+12;
	w=(pointer)SEND(ctx,3,local+9); /*send*/
	local[9]= w;
	ctx->vsp=local+10;
	w=(pointer)MKFLTVEC(ctx,2,local+8); /*float-vector*/
	local[2] = w;
	local[8]= local[3];
	local[9]= fqv[34];
	local[10]= fqv[39];
	ctx->vsp=local+11;
	w=(pointer)SEND(ctx,3,local+8); /*send*/
	local[8]= w;
	local[9]= local[3];
	local[10]= fqv[34];
	local[11]= fqv[35];
	ctx->vsp=local+12;
	w=(pointer)SEND(ctx,3,local+9); /*send*/
	local[9]= w;
	ctx->vsp=local+10;
	w=(pointer)MKFLTVEC(ctx,2,local+8); /*float-vector*/
	local[3] = w;
	local[8]= local[0];
	local[9]= fqv[40];
	local[10]= local[2];
	local[11]= makeint((eusinteger_t)0L);
	ctx->vsp=local+12;
	w=(pointer)ELT(ctx,2,local+10); /*elt*/
	local[10]= w;
	local[11]= local[2];
	local[12]= makeint((eusinteger_t)1L);
	ctx->vsp=local+13;
	w=(pointer)ELT(ctx,2,local+11); /*elt*/
	local[11]= w;
	ctx->vsp=local+12;
	w=(pointer)SEND(ctx,4,local+8); /*send*/
	local[8]= w;
	storeglobal(fqv[41],w);
	local[8]= local[0];
	local[9]= fqv[42];
	ctx->vsp=local+10;
	w=(pointer)SEND(ctx,2,local+8); /*send*/
	local[8]= w;
	local[9]= local[0];
	local[10]= fqv[42];
	ctx->vsp=local+11;
	w=(pointer)SEND(ctx,2,local+9); /*send*/
	local[9]= w;
	local[10]= makeint((eusinteger_t)3000L);
	local[11]= loadglobal(fqv[41]);
	ctx->vsp=local+12;
	w=(pointer)SCALEVEC(ctx,2,local+10); /*scale*/
	local[10]= w;
	ctx->vsp=local+11;
	w=(pointer)VPLUS(ctx,2,local+9); /*v+*/
	local[9]= w;
	ctx->vsp=local+10;
	w=(*ftab[11])(ctx,2,local+8,&ftab[11],fqv[43]); /*make-line*/
	local[8]= w;
	storeglobal(fqv[44],w);
	local[8]= local[1];
	local[9]= fqv[40];
	local[10]= local[3];
	local[11]= makeint((eusinteger_t)0L);
	ctx->vsp=local+12;
	w=(pointer)ELT(ctx,2,local+10); /*elt*/
	local[10]= w;
	local[11]= local[3];
	local[12]= makeint((eusinteger_t)1L);
	ctx->vsp=local+13;
	w=(pointer)ELT(ctx,2,local+11); /*elt*/
	local[11]= w;
	ctx->vsp=local+12;
	w=(pointer)SEND(ctx,4,local+8); /*send*/
	local[8]= w;
	storeglobal(fqv[45],w);
	local[8]= local[1];
	local[9]= fqv[42];
	ctx->vsp=local+10;
	w=(pointer)SEND(ctx,2,local+8); /*send*/
	local[8]= w;
	local[9]= local[1];
	local[10]= fqv[42];
	ctx->vsp=local+11;
	w=(pointer)SEND(ctx,2,local+9); /*send*/
	local[9]= w;
	local[10]= makeint((eusinteger_t)3000L);
	local[11]= loadglobal(fqv[45]);
	ctx->vsp=local+12;
	w=(pointer)SCALEVEC(ctx,2,local+10); /*scale*/
	local[10]= w;
	ctx->vsp=local+11;
	w=(pointer)VPLUS(ctx,2,local+9); /*v+*/
	local[9]= w;
	ctx->vsp=local+10;
	w=(*ftab[11])(ctx,2,local+8,&ftab[11],fqv[43]); /*make-line*/
	local[8]= w;
	storeglobal(fqv[46],w);
	local[8]= loadglobal(fqv[44]);
	local[9]= fqv[47];
	local[10]= loadglobal(fqv[46]);
	ctx->vsp=local+11;
	w=(pointer)SEND(ctx,3,local+8); /*send*/
	local[8]= w;
	local[9]= local[8];
	if (fqv[48]==local[9]) goto IF535;
	local[9]= (pointer)get_sym_func(fqv[49]);
	local[10]= makeflt(5.0000000000000000000000e-01);
	local[11]= loadglobal(fqv[44]);
	local[12]= fqv[47];
	local[13]= loadglobal(fqv[46]);
	ctx->vsp=local+14;
	w=(pointer)SEND(ctx,3,local+11); /*send*/
	local[11]= w;
	ctx->vsp=local+12;
	w=(pointer)APPLY(ctx,3,local+9); /*apply*/
	local[7] = w;
	local[9]= loadglobal(fqv[7]);
	ctx->vsp=local+10;
	w=(pointer)INSTANTIATE(ctx,1,local+9); /*instantiate*/
	local[9]= w;
	local[10]= local[9];
	local[11]= fqv[50];
	local[12]= fqv[38];
	local[13]= local[4];
	local[14]= fqv[34];
	local[15]= loadglobal(fqv[51]);
	ctx->vsp=local+16;
	w=(pointer)INSTANTIATE(ctx,1,local+15); /*instantiate*/
	local[15]= w;
	local[16]= local[15];
	local[17]= fqv[50];
	local[18]= fqv[39];
	local[19]= local[7];
	local[20]= makeint((eusinteger_t)0L);
	ctx->vsp=local+21;
	w=(pointer)ELT(ctx,2,local+19); /*elt*/
	local[19]= w;
	local[20]= fqv[35];
	local[21]= local[7];
	local[22]= makeint((eusinteger_t)1L);
	ctx->vsp=local+23;
	w=(pointer)ELT(ctx,2,local+21); /*elt*/
	local[21]= w;
	local[22]= fqv[52];
	local[23]= local[7];
	local[24]= makeint((eusinteger_t)2L);
	ctx->vsp=local+25;
	w=(pointer)ELT(ctx,2,local+23); /*elt*/
	local[23]= w;
	ctx->vsp=local+24;
	w=(pointer)SEND(ctx,8,local+16); /*send*/
	w = local[15];
	local[15]= w;
	ctx->vsp=local+16;
	w=(pointer)SEND(ctx,6,local+10); /*send*/
	w = local[9];
	local[9]= w;
	storeglobal(fqv[53],w);
	local[9]= fqv[54];
	local[10]= loadglobal(fqv[53]);
	ctx->vsp=local+11;
	w=(*ftab[12])(ctx,2,local+9,&ftab[12],fqv[55]); /*ros::publish*/
	local[9]= w;
	goto IF536;
IF535:
	local[9]= NIL;
IF536:
	w = local[9];
	local[2] = NIL;
	local[3] = NIL;
	local[8]= local[3];
	goto IF532;
IF531:
	local[8]= NIL;
IF532:
	goto IF525;
IF524:
	local[8]= NIL;
IF525:
	local[8]= makeint((eusinteger_t)1000L);
	{ eusinteger_t i,j;
		j=intval(makeint((eusinteger_t)10L)); i=intval(local[8]);
		local[8]=(makeint(i * j));}
	ctx->vsp=local+9;
	w=(*ftab[6])(ctx,1,local+8,&ftab[6],fqv[20]); /*unix:usleep*/
	goto WHL521;
WHX522:
	local[8]= NIL;
BLK523:
	w = local[8];
	local[0]= w;
BLK514:
	ctx->vsp=local; return(local[0]);}

/* initializer*/
pointer ___calc_coordinate(ctx,n,argv,env)
register context *ctx; int n; pointer *argv; pointer env;
{ register pointer *local=ctx->vsp, w, *fqv;
  register int i;
  numunion nu;
  module=argv[0];
  quotevec=build_quote_vector(ctx,QUOTE_STRINGS_SIZE, quote_strings);
  module->c.code.quotevec=quotevec;
  codevec=module->c.code.codevec;
  fqv=qv=quotevec->c.vec.v;
  init_ftab();
	local[0]= fqv[56];
	ctx->vsp=local+1;
	w=(*ftab[13])(ctx,1,local+0,&ftab[13],fqv[57]); /*ros::roseus-add-msgs*/
	local[0]= fqv[58];
	ctx->vsp=local+1;
	w=(*ftab[13])(ctx,1,local+0,&ftab[13],fqv[57]); /*ros::roseus-add-msgs*/
	ctx->vsp=local+0;
	compfun(ctx,fqv[30],module,F437callback_left,fqv[59]);
	ctx->vsp=local+0;
	compfun(ctx,fqv[32],module,F438callback_right,fqv[60]);
	local[0]= NIL;
	storeglobal(fqv[2],local[0]);
	local[0]= NIL;
	storeglobal(fqv[3],local[0]);
	ctx->vsp=local+0;
	compfun(ctx,fqv[11],module,F439callback_left_camerainfo,fqv[61]);
	ctx->vsp=local+0;
	compfun(ctx,fqv[14],module,F440callback_right_camerainfo,fqv[62]);
	ctx->vsp=local+0;
	compfun(ctx,fqv[63],module,F441calc_coordinate,fqv[64]);
	local[0]= fqv[65];
	ctx->vsp=local+1;
	w=(*ftab[5])(ctx,1,local+0,&ftab[5],fqv[19]); /*warn*/
	local[0]= NIL;
	ctx->vsp=local; return(local[0]);}
static void init_ftab()
{  register int i;
  for (i=0; i<14; i++) ftab[i]=fcallx;
}
