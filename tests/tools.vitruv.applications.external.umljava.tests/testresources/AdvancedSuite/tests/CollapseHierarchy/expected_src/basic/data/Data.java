package basic.data;

import basic.data.Metadata;
import java.lang.String;


public class Data {
	public Metadata metadata;
	public Metadata getMetadata() {
		return this.metadata;
	}
	public void setMetadata(Metadata metadata) {
		this.metadata = metadata;
	}
	public String deserialize() {
		
	}
	public int binaryData;
	public int getBinaryData() {
		return this.binaryData;
	}
	public void setBinaryData(int binaryData) {
		this.binaryData = binaryData;
	}
}



