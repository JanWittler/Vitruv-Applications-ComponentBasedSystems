package basic.config;

import basic.config.Printer;
import java.lang.String;


public class Component {
	public ArrayList<RequiredInterface>requiredInterfaces;
	public ArrayList<RequiredInterface>getRequiredInterfaces() {
		return this.requiredInterfaces;
	}
	public void setRequiredInterfaces(ArrayList<RequiredInterface>requiredInterfaces) {
		this.requiredInterfaces = requiredInterfaces;
	}
	public ArrayList<ProvidedInterface>providedInterfaces;
	public ArrayList<ProvidedInterface>getProvidedInterfaces() {
		return this.providedInterfaces;
	}
	public void setProvidedInterfaces(ArrayList<ProvidedInterface>providedInterfaces) {
		this.providedInterfaces = providedInterfaces;
	}
	private String identifier;
	public String getIdentifier() {
		return this.identifier;
	}
	public void setIdentifier(String identifier) {
		this.identifier = identifier;
	}
	Printer printer;
	public Printer getPrinter() {
		return this.printer;
	}
	public void setPrinter(Printer printer) {
		this.printer = printer;
	}
}



