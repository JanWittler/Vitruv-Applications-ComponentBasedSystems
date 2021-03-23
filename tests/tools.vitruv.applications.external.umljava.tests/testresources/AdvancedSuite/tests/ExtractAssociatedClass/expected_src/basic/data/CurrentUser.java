package basic.data;

import java.lang.String;


public class CurrentUser {
	private int id;
	public int getId() {
		return this.id;
	}
	public void setId(int id) {
		this.id = id;
	}
	private String firstName;
	public String getFirstName() {
		return this.firstName;
	}
	public void setFirstName(String firstName) {
		this.firstName = firstName;
	}
	private String lastName;
	public String getLastName() {
		return this.lastName;
	}
	public void setLastName(String lastName) {
		this.lastName = lastName;
	}
	private String email;
	public String getEmail() {
		return this.email;
	}
	public void setEmail(String email) {
		this.email = email;
	}
	private String passwordHash;
	public String getPasswordHash() {
		return this.passwordHash;
	}
	public void setPasswordHash(String passwordHash) {
		this.passwordHash = passwordHash;
	}
	public CurrentUser(int id,String firstName,String lastName,String email,String passwordHash) {
		this.id = id;
		this.firstName = firstName;
		this.lastName = lastName;
		this.email = email;
		this.passwordHash = passwordHash;
	}
}



