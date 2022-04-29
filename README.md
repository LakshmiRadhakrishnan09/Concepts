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

Scenario: Kubenertes in AWS : VPC, Public subnet, Private subnet, Bastion, VM with k8s, RDS

* Do not use use single state file for non-prod and production. Envt - Seperate state management into prod and test. Also seperate into logical files eg: networks.tf, vms.tf
* Avoid duplicate definition. Use Reusable modules. 
      * Identify logical groups. Eg: Core ( VPC, Subnets, Gateways, Bastion Hosts), DB(RDS, RDS Subnet), K8s cluster(Instances, Security Groups)
      * Modules : core, k8s-cluster, databse folders
            * input.tf and output.tf . Clear contarcts for each module. Pass output as inputs to other modules.
      * envs: config.tf, terraform.ts, terraform.tfvars, terraform.tfstate
      * Nested modules:
      *       common: aws(network-> vpc, pub_subnet, priv_subnet ;  comps -> instances, db-instances)
      *       Core modules will be composed of base modules. 
* Make things that change as configurable eg: IP address range
* Manage components independently. Scenario: Change only bastion host without affecting k8s cluster
      * One state file for each envt


### Spring multi module
https://spring.io/guides/gs/multi-module/

https://stackoverflow.com/questions/32282447/java-how-to-make-a-library-i-made-use-config-values/32282570

https://stackoverflow.com/questions/8775303/read-properties-file-outside-jar-file

https://stackoverflow.com/questions/57489226/spring-how-to-pass-configuration-from-application-to-library

https://docs.spring.io/spring-boot/docs/current/reference/html/features.html#features.developing-auto-configuration

### Spring Boot

* start.spring.io : spring intializer . Use IntelliJ plugin Spring Intializer.
* spring probject can be imported as a module
* in a spring web project, u can place static html files under resources folder. When spring boor starts u can hit it at port 80.
* GroupId, ArtifactId

**Auto-cofiguration**
* @EnableAutoConfiguration: Scans configuration classes dynamically. 
* Conditional Loading: @ConditionalOnClass, @ConditionalOnBean, @ConfigurationOnProperty, @ConfigurationOnMissingBean
* EnableConfigurationProperties
* Spring Configuration can be injected through properties or beans.
* Property based configuration : application.properties, application.yaml, Enviornment Variables, Command line parameters, Cloud Configuration( Config Server, Consul) - Most common way.
* Bean Configuration: Adding beans to default application class, adding beans to seperate configuration classes( using @ComponentScan) , importing xml based configuration( legacy) , Component Scanning( Any component that is in sub package of main SpringBootApplicatin package is component scanned automatically)

**Spring profiles**
* Change configuration based on enviornment profile.
* Multi enviornment deployments - dev, stage, prod
* Application.yaml: 

               ```
                    spring:
                         profiles: dev
                    server:
                         port: 8000
                    --- ( 3 hypens)
                    spring:
                         profiles: test
                    server:
                         port: 9000
            ```
            
* Engaging profile : spring.profiles.active as an enviornment variable

**Building**
Spring has build scripts for building. Maven and Grdle use these build scripts. Creates a executable JAR. 
Containaziring Spring boot application: You can use build-image plugin or write a DockerFile(allows more control). 

**Web Applications**
In Spring boot,web services and html based applications are same. A single application can have both. spring-boot-starter-web adds following dependencies -  Tomcat, JSON Marshalling - Jackson, Automatic marshalling and unmarshalling, Logging - Slf4j. Logback logging. SnakeYaml. Testing - Junit. \
Servlets, Filters and Listeners: Default servlet responds at "/". To add own Servlets u can annotate with @WebServlet. \
Embedded server: Can be configured by Properties. eg: server.port. All properties available at https://docs.spring.io/spring-boot/docs/current/reference/html/application-properties.html#application-properties.server \
Compression: Can be configured by Properties. \
TLS: Can be configured by Properties. U need to use a keystore that contains a certificate. 
Spring boot web application: Based on Spring MVC. To build an application
* Create a module
* Add spring web dependency
* Add Thymeleaf Template dependency
* Add a template under resources -> template -> HTML file with thyme namespace. Display th:each="room:${rooms}" th:text="${room.name}" in a table.
* Add a new model under main java
* Add controller. @Controller , @RequestMapping("/rooms")
* Add a @GetMapping which accepts a Model model method parameter. model.addAttribute("rooms", arrayListOfRooms); return "rooms"; "rooms" is used in template.
Spring boot web services(REST API):Based on Spring MVC. View is content type of page **not** HTML. Use @RestController instaed of @Controller in order not to return a view but intsead a marshalled object. JSON is the default output type.


### Spring Cloud

### ADFS

Active Directory Federation Service. \
Provide SSO for web applications. Once u signed to a workstation, u can use same crdetials with third party applications. \
Sends a claim to a web application in behalf of AD. \

Why we need ADFS? \
Organization AD on premise, Domain Users ---------------- Cloud Resources \
Alternate Options: \
1. VPN Tunnel and Domain Trust
2. Export from domain to cloud
3. Keep different username and password for work account and cloud resource: For any new service, need to bring new user and passwords.


ADFS Flow
1. User login to computer. Trying to access a cloud resource. 
2. Cloud Resource redirect to ADFS. 
3. User authenticated against ADFS.
4. ADFS authenticates check user against a AD. A claim in the form of cookie is handed back to user(SAML Cookie). A redirection link of cloud resource.
5. Cloud resource accept claim and allow the user.
6. Username and password is not provided to cloud resource. Login is using claim.

Authentication 
https://www.youtube.com/watch?v=CjarTgjKcX8

![ModernAuthentication](https://user-images.githubusercontent.com/33679023/156295307-cb6eae97-0608-4c56-9e79-ca6a72b8f86c.png)

![Authentication2](https://user-images.githubusercontent.com/33679023/156296972-3577c83f-7b83-43a4-a6c8-600ee1bcc354.png)

![SSO](https://user-images.githubusercontent.com/33679023/156297687-489f748f-b357-47e7-bbfa-97456aa48cd8.png)

![Federation-ADFS](https://user-images.githubusercontent.com/33679023/156299227-1542cbfe-de46-4c81-833c-d1716c4d0d66.png)


### Skaffold
Command line tool that facilitates continuous development for Kubernetes-native applications.

### Jenkins
https://www.youtube.com/watch?v=1fPTOhn8fgk

### Cucumber - BDD
Cucumber is a tool that supports Behaviour-Driven Development(BDD). \
Cucumber reads executable specifications written in plain text and validates that the software does what those specifications say. \
Gherkin is a set of grammar rules that makes plain text structured enough for Cucumber to understand. \
Gherkin documents are stored in .feature text files . \
Step definitions connect Gherkin steps to programming code. \

### Hibernate

##  ManyToOne Relationship

Many Students can have one address. A student can have only one address.

![image](https://user-images.githubusercontent.com/33679023/158552126-f52f0ec1-4b66-44ea-82f8-9351d92f83ff.png)

![image](https://user-images.githubusercontent.com/33679023/158552291-ad39fa2c-8ca0-4707-9b13-b2b15830f3a8.png)

```
@Entity
@Table(name = "STUDENT")
public class Student {
@ManyToOne(cascade = CascadeType.ALL)
public Address getStudentAddress() {
return this.studentAddress;
}
}
```

```
@Entity
@Table(name = "ADDRESS")
public class Address {

}
```
@ManyToOne annotation is used in the entity that is having foreign key.(In above case in Student entity)


//By using cascade=ALL option the address need not be saved explicitly when the student object is persisted the address will be automatically saved. No need to do this //session.save(address);

## Pesrsist vs Save

### Cockroach DB

Traditional DB - ACID. No Scalability(Only one server possible). No availability. \
Distributed NoSQL - No transactions.

CockroachDB - provides good of both worlds. \
Distributed SQL database. \
Provides ACID Transactions. \
Provides highest Isolation - Serialization. \

Keyspace: Ordered set of key and value. Key part contains where the data exist and the primary key. Rest of columns are put as value part. Cluster divides key space to ranges. When keyspace is greater than 64MB it splits to new range. Multiple replicas of range distributed across cluster. 

RAFT Protocol: Consensus algorithm . Has leaders and followers. If follower is not receiving a heartbeat from leader, it declares itself as a candidate and triggers an election process. Majority vote make it as a leader.\
Lease Holder: One of the replica act as lease holder. Its job is it serve reads on its own, bypassing raft. \
* All reads and writes will be sent to lease node.
* Cockroach DB tried to make lease holder as leader.
* Cockraoch Db use raft for writes. When it get an insert, leader writes it to Raft log. Leader then propose writes to followers. Each follower replica command on its raft log. Once majority of followers have completed write, leader will commit write and notify leaseholder to begin showing the writes to the readers.
* Leaseholders ensure that readers only see commited writes.
* Replicas join together to form a raft group


Availability and Durability in a 3 node cluster. \
Which ever node client connects to is called a gateway. Client can connect to any node. Leaders of a range may not be in same node. From the node client connected, internally requests are routed to leaders of specific range query is for and results are combined at gateway. \
If a node goes down : If a client is connected to that node, it has to find a new gateway. This problem can be solved by a load balancer. A leader election will be held and ranges in down nodes are distributed among live nodes. Cluster will be able to serve reads and writes with few seconds of latency. \

One To Many Relationship: Track vehicle location history. One vehicle can have multiple locations. \
Location_History table will include vehicle_id. While creating location_history table, vehicle_id REFERENCES on vehicles(id) ON DELETE CASCADE. Cockroach DB ensures referntial integrety. It checks that while insert a valid vehicle id exists.

```
class Location_History{

@ManyToOne
@JoinColumn(name="vehicle_id", nullable= false)
private Vehicle vehicle;
}

```

@ManyToOne annotation is used in the entity that is having foreign key.(In above case in Location_History)

If we want to get all locations associated with a vehicle, only above configuration will not help. In that case do the following:

```
class Vehicle{
@OneToMany(fetch = FetchType.LAZY, mappedBy= "vehicle" , cascade = CascadeType.ALL)
private List<LocationHistory> locationHistoryList;
}

```

Asscoiated location history is fetched lazily. If application is not refering locationHistoryList, then data is not fetched. "mappedBy" refers to property in locationHistory entity. CascadeType.ALL ensures if any vehicle is deleted, location histories are also deleted. 

We can use @OrderBy("timestamp DESC)

<img width="925" alt="Screenshot 2022-04-28 at 5 31 55 PM" src="https://user-images.githubusercontent.com/33679023/165748581-43553b83-624e-4c28-9ded-9dd27b5fb0a9.png">

Using Array Data Type:
phone_numbers String [];

Alter table is done as a background job. No impact to reads or writes.

Schema Design:
* Time related: Time: Stores date in UTC. TimeTZ: Not recommended. Timestamp: day in UTC. TimestanpTZ: Timestamp in Clients time zone. Store an offset. Recommended to use.
* Bytes: Binar information such as images.
* String: Varchar(n) = String(n) 
* Decimal:decimal(precision, scale
* Collate: Lanuage specific rules are applied. For example some special characters different in order in different languages. You can specify Collate when u create a column. While inserting you need to specify the language. You can query it back using any collation than what is specified for the column.
* now(): database time.
* Geometry datatype: 2d
* Geography datatype: lattitude and longitude. considering earths curvature.

Column Constraints
* Default
* NOT NULL
* Unique constaint
* Primary Key - Unique + Not null
* Foreign Key: "References". Null values are allowed by default.You can set Not Null
* By default, it will not allow foreign key table updates or deletes. But you can set ON delete Cascade. On delete Set Null.
* Check : limit values allowed for a field. CHECK (0 < chek_qualiy_inHand)
* SHOW constaints
* 

### Spring Boot JPA Data

https://spring.io/projects/spring-boot
https://docs.spring.io/spring-data/jpa/docs/current/reference/html/#reference
https://hibernate.org/orm/documentation/5.4/

### Monorepo vs Multi repo

Mono repo: Keep every code in one repo. U cannot use Git. U need to use VCS.

