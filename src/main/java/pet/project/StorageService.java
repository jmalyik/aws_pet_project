package pet.project;

import java.io.IOException;
import java.util.Map;

public interface StorageService {
	
	static final Map<String, String> CONTENT_TYPE_EXTENSION_MAP = Map.of(
		    "application/json", ".json",
		    "application/gzip", ".gz",
		    "text/plain", ".txt"
		);
	
	void uploadBytes(String key, byte[] content, String contentType) throws IOException;
	
	default String getExtensionFromContentType(String contentType) {
	    return CONTENT_TYPE_EXTENSION_MAP.getOrDefault(contentType, "");
	}
}
