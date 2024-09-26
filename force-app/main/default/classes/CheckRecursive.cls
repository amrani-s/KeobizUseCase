public class CheckRecursive {
    private static Integer runCount = 0;

    public static Boolean runOnce() {
        if (runCount < 1) { 
            runCount++; 
            return true; 
        } else {
            return false; 
        }
    }
}