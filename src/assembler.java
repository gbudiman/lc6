import java.util.*;

class assembler {
	public List<String> tinyTable;
	public List<String> varTable;
	public String t1, t2, t3, t4;
	private boolean use;

	public assembler() {
		tinyTable = new Vector<String>();
		varTable = new Vector<String>();
		use = false;
	}

	public void init(List<msTable> mTable) {
		for (msTable t: mTable) {
			if (t.scope.equals("__global")) {
				
				Iterator sti = t.symbolTable.iterator();

				while (sti.hasNext()) {
					mSymbol ese = (mSymbol) sti.next();
					tinyTable.add("var " + ese.getName());
				}
				tinyTable.add("push");
				tinyTable.add("push r0");
				tinyTable.add("push r1");
				tinyTable.add("push r2");
				tinyTable.add("push r3");

				tinyTable.add("jsr main");
				tinyTable.add("sys halt");
			}
			else { break; }
		}
	}

	public void fin() {
		tinyTable.add("unlnk");
		tinyTable.add("ret");
		tinyTable.add("end");
	}

	public List<String> process(List<String> irTable, boolean debug) {
		int registerCounter = 0;
		for (String ir : irTable) {
			if (debug) { tinyTable.add("----- " + ir); }
			String[] tiny = ir.split("\\s");
			switch(tiny.length) {
				case 2:
					if (tiny[0].equals("JUMP")) {
						tinyTable.add("jmp " + tiny[1]);
					}
					else if (tiny[0].equals("LABEL")) {
						tinyTable.add("label " + tiny[1]);
						if (!tiny[1].startsWith("LABEL")) {
							tinyTable.add("link 0");
						}
					}
					else if (tiny[0].equals("READI")) {
						tinyTable.add("sys readi " + tiny[1]);
					}
					else if (tiny[0].equals("READF")) {
						tinyTable.add("sys readr " + tiny[1]);
					}
					else if (tiny[0].equals("WRITEI")) {
						tinyTable.add("sys writei " + tiny[1]);
					}
					else if (tiny[0].equals("WRITEF")) {
						tinyTable.add("sys writer " + tiny[1]);
					}
				break;
				case 3:
					if (tiny[1].startsWith("$T")) {
						use = true;
						registerCounter = varTable.indexOf(tiny[1]);
						if (varTable.indexOf(tiny[1]) == -1) {
							varTable.add(tiny[1]);
							registerCounter = varTable.size() - 1;
						}
						t1 = "r" + registerCounter;
					}
					else {
						t1 = tiny[1];
					}

					if (tiny[2].startsWith("$T")) {
						use = true;
						registerCounter = varTable.indexOf(tiny[2]);
						if (varTable.indexOf(tiny[2]) == -1) {
							varTable.add(tiny[2]);
							registerCounter = varTable.size() - 1;
						}
						t2 = "r" + registerCounter;
					}
					else {
						t2 = tiny[2];
					}

					if (use) {
						use = false;
						tinyTable.add("move " + t1 + " " + t2);
					}
					else {
						varTable.add(tiny[2]);
						t3 = "r" + (varTable.size() - 1);
						tinyTable.add("move " + t1 + " " + t3);
						tinyTable.add("move " + t3 + " " + t2);
					}
				break;
				case 4:
					if (tiny[1].startsWith("$T")) {
						use = true;
						registerCounter = varTable.indexOf(tiny[1]);
						if (varTable.indexOf(tiny[1]) == -1) {
							varTable.add(tiny[1]);
							registerCounter = varTable.size() - 1;
						}
						t1 = "r" + registerCounter;
					}
					else {
						t1 = tiny[1];
					}
					if (tiny[2].startsWith("$T")) {
						use = true;
						registerCounter = varTable.indexOf(tiny[2]);
						if (varTable.indexOf(tiny[2]) == -1) {
							varTable.add(tiny[2]);
							registerCounter = varTable.size() - 1;
						}
						t2 = "r" + registerCounter;
					}
					else {
						t2 = tiny[2];
					}
					if (tiny[3].startsWith("$T")) {
						use = true;
						registerCounter = varTable.indexOf(tiny[3]);
						if (varTable.indexOf(tiny[3]) == -1) {
							varTable.add(tiny[3]);
							registerCounter = varTable.size() - 1;
						}
						t3 = "r" + registerCounter;
					}
					else {
						t3 = tiny[3];
					}

					if (use) {
						use = false;
						t4 = t2;
					}
					else {
						varTable.add(tiny[2]);
						t4 = "r" + (varTable.size() - 1);
						tinyTable.add("move " + t2 + " " + t4);
					}

					if (tiny[0].startsWith("ADD") 
						|| tiny[0].startsWith("SUB")
						|| tiny[0].startsWith("MULT")
						|| tiny[0].startsWith("DIV")) {
						tinyTable.add("move " + t1 + " " + t3);
						char lastc = tiny[0].charAt(tiny[0].length() - 1);
						switch (lastc) {
							case 'I':
							switch (tiny[0].charAt(0)) {
								case 'A': tinyTable.add("addi " + t2 + " " + t3); break;
								case 'S': tinyTable.add("subi " + t2 + " " + t3); break;
								case 'M': tinyTable.add("muli " + t2 + " " + t3); break;
								case 'D': tinyTable.add("divi " + t2 + " " + t3); break;
								default: tinyTable.add("Unhandled integer operation");
							}
							break;
							case 'F':
							switch (tiny[0].charAt(0)) {
								case 'A': tinyTable.add("addr " + t2 + " " + t3); break;
								case 'S': tinyTable.add("subr " + t2 + " " + t3); break;
								case 'M': tinyTable.add("mulr " + t2 + " " + t3); break;
								case 'D': tinyTable.add("divr " + t2 + " " + t3); break;
								default: tinyTable.add("Unhandled float operation");
							}
							break;
							default: tinyTable.add("Unrecognized datatype");
						}
					}
					else if (tiny[0].startsWith("GE")) {
						if (tiny[0].equals("GEF") || tiny[0].equals("GEQF")) {
							tinyTable.add("cmpr " + t1 + " " + t4);
						}
						else {
							tinyTable.add("cmpi " + t1 + " " + t4);
						}

						if (tiny[0].startsWith("GEQ")) {
							tinyTable.add("jge " + t3);
						}
						else {
							tinyTable.add("jgt " + t3);
						}
					}
					else if (tiny[0].startsWith("LE")) {
						if (tiny[0].equals("LEF") || tiny[0].equals("LEQF")) {
							tinyTable.add("cmpr " + t1 + " " + t4);
						}
						else {
							tinyTable.add("cmpi " + t1 + " " + t4);
						}

						if (tiny[0].startsWith("LEQ")) {
							tinyTable.add("jle " + t3);
						}
						else {
							tinyTable.add("jlt " + t3);
						}
					}
					else if (tiny[0].startsWith("NE")) {
						if (tiny[0].equals("NEF")) {
							tinyTable.add("cmpr " + t1 + " " + t4);
						}
						else {
							tinyTable.add("cmpi " + t1 + " " + t4);
						}
						tinyTable.add("jne " + t3);
					}
					else if (tiny[0].startsWith("EQ")) {
						if (tiny[0].equals("EQF")) {
							tinyTable.add("cmpr " + t1 + " " + t4);
						}
						else {
							tinyTable.add("cmpi " + t1 + " " + t4);
						}
						tinyTable.add("jeq " + t3);
					}
				break;
			}
		}
		fin();
		return tinyTable;
	}
}
