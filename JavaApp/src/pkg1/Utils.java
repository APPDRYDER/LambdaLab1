package pkg1;

import java.util.Enumeration;
import java.util.Iterator;
import java.util.Map;
import java.util.Timer;
import java.util.TimerTask;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;

import javax.servlet.http.HttpServletRequest;

import org.eclipse.jetty.client.HttpClient;
import org.eclipse.jetty.client.api.ContentResponse;
import org.eclipse.jetty.client.util.StringContentProvider;
import org.eclipse.jetty.http.HttpMethod;

//ContentResponse res = client.GET("http://localhost:8080/");
//System.out.println(res.getContentAsString());

public class Utils {
	public void printParameterMap(HttpServletRequest request) {
		Map<String, String[]> params = request.getParameterMap();
		Iterator<String> i = params.keySet().iterator();
		while (i.hasNext()) {
			String key = (String) i.next();
			String value = ((String[]) params.get(key))[0];
			System.out.println("Requst Params Key: [" + key + "] - Val: [" + value + "]");
		}
	} // printParametermap
	
	public int getIntParameter(HttpServletRequest request, String name, int v) {
		int result = v;
		try {
			result = Integer.parseInt(request.getParameter(name));
		} catch (Exception e) {
			result = v;
		}
		return result;
	}
	
	public String getStringParameter(HttpServletRequest request, String name, String v) {
		String result = v;
		try {
			result = request.getParameter(name);
			result = (result != null) ? result : v;
		} catch (Exception e) {
			result = v;
		}
		return result;
	}
	
	
	public int getIntParameter(String value, int v) {
		int result = v;
		try {
			result = Integer.parseInt(value);
		} catch (Exception e) {
			result = v;
		}
		return result;
	}
	
	public int getArgInt(String[] args, int argN, int defaultValue) {
		return (args.length > argN) ? getIntParameter(args[argN], defaultValue) : defaultValue;
	}
	
	public String getArgStr(String[] args, int argN, String defaultValue) {
		return (args.length > argN) ? args[argN] : defaultValue;
	}

	public void waitSeconds(int seconds) {
		try {
			Thread.sleep(seconds * 1000);
		} catch (InterruptedException e) {
			System.out.println(String.format("Exception: %s", e));
		}
	}
	
	public void printHeaders(org.eclipse.jetty.server.Request r) {
		System.out.println(r.getMethod() + " " + r.getContextPath());
		Enumeration<String> headerNames = r.getHeaderNames();
		while (headerNames.hasMoreElements()) {
			String key = (String) headerNames.nextElement();
			String value = r.getHeader(key);
			System.out.println(key + "  " + value);
		}
	} // printHeaders

	public void postMessage(HttpClient client, String uri, String message, boolean async) {
		System.out.println("PostMessage: " + async + " " + message);
		try {
			if (async) {
				ContentResponse r = client.newRequest(uri)
						.method(HttpMethod.POST)
						.content(new StringContentProvider(message), "text/plain")
						.timeout(30, TimeUnit.SECONDS)
						.send();
			} else {
				org.eclipse.jetty.client.api.Request r = client.POST(uri);
				r.content(new StringContentProvider(message), "text/plain");
				r.timeout(30, TimeUnit.SECONDS);
				r.send();
			}
		} catch (InterruptedException | TimeoutException | ExecutionException e) {
			System.out.println("PostMessage: Error:" + async + " " + uri + " " + message);
			// e.printStackTrace();
		}
		System.out.println("PostMessage: Complete");
	} // postMessage

	class PostMessageTask extends TimerTask {
		private HttpClient client;
		private String uri;
		private String message;
		private long count;
		private boolean async;

		public PostMessageTask(HttpClient client, String uri, String message, boolean async) {
			this.client = client;
			this.uri = uri;
			this.message = message;
			this.count = 0;
			this.async = async;
		}

		public void run() {
			postMessage(this.client, this.uri, this.message + "-" + this.count, this.async);
			this.count++;
			//
			// try {
			// ContentResponse res = this.client.GET(this.uri);
			// System.out.println(res.getContentAsString());
			// } catch (InterruptedException | ExecutionException | TimeoutException e) {
			// e.printStackTrace();
			// }
		}

	} // PostMessageTask

	public Timer postMessageScheduler(HttpClient client, String uri, String message, long delay, long period, boolean async) {
		Timer t = new Timer();
		t.schedule(new PostMessageTask(client, uri, message, async), delay, period);
		return t;
	} // postMessageScheduler

} // Utils
