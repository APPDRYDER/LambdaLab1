package pkg1;

import java.util.concurrent.ExecutionException;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;

import org.eclipse.jetty.client.HttpClient;
import org.eclipse.jetty.client.api.ContentResponse;
import org.eclipse.jetty.client.util.StringContentProvider;
import org.eclipse.jetty.http.HttpMethod;
import org.eclipse.jetty.server.Server;
import org.eclipse.jetty.server.handler.ContextHandlerCollection;
import org.eclipse.jetty.http.HttpHeader;
import org.eclipse.jetty.util.ssl.SslContextFactory;

public class AwsLambda {
	private static  Utils ut;
	private HttpClient client;
	private int count;

	public AwsLambda() {
		count = 0;
		ut = new Utils();
		try {
			SslContextFactory.Client sslContextFactory = new SslContextFactory.Client();
			client = new HttpClient(sslContextFactory);
			client.start();
		} catch (Exception e) {
			System.out.println("AwsLambda: Error:" + e);
			// e.printStackTrace();
		}
	} // AwsLambda

	public void clientStop() {
		try {
			client.stop();
		} catch (Exception e) {
			System.out.println("clientStop: Error:" + e);
			// e.printStackTrace();
		}
	} // AwsLambda

	public void postMessage(HttpClient client, String uri, String message, String apiKey) {
		count++;
		System.out.println(String.format("PostMessage: %s, %s, %d", uri, message, count));
		try {
			org.eclipse.jetty.client.api.Request r = client.POST(uri);
			r.content(new StringContentProvider(message));
			r.header(HttpHeader.CONTENT_TYPE, "application/json");
			if (apiKey.length() > 0) {
				r.header("x-api-key", apiKey);
			}
			r.timeout(30, TimeUnit.SECONDS);
			ContentResponse cr = r.send();
			System.out.println("Response " + cr.getContentAsString());
		} catch (Exception e) {
			System.out.println("PostMessage: Error: " + uri + " " + message);
			e.printStackTrace();
		}
		System.out.println("PostMessage: Complete");
	} // postMessage

	public void sendApiCall(String awsRegion, String awsApiId, String awsStage, String apipath, String apiKey,
			String message) {
		// Invoke URL:
		// https://wocm6phj94.execute-api.us-west-1.amazonaws.com/PROD/DDRTEST1
		// System.out.println(String.format("AWS Lambda [%s %s %s %s %s %s]", awsRegion,
		// awsApiId, awsStage, apipath, apiKey, message));
		try {
			String uri = String.format("https://%s.execute-api.%s.amazonaws.com/%s/%s", awsApiId, awsRegion, awsStage,
					apipath);
			postMessage(client, uri, message, apiKey);
		} catch (Exception e) {
			e.printStackTrace();
		}
	} // sendApiCall

	public void testApiCall(String[] args) {

	} // testApiCall

	public static void main(String[] args) throws Exception {
		AwsLambda al = new AwsLambda();
		
		String awsRegion = ut.getArgStr(args, 0, "");
		String awsApiId = ut.getArgStr(args, 1, "");
		String awsStage = ut.getArgStr(args, 2, "");
		String apipath = ut.getArgStr(args, 3, "");
		String apiKey = ut.getArgStr(args, 4, "");
		String message = ut.getArgStr(args, 5, "{ \"firstName\": \"David...\", \"lastName\": \"Ryder\" }");
		System.out.println(String.format("Params: (%s, %s, %s, %s, %s, %s)", awsRegion, awsApiId, awsStage, apipath,
				apiKey, message));

		al.sendApiCall(awsRegion, awsApiId, awsStage, apipath, apiKey, message);
		
		al.clientStop();
	} // main
} // AwsLambda
