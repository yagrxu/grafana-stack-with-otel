# Install required packages for instrumentation and to support tracing with AWS X-Ray
pip install opentelemetry-distro[otlp]>=0.24b0 \
            opentelemetry-sdk-extension-aws~=2.0 \
            opentelemetry-propagator-aws-xray~=1.0

# Automatically install supported Instrumentors for the application's dependencies
opentelemetry-bootstrap --action=install
