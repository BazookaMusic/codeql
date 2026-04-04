import org.apache.logging.log4j.Logger;

class Test {
    void test(String password, String authToken, String username, String nullToken, String stringTokenizer) {
        Logger logger = null;
        int zero = 0;
        int four = 4;
        short zeroS = 0;
        long fourL = 4L;

        logger.info("User's password is: " + password); // $ Alert
        logger.error("Auth failed for: " + authToken); // $ Alert
        logger.error("Auth failed for: " + username); // Safe
        logger.error("Auth failed for: " + nullToken); // Safe
        logger.error("Auth failed for: " + stringTokenizer); // Safe
        logger.error("Auth failed for: " + authToken.substring(4) + "..."); // Safe
        logger.error("Auth failed for: " + authToken.substring(four) + "..."); // Safe
        logger.error("Auth failed for: " + authToken.substring(0,4) + "..."); // Safe
        logger.error("Auth failed for: " + authToken.substring(zero,four) + "..."); // Safe
        logger.error("Auth failed for: " + authToken.substring((int)zeroS,(int)fourL) + "..."); // Safe
        logger.error("Auth failed for: " + authToken.substring(1,5) + "..."); // $ Alert
        logger.error("Auth failed for: " + authToken.substring(0,8) + "..."); // $ Alert
    }

    // Tests for hash/encryption sanitizer
    void testHashSanitizer(String password, String authToken) {
        Logger logger = null;
        logger.info("hash: " + hashPassword(password)); // Safe - hashed
        logger.info("hash: " + sha256Digest(authToken)); // Safe - digested
        logger.info("enc: " + encryptValue(password)); // Safe - encrypted
        logger.info("pw: " + password); // $ Alert - not hashed
    }

    static String hashPassword(String input) { return input; }
    static String sha256Digest(String input) { return input; }
    static String encryptValue(String input) { return input; }
}
