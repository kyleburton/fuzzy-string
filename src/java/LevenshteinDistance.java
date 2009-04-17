// see: http://en.wikibooks.org/wiki/Algorithm_implementation/Strings/Levenshtein_distance

public class LevenshteinDistance {
    private static int min3(int a, int b, int c) {
        return Math.min(Math.min(a, b), c);
    }
    
    public static double edistSimilarity(String s1, String s2) {
        int totLen = (s1.length()+s2.length());
        double avgLen = totLen / 2.0;
        return (avgLen - editDistance(s1,s2)) / avgLen;
    }

    public static int editDistance(String str1, String str2) {
        return editDistance(str1.toCharArray(), str2.toCharArray() );
    }

    public static int editDistance(char[] str1, char[] str2) {
        int [][] matrix = buildMatrix(str1,str2);
        return matrix[ matrix.length-1 ][ matrix[0].length-1 ];
    }

    public static int[][] buildMatrix(String str1, String str2) {
        return buildMatrix(str1.toCharArray(), str2.toCharArray() );
    }

    /**
     * Normal Levenshtein distance.  Counts any char difference as
     * cost=1.
     *
     */
    public static int[][] buildMatrix(char[] str1, char[] str2) {
        int[][] matrix = new int[str1.length+1][str2.length+1];
        
        for (int i=0; i<=str1.length; i++)
            matrix[i][0] = i;
        for (int j=0; j<=str2.length; j++)
            matrix[0][j]=j;
 
        for (int i=1; i<=str1.length; i++) {
            for (int j=1;j<=str2.length; j++) {
                int leftCost     = matrix[i-1][j]+1;
                int aboveCost    = matrix[i][j-1]+1;
                int diffCharCost = (str1[i-1]==str2[j-1]) 
                    ? 0 
                    : 1;
                int upLeftCost   = matrix[i-1][j-1] + diffCharCost;
                matrix[i][j]= min3(leftCost, 
                                   aboveCost, 
                                   upLeftCost);
            }
        }
        
        return matrix;
    }

    /**
     * Damerau-Levenshtein distance.  Supports transpositions at
     * cost=1.
     *
     *
     */
    public static int[][] buildMatrix2(char[] str1, char[] str2) {
        int[][] matrix = new int[str1.length+1][str2.length+1];
        
        for (int ii=0; ii<=str1.length; ii++)
            matrix[ii][0] = ii;
        for (int jj=0; jj<=str2.length; jj++)
            matrix[0][jj]=jj;
 
        for (int ii=1; ii<=str1.length; ii++) {
            for (int jj=1;jj<=str2.length; jj++) {
                int leftCost     = matrix[ii-1][jj]+1;
                int aboveCost    = matrix[ii][jj-1]+1;
                int diffCharCost = (str1[ii-1]==str2[jj-1]) 
                    ? 0 
                    : 1;
                int upLeftCost   = matrix[ii-1][jj-1] + diffCharCost;
                matrix[ii][jj]= min3(leftCost, 
                                   aboveCost, 
                                   upLeftCost);
                if (    ii > 1
                     && jj > 1
                     && str1[ii-1] == str2[jj-2] ) {
                    matrix[ii][jj] = Math.min(matrix[ii][jj],
                                              matrix[ii-2][jj-2]+diffCharCost);
                }
            }
        }
        
        return matrix;
    }


    public static double edistSimilarity2(String s1, String s2) {
        int totLen = (s1.length()+s2.length());
        double avgLen = totLen / 2.0;
        return (avgLen - editDistance2(s1,s2)) / avgLen;
    }

    public static int editDistance2(String str1, String str2) {
        return editDistance2(str1.toCharArray(), str2.toCharArray() );
    }

    public static int editDistance2(char[] str1, char[] str2) {
        int [][] matrix = buildMatrix2(str1,str2);
        return matrix[ matrix.length-1 ][ matrix[0].length-1 ];
    }

    public static int[][] buildMatrix2(String str1, String str2) {
        return buildMatrix2(str1.toCharArray(), str2.toCharArray() );
    }
}
