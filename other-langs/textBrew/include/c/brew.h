#if !defined(__BREW_H)
#define __BREW_H

#define BREW_EDIT_TYPE_INITIAL     0
#define BREW_EDIT_TYPE_DELETE      1
#define BREW_EDIT_TYPE_INSERT      2
#define BREW_EDIT_TYPE_MATCH       3
#define BREW_EDIT_TYPE_SUBSTITUTE  4

#if defined (DEBUG)
#  define DBG(a) a
#else
#  define DBG(a)
#endif 

#include <stdlib.h>

void* mallocAbort(size_t,const char*,const char*,int);

/**
 * Doubly linked list with 1 data member to track the edit/move type -
 * INITIAL, INSERT, DELETE, MATCH or SUBSTITUTE.
 */
struct _PathList {
  int editType;
  char leftChar;
  char rightChar;
  struct _PathList *prev;
  struct _PathList *next;
};
typedef struct _PathList PathList;

/** Singleton to represent head/tail and empty path lists. */
extern PathList *pathList_Dummy;

PathList* pathList_new              ();
void      pathList_delete           (PathList*);
PathList* pathList_next             (PathList*);
int       pathList_hasNext          (PathList*);
int       pathList_hasPrevious      (PathList*);
PathList* pathList_prev             (PathList*);
void      pathList_appendEditType   (PathList*,int,char,char);
PathList* pathList_preppendEditType (PathList*,int,char,char);
void      pathList_prettyPrint(PathList*,const char*, const char*);


struct _BrewMove {
  double bestCost;
  int editType;
  struct _BrewMove* traceBack;
  char* leftChar;
  char* rightChar;
};
typedef struct _BrewMove BrewMove;

double       move_getTraceBackBestCost  ( BrewMove* this );
void         move_copyMoveValues        ( BrewMove*, BrewMove* );
void         move_checkForMatch         ( BrewMove* );
char*        move_toString              ( BrewMove*, char*, size_t );
const char*  editTypeToString           (int);

struct _BrewEditDistanceResults {
  double distance;
  PathList *editPath;
  BrewMove **matrix;
  int   matrixXSize;
  int   matrixYSize;
  char *left;
  char *right;
};
typedef struct _BrewEditDistanceResults BrewEditDistanceResults;

BrewEditDistanceResults* brewResults_new(const char* left, const char* right);
void                     brewResults_destroy(BrewEditDistanceResults*);
void                     brew_deleteMoveMatrix(BrewEditDistanceResults*);
BrewMove*                brew_matrixElt(BrewEditDistanceResults*,int,int);

struct _BrewConfig {
  double matchCost;
  double insertCost;
  double deleteCost;
  double substituteCost;
  int printMatrix;
};
typedef struct _BrewConfig BrewConfig;

extern BrewConfig* brew_defaultConfig;

BrewConfig* brewConfig_new(float,float,float,float,int);
void        brewConfig_destroy(BrewConfig*);

void brew_setUp();
void brew_tearDown();
void       brew_distance      (BrewConfig*,BrewEditDistanceResults*);
BrewMove*  brew_editPath      (BrewConfig*,BrewMove*,BrewEditDistanceResults*);
void       brew_useBestMove   (BrewMove*,BrewMove*,BrewMove*,BrewMove*);
void       brew_lookForBest   (BrewMove*,BrewMove*compareMove);


// __FUNCTION__ is not available on solaris' forte C/C++ compiler
// #define __FUNCTION__ "func-name"

#endif // !defined (__BREW_H)
