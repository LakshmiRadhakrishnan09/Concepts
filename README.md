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
* JSON Datatype: make sure size is less than one mg.
* Array Datatype
* Inverted Indexes: Standard Index cannot be created on Json column or array column. Instead use inverted index. Eg : index/key/valve primary_key. You cannot perform less than greater than functions.
* Computed Column: They expose data generated in other columns by an expression. Efficient way to query array and jsons columns. Extract a value from json column and create secondary indexes.
* Use UUID for primarykey.


Anti-Pattern
* Using auto generated primary key is a anti-pattern.
* Auto incremented keys will result in hot-spots. All new inserts will be for a range and single node need to handle all inserts.
* Generating incremnts can cause contention in servers.
* Primary Key - Unuque and non sequential. Example username+ timestamp
* Or use server side UUID. CockroachDB generates them efficiently.

Hash-Sharded Table
* To eliminate hot spots
* Timestamps as primark keys can result in hot spots.
* Creates a comuputed column that hold the hash value. Use a hash value before primary key. Bucket is a random hash value.Make sure inserts are spread across nodes.
* USING HASHWITH BUCKET_COUNT = 5
* Can be created for secondary indexes

Main Points
* Do not use auto increment ids.
* Do not use timestamp as primary key
* Use UUID. @Id @GeneratedValue private UUID id;
* Use TimeStampTZ for storing time
* use now() at database at database.
* Use JSON DataTypes for unstratured data
* Use Array data types
* Use computed columns
* U can create secondary index on data that is queried frequently to improve performance.
* Use composite indexes 
* Use stored column on indexes 

Serializable Transaction: A database behaves like it has entire database to itself while its execution. This means other writes cannot affect the transaction unless other transactions commit before the start of transaction. And other reads cannot see the transaction until it commits. Wherever possible cockroachDB will retry a transaction.

Tables in a database are sorted by primary keys. So looking up a record by their primary key value is relatively quick.But when filtering by a column that is not part of index, database has to scan one by one. Full table scan is the most common cause of performance issues. 

EXPLAIN <Query> : plan.  EXPLAIN ANALYSE <Query> : Execution statistics."
     
distribution-> full: Query is executed by all nodes in parallel. Final results will be returned by gateway node. distribution -> local: Query is executed by only gateway node. /
vectorized : true or false. Read more /
FULL SCAN - Full table
 
Composite Index: Indexes built from multiple columns. CREATE INDEX on user(lastname, firstname). This composite index will benefit if we want to query by last name or by both first name and last name. If we have to filter by only first name, it will result in a full table scan.  Index prefix is the set of columns of an index. Suppose u are creating a composite index on A,B, C, D, E. You can use it to filter by A, A and B, A and B and C. But you cannot use it for filtering by C or by for filtering by A and C. In that case u need to create a seperate index. 
     
ORDER BY: Order by on an indexed column make use of inherent order of index. If u use order by on a non-indexed column, then a full table scan is performed.
     
Covered Query: A query that can be answered by an index, without looking into underlying table. Sometimes u want to retrieve a column, but do not want to filter by it. For example u want to get all vehicles with battery > 10%. In this case of we have an index on battery, then it is a covered query. But what if u want to retrieve sampling time also. In this case, CREATE INDEX on vehicle(battery) STORING (sampling_time).
     
Index addes write time to db. It makes reads efficient. Sometimes u are creating unwanted indexes. Use internal cockroachdb to check if indexes are used or not. crdb_internal.table_indexes. 
     
Using JSON columns: use jsonb_pretty(vehicle_info) to get full json as part of select. To get a specific key, use arrow key. vehicle_info -> color. To filter SELECT id, vehicle_info -> 'wear' as wear FROM vehicles where vehicle_info > '{"wear":"damaged"}'.
It is possible to move data from existing columns to json columns as an UPDATE statement.
     
Inverted Index: CREATE INVERTED INDEX on vehicles(vehicles_info).
Vehicles table ; vehicle_info column: data { "color": "green", "purchase_info" : {"seral number": 123}, "type":"scooter"}
This will create invereted indexes:
     * vehicles/vehicle_info_idx/type/scooter/Vehicle 1
     * vehicles/vehicle_info_idx/purchase_info/serail number/123/Vehicle 1
Inverted indexes cannot use less than or greater than operatons. They support only contains  or contained by or equals.
     
Computed columns:Allows to run comparison queries. For better performance, u should index computed columns.  

Serverless Database: No operations. Responds automatically to changing loads. Pay for what u use. Is always ON. For unpredictable loads. 
     
RUs: Resource utilization is measured in RUs.Compute resources and I/O resources. 
     
Use multi row inserts for bulk imports. 
     
How cockroachDb serverless works: Use multi tenant architecture. Single server shared between multiple customers. To distribute compute and storage power across multiple customers. All built on top of k8s. When u get a spike, a "pool" is allocated(not from other customers). 
     
## CocroachDb and event driven microservice     

Dual write problem: Need to update two different systems with same data.
  
Consider 4 microservices. User Service, Vehicle service , rides service and UI gateway service. We create 3 databases( not 3 tables) - vehicles db, rides db and user db. Vehicles db has vehicles table and location_history table. When we start a ride, we need to inform vehicles service that the vehicle is no more available for rise(communication between services).
  
Transactional Outbox pattern: 
  Each microservice should have exclusive access to its database. If another servive need to use the data, it cannot query the database, but use an API or a message queue(Sync or Asyn communication). Synchronous communication is brittle because it needs all services to be alive. In an asynchronous communication, one of the system can be down other services can still continue. But pushing messages to an extrnal system can cause problems. We may need to update the table and publish the event. If one of this operation fails, then two systems will be out of sync -> Dual write problem. Transactional Outbox pattern helps to eliminate dual write problem. We persist both the state of entity and domain transaction in the same transaction. We refer to log of domain events as our outbox. A service or job consume the message from the outbox table and publish them to message platform. We can write outbox consumer ourself or use cockroachDB CDC(Change Data Capture). CDC can read messages from outbox table and publish to kafka.
  
  
 Messages in a system can be : Commands, Queries and Events. Commands are request to change the state of a system. They can be accepted or rejected. Eg: adding a user or creating a vehicle. It may be important to know if command is failed or success. So mostly this is handled synchrnously. Queries are request for information about the state of a system. U send query and wait for response. They are often handled synchrously. Events record changes to the system. They represent something that occured in past. Eg user added, vehicle created. Since events occured in past, there is no need to handle then synchrously. They are usually broadcast to the system in a fire and forget way.This will be handled by downsteam when it is convinient.Events represent history of system. They should be immutable.
  
Outbox Table: Name it as event table. Will have event_id(UUID), timestamp(UTC time),  eventType, eventData(JSON) , publisher, correlation_id, offset(anti-pattern).
     
@Type(type="jsonb")     
private Map<String, Object> eventData;
     
EventLog:
     * As an audit log
     * Able to look back what happened while debugging
     * Will help to recover
Write them once. Never update them.\
Event should reveal intent. Instaed of VehicleUpdated, use VehicleLocationChanged or VehicleBatteryLevelChanged. Reduce coupling.
     
RideService: @Transactional public startRide() { save to repo and publish event }
     
CDC: CDC monitors a specific set of tables. If changes happened in monitored table, changes are broadcasted. Core change feeds: Streams changes to a client until the underlying connection is closed. Available for all. Enterprise Change Feed: Stream changes to a sink like kafka. Available for only licensed version.
     
Enterprise Change Feed: Step 1. Enable it SET kv.rangefeed.enabled cluster setting to true in database(require admin priviledge). Step 2. Create feed. CREATE CHANGEFEED For table <table_name> INTO kafka_url. No other changes or code required.
     
CDC guarantess 1. "atleast-once". There can be potential duplicates. Design ur ysystem to handle duplicates. 2. "ordering" with a row. Duplicates may appear out of order. So check if greater timestamp is processed.If yes ignore the message. No gurantee across row. Think about event ordering and duplication impact on system when u use cockroachDB ctc.
     
RESOLVED timestamp: Indicates we no longer see messages onlder than this timestamp. Need to be configured when we create a feed. Read more. 
	
SHOW JOBS;PAUSE JOB <job_id>;RESUME JOB <job_id>; CANCEL JOB\
protect_data_from_gc_on_pause, on_error flags \
	
Consuming Events: Duplicate events are handled by ensuring consuming application is idempotent. Eg: adding to list vs adding to set. Use timestamp for idempotent. If u find a repeated timestamp, ignore the new one. But sometimes two different events can have same timestamp. So use a combination of timestamp and entity id to ensure duplicates. Another technique is using version number or using eventIds. If u are using kafka, ordering is guarenteed for a partitin. Wherever possible allow concurrency over ordering. 	
	
Deleting event log: Avoid deleting data. If you cant keep, consider archiving it.

Read More: https://glennfawcett.wpcomstaging.com

### Spring Boot JPA Data

https://spring.io/projects/spring-boot
https://docs.spring.io/spring-data/jpa/docs/current/reference/html/#reference
https://hibernate.org/orm/documentation/5.4/

### Monorepo vs Multi repo

Mono repo: Keep every code in one repo. U cannot use Git. U need to use VCS.
