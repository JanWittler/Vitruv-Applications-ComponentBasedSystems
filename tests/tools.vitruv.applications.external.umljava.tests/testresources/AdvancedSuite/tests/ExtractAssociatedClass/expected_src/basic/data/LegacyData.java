package basic.data;

import basic.data.AbstractData;


public class LegacyData extends AbstractData {
	public RequiredInterface requiredInterface;
	public RequiredInterface getRequiredInterface() {
		return this.requiredInterface;
	}
	public void setRequiredInterface(RequiredInterface requiredInterface) {
		this.requiredInterface = requiredInterface;
	}
}



