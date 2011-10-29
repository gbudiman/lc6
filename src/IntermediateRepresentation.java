class IntermediateRepresentation {
	public int i = 0;
	public int j = 0;
	public IntermediateRepresentation() {
	}

	public String generate() {
		return ("$T" + (i++));
	}
	
	public String generateLabel() {
		return ("LABEL" + (j++));
	}

	public String generateLabel(String l) {
		return ("LABEL " + l);
	}

	/*public String conditional(String left, String op, String right, String label, String type) {
		String condition = "";
		if (op.equals("<")) {
			condition += "LE";
		}
		else if (op.equals(">")) {
			condition += "GE";
		}
		else if (op.equals("!=")) {
			condition += "NE";
		}

		if (type.equals("INT")) {
			condition += " ";
		}
		else if (type.equals("FLOAT")) {
			condition += "F ";
		}

		return (condition + left + ' ' + right + ' ' + label);
	}*/

	public String arithmetic(String a, String b, String target, char op, String type) {
		String opcode = "";
		switch (op) {
			case '+': opcode += "ADD"; 	break;
			case '-': opcode += "SUB";	break;
			case '*': opcode += "MULT";	break;
			case '/': opcode += "DIV";	break;
		}

		if (type.equals("INT")) {
			opcode += "I";
		}
		else if (type.equals("FLOAT")) {
			opcode += "F";
		}

		return (opcode + ' ' + a + ' ' + b + ' ' + target);
	}

	public String store(String a, String result, String type) {
		if (type.equals("INT")) {
			return ("STOREI " + a + ' ' + result);
		}
		else if (type.equals("FLOAT")) {
			return ("STOREF " + a + ' ' + result);
		}

		return null;
	}

	public String rw(String result, String action, String type) {
		if (type.equals("INT")) {
			return (action + "I " + result);
		}
		else if (type.equals("FLOAT")) {
			return (action + "F " + result);
		}

		return null;
	}

	public String comparison(String a, String b, String op, String target, String type) {
		String opcode = "";

		// need to reverse operands if comparing register (comes first) with memory
		if (a.startsWith("$")) {
			String temp = a;
			a = b;
			b = temp;
			if (op.equals("<")) { op = ">"; }
			else if (op.equals(">")) { op = "<"; }
		}
		if (op.equals("<")) { opcode += "GEQ"; }
		else if (op.equals("<=")) { opcode += "GE"; }
		else if (op.equals(">")) { opcode += "LEQ"; }
		else if (op.equals(">=")) { opcode += "LE"; }
		else if (op.equals("!=")) { opcode += "EQ"; }
		else if (op.equals("=")) { opcode += "NE"; }

		if (type.equals("FLOAT")) {
			opcode += "F";
		}
		return (opcode + ' ' + a + ' ' + b + ' ' + target);
	}

	public String jump(String target) {
		return ("JUMP " + target);
	}

	public String label(String l) {
		return ("LABEL " + l);
	}
}
