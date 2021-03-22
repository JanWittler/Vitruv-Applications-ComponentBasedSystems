package basic.config;

import java.lang.String;


public class RequiredInterface {
	private String name;
	public String getName() {
		return this.name;
	}
	public void setName(String name) {
		this.name = name;
	}
	public ArrayList<Method>requiredMethods;
	public ArrayList<Method>getRequiredMethods() {
		return this.requiredMethods;
	}
	public void setRequiredMethods(ArrayList<Method>requiredMethods) {
		this.requiredMethods = requiredMethods;
	}
}



