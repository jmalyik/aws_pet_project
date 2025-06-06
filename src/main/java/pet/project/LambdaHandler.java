package pet.project;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;

import software.amazon.awssdk.services.s3.S3Client;

public class LambdaHandler implements RequestHandler<Object, String> {

        private final AlphaVantageClient alphaVantageClient = new AlphaVantageClient();
        
        private final S3StorageService s3StorageService;
        
        public LambdaHandler() {
        	S3Client s3Client = S3Client.builder().build();
        	s3StorageService = new S3StorageService(s3Client, "aws-pet-bucket");
        }
        

        @Override
        public String handleRequest(Object input, Context context) {
            context.getLogger().log("Lambda invoked, fetching stock data for tickers...");
            try {
                byte[] stockDataAsGzip = alphaVantageClient.fetchDailyStockData();

                String key = "stocks/dailyMagnificentSeven.json";

                s3StorageService.uploadBytes(key, stockDataAsGzip, "application/gzip");

                return "Upload successful: " + key;

            } catch (Exception e) {
                e.printStackTrace();
                return "Upload failed: " + e.getMessage();
            } finally {
            	context.getLogger().log("Lambda execution completed.");
            }
        }
}
