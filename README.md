# Concepts
### REST
REST - based on HTTP. use HTTP verbs. representation of a resource. HATEOAS (Hypertext As The Engine Of Application State) 

Drawbacks of HTTP:
Only for request-response. Not for notifications.
Interface Definition: RAML and swagger.

### Web sockets
Are bidrectional. Are full duplex. Single TCP connection  - Initial HTTP request, upgrade to socket connection

### Serverless
* AWS Step Functions
* Azure Durable Functions
* Azure Logic Apps 

### Architecture

UseCase : Why we need it. Interation between user and system. \
API Requirements: APIS- HTTP Request, Description, Response, Error Response \
Physical Architecture: Services/Components involved \

### Build

## To create a library project

1. The project version is set as “${revision}”. Pass version from CI/CD tool. https://medium.com/trendyol-tech/semantic-versioning-and-gitlab-6bcd1e07c0b0
2. <packaging>jar</packaging>
3. use the maven-compiler-plugin that will compile the project and create the jar file.

## To create a web api
1. use the maven-compiler-plugin that will compile the project and create the jar file.
2. use spring-boot-maven-plugin

## To pass configuration to a library
1. In library create marvelousapiclient-application.yaml file
2. To read properties file create a class that implements PropertySourceFactory. Select the profile
3. @PropertySource(value = "classpath:marvelousapiclient-application.yaml", factory = YamlPropertySourceFactory.class)

### Teraform
https://www.hashicorp.com/resources/evolving-infrastructure-terraform-opencredo


### Spring multi module
https://spring.io/guides/gs/multi-module/

https://stackoverflow.com/questions/32282447/java-how-to-make-a-library-i-made-use-config-values/32282570

https://stackoverflow.com/questions/8775303/read-properties-file-outside-jar-file

https://stackoverflow.com/questions/57489226/spring-how-to-pass-configuration-from-application-to-library

https://docs.spring.io/spring-boot/docs/current/reference/html/features.html#features.developing-auto-configuration



