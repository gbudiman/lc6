import java.util.Vector;
import java.util.List;

class masterIR {
	public List<String> ir;
	public String scope;

	public masterIR(String s) {
		scope = s;
	}

	public masterIR(List<String> _ir, String s) {
		ir = _ir;
		scope = s;
	}

	public void attachTable(List<String> _ir) {
		ir = _ir;
	}

}
