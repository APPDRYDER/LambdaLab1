package lambda;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.appdynamics.serverless.tracers.aws.api.AppDynamics;
import com.appdynamics.serverless.tracers.aws.api.Tracer;
import com.appdynamics.serverless.tracers.aws.api.Transaction;
import com.appdynamics.serverless.tracers.dependencies.com.amazonaws.Request;
import com.appdynamics.serverless.tracers.dependencies.com.amazonaws.Response;

public class TestFn3 implements RequestHandler<Request, Response>  {

	public int handleRequest(InputStream input, OutputStream output, Context context) throws IOException {

		Tracer tracer = AppDynamics.getTracer(context);
		Transaction transaction = tracer.createTransaction(input, context);

		// Start the transaction monitoring.
		transaction.start();
		int count = 0;
		try {
			int letter = 0;
			while ((letter = input.read()) >= 0) {
				output.write(Character.toUpperCase(letter));
				count++;
			}
		} finally {
			// Stop the transaction monitoring. Place in a finally block to monitor all events.
			transaction.stop();
			AppDynamics.cleanup();
		}
		return count;
	}

	public Response handleRequest(Request input, Context context) {
		// TODO Auto-generated method stub
		return null;
	}
} // TestFn3