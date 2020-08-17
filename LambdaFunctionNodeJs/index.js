
const tracer = require('appdynamics-lambda-tracer');
//Initialize the tracer
tracer.init();

// Your AWS Lambda handler function code here, for example:
exports.handler = async (event) => {
    // TODO implement
    const response = {
        statusCode: 200,
        body: JSON.stringify('Hello from Lambda!'),
    };
    return response;
};
//Complete the instrumentation
tracer.mainModule(module);
