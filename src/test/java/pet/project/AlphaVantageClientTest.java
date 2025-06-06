package pet.project;

import java.io.File;
import java.nio.file.Paths;

import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;

public class AlphaVantageClientTest {
	@Test
	void testAlphaVantageClient() throws Exception {
	    AlphaVantageClient client = new AlphaVantageClient();
	    byte[] stockData = client.fetchDailyStockData();
	    Assertions.assertNotNull(stockData);
	    LocalStorageService svc = new LocalStorageService(Paths.get("target"));
	    String key = "dailyStockData.json";
	    String contentType = "application/gzip";
	    svc.uploadBytes(key, stockData, contentType);
	    File targetFile = svc.getTargetFile(contentType, key);
	    Assertions.assertTrue(targetFile.exists());
	    Assertions.assertTrue(targetFile.canRead());
	    Assertions.assertTrue(targetFile.length() > 0);
	    System.out.println(targetFile + " created.");
	}
}
