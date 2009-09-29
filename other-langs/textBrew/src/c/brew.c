#include "brew.h"
#include <stdio.h>
#include <errno.h>
#include <stdlib.h>
#include <string.h>

// flip this between 1 and 0
//#define PBREW_BUG_COMPAT 1

/**
 * Mallocs and zeros out memory of the requested size.  If the memory
 * can not be allocated (malloc returns NULL), this procedure will
 * report the error to stdout and then abort the process (via exit).
 *
 * @param memSize - the number of bytes to allocate
 * @param file - the file name where mallocAbort is being called (__FILE__).
 * @param func - the function name where mallocAbort is being called (__FUNCTION__).
 * @param lineNum - the line number where mallocAbort is being called (__LINE__).
 */
void* 
mallocAbort( size_t memSize, const char* file, const char* func, int lineNum ) {
  void *thing = malloc(memSize);
  if ( NULL == thing ) {
    fprintf(stderr,"%s->%s(%d): Error allocating memory size=%d, errno: %d error: %s\n",
            __FILE__,__FUNCTION__,__LINE__,
            (int)memSize,
            errno,
            strerror(errno)
            );
    exit(errno);
  }
  memset(thing,'\0',memSize);
  return thing;
}

/**
 * Copy the given string into a newly allocated buffer.  The caller is
 * responsible for freeing the returned buffer.
 * 
 * @param s - the string to copy
 * @return the newly allocated buffer
 */
char*
copyString( const char* s ){
  char* new = (char*)mallocAbort(strlen(s)+1,__FILE__,__FUNCTION__,__LINE__);
  strcpy(new,s);
  return new;
}

/** The dummy PathList */
PathList *pathList_Dummy = NULL;
/** A default configuration. */
BrewConfig* brew_defaultConfig;

/**
 * Construct and initialize a new BrewConfig.  The returned struct is
 * will have been allocated with malloc and the caller is responsible
 * for freeing the memory (via brewConfig_destroy).
 *
 * @param matchCost      - the configured match cost
 * @param insertCost     - the configured insert
 * @param deleteCost     - the configured delete cost
 * @param substituteCost - the configured substitute cost
 * @param printMatrix    - boolean to enable some diagnostic/debugging output (this is different from #define DEBUG 1)
 * @return newly allocated and initialized configuration. 
 */
BrewConfig*
brewConfig_new(float matchCost,float insertCost,float deleteCost,float substituteCost,int printMatrix) {
  BrewConfig* cfg = NULL;
  cfg = (BrewConfig*)mallocAbort(sizeof(BrewConfig),__FILE__,__FUNCTION__,__LINE__);
  DBG(fprintf(stderr,"%s->%s(%d): new config: (m:%f,i:%f,d:%f,s:%f)\n",__FILE__,__FUNCTION__,__LINE__,matchCost,insertCost,deleteCost,substituteCost));
  cfg->matchCost      = matchCost;
  cfg->insertCost     = insertCost;
  cfg->deleteCost     = deleteCost;
  cfg->substituteCost = substituteCost;
  cfg->printMatrix    = printMatrix;
  return cfg;
}

/**
 * Destroy an allocated configuration.
 * @param cfg - the configuration to free.
 */
void
brewConfig_destroy (BrewConfig *cfg) {
  free(cfg);
}

int IsInitialized = 0;

/**
 * Initialize the C library.
 *
 * @see brew_tearDown
 */
void
brew_setUp() {
  if ( !IsInitialized ) {
    pathList_Dummy            = pathList_new();
    pathList_Dummy->editType  = 0;
    pathList_Dummy->leftChar  = '\0';
    pathList_Dummy->rightChar = '\0';
    pathList_Dummy->prev      = NULL;
    pathList_Dummy->next      = NULL;
    brew_defaultConfig        = (BrewConfig*)mallocAbort(sizeof(BrewConfig),__FILE__,__FUNCTION__,__LINE__);
    brew_defaultConfig->matchCost      = 0.0;
    brew_defaultConfig->insertCost     = 0.1;
    brew_defaultConfig->deleteCost     = 15.0;
    brew_defaultConfig->substituteCost = 1.0;
    brew_defaultConfig->printMatrix    = 0; /* false */
    IsInitialized = 1;
  }
}

/**
 * Cleans up default configuration and other items allocated by the
 * library.
 */
void
brew_tearDown() {
  if (IsInitialized) {
    free(pathList_Dummy);
    free(brew_defaultConfig);
    IsInitialized = 0;
  }
}

/**
 * Construct a new path list.  The PathList will have been allocated
 * with malloc and will need to be be freed by the caller.  The
 * recommended way of freeing such an allocated PathList is to call
 * pathList_delete.
 * 
 * @return PathList* - the newly allocated PathList.
 */
PathList*
pathList_new     () {
  PathList *pl = (PathList*)mallocAbort(sizeof(PathList),__FILE__,__FUNCTION__,__LINE__);
  pl->editType = BREW_EDIT_TYPE_INITIAL;
  pl->prev = pathList_Dummy;
  pl->next = pathList_Dummy;
  pl->leftChar  = '\0';
  pl->rightChar = '\0';
  return pl;
}

/**
 * 'Destructor' for a PathList.  Frees the entire list by travering
 * it, not just the pased node.  After you call this, the memory
 * pointed to by the argument will no longer be valid, don't use it!
 * 
 * @param PathList* pl - the PathList to free
 */
void
pathList_delete (PathList*pl) {
  PathList *current = pl;
  DBG(fprintf(stderr,"%s->%s(%d): Dummy:%p hasNext, current=%p next=%p\n",__FILE__,__FUNCTION__,__LINE__,pathList_Dummy,current,current->next));
  while (current && pathList_hasNext(current)) {
    DBG(fprintf(stderr,"%s->%s(%d): Dummy:%p hasNext, current=%p next=%p\n",__FILE__,__FUNCTION__,__LINE__,pathList_Dummy,current,current->next));
    PathList *tmp = current->next;
    free(current);
    current = tmp;
  }

  if (current && current != pathList_Dummy) {
    DBG(fprintf(stderr,"%s->%s(%d): Dummy:%p freeing current, current=%p\n",__FILE__,__FUNCTION__,__LINE__,pathList_Dummy,current));
    free(current);
  }
}


/**
 * Returns true if both the PathList and the pathList->next is not the
 * empty list.
 * 
 * @param PathList *pl - the path list to test.
 * @return true/false
 */
int
pathList_hasNext (PathList* pl) {
  return pl       != pathList_Dummy
      && pl->next != pathList_Dummy;
}


/**
 * Returns true if both the PathList and the pathList->prev is not the
 * empty list.
 *
 * @param PathList *pl - the path list to test.
 * @return true/false
 */
int
pathList_hasPrevious (PathList* pl) {
  return pl       != pathList_Dummy
      && pl->prev != pathList_Dummy;
}


/**
 * Get the previous item from the path list.
 * @param PathList *pl
 * @return NULL or the previous item in the linked list.
 */
PathList*
pathList_prev    (PathList*pl) {
  if ( !pathList_hasPrevious(pl) ) {
    return NULL;
  }

  return pl->prev;
}


/**
 * Get the next item from the path list.
 * 
 * @param PathList *pl
 * @return NULL or the next item in the linked list.
 */
PathList*
pathList_next (PathList*pl) {
  if ( !pathList_hasNext(pl) ) {
    return NULL;
  }

  return pl->next;
}


PathList*
pathList_findEnd (PathList*pl) {
  PathList *tmp = pl;
  while ( pathList_hasNext(tmp) ) {
    tmp = tmp->next;
  }
  return tmp;
}

void
pathList_appendEditType (PathList*pl,int editType,char leftChar,char rightChar) {
  PathList *end      = pathList_findEnd(pl);
  PathList *newItem  = pathList_new();
  end->next          = newItem;
  newItem->prev      = end;
  newItem->editType  = editType;
  newItem->leftChar  = leftChar;
  newItem->rightChar = rightChar;
}

PathList*
pathList_prependEditType (PathList*pl,int editType,char leftChar,char rightChar) {
  PathList *newHead  = pathList_new();
  newHead->next      = pl;
  newHead->editType  = editType;
  newHead->leftChar  = leftChar;
  newHead->rightChar = rightChar;
  pl->prev           = newHead;
  return newHead;
}

int
pathList_length(PathList*pl) {
  if (!pl) {
    return 0;
  }

  int len = 1;
  PathList *tmp = pl;
  while ( tmp->next ) {
    ++len;
    tmp = tmp->next;
  }
  return len;
}

const char*
editTypeToString(int editType) {
  switch(editType) {
  case BREW_EDIT_TYPE_INITIAL:
    return "INITIAL";
  case BREW_EDIT_TYPE_DELETE:
    return "DEL";
  case BREW_EDIT_TYPE_INSERT:
    return "INS";
  case BREW_EDIT_TYPE_MATCH:
    return "MATCH";
  case BREW_EDIT_TYPE_SUBSTITUTE:
    return "SUBST";
  }
  return "UNKNOWN";
}

const char*
editTypeToAbbr(int editType) {
  switch(editType) {
  case BREW_EDIT_TYPE_INITIAL:
    return "*";
  case BREW_EDIT_TYPE_DELETE:
    return "D";
  case BREW_EDIT_TYPE_INSERT:
    return "I";
  case BREW_EDIT_TYPE_MATCH:
    return "M";
  case BREW_EDIT_TYPE_SUBSTITUTE:
    return "S";
  }
  return "U";
}

void
pathList_prettyPrint(PathList*pl,const char* left, const char* right) {
  PathList *tmp = pl;
  fprintf(stderr,"%s->%s(%d): LEN:%d pl=%p{editType:%d;next:%p}",__FILE__,__FUNCTION__,__LINE__,
          pathList_length(pl),tmp,tmp->editType,tmp->next);
  tmp = tmp->next;
  while ( tmp ) {
      fprintf(stderr,"->pl=%p{editType:%d;next:%p;leftChar:%c;rightChar:%c}",tmp,tmp->editType,tmp->next,tmp->leftChar,tmp->rightChar);
    tmp = tmp->next;
  }
  fprintf(stderr,"\n");

  tmp = pl;
  fprintf(stderr,"x EDITS(%s,%s): %s",left,right,editTypeToString(tmp->editType));
  tmp = tmp->next;
  while (tmp) {
    fprintf(stderr,"->%s",editTypeToString(tmp->editType));
    tmp = tmp->next;
  }
  
  fprintf(stderr,"\n");
}

BrewMove* 
move_new() {
  BrewMove* item = (BrewMove*)mallocAbort(sizeof(BrewMove),__FILE__,__FUNCTION__,__LINE__);
  item->bestCost     = 0;
  item->editType     = BREW_EDIT_TYPE_INITIAL;
  item->traceBack    = NULL;
  item->leftChar     = (char*)mallocAbort(2*sizeof(char),__FILE__,__FUNCTION__,__LINE__);
  item->leftChar[0]  = '\0';
  item->leftChar[1]  = '\0';
  item->rightChar    = (char*)mallocAbort(2*sizeof(char),__FILE__,__FUNCTION__,__LINE__);
  item->rightChar[0] = '\0';
  item->rightChar[1] = '\0';
  return item;
}

void
move_destroy(BrewMove* move) {
  free(move->leftChar);
  free(move->rightChar);
  free(move);
}


double
move_getTraceBackBestCost  ( BrewMove* this ) {
  return this->bestCost 
       + (this->traceBack != NULL ? this->traceBack->bestCost : 0.0);
}

void
move_becomeCopyOf ( BrewMove* this, BrewMove* that ) {
  this->bestCost     = that->bestCost;
  this->editType     = that->editType;
  this->traceBack    = that->traceBack;
  DBG(fprintf(stderr,"%s->%s(%d): strcpy from this->'%p'=%s to: => that->%p=%s\n",__FILE__,__FUNCTION__,__LINE__,
              this->leftChar,
              this->leftChar,
              that->rightChar,
              that->rightChar));
  strcpy(this->leftChar,  that->leftChar);
  strcpy(this->rightChar, that->rightChar);
}

char*
move_toString ( BrewMove* move, char* buff, size_t blen ) {
  static char tmpbuff[2048];
  // snprintf(buff,blen,"BrewMove(%p){bestCost:%f;editType:%d;traceBack:%p}",move,move->bestCost,move->editType,move->traceBack);
  buff[0] = '\0';
  strcat(buff,"BrewMove(");
  snprintf(tmpbuff,sizeof(tmpbuff),"%p",move);  strcat(buff,tmpbuff);
  strcat(buff,"){bestCost:");
  snprintf(tmpbuff,sizeof(tmpbuff),"%f",move->bestCost);  
  strcat(buff,tmpbuff);
  strcat(buff,";editType:");
  snprintf(tmpbuff,sizeof(tmpbuff),"%s:%d",editTypeToString(move->editType),move->editType);  
  strcat(buff,tmpbuff);

  strcat(buff,";traceBack:");
  snprintf(tmpbuff,sizeof(tmpbuff),"%p",move->traceBack);  
  strcat(buff,tmpbuff);

  strcat(buff,";leftChar:");
  strcat(buff,move->leftChar);

  strcat(buff,";rightChar:");
  strcat(buff,move->rightChar);

  strcat(buff,"}");
  return buff;
}

BrewMove**
brew_newMoveMatrix(int xlen, int ylen) {
  BrewMove **matrix = (BrewMove**)mallocAbort(sizeof(BrewMove*)*(xlen+1),__FILE__,__FUNCTION__,__LINE__);
  int ii, jj;
  for ( ii = 0; ii <= xlen; ++ii ) {
    matrix[ii] = (BrewMove*)mallocAbort(sizeof(BrewMove)*(ylen+1),__FILE__,__FUNCTION__,__LINE__);
    for ( jj = 0; jj <= ylen; ++jj ) {
      matrix[ii][jj].bestCost     = 0.0;
      matrix[ii][jj].editType     = BREW_EDIT_TYPE_INITIAL;
      matrix[ii][jj].traceBack    = NULL;
      matrix[ii][jj].leftChar     = (char*)mallocAbort(2*sizeof(char),__FILE__,__FUNCTION__,__LINE__);
      matrix[ii][jj].leftChar[0]  = '\0';
      matrix[ii][jj].leftChar[1]  = '\0';
      
      matrix[ii][jj].rightChar    = (char*)mallocAbort(2*sizeof(char),__FILE__,__FUNCTION__,__LINE__);
      matrix[ii][jj].rightChar[0] = '\0';
      matrix[ii][jj].rightChar[1] = '\0';
    }
  }
  return matrix;
}

BrewEditDistanceResults*
brewResults_new(const char* left, const char* right) {
  BrewEditDistanceResults* res = (BrewEditDistanceResults*)mallocAbort(sizeof(BrewEditDistanceResults),__FILE__,__FUNCTION__,__LINE__);
  res->distance    = 0;
  res->editPath    = pathList_new();
  res->left        = copyString(left);
  res->right       = copyString(right);
  res->matrixXSize = strlen(left);
  res->matrixYSize = strlen(right);
  res->matrix      = brew_newMoveMatrix(strlen(left),strlen(right));
  return res;
}

void
brewResults_destroy(BrewEditDistanceResults* res) {
  pathList_delete(res->editPath);
  brew_deleteMoveMatrix(res);
  free(res->left);
  free(res->right);
  free(res);
}

void
brew_deleteMoveMatrix(BrewEditDistanceResults* res) {
    int ii, jj;
  DBG(fprintf(stderr,"%s->%s(%d): freeing matrix: => %p\n",__FILE__,__FUNCTION__,__LINE__,res->matrix));
  for ( ii = 0; ii <= res->matrixXSize; ++ii ) {
    for ( jj = 0; jj <= res->matrixYSize; ++jj ) {
      free(res->matrix[ii][jj].leftChar);
      free(res->matrix[ii][jj].rightChar);
    }
    free(res->matrix[ii]);
  }
  free(res->matrix);
  res->matrix = NULL;
}

void brew_printMoveMatrix(BrewEditDistanceResults *results) {
  int xx, yy;
  fprintf(stderr,"                       ");
  for ( xx = 1; xx <= results->matrixYSize; ++xx ) {
    fprintf(stderr,"%c                   ",results->right[xx-1]);
  }
  fprintf(stderr,"\n");

  for ( xx = 0; xx <= results->matrixXSize; ++xx ) {
    if(xx>0) {
      fprintf(stderr,"%c  ",results->left[xx-1]);
    }
    else {
      fprintf(stderr,"   ");
    }
    for ( yy = 0; yy <= results->matrixYSize; ++yy ) {
      const char* pad = results->matrix[xx][yy].bestCost < 10.0 
                      ? "  "
                      : results->matrix[xx][yy].bestCost < 100.0 
                      ? " "
                      : "";
      fprintf(stderr,"[%02d][%02d](%s%3.2f,%s)  ",
              xx,yy,
              pad,
              results->matrix[xx][yy].bestCost,
              editTypeToAbbr(results->matrix[xx][yy].editType)
              );
    }
    fprintf(stderr,"\n");
  }
}

BrewMove*
brew_matrixElt(BrewEditDistanceResults* results,int xx,int yy) {
  if ( xx > results->matrixXSize || yy > results->matrixYSize ) {
    return NULL;
  }
  return &(results->matrix[xx][yy]);
}

void
brew_distance (BrewConfig* cfg, BrewEditDistanceResults *brewResults) {
  DBG(char buff1[2048]);
  DBG(fprintf(stderr,"%s->%s(%d): comparing '%s' vs '%s'\n",__FILE__,__FUNCTION__,__LINE__,brewResults->left,brewResults->right));
  DBG(fprintf(stderr,"%s->%s(%d): costs: match:%f ins:%f del:%f subst:%f\n",__FILE__,__FUNCTION__,__LINE__,cfg->matchCost,cfg->insertCost,cfg->deleteCost,cfg->substituteCost));

  BrewMove *move = move_new();

  BrewMove *tmp = brew_editPath(cfg,move,brewResults);
  DBG(fprintf(stderr,"%s->%s(%d): calculated edit path: %p : %s\n",__FILE__,__FUNCTION__,__LINE__,&move,move_toString(&move,buff1,sizeof(buff1))));

  if ( !tmp ) {
    fprintf(stderr,"%s->%s(%d): ERROR: move was null! ",__FILE__,__FUNCTION__,__LINE__);
    exit(1);
  }

  DBG(fprintf(stderr,"%s->%s(%d): distance is %f\n",__FILE__,__FUNCTION__,__LINE__,
              move->bestCost));
  brewResults->distance = move->bestCost;

  while ( NULL != tmp ) {
    brewResults->editPath = pathList_prependEditType( brewResults->editPath, tmp->editType, tmp->leftChar[0], tmp->rightChar[0] );
    tmp = tmp->traceBack;
  }

  DBG(pathList_prettyPrint(brewResults->editPath,brewResults->left,brewResults->right));


  DBG(fprintf(stderr,"%s->%s(%d): Move Matrix:\n",__FILE__,__FUNCTION__,__LINE__));
  if (cfg->printMatrix) {
    brew_printMoveMatrix(brewResults);
  }

  DBG(fprintf(stderr,"%s->%s(%d): returning results: %p\n",__FILE__,__FUNCTION__,__LINE__,brewResults));

  move_destroy(move);
}


BrewMove*
brew_editPath(BrewConfig* cfg, BrewMove *finalMove, BrewEditDistanceResults *brewResults) {
  int xx, yy;
  double charCost;
  char c1, c2;
  BrewMove *subMove, *insMove, *delMove;
  DBG(char buff1[2048]);

  subMove = move_new();
  insMove = move_new();
  delMove = move_new();

  brewResults->matrix[0][0].bestCost = 0;
  brewResults->matrix[0][0].editType = BREW_EDIT_TYPE_INITIAL;
  brewResults->matrix[0][0].traceBack = NULL;

#ifdef PBREW_BUG_COMPAT
  DBG(fprintf(stderr,"%s->%s(%d): bug compat mode, best cost init in matrix will be 3+cfg.cost\n",__FILE__,__FUNCTION__,__LINE__));
#endif

  // initialize the deletes
  for (xx = 0; xx < strlen(brewResults->left); ++xx) {
    BrewMove *lastMove = &(brewResults->matrix[xx][0]);
    BrewMove *newMove  = &(brewResults->matrix[xx+1][0]);
    // bug compatibility with Text::Brew
#ifdef PBREW_BUG_COMPAT
    newMove->bestCost  = 3 + cfg->deleteCost;
#else
    newMove->bestCost  = lastMove->bestCost + cfg->deleteCost;
#endif
    newMove->editType  = BREW_EDIT_TYPE_DELETE;
    newMove->traceBack = lastMove;
  }

  // initialize the inserts
  for (yy = 0; yy < strlen(brewResults->right); ++yy) {
    BrewMove *lastMove = &(brewResults->matrix[0][yy]);
    BrewMove *newMove  = &(brewResults->matrix[0][yy+1]);
    // bug compatibility with Text::Brew
#ifdef PBREW_BUG_COMPAT
    newMove->bestCost  = 3 + cfg->insertCost;
#else
    newMove->bestCost  = lastMove->bestCost + cfg->insertCost;
#endif
    newMove->editType  = BREW_EDIT_TYPE_INSERT;
    newMove->traceBack = lastMove;
  }

  // move down the string and calculate the moves
  for ( xx = 0; xx < strlen(brewResults->left); ++xx) {
    c1 = brewResults->left[xx];
    for ( yy = 0; yy < strlen(brewResults->right); ++yy) {
      c2 = brewResults->right[yy];
      charCost
        = (c1 == c2) 
        ? cfg->matchCost 
        : cfg->substituteCost;
      
      DBG(fprintf(stderr,"%s->%s(%d): (%d,%d) c1:%c c2:%c charCost:%f\n",__FILE__,__FUNCTION__,__LINE__,xx,yy,c1,c2,charCost));

      BrewMove *currentMove = &(brewResults->matrix[xx+1][yy+1]);
      DBG(fprintf(stderr,"%s->%s(%d): currentMove=%p from (%d,%d) => %s\n",__FILE__,__FUNCTION__,__LINE__,currentMove,xx+1,yy+1,move_toString(currentMove,buff1,sizeof(buff1))));
      
      subMove->bestCost = charCost;
      subMove->editType = BREW_EDIT_TYPE_SUBSTITUTE;
      subMove->traceBack = &(brewResults->matrix[xx][yy]);
      
      insMove->bestCost = cfg->insertCost;
      insMove->editType = BREW_EDIT_TYPE_INSERT;
      insMove->traceBack = &(brewResults->matrix[xx+1][yy]);
      
      delMove->bestCost = cfg->deleteCost;
      delMove->editType = BREW_EDIT_TYPE_DELETE;
      delMove->traceBack = &(brewResults->matrix[xx][yy+1]);
      
      // Find whether a substitution/match, insert, or delete
      // is the best move to make
      brew_useBestMove(currentMove, subMove, insMove, delMove);

      currentMove->leftChar[0]  = c1;
      currentMove->rightChar[0] = c2;

      DBG(fprintf(stderr,"%s->%s(%d): best currentMove=%p from (%d,%d) (%c,%c) => %s\n",__FILE__,__FUNCTION__,__LINE__,currentMove,xx,yy,c1,c2,move_toString(currentMove,buff1,sizeof(buff1))));
    }
  }

  // Return the move that transforms the string from the start to final strng
  move_becomeCopyOf(finalMove,&(brewResults->matrix[strlen(brewResults->left)][strlen(brewResults->right)]));
  DBG(fprintf(stderr,"%s->%s(%d): finalMove(%d,%d)=%p => %s\n",
              __FILE__,__FUNCTION__,__LINE__,
              strlen(brewResults->left),
              strlen(brewResults->right),
              finalMove,move_toString(finalMove,buff1,sizeof(buff1))));

  move_destroy(subMove);
  move_destroy(insMove);
  move_destroy(delMove);

  return finalMove;
}

void
brew_useBestMove(BrewMove *currentMove, BrewMove *subMove, BrewMove *insMove, BrewMove *delMove) {
  double costWithSub = subMove->bestCost + subMove->traceBack->bestCost;
  double costWithIns = insMove->bestCost + insMove->traceBack->bestCost;
  double costWithDel = delMove->bestCost + delMove->traceBack->bestCost;
  double bestCost = costWithSub;
  int editType = subMove->editType;
  BrewMove* tb = subMove->traceBack;

  DBG(fprintf(stderr,"%s->%s(%d): subMove->bestCost:%f insMove->bestCost:%f delMove->bestCost:%f\n",__FILE__,__FUNCTION__,__LINE__,subMove->bestCost,insMove->bestCost,delMove->bestCost));

  double bestOfSet = costWithSub < costWithIns ? costWithSub : costWithIns;
  bestOfSet        = bestOfSet   < costWithDel ? bestOfSet   : costWithDel;
  int numWithMin = 0;
  if ( costWithIns == bestOfSet ) ++numWithMin;
  if ( costWithDel == bestOfSet ) ++numWithMin;
  if ( costWithSub == bestOfSet ) ++numWithMin;

  if ( numWithMin > 1 ) {
    DBG(fprintf(stderr,"%s->%s(%d): equivalent costs, should preferr the cheapest based on cost vector, then fall back to hard-coded list. costWithSub(%f) costWithIns(%f), costWithDel(%f)\n",__FILE__,__FUNCTION__,__LINE__,costWithSub,costWithIns,costWithDel));
  }

  if ( costWithIns < bestCost ) {
    bestCost = costWithIns;
    editType = insMove->editType;
    tb = insMove->traceBack;
    DBG(fprintf(stderr,"%s->%s(%d): costWithIns(%f) < bestCost(%f), setting to INS\n",__FILE__,__FUNCTION__,__LINE__,costWithIns,bestCost));
  }

  if ( costWithDel < bestCost ) {
    bestCost = costWithDel;
    editType = delMove->editType;
    tb = delMove->traceBack;
    DBG(fprintf(stderr,"%s->%s(%d): costWithDel(%f) < bestCost(%f), setting to DEL\n",__FILE__,__FUNCTION__,__LINE__,costWithDel,bestCost));
  }

  if ( bestCost == tb->bestCost ) {
    editType = BREW_EDIT_TYPE_MATCH;
    DBG(fprintf(stderr,"%s->%s(%d): bestCost(%f) == tb->bestCost(%f), setting to MATCH\n",__FILE__,__FUNCTION__,__LINE__,bestCost,tb->bestCost));
  }

  currentMove->bestCost = bestCost;
  currentMove->editType = editType;
  currentMove->traceBack = tb;

  if ( numWithMin > 1 ) {
    DBG(fprintf(stderr,"%s->%s(%d): actually chose move type:%d %s, cost=%f\n",__FILE__,__FUNCTION__,__LINE__,currentMove->editType,editTypeToAbbr(currentMove->editType),currentMove->bestCost));
  }
}

