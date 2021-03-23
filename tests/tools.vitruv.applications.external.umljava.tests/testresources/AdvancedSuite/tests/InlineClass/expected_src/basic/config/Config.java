package basic.config;

import basic.config.EJB;
import java.lang.String;


public class Config {
	private static int timestamp;
	public int getTimestamp() {
		return this.timestamp;
	}
	public void setTimestamp(int timestamp) {
		this.timestamp = timestamp;
	}
	private static boolean reconfigurable;
	public boolean getReconfigurable() {
		return this.reconfigurable;
	}
	public void setReconfigurable(boolean reconfigurable) {
		this.reconfigurable = reconfigurable;
	}
	public static ArrayList<EJB>ejbs;
	public ArrayList<EJB>getEjbs() {
		return this.ejbs;
	}
	public void setEjbs(ArrayList<EJB>ejbs) {
		this.ejbs = ejbs;
	}
	public static void loadConfig() {
	}
	public static boolean isReconfigurable() {
	}
	public static String getEJBs() {
	}
}



