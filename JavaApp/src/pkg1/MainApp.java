package pkg1;

import java.util.List;
import java.util.Random;

import org.eclipse.jetty.server.Handler;
import org.eclipse.jetty.server.Server;
import org.eclipse.jetty.server.handler.ContextHandler;
import org.eclipse.jetty.server.handler.ContextHandlerCollection;

public class MainApp {
	private Random r1 = new Random();
	private static Utils ut;

	public MainApp() {
		ut = new Utils();
	}

	public void addTest1ContextHandler(ContextHandlerCollection contexts, String segment0) {
		AwsHandler1 mh1 = new AwsHandler1();
		ContextHandler c1 = new ContextHandler(segment0);
		c1.setHandler((Handler) mh1);
		contexts.addHandler(c1);
		System.out.println(String.format("Starting context handler %s)", segment0));
	} // add....

	public static void main(String[] args) throws Exception {
		MainApp fa = new MainApp();
		int serverPort = 18081;
		int sqlQueryListSize = 5000;
		int sqlLongQueries = 100;
		String nodeName;

		//nodeName = (args.length >= 1) ? args[0] : "NODE-";
		serverPort = ut.getArgInt( args, 0, 18081);
		//sqlQueryListSize = ut.getArgInt( args, 2, 10);
		//sqlLongQueries = ut.getArgInt( args, 3, 2);

		Server server = new Server(serverPort);
		ContextHandlerCollection contexts = new ContextHandlerCollection();

		fa.addTest1ContextHandler(contexts, "/aws/");

		server.setHandler(contexts);

		server.start();
		server.join();
	}

}
