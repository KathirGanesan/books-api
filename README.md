# 📚 Books API

A RESTful API built with **Spring Boot 3**, designed for managing book data with basic CRUD (Create, Read, Update, Delete) operations. This project uses in-memory storage for demonstration and learning purposes.

## 🚀 Features

* **CRUD Operations**: Easily manage books (Create, Read, Update, Delete).
* **Validation**: Ensures required fields (title, author) are provided.
* **Structured Error Handling**: Provides clear JSON responses on validation errors or exceptions.
* **Logging**: Structured and leveled logging for easy debugging.
* **Swagger Documentation**: API documented with OpenAPI (Swagger UI).
* **Health Check**: Endpoint to verify API health.

## 🛠️ Tech Stack

* Java 17
* Spring Boot 3.2.5
* Lombok
* SpringDoc OpenAPI (Swagger)
* JUnit 5 & Mockito for Testing
* Maven
* AWS EC2 (Infrastructure as Code using Terraform)
* AWS CloudWatch for monitoring and logging

## 📦 Project Structure

```
books-api
├── src
│   ├── main
│   │   ├── java
│   │   │   └── com.booksapi.books_api
│   │   │       ├── controller
│   │   │       │   └── BookController.java
│   │   │       ├── exception
│   │   │       │   ├── BookNotFoundException.java
│   │   │       │   └── GlobalExceptionHandler.java
│   │   │       ├── model
│   │   │       │   └── Book.java
│   │   │       ├── service
│   │   │       │   └── BookService.java
│   │   │       └── BooksApiApplication.java
│   │   └── resources
│   │       └── application.properties
│   └── test
│       └── java
│           └── com.booksapi.books_api
│               └── controller
│                   └── BookControllerMvcTest.java
├── terraform
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── terraform.tfvars.example
├── pom.xml
├── deploy.sh
└── README.md
```

## 🔧 Setup Instructions

### 1. Clone the repository

```bash
git clone https://github.com/yourusername/books-api.git
cd books-api
```

### 2. Build and Run

```bash
mvn clean install
mvn spring-boot:run
```

Your API will run on `http://localhost:8080`.

## 🚀 Deployment on AWS with Terraform

### Prerequisites

* Terraform installed
* AWS CLI configured with credentials

### Deploying with Terraform

```bash
cd terraform
terraform init
terraform apply -var-file="terraform.tfvars"
```

Your API will be deployed to an AWS EC2 instance.

## ☁️ AWS CloudWatch Monitoring

AWS CloudWatch is configured for monitoring and logging the API's health and performance metrics. Logs and metrics can be accessed directly through the AWS CloudWatch console.

## 📖 API Endpoints

| Method | URL                 | Description              |
| ------ | ------------------- | ------------------------ |
| GET    | `/api/books`        | Retrieve all books       |
| GET    | `/api/books/{id}`   | Retrieve a specific book |
| POST   | `/api/books`        | Create a new book        |
| PATCH  | `/api/books/{id}`   | Update an existing book  |
| DELETE | `/api/books/{id}`   | Delete a book            |
| GET    | `/api/books/health` | Health check             |

## 🎯 Example Requests

**Create a Book:**

```bash
POST /api/books
```

Request Body:

```json
{
  "title": "Clean Code",
  "author": "Robert C. Martin",
  "isbn": "978-0132350884",
  "publishedYear": 2008
}
```

**Validation Error Response:**

```json
{
  "timestamp": "2025-05-24T13:45:00.123Z",
  "status": 400,
  "errors": [
    "Title is required",
    "Author is required"
  ]
}
```

## 📝 Swagger UI

API documentation via Swagger UI is available here:

```
https://books.zenflixapp.online/swagger-ui/index.html
```

## ✅ Unit Testing

Tests are written using JUnit 5 and Mockito. To run tests:

```bash
mvn test
```

## 🛡️ Logging

Structured logging with levels (`DEBUG`, `INFO`, `WARN`, `ERROR`) provided by SLF4J and Lombok's `@Slf4j`.

Configure log level in `application.properties`:

```properties
logging.level.com.booksapi=DEBUG
```

## 📬 Feedback & Contributions

Contributions are welcome! Please open an issue or submit a pull request.

---

⭐ If you found this helpful, consider starring the repository!
