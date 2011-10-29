class mSymbol {
	public String variableName;
	public String variableType;
	public String variableValue;

	public mSymbol() {
		variableName = "";
		variableType = "";
		variableValue = "";
	}

	public mSymbol(String vName, String vType) {
		variableName = vName;
		variableType = vType;
		variableValue = "";
	}

	public mSymbol(String vName, String vType, String vValue) {
		variableName = vName;
		variableType = vType;
		variableValue = vValue;
	}

	public String getName() { return variableName; }
	public String getType() { return variableType; }
	public String getValue() { return variableValue; }
}
