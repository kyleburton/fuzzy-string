#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include "brew.h"

typedef struct {
  char* left;
  char* right;
  double expectedDistance;
} TestCase;

TestCase testCases[] = {
  { "BRYN",     "BEIJING",     2.3 },
  { "foo",      "foobar",      0.3 }
};

int
runTest( int testNum, TestCase* testCase ) {

  BrewEditDistanceResults *result = brewResults_new(testCase->left,testCase->right);
  brew_distance(brew_defaultConfig,result);

  double factor = 1000000.0;
  double delta = (round(result->distance*factor) - round(testCase->expectedDistance*factor))/factor;
  char *msg = delta == 0.0 ? "PASS" : "FAIL";

  fprintf(stderr,"%s->%s(%d): %d %s expected dist: %3.30f actual dist: %3.30f delta:%3.30f '%s' vs '%s'\n",
          __FILE__,
          __FUNCTION__,
          __LINE__,
          testNum,
          msg,
          testCase->expectedDistance,
          result->distance,
          delta,
          testCase->left,
          testCase->right
         );

  DBG(pathList_prettyPrint(result->editPath,testCase->left,testCase->right));

  brewResults_destroy(result);
  return delta == 0.0;
}

void
runInternalTests ( TestCase *testCases, int numTests) {
  int testsRun  = 0;
  int numPassed = 0;
  int numFailed = 0;
  int ii;

  for ( ii = 0; ii < numTests; ++ii ) {
    if (runTest( ii, &testCases[ii] ) ) {
      ++numPassed;
    }
    else {
      ++numFailed;
    }
    ++testsRun;
  }

  fprintf(stderr,"%s->%s(%d): %d Tests Run out of %d\n", __FILE__, __FUNCTION__, __LINE__, testsRun, numFailed);
  fprintf(stderr,"%s->%s(%d): %d Passed\n", __FILE__, __FUNCTION__, __LINE__, numPassed);
  fprintf(stderr,"%s->%s(%d): %d Failed\n", __FILE__, __FUNCTION__, __LINE__, numFailed);
  fprintf(stderr,"%s->%s(%d): %s\n", __FILE__, __FUNCTION__, __LINE__, numFailed ? "FAILURE" : "SUCCESS" );
}

int
main ( int argc, char ** argv ) {
  int argCount;

  brew_setUp();
  brew_defaultConfig->printMatrix = 1;
  atexit(brew_tearDown);
  DBG(fprintf(stderr,"%s->%s(%d): argc=%d\n", __FILE__, __FUNCTION__, __LINE__, argc));

  /* test string1 string2 expected-distance(float) */
  if ( 1 != argc && 0 == ((argc-1)%3) ) {
    DBG(fprintf(stderr,"%s->%s(%d): running tests from cmdline\n", __FILE__, __FUNCTION__, __LINE__));
    TestCase sample;
    for (argCount=1; argCount < argc; argCount += 3) {
      DBG(fprintf(stderr,"%s->%s(%d): argc=%d argCount=%d\n", __FILE__, __FUNCTION__, __LINE__, argc, argCount));
      DBG(fprintf(stderr,"%s->%s(%d):   left =%s\n", __FILE__, __FUNCTION__, __LINE__, argv[argCount]));
      DBG(fprintf(stderr,"%s->%s(%d):   right=%s\n", __FILE__, __FUNCTION__, __LINE__, argv[argCount+1]));
      DBG(fprintf(stderr,"%s->%s(%d):   exp  =%s\n", __FILE__, __FUNCTION__, __LINE__, argv[argCount+2]));
      sample.left=argv[argCount];
      sample.right=argv[argCount+1];
      sample.expectedDistance=strtod(argv[argCount+2],NULL);
      int determination = runTest( 1, &sample );
      const char* msg = determination ? "PASS" : "FAIL";
      fprintf(stderr,"%s->%s(%d): %s: %s vs %s : %f\n", __FILE__, __FUNCTION__, __LINE__,msg,sample.left,sample.right,sample.expectedDistance);
    }
    return 0;
  }

  /* some unknown number of arguments*/
  if ( 1 != argc ) {
    fprintf(stderr,"%s->%s(%d): Don't know how to handle your arguments.\n", __FILE__, __FUNCTION__, __LINE__);
    fprintf(stderr,"%s->%s(%d):   %s\n", __FILE__, __FUNCTION__, __LINE__,argv[0]);
    fprintf(stderr,"%s->%s(%d):   %s string1 string2 expected-distance(double)\n", __FILE__, __FUNCTION__, __LINE__,argv[0]);
    return 1;
  }

  runInternalTests(testCases, sizeof(testCases) / sizeof(TestCase));


  return 0;
}
