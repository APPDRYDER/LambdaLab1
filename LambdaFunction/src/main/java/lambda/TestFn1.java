
package lambda;

import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.Reader;
import com.google.common.io.CharStreams;
import org.json.JSONObject;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestStreamHandler;

public class TestFn1 implements RequestStreamHandler {
	public void handleRequest(InputStream input, OutputStream output, Context context) throws IOException {
		String s1 = null;
		Reader reader = new InputStreamReader(input);
		s1 = CharStreams.toString(reader);
		try {
			JSONObject j = new JSONObject(s1);
			System.out.println(String.format("JSON ok %s", s1));
			if (j.has("error")) {
				throw new java.lang.Error("Error");
			}
		} catch (Exception e) {
			System.out.println(String.format("JSON error %s, %s", s1, e));
		}
		String s2 = s1.toUpperCase();
		output.write(s2.getBytes());
	} // handleRequest
} // class TestFn1
