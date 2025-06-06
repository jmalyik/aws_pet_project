package pet.project;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.file.Path;

public class LocalStorageService implements StorageService {
	private final Path targetDirectory;

	public LocalStorageService(Path targetDirectory) {
		this.targetDirectory = targetDirectory;
	}

	@Override
	public void uploadBytes(String key, byte[] content, String contentType) throws IOException {
		File targetFile = getTargetFile(contentType, key);
		targetFile.getParentFile().mkdirs();
		try (FileOutputStream fos = new FileOutputStream(targetFile)) {
           	fos.write(content);
        }
	}

	public File getTargetFile(String contentType, String key) {
		return targetDirectory.resolve(key + getExtensionFromContentType(contentType)).toFile();
	}
}
