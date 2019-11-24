package pkg1;

import java.io.IOException;
import java.io.PrintWriter;
import java.net.URL;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Random;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.eclipse.jetty.server.Request;
import org.eclipse.jetty.server.handler.AbstractHandler;
import org.json.JSONObject;

public class AwsHandler1 extends AbstractHandler {
	private int totalReads = 0;
	private Utils ut;
	private Map<String, Integer> accessLog;
	private Random r1 = new Random();
	AwsLambda al = new AwsLambda();

	public AwsHandler1() {
		ut = new pkg1.Utils();
	} // Test1Handler

	public static final void log(String s) {
		// log1.info(s);
		System.out.println(s);
	}

	public void handle(String target, Request baseRequest, HttpServletRequest request, HttpServletResponse response)
			throws IOException, ServletException {
		String bodyStr = null;
		PrintWriter out = response.getWriter();

		System.out.println(String.format("[%s, %s, %s]", baseRequest.getMethod(), baseRequest.getRequestURL(),
				baseRequest.getPathInfo()));

		if (baseRequest.getMethod() == "POST") {
			bodyStr = request.getReader().lines().reduce("", (accumulator, actual) -> accumulator + actual);
			System.out.println(String.format("POST body %s", bodyStr));
			try {
				JSONObject j = new JSONObject(bodyStr);
				String awsRegion = ut.getJSONStringParameter(j, "region", "");
				String awsApiId = ut.getJSONStringParameter(j, "apiId", "");
				String awsStage = ut.getJSONStringParameter(j, "stage", "");
				String apiPath = ut.getJSONStringParameter(j, "apiPath", "");
				String apiKey = ut.getJSONStringParameter(j, "apiKey", "");
				String message = ut.getJSONStringParameter(j, "message", "");
				System.out.println(String.format("POST(%s, %s, %s, %s, %s, %s)", awsRegion, awsApiId, awsStage, apiPath,
						apiKey, message));
				System.out.println(String.format("JSON ok %s", bodyStr));
				//j.put("duration", durationTime);
			} catch (Exception e) {
				System.out.println(String.format("JSON error %s, %s", bodyStr, e));
			}
			response.setContentType("text/html; charset=utf-8");
			response.setStatus(HttpServletResponse.SC_OK);

		} else if (baseRequest.getMethod() == "GET") {
			// Expects /thread/fn
			// curl -G 0.0.0.0:18081/threads/ --data-urlencode "threads=1" --data-urlencode
			// "reads=4"
			// ut.printParameterMap(request);
			response.setContentType("text/html; charset=utf-8");
			if (baseRequest.getPathInfo().equals("/health")) {
				out.println(String.format("ok"));
				System.out.println("ok");

			} else if (baseRequest.getPathInfo().equals("/API")) {
				String awsRegion = ut.getStringParameter(request, "region", "");
				String awsApiId = ut.getStringParameter(request, "apiId", "");
				String awsStage = ut.getStringParameter(request, "stage", "");
				String apiPath = ut.getStringParameter(request, "apiPath", "");
				String apiKey = ut.getStringParameter(request, "apiKey", "");
				String message = ut.getStringParameter(request, "message", "");
				System.out.println(String.format("(%s, %s, %s, %s, %s, %s)", awsRegion, awsApiId, awsStage, apiPath,
						apiKey, message));
				al.sendApiCall(awsRegion, awsApiId, awsStage, apiPath, apiKey, message);

			} else {
				response.setStatus(HttpServletResponse.SC_NOT_FOUND);
				out.println(String.format("<h1>PathInfo Not found [%s, (%s)]</h1>", baseRequest.getRequestURL(),
						baseRequest.getPathInfo()));
			}

		} else {
			response.setContentType("text/html; charset=utf-8");
			response.setStatus(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
		}

		//if (body != null) {
		//	out.println(body);
		//}
		baseRequest.setHandled(true);
	} // handle
} // Test1Handler
