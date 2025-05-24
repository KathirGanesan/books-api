# Books API

This is a Spring Boot REST API application that manages a collection of books. It provides endpoints for creating, retrieving, updating, and deleting books, along with basic input validation and error handling.

## Features

- In-memory storage for books
- Basic input validation
- Error handling with custom exceptions
- Health check endpoint

## Project Structure

```
books-api
├── src
│   ├── main
│   │   ├── java
│   │   │   └── com
│   │   │       └── booksapi
│   │   │           └── books_api
│   │   │               ├── BooksApiApplication.java
│   │   │               ├── controller
│   │   │               │   └── BookController.java
│   │   │               ├── model
│   │   │               │   └── Book.java
│   │   │               ├── service
│   │   │               │   └── BookService.java
│   │   │               └── exception
│   │   │                   ├── BookNotFoundException.java
│   │   │                   └── GlobalExceptionHandler.java
│   │   └── resources
│   │       └── application.properties
├── pom.xml
└── README.md
```

## API Endpoints

### Health Check

- **GET** `/actuator/health` - Check the health status of the application.

### Books

- **GET** `/api/books` - Retrieve all books.
- **GET** `/api/books/{id}` - Retrieve a specific book by ID.
- **POST** `/api/books` - Create a new book.
- **PATCH** `/api/books/{id}` - Update an existing book by ID.
- **DELETE** `/api/books/{id}` - Delete a book by ID.

## Setup Instructions

1. Clone the repository:
   ```
   git clone <repository-url>
   ```

2. Navigate to the project directory:
   ```
   cd books-api
   ```

3. Build the project using Maven:
   ```
   mvn clean install
   ```

4. Run the application:
   ```
   mvn spring-boot:run
   ```

5. Access the API at `http://localhost:8080/api/books`.

## Dependencies

This project uses the following dependencies:

- Spring Boot Starter Web
- Spring Boot Starter Actuator
- Spring Boot Starter Test (for testing)

## License

This project is licensed under the MIT License.