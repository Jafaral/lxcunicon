//////////////////////
//   gcc -std=c99 -shared -fpic -o luxicon.so luxicon.c -llxc
////////////////////
#include "icall.h"
#include <lxc/lxccontainer.h>

/*
 * Error Codes
 */
#define SETUP_FAILED -1 
//"Failed to setup lxc_container struct"

#define ALREADY_EXISTS -2
//"Container already exists"

#define CREATE_FAILED -3
//"Can't to create container rootfs"


#define UNRECOGNIZED_CONTAINER_ID -4
//"Don't know this container"

#define START_FAILED
//"Failed to start the container"

//    printf("Failed to cleanly shutdown the container, forcing.\n");
//      fprintf(stderr, "Failed to kill the container.\n");

//    fprintf(stderr, "Failed to destroy the container.\n");

#define MAXC 64
word maxc=MAXC;
struct lxc_container *cs[MAXC];
word csid;

word getid(){
  return csid;
}

#define CACHE(c, id) do { id=csid++; cs[id]=c;} while(0)

#define NEWC(name, c) \
  if (!(c = lxc_container_new(name, NULL))) Error(305); /* out of memory */


#define GETCONTAINER( arg, id, c) do {					\
    if (Type(arg) == T_Integer){					\
      id = IntegerVal(arg);						\
      if(( c = get_cont(id)) == NULL) ArgError(1,101);			\
    }									\
    else {								\
      ArgString(1);							\
      NEWC(StringVal(arg), c);						\
      CACHE(c, id);							\
    }									\
  } while (0)

struct lxc_container *get_cont(word id){
  if (id>=0 && id<csid)
    return cs[id];
  else
    return NULL;
}

word
lxcinit(int argc, descriptor *argv)
{
  int i;
  csid = 0;
  for (i=0; i<maxc; i++)
    cs[i]=NULL;
  // return lxc version 
  RetConstString((char *)lxc_get_version());
}


word
exist(int argc, descriptor *argv)
{
  struct lxc_container *c;
  word handle;
  if (argc < 1) Error(130);
  GETCONTAINER(argv[1], handle, c);
  //printf("%s(): handle:%lu\n", __PRETTY_FUNCTION__, handle);
  if (c->is_defined(c))
    RetInteger(handle);
  
  Fail;
}

word
create(int argc, descriptor *argv)
{
  struct lxc_container *c;
  word id=-1;
  if (argc < 1) Error(130);

  ArgString(1);
  ArgString(2);
  ArgString(3);
  ArgString(4);

  GETCONTAINER(argv[1], id, c);

  if (c->is_defined(c)) {
    fprintf(stderr, "Container already exists\n");
    lxc_container_put(c);
    Fail;
  }
  /* Create the container */
  if (!c->createl(c, "download", NULL, NULL, LXC_CREATE_QUIET,
		  "-d", StringVal(argv[2]),
		  "-r", StringVal(argv[3]),
		  "-a", StringVal(argv[4]),
		  NULL)) {
    //fprintf(stderr, "Can't to create container rootfs\n");
    lxc_container_put(c);
    Fail;
  }
  RetInteger(id);    
}

word
start(int argc, descriptor *argv){
  struct lxc_container *c;
  word handle;
  if (argc < 1) Error(130);
  GETCONTAINER(argv[1], handle, c);
  /* Start the container */
  if (!c->start(c, 0, NULL)) {
    //fprintf(stderr, "Failed to start the container\n");
    Fail;
  }

  RetInteger(handle);
}

word
state(int argc, descriptor *argv){
  struct lxc_container *c;
  word id;
  if (argc < 1) Error(130);
  GETCONTAINER(argv[1], id, c);
  //printf("Container PID: %d\n", c->init_pid(c));
  RetString((char *)c->state(c));
}

word
stop(int argc, descriptor *argv){
  struct lxc_container *c;
  word id;
  word timeout;
  if (argc < 2) Error(130);
  GETCONTAINER(argv[1], id, c);
  ArgInteger(2);
  timeout = IntegerVal(argv[2]); 
  /* Stop the container */
  if ((timeout > 0 && c->shutdown(c, timeout)) || (c->stop(c)))
     RetInteger(id);
 
  //fprintf(stderr, "Failed to kill the container.\n");
  Fail;
}

word
shutdown(int argc, descriptor *argv){
  struct lxc_container *c;
  word id;
  word timeout;
  if (argc < 2) Error(130);
  GETCONTAINER(argv[1], id, c);
  ArgInteger(2);
  timeout = IntegerVal(argv[2]);
  /* Stop the container */
  if (!c->shutdown(c, timeout))
    //fprintf(stderr, "Failed to cleanly shutdown the container, forcing.\n");
    Fail;

  RetInteger(id);
}

word
destroy(int argc, descriptor *argv){
  struct lxc_container *c;
  word id;
  if (argc < 1) Error(130);
  GETCONTAINER(argv[1], id, c);

  /* Destroy the container */
  if (!c->destroy(c)) {
    //fprintf(stderr, "Failed to destroy the container.\n");
    Fail;
  }
  RetInteger(id);
}

word
freeze(int argc, descriptor *argv){
  struct lxc_container *c;
  word id;
  if (argc < 1) Error(130);
  GETCONTAINER(argv[1], id, c);

  /* Destroy the container */
  if (!c->freeze(c)) {
    //fprintf(stderr, "Failed to destroy the container.\n");
    Fail;
  }
  RetInteger(id);
}

word
unfreeze(int argc, descriptor *argv){
  struct lxc_container *c;
  word id;
  if (argc < 1) Error(130);
  GETCONTAINER(argv[1], id, c);

  /* Destroy the container */
  if (!c->unfreeze(c)) {
    //fprintf(stderr, "Failed to destroy the container.\n");
    Fail;
  }
  RetInteger(id);
}

word
reboot(int argc, descriptor *argv){
  struct lxc_container *c;
  word id;
  if (argc < 1) Error(130);
  GETCONTAINER(argv[1], id, c);

  /* Destroy the container */
  if (!c->reboot(c)) {
    //fprintf(stderr, "Failed to destroy the container.\n");
    Fail;
  }
  RetInteger(id);
}
