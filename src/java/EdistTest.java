public class EdistTest {

    public static void main (String [] args) throws Exception {
	String left = "Smith";
	String right = "Smyth";
	if ( args.length < 1 ) {
	    throw new Exception("Error: you must say editDistance or editDistance2");
	}
	
	if ( args.length > 1 ) left  = args[1];
	if ( args.length > 2 ) right = args[2];
	left  = left.toUpperCase();
	right = right.toUpperCase();
	if ("editDistance".equals(args[0]) ) {
	    showEditDistance(left,right);
	    return;
	}
	if ("editDistance2".equals(args[0]) ) {
	    showEditDistance2(left,right);
	    return;
	}

	throw new Exception("Error: didn't now what you wanted, try editDistance or editDistance2");
    }
    
    public static void showEditDistance(String left, String right) {
	printfln("'%s'(%d) vs '%s'(%d) => (%.0f%%) %d", 
		 left,  left.length(),
		 right, right.length(),
		 100.0 * LevenshteinDistance.edistSimilarity(left,right),
		 LevenshteinDistance.editDistance(left,right));
	
	printMatrix(left,right,LevenshteinDistance.buildMatrix(left,right));
    }

    public static void showEditDistance2(String left, String right) {
	printfln("'%s'(%d) vs '%s'(%d) => (%.0f%%) %d", 
		 left,  left.length(),
		 right, right.length(),
		 100.0 * LevenshteinDistance.edistSimilarity2(left,right),
		 LevenshteinDistance.editDistance2(left,right));
	
	printMatrix(left,right,LevenshteinDistance.buildMatrix2(left,right));
    }

    private static void printMatrix(String left, String right,int [][] matrix) {
	
	printf("|    |");
	for ( int ii = 0; ii < matrix[0].length; ++ii ) {
	    if ( ii > 0 )
		printf(" %2s |",right.substring(ii-1,ii));
	    else
		printf("    |");
	}
	printfln("");

	for ( int ii = 0 ; ii < matrix.length; ++ii ) {
	    if ( ii > 0 ) 
		printf("| %2s |",left.substring(ii-1,ii));
	    else
		printf("|    |");

	    for ( int jj = 0; jj < matrix[ii].length; ++jj ) {
		printf(" %2d |",matrix[ii][jj]);
	    }
	    printfln("");
	}
    }

    public static void printf( String fmt, Object...args ) {
	System.out.print(String.format(fmt,args));
    }

    public static void printfln( String fmt, Object...args ) {
	System.out.println(String.format(fmt,args));
    }
}