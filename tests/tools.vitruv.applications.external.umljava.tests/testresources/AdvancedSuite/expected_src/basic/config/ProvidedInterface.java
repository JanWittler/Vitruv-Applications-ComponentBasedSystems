package basic.config;

import java.lang.String;


public class ProvidedInterface {
	private String name;
	public String getName() {
		return this.name;
	}
	public void setName(String name) {
		this.name = name;
	}
	public ArrayList<Method>providedMethods;
	public ArrayList<Method>getProvidedMethods() {
		return this.providedMethods;
	}
	public void setProvidedMethods(ArrayList<Method>providedMethods) {
		this.providedMethods = providedMethods;
	}
}



