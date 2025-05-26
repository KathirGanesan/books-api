package com.booksapi.books_api.exception;
import java.time.Instant;
import java.util.List;
import java.util.Map;

import org.springframework.context.support.DefaultMessageSourceResolvable;
import org.springframework.http.ResponseEntity;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@ControllerAdvice
public class GlobalExceptionHandler {
    @ExceptionHandler(BookNotFoundException.class)
    public ResponseEntity<Map<String,Object>> handleNotFound(BookNotFoundException ex) {
        log.warn("Handling BookNotFoundException: {}", ex.getMessage());
        Map<String,Object> body = Map.of(
            "timestamp", Instant.now().toString(),
            "status", 404,
            "errors", List.of(ex.getMessage())
        );
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(body);
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<Map<String,Object>> handleValidation(MethodArgumentNotValidException ex) {
        List<String> errors = ex.getBindingResult()
                                .getFieldErrors()
                                .stream()
                                .map(DefaultMessageSourceResolvable::getDefaultMessage)
                                .toList();
        log.info("Validation failed: {}", errors);
        Map<String,Object> body = Map.of(
            "timestamp", Instant.now().toString(),
            "status", 400,
            "errors", errors
        );
        return ResponseEntity.badRequest().body(body);
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<Map<String,Object>> handleGeneric(Exception ex) {
        log.error("Unhandled exception", ex);
        Map<String,Object> body = Map.of(
            "timestamp", Instant.now().toString(),
            "status", 500,
            "errors", List.of("An unexpected error occurred: " + ex.getMessage())
        );
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(body);
    }
}
