package pet.project;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.TreeMap;
import java.util.zip.GZIPOutputStream;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

public class AlphaVantageClient {

    private static final String API_KEY = System.getenv("ALPHA_VANTAGE_APIKEY");
    private static final String BASE_URL = "https://www.alphavantage.co/query";

    private final HttpClient httpClient = HttpClient.newHttpClient();
    
	 List<String> LARGE_CAP_TICKERS = List.of(
			    "AAPL",   // Apple
			    "MSFT",   // Microsoft
			    "GOOGL",  // Alphabet (Google)
			    "AMZN",   // Amazon
			    "META",   // Meta Platforms (Facebook)
			    "NVDA",   // Nvidia
			    "TSLA"    // Tesla
			);
    
	   private static final ObjectMapper objectMapper = new ObjectMapper();

	    public byte[] fetchDailyStockData() throws IOException, InterruptedException {
	        Map<String, JsonNode> stockDataMap = new TreeMap<>();

	        for (String symbol : LARGE_CAP_TICKERS) {
	            try {
	                JsonNode node = fetchDailyStockData(symbol);
	                stockDataMap.put(symbol, node);
	                Thread.sleep(1000); // defending API rate limit
	            } catch (IOException | InterruptedException e) {
	                System.err.println("Failed to fetch data for: " + symbol);
	                e.printStackTrace();
	            }
	        }

	        // creating a zipped JSON
	        ByteArrayOutputStream rawOut = new ByteArrayOutputStream();
	        try (GZIPOutputStream gzipOut = new GZIPOutputStream(rawOut);
	             OutputStreamWriter writer = new OutputStreamWriter(gzipOut)) {
	            objectMapper.writeValue(writer, stockDataMap);
	        }

	        return rawOut.toByteArray();
	    }
    
    private JsonNode fetchDailyStockData(String symbol) throws IOException, InterruptedException {
        String url = String.format("%s?function=TIME_SERIES_INTRADAY&symbol=%s&interval=5min&apikey=%s", BASE_URL, symbol, API_KEY);
        System.out.println(url);
        HttpRequest request = HttpRequest.newBuilder()
            .uri(URI.create(url))
            .GET()
            .build();

        HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
        for(Entry<String, List<String>> e : response.headers().map().entrySet()) {
        	System.err.println(e.getKey() + " = " + e.getValue());
        }
        if (response.statusCode() == 200) {
            ObjectMapper mapper = new ObjectMapper();
            return mapper.readTree(response.body());
        } else {
            throw new IOException("Failed to fetch data: " + response.statusCode());
        }
    }
}
