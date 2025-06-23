# Web Infrastructure Design

## Simple Web Stack

### 1. User Access

The user opens a browser and types `www.foobar.com` to visit the website.


### 2. Domain Name Resolution

* The browser sends a DNS query to resolve `www.foobar.com`.
* A DNS **A Record** maps the domain to an IP address.
* In this setup:

  ```
  www.foobar.com ➝ A record ➝ 0.0.0.0
  ```

Key concepts:

* **Domain Name**: A human-readable address (e.g., `foobar.com`) that maps to a server’s IP address.
* **A Record**: A DNS record that maps a domain or subdomain (like `www`) to an IPv4 address.
* `www.foobar.com`: The `www` is a subdomain defined with an A record.

---

### 3. Server

A single server located at IP `0.0.0.0` hosts all components of the website, including:

* Web server (Nginx)
* Application server (e.g., Gunicorn)
* Application files (codebase)
* Database (MySQL)

---

### 4. Web Server (Nginx)

Role:

* Receives and handles all incoming HTTP requests.
* Serves static content such as HTML, CSS, JavaScript, and images.
* Forwards dynamic requests to the application server.
* Can handle other features like SSL termination, compression, and caching.


### 5. Application Server

Role:

* Executes backend application logic.
* Handles dynamic routes and generates appropriate responses.
* Processes requests forwarded by the web server.
* Examples: Gunicorn (for Python), uWSGI, PHP-FPM, etc.


### 6. Application Files

Role:

* Contain the source code of the web application.
* Includes route handlers, templates, services, and business logic.
* Could be built using frameworks such as Django, Flask, Laravel, etc.


### 7. Database (MySQL)

Role:

* Stores persistent application data such as user profiles, sessions, and records.
* Receives SQL queries from the application server and returns results.
* Runs as a service on the same machine as the rest of the stack.


### 8. Communication Path

* **User to Server**: Communicates over HTTP or HTTPS using TCP/IP.
* **Nginx to Application Server**: Communicates over a local HTTP connection or Unix socket.
* **Application Server to MySQL**: Connects using MySQL TCP protocol (default port 3306).


## Limitations of This Infrastructure

### 1. Single Point of Failure (SPOF)

* One server hosts everything.
* If the server crashes or is unreachable, the entire website becomes unavailable.

### 2. No Redundancy

* If any single component (web server, app server, database) fails, the whole stack fails.
* There are no backups or failover components.

### 3. Downtime During Maintenance

* When deploying new code or restarting the server, the website experiences downtime.
* Even minor updates require stopping services, making the site temporarily unavailable.

### 4. Not Scalable

* All traffic is served by one server.
* Cannot handle high volumes of concurrent users.
* No load balancing or distribution of workload is possible in this setup.


## Distributed Web Infrastructure

### Infrastructure Overview

This setup expands on the simple one-server stack by distributing responsibilities across **three servers** to improve availability, performance, and maintainability.

* **Server A**: Nginx (web server), Gunicorn (application server), application codebase
* **Server B**: Nginx (web server), Gunicorn (application server), application codebase
* **Server C**: HAProxy (load balancer) and MySQL (database server)


### Component Roles and Justifications

#### Load Balancer (HAProxy)

* **Why Added**: Balances incoming traffic across multiple backend servers to avoid overload and improve reliability.
* **Algorithm**: Configured with **Round Robin**, which distributes requests sequentially to each server in turn.
* **Setup Type**: This is an **Active-Active** configuration — both Server A and Server B handle traffic simultaneously.

#### Web + Application Servers (Server A and B)

* **Why Added**:

  * Share the application load between multiple servers.
  * Increase fault tolerance — if one server fails, the other continues serving users.
* **Nginx**: Handles HTTP requests, serves static files, and forwards dynamic requests to the application.
* **Gunicorn**: Executes the backend logic written in the application codebase.
* **Application Codebase**: Deployed identically on both servers to maintain consistent behavior.

---

#### Database (MySQL on Server C)

* **Why Added**: Centralized storage for all application data such as users, content, and sessions.
* All backend servers connect to this single database to perform data operations (reads and writes).

---

### Infrastructure Limitations

#### Single Points of Failure (SPOF)

* **Load Balancer**: If HAProxy becomes unavailable, the entire system is inaccessible even if backend servers are running.
* **Database**: Without replication or failover, a database crash results in total data inaccessibility.

#### Security Issues

* No **firewall** in place means all ports and services may be exposed to the public internet.
* Lack of **HTTPS** leaves all user-server communications unencrypted and vulnerable to interception.

#### No Monitoring

* No infrastructure-level monitoring to track service health, performance, or downtime.
* No automated alerting system to notify administrators of issues.
