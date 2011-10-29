grammar MicroParser;
@rulecatch {
	catch (RecognitionException re) {
		System.out.println("Not Accepted\n");
		System.exit(1);	
	}
}
@header {
	import java.util.Vector;
	import java.util.LinkedList;
	import java.util.Iterator;
	import java.util.Collections;
	import java.util.ArrayList;
}
@members {
	private List<String> errors = new LinkedList<String>();
	public void displayRecognitionError(String[] tokenNames, RecognitionException e) {
		String hdr = getErrorHeader(e);
		String msg = getErrorMessage(e, tokenNames);
		errors.add(hdr + " " + msg);
	}
	public List<String> getErrors() {
		return errors;
	}
	public int getErrorCount() {
		return errors.size();
	}

	public IntermediateRepresentation ir = new IntermediateRepresentation();
	public List<msTable> masterTable = new Vector<msTable>();
	public List<mSymbol> symbolTable = new Vector<mSymbol>();
	public List<String> irTable = new Vector<String>();
	public msTable tms = new msTable("__global");
	public assembler a = new assembler();
	public Stack<String> labelStack = new Stack<String>();

	public String getType(String varName) {
		Iterator mtc = symbolTable.iterator();
		//System.out.println("Searching for " + varName);
		while (mtc.hasNext()) {
			mSymbol ese = (mSymbol) mtc.next();
			if (ese.getName().equals(varName)) {
				return ese.getType();
			}
		}

		Iterator mti = masterTable.iterator();
		//System.out.println("Searching global for " + varName);
		while (mti.hasNext()) {
			msTable cmte = (msTable) mti.next();
			if (cmte.scope.equals("__global")) {
				Iterator esti = cmte.symbolTable.iterator();
				while (esti.hasNext()) {
					mSymbol ese = (mSymbol) esti.next();
					if (ese.getName().equals(varName)) {
						return ese.getType();
					}
				}
			}
			break;
		}

		System.out.println("Variable " + varName + " not found");
		return null;
	}
}
/* Program */
program 	: 'PROGRAM' id 'BEGIN' {
			irTable.add(ir.generateLabel("main"));
		} 
		pgm_body 'END'
{
	tms.attachTable(symbolTable);
	masterTable.add(tms);

	// IR table
	//System.out.println("===================");
	Iterator irti = irTable.iterator();
	while (irti.hasNext()) {
		System.out.println(";" + irti.next());
	}

	// Symbol table
	//System.out.println("===================");
	/*Iterator mti = masterTable.iterator();
	while (mti.hasNext()) {
		msTable cmte = (msTable) mti.next();
		if (cmte.scope.equals("__global")) {
			System.out.println("Printing Global Symbol Table");
		}
		else {
			System.out.println("Printing Symbol Table for " + cmte.scope);
		}
		Iterator esti = cmte.symbolTable.iterator();

		while (esti.hasNext()) {
			mSymbol ese = (mSymbol) esti.next();
			System.out.print("name: " + ese.getName());
			System.out.print(" type " + ese.getType());
			if (ese.getValue() != "") {
				System.out.print(" value: " + ese.getValue());
			}
			System.out.println();
		}
		System.out.println();
	}*/
	// End Symbol Table

	a.init(masterTable);
	List<String> tinyOutput = a.process(irTable, false);

	//System.out.println("===================");
	for (String x: tinyOutput) {
		System.out.println(x);
	}

};
id		: IDENTIFIER;
pgm_body	: decl func_declarations;
decl 		: (string_decl | var_decl)*;
/* Global String Declaration */
string_decl	: 'STRING' id ':=' str ';'
{
	symbolTable.add(new mSymbol($id.text, "STRING", $str.text));
};
str		: STRINGLITERAL;
string_decl_tail: string_decl string_decl_tail?;
/* Variable Declaration */
var_decl	: var_type id_list ';' 
{
	while (!$id_list.stringList.empty()) {
		String t = $id_list.stringList.pop();
		symbolTable.add(new mSymbol(t, $var_type.text));
	}
};
var_type	: 'FLOAT' | 'INT';
any_type	: var_type | 'VOID';
id_list	returns [ Stack<String> stringList ]
		: id id_tail 
{
	$stringList = $id_tail.stringList;
	$stringList.push($id.text);
};
id_tail returns [ Stack<String> stringList ]
	 	: ',' id tailLambda = id_tail 
{
	$stringList = $tailLambda.stringList;
	$stringList.push($id.text);
}
		| 
{
	$stringList = new Stack<String>();
};
var_decl_tail	: var_decl var_decl_tail?;
/* Function Parameter List */
param_decl_list : param_decl param_decl_tail;
param_decl	: var_type id;
param_decl_tail	: ',' param_decl param_decl_tail | ;
/* Function Delcarations */
func_declarations: (func_decl func_decl_tail)?;
func_decl	: 'FUNCTION' any_type id 
{
	Iterator fti = symbolTable.iterator();
	while (fti.hasNext()) {
		mSymbol init = (mSymbol) fti.next();
	}
	tms.attachTable(symbolTable);
	masterTable.add(tms);
	tms = new msTable($id.text);
	symbolTable = new Vector<mSymbol>();
}
		'(' param_decl_list? ')' 'BEGIN' func_body 'END' ;
func_decl_tail	: func_decl*;
func_body	: decl stmt_list;
/* Statement List */
stmt_list	: stmt stmt_tail | ;
stmt_tail	: stmt stmt_tail | ;
stmt		: assign_stmt | read_stmt | write_stmt | return_stmt | if_stmt | do_stmt;
/* Basic Statement */
assign_stmt	: assign_expr ';';
assign_expr	: id ':=' expr {
	//System.out.println($id.text + ", " + $expr.temp);
	if (getType($id.text).equals("INT") || getType($id.text).equals("FLOAT")) {
		irTable.add(ir.store($expr.temp, $id.text, getType($id.text)));
	}
}
;
read_stmt	: 'READ' '(' id_list ')' ';' {
	Stack<String> ds = new Stack<String>();
	for (String i : $id_list.stringList) {
		//System.out.println(i + " " + getType(i));
		ds.push(ir.rw(i, "READ", getType(i)));
		//irTable.add(ir.rw(i, "READ", getType(i)));
	}
	while (!ds.empty()) {
		irTable.add(ds.pop());
	}
};
write_stmt	: 'WRITE' '(' id_list ')' ';' {
	Stack<String> ds = new Stack<String>();
	for (String i : $id_list.stringList) {
		//System.out.println(i + " " + getType(i));
		ds.push(ir.rw(i, "WRITE", getType(i)));
		//irTable.add(ir.rw(i, "WRITE", getType(i)));
	}
	while (!ds.empty()) {
		irTable.add(ds.pop());
	}
};
return_stmt	: 'RETURN' expr ';';
/* Expressions */
expr returns [String temp]
		: factor expr_tail {
		char tempOp;
		String tempVar;
		String left = $factor.temp;
		//System.out.println("xl: " + left);

		while(!$expr_tail.ops.isEmpty()) {
			String result = ir.generate();
			tempOp = $expr_tail.ops.removeFirst();
			tempVar = $expr_tail.temp.removeFirst();
			//System.out.println("left: " + left + " tail: " + tempOp + ", " + tempVar);
			
			irTable.add(ir.arithmetic(left, tempVar, result, tempOp, getType(tempVar)));
			symbolTable.add(new mSymbol(result, getType(tempVar)));
			left = result;
		}
		//System.out.println("returning: " + left);
		$temp = left;
		};
expr_tail returns [LinkedList<Character> ops, LinkedList<String> temp]
		: addop factor lambda=expr_tail {
			$ops = $lambda.ops;
			$temp = $lambda.temp;
			$ops.addLast($addop.op);
			$temp.addLast($factor.temp);
		}
		| {
			$ops = new LinkedList();
			$temp = new LinkedList();
		};
factor returns [String temp]
		: postfix_expr factor_tail {
		char tempOp;
		String tempVar;
		String left = $postfix_expr.temp;

		while (!$factor_tail.ops.isEmpty()) {
			String result = ir.generate();
			tempOp = $factor_tail.ops.removeFirst();
			tempVar = $factor_tail.temp.removeFirst();
		
			irTable.add(ir.arithmetic(left, tempVar, result, tempOp, getType(tempVar)));
			symbolTable.add(new mSymbol(result, getType(tempVar)));
			left = result;
		}
		$temp = left;
		};
factor_tail returns [LinkedList<Character> ops, LinkedList<String> temp]
		: mulop postfix_expr lambda=factor_tail {
			$ops = $lambda.ops;
			$temp = $lambda.temp;
			$ops.addLast($mulop.op);
			$temp.addLast($postfix_expr.temp);
		}
		| {
			$ops = new LinkedList();
			$temp = new LinkedList();
		};
postfix_expr returns [String temp]
		: primary {
			$temp = $primary.temp;
		} | call_expr;
call_expr returns [String temp]
		: id '(' expr_list? ')';
expr_list	: expr expr_list_tail;
expr_list_tail 	: ',' expr expr_list_tail |;
primary returns [String temp]
		: '(' expr ')' {
			$temp = $expr.temp;
		}
		| id {
			$temp = $id.text;
		}
		| INTLITERAL {
			$temp = ir.generate();
			symbolTable.add(new mSymbol($temp, "INT"));
			irTable.add(ir.store($INTLITERAL.text, $temp, "INT"));
		}
		| FLOATLITERAL {
			$temp = ir.generate();
			symbolTable.add(new mSymbol($temp, "FLOAT"));
			irTable.add(ir.store($FLOATLITERAL.text, $temp, "FLOAT"));
		};
addop returns [char op]
		: '+' {$op = '+';} | '-' {$op = '-';};
mulop returns [char op]
		: '*' {$op = '*';} | '/' {$op = '/';};
/* Comples Statemens and Condition */
if_stmt 	: 'IF' '(' cond ')' 'THEN' stmt_list else_part 'ENDIF' {irTable.add(ir.label(labelStack.pop())); };
else_part	: 'ELSE' {
			String nextLabel = labelStack.pop();
			irTable.add(ir.jump(labelStack.peek())); 
			irTable.add(ir.label(nextLabel));
		} stmt_list | { irTable.add(ir.label(labelStack.pop())); };
cond 		: l1=expr compop l2=expr {
			labelStack.push(ir.generateLabel());
			String nLabel = ir.generateLabel();
			labelStack.push(nLabel);
			irTable.add(ir.comparison($l1.temp, $l2.temp, $compop.text, nLabel, getType($l1.temp)));
		};
compop		: '<' | '>' | '=' | '!=';
do_stmt		: 'DO' {
			String lLabel = ir.generateLabel();
			labelStack.push(lLabel);
			irTable.add(ir.label(lLabel));
		}
	 	stmt_list 'WHILE' '(' cond ')' ';' {
			String loopBack = labelStack.pop();
			String unused = labelStack.pop();
			String loopExit = labelStack.pop();
			irTable.add(ir.jump(loopExit));
			irTable.add(ir.label(loopBack));
		};

fragment DIGIT          : '0'..'9';
fragment LETTER         : 'A'..'Z'|'a'..'z';
fragment ALPHANUMERIC   : '0'..'9'|'A'..'Z'|'a'..'z';

KEYWORD         : 'PROGRAM' 
                | 'BEGIN' 
                | 'END' 
                | 'PROTO' 
                | 'FUNCTION' 
                | 'READ' 
                | 'WRITE' 
                | 'IF' 
                | 'THEN'
                | 'ELSE'
                | 'ENDIF'
                | 'RETURN'
		| 'CASE'
		| 'ENDCASE'
		| 'BREAK'
		| 'DEFAULT'
		| 'DO' 
		| 'WHILE' 
                | 'FLOAT'
                | 'INT' 
                | 'VOID'
                | 'STRING';
/*OPERATOR        : ':='
                | '+'
                | '-'
                | '*'
                | '/'
                | '='
		| '!='
                | '<'
                | '>'
                | '('
                | ')'
                | ';'
                | ',';*/
INTLITERAL      : (DIGIT)+;
FLOATLITERAL    : (DIGIT)*('.'(DIGIT)+);
STRINGLITERAL   : ('"'(~('\r'|'\n'|'"'))*'"');
WHITESPACE      : ('\n'|'\r'|'\t'|' ')+
                {skip();};
COMMENT         : '--'
                (~('\n'|'\r'))*
                ('\n'|'\r'('\n')?)?
                {skip();};
IDENTIFIER      : (LETTER)(ALPHANUMERIC)*;
