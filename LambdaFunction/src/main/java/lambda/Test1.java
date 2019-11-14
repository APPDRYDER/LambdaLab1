
package lambda;

import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.Reader;

import com.amazonaws.services.lambda.runtime.Context;
import com.appdynamics.serverless.tracers.aws.api.MonitoredRequestStreamHandler;
import com.google.common.io.CharStreams;

public class Test1 extends MonitoredRequestStreamHandler {
	public void handleMonitoredRequest(InputStream input, OutputStream output, Context context) throws IOException {
		String s1 = null;
		Reader reader = new InputStreamReader(input);
		s1 = CharStreams.toString(reader);
		System.out.println(String.format("Read v1 %s", s1));
		String s2 = s1.toUpperCase();

		output.write(s2.getBytes());
	} // handleMonitoredRequest
} // class Test1