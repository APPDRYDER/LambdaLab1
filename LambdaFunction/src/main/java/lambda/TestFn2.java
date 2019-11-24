
package lambda;

import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.text.SimpleDateFormat;
import java.util.Date;

import com.google.common.io.CharStreams;
import org.json.JSONObject;

import com.amazonaws.services.lambda.runtime.Context;
import com.appdynamics.serverless.tracers.aws.api.MonitoredRequestStreamHandler;

public class TestFn2 extends MonitoredRequestStreamHandler {
	public void handleMonitoredRequest(InputStream input, OutputStream output, Context context) throws IOException {
		long startTime = System.currentTimeMillis();
		String jStrSrc, jStr = null;
		jStrSrc = CharStreams.toString(new InputStreamReader(input));
		try {
			JSONObject j = new JSONObject(jStrSrc);
			if (j.has("error")) {
				throw new java.lang.Error("Error");
			}
			j.put("fnname", context.getFunctionName());
			j.put("timestamp", new SimpleDateFormat("yyyy.MM.dd.HH.mm.ss").format(new Date()));
			j.put("duration", System.currentTimeMillis() - startTime);
			jStr = j.toString();
		} catch (Exception e) {
			System.out.println(String.format("JSON error %s, %s", jStrSrc, e));
		}
		output.write(jStr.getBytes());
	} // handleMonitoredRequest
} // class TestFn2
