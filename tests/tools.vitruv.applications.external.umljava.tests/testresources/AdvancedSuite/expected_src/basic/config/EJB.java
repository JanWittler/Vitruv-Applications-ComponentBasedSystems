package basic.config;

import basic.config.ProvidedInterface;
import basic.config.RequiredInterface;
import java.lang.String;


public class EJB {
	private String name;
	public String getName() {
		return this.name;
	}
	public void setName(String name) {
		this.name = name;
	}
	private String host;
	public String getHost() {
		return this.host;
	}
	public void setHost(String host) {
		this.host = host;
	}
	private String port;
	public String getPort() {
		return this.port;
	}
	public void setPort(String port) {
		this.port = port;
	}
	private String appName;
	public String getAppName() {
		return this.appName;
	}
	public void setAppName(String appName) {
		this.appName = appName;
	}
	private String moduleName;
	public String getModuleName() {
		return this.moduleName;
	}
	public void setModuleName(String moduleName) {
		this.moduleName = moduleName;
	}
	private String beanName;
	public String getBeanName() {
		return this.beanName;
	}
	public void setBeanName(String beanName) {
		this.beanName = beanName;
	}
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
	void printProvidedInterfaces() {
		printProvidedInterfaces();
	}
	void printRequiredInterfaces() {
		printRequiredInterfaces();
	}
}



