package com.example.first;

import java.lang.String;


public class Example {
	private String newName;
	public String getNewName() {
		return this.newName;
	}
	public void setNewName(String newName) {
		this.newName = newName;
	}
	public boolean nameEquals(String otherName) {
		return this.newName == otherName;
	}
}



