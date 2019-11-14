
package lambda;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.Reader;
import java.io.InputStreamReader;
import com.amazonaws.services.lambda.runtime.RequestStreamHandler;
import com.google.common.io.CharStreams;
import com.amazonaws.services.lambda.runtime.Context;

public class TestFn0 implements RequestStreamHandler{
    public void handleRequest(InputStream inputStream, OutputStream outputStream, Context context) throws IOException {
		String s1 = null;
		Reader reader = new InputStreamReader(inputStream);
		s1 = CharStreams.toString(reader);
		System.out.println(String.format("Read v1 %s", s1));
		String s2 = s1.toUpperCase();

		outputStream.write(s2.getBytes());
    }
}